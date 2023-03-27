// Search TODO for filers.

# Project setup 
```bash
├── credentials ======================== All Credential files in JSON
├── exam-extras ======================== Files added to the Exam repo
│   ├── docker-compose-build.yml
│   ├── docker-compose-deploy.yml
│   └── Jenkinsfile
│
├── gitea
│   ├── docker-compose.yml ============= UP Gitea + DB
│   ├── setup_repo.sh ================== Setup Exam repo, Webhook
│   └── setup.sh  ====================== Setup Gitea, Users
│
├── jenkins
│   ├── exam.xml ======================= Already prepared job
│   ├── install.sh ===================== Install bare-metal Jenkins
│   ├── jenkins.yaml =================== Config as Code Plugin
│   ├── plugins.txt ==================== List of plugins to install
│   └── setup.sh ======================= Init, Config, Import
│
├── monitoring
│   ├── docker-compose-exporters.yml === Node Exporter 
│   ├── docker-compose-metrics.yml ===== Prometheus, Grafana
│   ├── grafana
│   │   ├── dashboards
│   │   │   ├── dashboard.yml ========== Dashboards config
│   │   │   └── exam_dash.json ========= Exam Dashboard Config
│   │   └── datasources
│   │       └── datasource.yml ========= Datasources config
│   └── prometheus
│       └── prometheus.yml ============= Prometheus config
│
├── common_steps.sh
├── install_docker.sh
└── Vagrantfile
```

# Infrastructure setup

* Machines follow the proper naming convention:
  - `vm101.do1.exam`
  - `vm102.do1.exam`
  - `vm103.do1.exam`
* They are part of the same network:
  - `monitoring.vm.network "private_network", ip: "192.168.99.103"`
  - `containers.vm.network "private_network", ip: "192.168.99.102"`
  - `pipelines.vm.network "private_network", ip: "192.168.99.101"`
* Relevant ports are port-forwarded:
  - `monitoring.vm.network "forwarded_port", guest: 3000, host: 8082`
  - `containers.vm.network "forwarded_port", guest: 8080, host: 8081`
  - `pipelines.vm.network "forwarded_port", guest: 8080, host: 8080`
* Provisioning is done both with `path` and `inline`.
* All machines have their hosts file edited and Docker installed.

# Gitea Setup

Gitea is a added through a pre-written `docker-compose.yml` file. Provisioning is split into 2 scripts - `/vagrant/gitea/setup.sh` and `/vagrant/gitea/setup_repo.sh`

## Setting up Gitea Server

### 1. Importing Gitea Credentails.
For ease of use all credentails are storead as separate JSON files. They are imported and parsed by `jq` in the script:
```bash
g_user="$(jq -r '.username' /vagrant/credentials/gitea_user.json)"
g_pass="$(jq -r '.password' /vagrant/credentials/gitea_user.json)"
```

### 2. Starting the docker-compose.yml
```bash
echo "* Deploying Gitea Stack"
docker compose -f /vagrant/gitea/docker-compose.yml up -d --force-recreate
```
Notable parts of the file are the environmental variables. 
```yaml
...
services:
  server:
    image: gitea/gitea:1.18.4
    environment:
      ...
      - GITEA__security__INSTALL_LOCK=true # Skips the setup wizard
      - GITEA__repository__ENABLE_PUSH_CREATE_USER=true # Allow local Push
      - GITEA__repository__ENABLE_PUSH_CREATE_ORG=true
      - GITEA__webhook__ALLOWED_HOST_LIST=192.168.99.0/24 # Allowed Webhooks from here
```

### 3. Waiting for the Gitea Server and DB containers to start
```bash
echo "Waiting for Gitea:"
while true; do
  url=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)
  if [ $url == "200" ]; then
    echo 'Connected!';
    break;
  else
    echo 'Waiting...';
    sleep 5;
  fi
done
```

### 4. Adding a Gitea user
This requires executing commands inside the Gitea container. variables supplied in Step 1.
```bash
echo "Adding a Gitea User"
docker container exec -u 1000 gitea gitea admin user create --username "$g_user" --password "$g_pass" --email "$g_user@testmail.com"
```

## Setting up Gitea exam repo

### 1. Declaring variables and Importing credentials.
For ease of use, repetitive values are stored as variables.
```bash
github_repo="https://github.com/shekeriev/dob-2021-04-exam-re.git"

jenkins_host="192.168.99.101"

g_project_name="exam"
g_user="$(jq -r '.username' /vagrant/credentials/gitea_user.json)"
g_pass="$(jq -r '.password' /vagrant/credentials/gitea_user.json)"
```

### 2. Downloading Github Exam Repo
To ensure a fresh start, any previous repos are deleted beforehand. I prefer to pull the repo in my working directory - `/vagrant` for easier testing.
```bash
echo "* 📦 Downlading repo"
rm -rf "/vagrant/$g_project_name"
git clone "$github_repo" "/vagrant/$g_project_name" && cd "/vagrant/$g_project_name"
```

### 3. Adding extra files
The Exam Repo lacks several files that are used in the automated building process. Like `Jenkinsfile`, `docker-compose-build.yml` and `docker-compose-deploy.yml`. I'm adding them here:
```bash
echo "*  ➕ Add Extra files"
cp -rv /vagrant/exam-extras/* "/vagrant/$g_project_name"
```

### 4. Add, Commit, Push
A combo command to do everything and create the Gitea repo. With default values, the Gitea repo should be http://192.168.0.102:3000/gitea_user/exam.
```bash
echo "* ⬆️   Initializing Git"
git add . && git commit -m "Initial commit to Gitea" && git push -o repo.private=false "http://$g_user:$g_pass@localhost:3000/$g_user/$g_project_name"
```

### 5. Adding a Webhook
I played a little bit with a script that adds a webhook only if there are none present in the repo:
```bash
echo "* 🪝   Checking for Webhooks"
webhooks=$(curl -s -X 'GET' "http://localhost:3000/api/v1/repos/$g_user/$g_project_name/hooks" \
  -H 'accept: application/json' \
  -H 'authorization: Basic '$(echo -n "$g_user:$g_pass" | base64) \
  -H 'Content-Type: application/json' )
webhooks_lenght=${#webhooks}

if [ $webhooks_lenght -le 5 ]; then
  echo '* 🪝❌ No webhooks! Creating Webhook!';
  curl -S -s -o /dev/null -X 'POST' "http://localhost:3000/api/v1/repos/$g_user/$g_project_name/hooks" \
    -H 'accept: application/json' \
    -H 'authorization: Basic '$(echo -n "$g_user:$g_pass" | base64) \
    -H 'Content-Type: application/json' \
    -d '{
            "active": true,
            "type": "gitea",
            "branch_filter": "*",
            "config": {
                "content_type": "json",
                "url": "http://'"$jenkins_host"':8080/gitea-webhook/post",
                "http_method": "post"
            },
            "events": [
                "push"
            ]
        }'
  echo '* 🪝✔️ Created Webhook!';
else
  echo '* 🪝✔️ Webhooks Present! Skipping!';
fi
```

## TODO WORKING REPO PICTURE!!!!

# Jenkins setup

I wanted to avoid setting up Jenkins via Groovy init scripts. Here Jenkins is primarily setup via a plugin called [Jenkins Configuration as Code](https://github.com/jenkinsci/configuration-as-code-plugin). The plugin is a wrapper for the Jenkins API and offer configuration via a YAML file. I use it to import Users, Nodes, Credentials and various other configs.

The setup should be completely automated. During initial project setup I exported the job as `exam.xml`. Job importing/exporting is done via SSH. The `jenkins-cli` method is also present but __commented out__. 

Full provision file at `/vagrant/jenkins/setup.sh`

## 1. Generating keys

I generate a key pair for my `vagrant` user. It's saved in the credentials directory. It will be added to Jenkin's `admin` user once I create it. It is used to connect to Jenkins Server via SSH and import/export `exam.xml` job file.

```bash
echo "* 🗝️   Exporting vagrant SSH pub.key"
su -l vagrant -c 'rm -f ~/.ssh/id_rsa* && ssh-keygen -t rsa -f "$HOME/.ssh/id_rsa" -P "" && cat ~/.ssh/id_rsa.pub > /vagrant/credentials/vagrant_at_vm101.pub'
```

## 2. Stop Jenkins
```bash
echo "* ⬇️   Stopping Jenkins"
systemctl stop jenkins
```

## 3. Copying Jenkins Configuration as Code file
`jenkins.yml` file is copied over to Jenkins's home directory, fixed permissions.
```bash
echo "* ↪️   Moving JCasC jenkins.yaml"
cp /vagrant/jenkins/jenkins.yaml /var/lib/jenkins/jenkins.yaml
chown -R jenkins:jenkins /var/lib/jenkins/jenkins.yaml
```
Here are the significant snippets:

### ⚡Admin User
The `${json:}` and `${readFile:}` are specific to JCasC Plugin and allow me to import credentails from other files.
```yaml
jenkins:
  ...
  securityRealm:
    local:
      users:
      - id: "admin"
        name: ${json:username:${readFile:/vagrant/credentials/jenkins_admin.json}}
        password: ${json:password:${readFile:/vagrant/credentials/jenkins_admin.json}}
        ...
        - sshPublicKey:
            authorizedKeys: ${readFile:/vagrant/credentials/vagrant_at_vm101.pub}
            # vagrant's pub key is being added here
```

### 🖥️ Nodes
```yaml
jenkins:
  ...
  nodes:
    - permanent:
        labelString: "docker"
        mode: NORMAL
        name: "vm102.do1.exam"
        numExecutors: 3
        remoteFS: "/home/vagrant"
        launcher:
          ssh:
            host: "192.168.99.102"
            port: 22
            credentialsId: "vagrant_at_vm102"
```

### 🔐 Credentials
```yaml
credentials:
  system:
    domainCredentials:
    - credentials:
        - usernamePassword:
            scope: GLOBAL
            id: "vagrant_at_vm102"
            username: ${json:username:${readFile:/vagrant/credentials/vagrant_at_vm102.json}}
            password: ${json:password:${readFile:/vagrant/credentials/vagrant_at_vm102.json}}
            description: "Credentials for Docker Slave Node user"
        - usernamePassword:
            scope: GLOBAL
            id: "gitea"
            username: ...
            password: ...
            description: "Credentials for a Gitea user"
        - usernamePassword:
            scope: GLOBAL
            id: "docker_hub"
            username: ...
            password: ...
            description: "Credentials for Docker Hub user"
```

### 🔗 Activating Jenkins Server's SSH
Port set to `6666` to not interfere with the machine's SSH server on port `22`
```yaml
security:
  ...
  sSHD:
    port: 6666
```

## 4. Editing JAVA_OPTS to disable Wizard
```bash
echo "* 😵   Kill the Wizard!"
sed -i 's/# arguments to pass to java/JAVA_OPTS="-Djenkins.install.runSetupWizard=false"/' /etc/default/jenkins
```

## 5. Installing Plugin Manager
```bash
echo "* 📦   Downloading Jenkins Plugin Manager" 
wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.11/jenkins-plugin-manager-2.12.11.jar
```

## 6. Installing Plugins
There are __9__ plugins being installed. Full list in /vagrant/jenkins/plugins.txt
```bash
echo "* 📦 Installing plugins" 
java -jar jenkins-plugin-manager-*.jar --war /usr/share/java/jenkins.war --plugin-file /vagrant/jenkins/plugins.txt -d /var/lib/jenkins/plugins --verbose
```

## 7. Start Jenkins
```bash
echo "* ⬆️   Starting Jenkins" 
systemctl start jenkins
```

## 8. Manually creating Jobs
On my first run, I manually log into Jenkins WebUI and create a new Job named "exam". 

`Dashboard` > `New Item` > `Pipeline` > Name "exam" > [OK]

Github Webhooks must be enabled. Polling SCM is set to every `5min` to ensure triggering.

![Build Triggers](doc_img_build_triggers.png)

Pipeline is set to `Pipeline script from SCM`. This allows for easier tweaking of the pipeline as code. The pipeline is stored in a `Jenkinsfile`, in the Gitea repo. It's not part of the initial Github repo but I'm adding it before pusing it to Gitea. Jenkins expects a `Jenkinsfile` to be present in the repo.

![Pipeline script from SCM](doc_img_pipeline.png)

Once the job is setup, I can export it with the command below and subsequent runs *should* be completely automated with `create-job` from Step 9. This command is ran as the `vagrant` user of the Jenkins machine. 
```bash
ssh -o StrictHostKeyChecking=no -p 6666 admin@localhost get-job exam >> /vagrant/jenkins/exam.xml
```

## 9. Automatically importing Jobs 
The job should trigger immediately after creation because all users, nodes and credentials, as well as Gitea are set up and available.

### With SSH
The newly created Jenkin's `admin` user has `vagrant`'s public key. This snippet makes sure the job is imported or re-imported successfully every time. 
```bash
echo "* ➕   Importing job"
su -l vagrant -c 'ssh -o StrictHostKeyChecking=no -p 6666 admin@localhost delete-job exam'
su -l vagrant -c 'ssh -o StrictHostKeyChecking=no -p 6666 admin@localhost create-job exam < /vagrant/jenkins/exam.xml'
echo "* ✔️   Importing complete"
```

### With HTTP
Alternatively, `jenkins-cli` can be used to import/re-create  the job.
```bash
echo "* ➕   Importing job"
j_user="$(jq -r '.username' /vagrant/credentials/jenkins_admin.json)"
j_pass="$(jq -r '.password' /vagrant/credentials/jenkins_admin.json)"
java -jar /home/vagrant/jenkins-cli.jar -s http://localhost:8080/ -http -auth "$j_user:$j_pass" delete-job exam
java -jar /home/vagrant/jenkins-cli.jar -s http://localhost:8080/ -http -auth "$j_user:$j_pass" create-job exam < /vagrant/jenkins/exam.xml
echo "* ✔️   Importing complete"
```

## TODO SCREENSHOTS FROM LOGS OF RUNNING JOBS!!
## TODO SCREENSHOTS FROM RUNNING SERVICES!!
#!/bin/bash

user=xxxxxx
pass=xxxxx

# Generating SSH Key for the Vagrant user and adding it to the Jenkins init
echo "* Setting up SSH access"
su -l vagrant -c 'ssh-keygen -t rsa -f "$HOME/.ssh/id_rsa" -P "" && cat ~/.ssh/id_rsa.pub'
sed -i "s%+++replaceme+++%$(cat ~/.ssh/id_rsa.pub)%g" /vagrant/jenkins/setup.groovy

echo "* Stop Jenkins"
systemctl stop jenkins

# Commands used from: https://riptutorial.com/jenkins/example/24925/disable-setup-wizard
echo "* Kill the Wizard! 😵 Setup JCasC! 📖"
java_args='-Djenkins.install.runSetupWizard=false'
sed -i "s/# arguments to pass to java/JAVA_OPTS=$java_args/" /etc/default/jenkins

# Commands used from: https://riptutorial.com/jenkins/example/24924/create-default-user
echo "* Moving setup.groovy"
mkdir /var/lib/jenkins/init.groovy.d
cp /vagrant/jenkins/setup.groovy /var/lib/jenkins/init.groovy.d/
chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d/

echo "* Downloading Jenkins Plugin Manager" 
wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.11/jenkins-plugin-manager-2.12.11.jar

echo "* Installing plugins" 
java -jar jenkins-plugin-manager-*.jar --war /usr/share/java/jenkins.war --plugin-file /vagrant/jenkins/plugins.txt -d /var/lib/jenkins/plugins --verbose

echo "* Restart Jenkins" 
systemctl start jenkins


echo "* ⬆️ Starting Jenkins" 
systemctl start jenkins

# echo "* ⌛ Waiting for Jenkins:"
# i=0
# while [ $i -le 2 ]; do

#   url=$(curl -s -o /dev/null -w "%{http_code}" http://192.168.99.101:8080)

#   if [ $url == "200" ]; then
#     echo 'Connected!';
#     break;
#   else
#     echo 'Waiting ...';
#     sleep 5;
#   fi

# let i=i+1
# done

# Importing Job
echo "* Importing job"
ssh -p 6666 admin@192.168.99.101 create-job DiabetesDemo < /vagrant/jenkins/DiabetesDemo.xml

# Adding credentials. A separate script is used to reduce repetition.
echo "* Creating vagrant credentials"
/vagrant/jenkins/create-credentials.sh vagrant vagrant vagrant

echo "* Creating Docker Hub credentials"
/vagrant/jenkins/create-credentials.sh docker-hub $user $pass

# Adding a slave node - the Docker Host.
echo "* Add slave node"
/vagrant/jenkins/create-slave.sh docker.do1.lab vagrant

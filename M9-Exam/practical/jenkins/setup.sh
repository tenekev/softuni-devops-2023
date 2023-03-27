#!/bin/bash

echo "* 🗝️   Exporting vagrant SSH pub.key"
su -l vagrant -c 'rm -f ~/.ssh/id_rsa* && ssh-keygen -t rsa -f "$HOME/.ssh/id_rsa" -P "" && cat ~/.ssh/id_rsa.pub > /vagrant/credentials/vagrant_at_pipelines.pub'


echo "* ⬇️   Stopping Jenkins"
systemctl stop jenkins


# Using Jenkins Configuration as Code Plugin: https://github.com/jenkinsci/configuration-as-code-plugin
echo "* ↪️   Moving JCasC jenkins.yaml"
cp /vagrant/jenkins/jenkins.yaml /var/lib/jenkins/jenkins.yaml
chown -R jenkins:jenkins /var/lib/jenkins/jenkins.yaml


# Commands used from: https://riptutorial.com/jenkins/example/24925/disable-setup-wizard
echo "* 😵   Kill the Wizard!"
sed -i 's/# arguments to pass to java/JAVA_OPTS="-Djenkins.install.runSetupWizard=false"/' /etc/default/jenkins


echo "* 📦   Downloading Jenkins Plugin Manager" 
wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.11/jenkins-plugin-manager-2.12.11.jar


echo "* 📦 Installing plugins" 
java -jar jenkins-plugin-manager-*.jar --war /usr/share/java/jenkins.war --plugin-file /vagrant/jenkins/plugins.txt -d /var/lib/jenkins/plugins --verbose


echo "* ⬆️   Starting Jenkins" 
systemctl start jenkins


echo "* ➕   Importing job"
su -l vagrant -c 'ssh -o StrictHostKeyChecking=no -p 6666 admin@localhost delete-job exam_26_03_2023'
su -l vagrant -c 'ssh -o StrictHostKeyChecking=no -p 6666 admin@localhost create-job exam_26_03_2023 < /vagrant/jenkins/exam.xml'
#su -l vagrant -c 'ssh -o StrictHostKeyChecking=no -p 6666 admin@localhost get-job exam_26_03_2023 >> /vagrant/jenkins/exam.xml'
echo "* ✔️   Importing complete"


#
#  !!  Alternative connection via the Jenkin CLI  !!!
#

#echo "* 📦   Download Jenkins CLI"
#wget http://localhost:8080/jnlpJars/jenkins-cli.jar

#echo "* ➕   Importing job"
#j_user="$(jq -r '.username' /vagrant/credentials/jenkins_admin.json)"
#j_pass="$(jq -r '.password' /vagrant/credentials/jenkins_admin.json)"
#java -jar /home/vagrant/jenkins-cli.jar -s http://localhost:8080/ -http -auth "$j_user:$j_pass" delete-job exam_26_03_2023
#java -jar /home/vagrant/jenkins-cli.jar -s http://localhost:8080/ -http -auth "$j_user:$j_pass" create-job exam_26_03_2023 < /vagrant/jenkins/exam.xml
#java -jar /home/vagrant/jenkins-cli.jar -s http://localhost:8080/ -http -auth "$j_user:$j_pass" get-job exam_26_03_2023 >> /vagrant/jenkins/exam.xml
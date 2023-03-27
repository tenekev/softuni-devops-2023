#!/bin/bash

echo "* 🗝️   Exporting vagrant SSH pub.key"
su -l vagrant -c 'rm -f ~/.ssh/id_rsa* && ssh-keygen -t rsa -f "$HOME/.ssh/id_rsa" -P "" && cat ~/.ssh/id_rsa.pub > /vagrant/credentials/vagrant-at-jenkins.pub'


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
su -l vagrant -c 'ssh -o StrictHostKeyChecking=no -p 6666 admin@localhost delete-job DiabetesDemo'
su -l vagrant -c 'ssh -o StrictHostKeyChecking=no -p 6666 admin@localhost create-job DiabetesDemo < /vagrant/jenkins/DiabetesDemo.xml'
echo "* ✔️   Importing complete"
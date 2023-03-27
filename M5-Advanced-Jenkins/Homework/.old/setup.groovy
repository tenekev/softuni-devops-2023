import jenkins.model.*
import hudson.util.*;
import jenkins.install.*;
import hudson.security.*

def instance = Jenkins.getInstance()

// Set URL
url = 'http://192.168.99.101:8080'
urlConfig = JenkinsLocationConfiguration.get()
urlConfig.setUrl(url)
urlConfig.save()


// Enable SSH
def sshDesc = Jenkins.instance.getDescriptor("org.jenkinsci.main.modules.sshd.SSHD")
sshDesc.setPort(6666)
sshDesc.getActualPort()
sshDesc.save()


// Disable Wizard
instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)


// Register User
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin","admin")
instance.setSecurityRealm(hudsonRealm)

//
// Add ssh key to admin
//
// https://stackoverflow.com/questions/66350749/jenkins-how-to-configure-initial-admin-with-ssh-publickey-by-script
// https://gist.github.com/nigimaster/6a014c62b444fe7a7744304d66881451
// https://gist.github.com/fishi0x01/7c2d29afbaa0f16126eb4d4b35942f76
// https://riptutorial.com/jenkins/topic/7562/jenkins-groovy-scripting
//
def user = hudson.model.User.get('admin')
user.addProperty(new org.jenkinsci.main.modules.cli.auth.ssh.UserPropertyImpl(
    '+++replaceme+++'
))
user.save()

instance.save()

// '# ##replaceme## #'
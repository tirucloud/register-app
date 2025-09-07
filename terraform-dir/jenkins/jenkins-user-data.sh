#!/bin/bash
set -e

# Update and upgrade system
sudo apt update -y
sudo apt upgrade -y

# Set hostname (optional, replace with your desired hostname)
# sudo hostnamectl set-hostname jenkins-server

# Install Java 17
sudo apt install -y openjdk-17-jre

# Verify Java installation
java -version

# Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y jenkins

# Enable and start Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Check Jenkins status
sudo systemctl status jenkins

# SSH configuration (optional, uncomment if needed)
# sudo sed -i 's/^#*Port .*/Port 22/' /etc/ssh/sshd_config
# sudo systemctl reload sshd

# Generate SSH key (optional, uncomment if needed)
# ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519

# Print Jenkins initial admin password
echo "Jenkins initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

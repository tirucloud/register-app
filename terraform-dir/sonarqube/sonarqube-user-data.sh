#!/bin/bash
set -e

# Update and upgrade system
sudo apt update -y
sudo apt upgrade -y

# Add PostgreSQL repository
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null

# Install PostgreSQL
sudo apt-get update -y
sudo apt-get -y install postgresql postgresql-contrib
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Create SonarQube DB and user
sudo -u postgres psql <<EOF
CREATE USER sonar WITH ENCRYPTED PASSWORD 'sonar';
CREATE DATABASE sonarqube OWNER sonar;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;
EOF

# Add Adoptium repository and install Java 17
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo tee /etc/apt/keyrings/adoptium.asc
CODENAME=$(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release)
echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $CODENAME main" | sudo tee /etc/apt/sources.list.d/adoptium.list
sudo apt update -y
sudo apt install -y temurin-17-jdk

# Linux kernel tuning
sudo bash -c 'echo "sonarqube   -   nofile   65536" >> /etc/security/limits.conf'
sudo bash -c 'echo "sonarqube   -   nproc    4096" >> /etc/security/limits.conf'
sudo bash -c 'echo "vm.max_map_count = 262144" >> /etc/sysctl.conf'
sudo sysctl -p

# Download and extract SonarQube
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.0.65466.zip
sudo apt install -y unzip
sudo unzip sonarqube-9.9.0.65466.zip -d /opt
sudo mv /opt/sonarqube-9.9.0.65466 /opt/sonarqube

# Create user and set permissions
sudo groupadd sonar || true
sudo useradd -c "user to run SonarQube" -d /opt/sonarqube -g sonar sonar || true
sudo chown sonar:sonar /opt/sonarqube -R

# Update SonarQube properties with DB credentials
sudo bash -c 'cat >> /opt/sonarqube/conf/sonar.properties <<EOL
sonar.jdbc.username=sonar
sonar.jdbc.password=sonar
sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube
EOL'

# Create SonarQube systemd service
sudo bash -c 'cat > /etc/systemd/system/sonar.service <<EOL
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOL'

# Start and enable SonarQube
sudo systemctl daemon-reload
sudo systemctl start sonar
sudo systemctl enable sonar
sudo systemctl status sonar

# Tail SonarQube log
sudo tail -n 50 /opt/sonarqube/logs/sonar.log

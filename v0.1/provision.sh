# Install software
yum install -y oracle-rdbms-server-12cR1-preinstall
yum install -y openssh
yum install -y glibc

su - oracle -c 'unzip /vagrant/software/linuxamd64_12c_database_1of2.zip'
su - oracle -c 'unzip /vagrant/software/linuxamd64_12c_database_2of2.zip'

mv /etc/hosts /etc/hosts.original
cp /vagrant/hosts /etc/hosts
mkdir -p /u01/app/oracle
mkdir -p /u01/app/oraInventory
mkdir -p /u01/oradata
mkdir -p /u01/recovery
chown oracle:oinstall /u01/oradata
chown oracle:oinstall /u01/recovery
chown oracle:oinstall /u01/app/oracle
chown oracle:oinstall /u01/app/oraInventory

su - oracle -c 'mkdir -p /u01/app/oracle/product/12c'
chmod -R 775 /u01/app

su - oracle -c '/home/oracle/database/runInstaller -silent -showProgress -promptForPassword -waitforcompletion -responseFile /vagrant/db_install.rsp'

su - oracle -c '/u01/app/oraInventory/orainstRoot.sh'
su - oracle -c '/u01/app/oracle/product/12c/root.sh'

# Create database
su - oracle -c '/u01/app/oracle/product/12c/cfgtoollogs/configToolAllCommands RESPONSE_FILE=/vagrant/cfgrsp.properties' 



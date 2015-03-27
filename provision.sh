# v0.1 Initial
# v0.2 Adding conditions to each statement for idempotence.


# PreInstall requirements
# Install software
# Referred to Oracle Install Guide 3.6 Installing Oracle Linux with Public Yum repo
# http://docs.oracle.com/database/121/LADBI/olinrpm.htm#LADBI7480
# thanks Alvaro https://github.com/kikitux/stagefiles/blob/master/db/preinstall_crs_db.sh#L1
 
echo "installing oracle-rdbms-server-12cR1-preinstall" 
PACKAGES="oracle-rdbms-server-12cR1-preinstall openssh glibc" 

rpm -q $PACKAGES 
if [ $? -ne 0 ]; then 
  yum clean all 
  yum -y install $PACKAGES  
fi


# Unpack previously downloaded software

if [ -d /home/oracle/database ]; then
    echo "Skipping unzipping..."
  else
    su - oracle -c 'unzip /vagrant/software/linuxamd64_12c_database_1of2.zip'
    su - oracle -c 'unzip /vagrant/software/linuxamd64_12c_database_2of2.zip'
fi


# Add hostname to hosts file. 
# The is to avoid 
# [FATAL] PRVF-0002 : Could not retrieve local nodename
# Explaination : https://www.krenger.ch/blog/fatal-prvf-0002-could-not-retrieve-local-nodename/
# Oracle doc : 
# PRVF-00002: Could not retrieve local nodename
# Cause: Unable to determine local host name using Java network functions.
# Action: Ensure that hostname is defined correctly using the 'hostname' command.

if [ `grep oracle6 /etc/hosts | wc -l` -gt 0 ]; then
    echo "Skipping modifying hosts file, hostname present"
  else
    mv /etc/hosts /etc/hosts.original
    cp /vagrant/hosts /etc/hosts
fi


# Create ORACLE_BASE directory

[ -d /u01/app/oracle ] || mkdir -p /u01/app/oracle


# Create Oracle Inventory directory

[ -d /u01/app/oraInventory ] || mkdir -p /u01/app/oraInventory


# Create database directories

[ -d /u01/oradata ] || mkdir -p /u01/oradata
[ -d /u01/recovery ] || mkdir -p /u01/recovery


# Change ownership to oracle:oinstall

chown oracle:oinstall /u01/oradata
chown oracle:oinstall /u01/recovery
chown oracle:oinstall /u01/app/oracle
chown oracle:oinstall /u01/app/oraInventory


# Create directory for database software

su - oracle -c '[ -d /u01/app/oracle/product/12c ] || mkdir -p /u01/app/oracle/product/12c'


# Set base permissions for Oracle directories

[ `du -s /u01/app/oracle/product/12c | cut -f 1` -gt 1000000 ] || chmod -R 775 /u01/app


# Run Oracle installer in silent mode with a response file
# Referred to Oracle Database Install Guide on Linux, Appendix A
# http://docs.oracle.com/database/121/LADBI/app_nonint.htm#LADBI7838
# Edited db_install.rsp with valid inputs (depends on requirements)

su - oracle -c '[ -e /u01/app/oracle/product/12c/root.sh ] || /home/oracle/database/runInstaller -silent -showProgress -promptForPassword -waitforcompletion -responseFile /vagrant/db_install.rsp'


# Run root scripts to complete the database software install

su - root -c '/u01/app/oraInventory/orainstRoot.sh'
su - root -c '/u01/app/oracle/product/12c/root.sh'


# Run post install scripts which includes the option to create a database
# Referred to Oracle DB Install Guide - A.5,6 Running Database Configuration Assistant Using a Response File
# http://docs.oracle.com/database/121/LADBI/app_nonint.htm#LADBI7843

if [ `cat /proc/meminfo | grep MemTotal | awk '{print $2}'` -gt 1000000 ]; then
    [ `ps -ef | grep pmon | grep oracle | wc -l` -gt 0 ] || su - oracle -c '/u01/app/oracle/product/12c/cfgtoollogs/configToolAllCommands RESPONSE_FILE=/vagrant/cfgrsp.properties' 
  else
    echo "Skipping database creation, not enough memory"
fi

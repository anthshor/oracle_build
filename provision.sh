#!/bin/bash
# Changelog
# 20150615
# v0.4 sudo -u oracle -E so it inherits variables from parent process. 
#      Alvaros code to configure /dev/shm to 95% of VMs memory. 
#      variables ORACLE_HOME,STAGE, BASEDIR
#      unzip -n for software instead of if statement
#      distill down, remove uneccessary code - combine similar tests
# v0.3 Added proxy
# v0.2 Adding conditions to each statement for idempotence.
# v0.1 Initial

# Proxy
[ -f /vagrant/proxy.env ] && source /vagrant/proxy.env

# PreInstall requirements
# Install software
# Referred to Oracle Install Guide 3.6 Installing Oracle Linux with Public Yum repo
# http://docs.oracle.com/database/121/LADBI/olinrpm.htm#LADBI7480
# thanks Alvaro https://github.com/kikitux/stagefiles/blob/master/db/preinstall_crs_db.sh#L1
 
echo "installing oracle-rdbms-server-12cR1-preinstall" 
PACKAGES="oracle-rdbms-server-12cR1-preinstall" 
rpm -q $PACKAGES 
if [ $? -ne 0 ]; then 
  #yum clean all 
  yum -y install $PACKAGES  
fi

#per Oracle manual, we require add rw,exec to /dev/shm
#and will adjust size to 95% of ram
cp /etc/fstab /etc/fstab.ori
egrep -v '/dev/shm' /etc/fstab.ori > /etc/fstab
awk '{ $1="MemTotal:" };END{printf "tmpfs  /dev/shm  tmpfs rw,exec,size=%.0fm,defaults  0 0\n", $2/1024*0.95}' /proc/meminfo >> /etc/fstab
mountpoint /dev/shm 2>&1 >/dev/null  && mount -o remount,rw,exec /dev/shm || mount /dev/shm

# Add hostname to hosts file. 
# The is to avoid 
# [FATAL] PRVF-0002 : Could not retrieve local nodename
# Explaination : https://www.krenger.ch/blog/fatal-prvf-0002-could-not-retrieve-local-nodename/
# Oracle doc : 
# PRVF-00002: Could not retrieve local nodename
# Cause: Unable to determine local host name using Java network functions.
# Action: Ensure that hostname is defined correctly using the 'hostname' command.

if [ `grep -i $hostname /etc/hosts | wc -l` -ne 0 ]; then
    echo "Skipping modifying hosts file, hostname present"
else
    long="`hostname`"
    short="`hostname -s`"
    echo "updating /etc/hosts with $HOSTNAME information"
    if [ "$short" == "$long" ]; then
        echo "127.0.0.1 localhost.localdomain localhost $short" > /etc/hosts
    else
        echo "127.0.0.1 localhost.localdomain localhost $long $short" > /etc/hosts
    fi
fi

# Create ORACLE_BASE directory
[ -d /u01/app/oracle ] || mkdir -p /u01/app/oracle

# Create stage directory
[ -d /u01/stage ] || mkdir -p /u01/stage

# Create Oracle Inventory directory
[ -d /u01/app/oraInventory ] || mkdir -p /u01/app/oraInventory

# Create database directories
[ -d /u01/oradata ] || mkdir -p /u01/oradata
[ -d /u01/recovery ] || mkdir -p /u01/orafra

# Change ownership to oracle:oinstall
chown oracle:oinstall /u01/app/oracle
chown oracle:oinstall /u01/stage
chown oracle:oinstall /u01/app/oraInventory
chown oracle:oinstall /u01/oradata
chown oracle:oinstall /u01/orafra

# use sudo over su
# sudo -u oracle -E (command 1 ; command 2)

#define the global variables
export ORACLE_HOME="/u01/app/oracle/product/12c"
export STAGE="/u01/stage"
export BASEDIR="/vagrant"

# Unpack previously downloaded software
sudo -u oracle -E unzip -n -d $STAGE /u01/software/linuxamd64_12102_database_1of2.zip
sudo -u oracle -E unzip -n -d $STAGE /u01/software/linuxamd64_12102_database_2of2.zip

# Create directory for database software
[ -d $ORACLE_HOME ] || sudo -u oracle -E mkdir -p $ORACLE_HOME


if [ ! -f $ORACLE_HOME/root.sh ]; then
  # Set base permissions for Oracle directories
  chmod -R 775 /u01/app

# Run Oracle installer in silent mode with a response file
# Referred to Oracle Database Install Guide on Linux, Appendix A
# http://docs.oracle.com/database/121/LADBI/app_nonint.htm#LADBI7838
# Edited db_install.rsp with valid inputs (depends on requirements)
  sudo -u oracle -E $STAGE/database/runInstaller -silent -showProgress -promptForPassword -waitforcompletion -responseFile $BASEDIR/db_install.rsp
fi

# Run root scripts to complete the database software install
/u01/app/oraInventory/orainstRoot.sh
[ -f $ORACLE_HOME/root.sh ] && bash $ORACLE_HOME/root.sh

# Run post install scripts which includes the option to create a database
# Referred to Oracle DB Install Guide - A.5,6 Running Database Configuration Assistant Using a Response File
# http://docs.oracle.com/database/121/LADBI/app_nonint.htm#LADBI7843
if [ `cat /proc/meminfo | grep MemTotal | awk '{print $2}'` -gt 1000000 ]; then
    [ `ps -ef | grep pmon | grep oracle | wc -l` -gt 0 ] || su - oracle -c '/u01/app/oracle/product/12c/cfgtoollogs/configToolAllCommands RESPONSE_FILE=/vagrant/cfgrsp.properties' 
  else
    echo "Skipping database creation, not enough memory"
fi



# v0.1 Initial
# v0.2 Adding conditions to each statement for idempotence.
# v0.3 Added proxy 

# Proxy
[ -f /vagrant/proxy.env ] && source /vagrant/proxy.env

# PreInstall requirements
# Install software
# Referred to Oracle Install Guide 3.6 Installing Oracle Linux with Public Yum repo
# http://docs.oracle.com/database/121/LADBI/olinrpm.htm#LADBI7480
# thanks Alvaro https://github.com/kikitux/stagefiles/blob/master/db/preinstall_crs_db.sh#L1
 
echo "installing oracle-rdbms-server-12cR1-preinstall" 
PACKAGES="oracle-rdbms-server-12cR1-preinstall openssh glibc git" 

rpm -q $PACKAGES 
if [ $? -ne 0 ]; then 
  yum clean all 
  yum -y install $PACKAGES  
fi


# Unpack previously downloaded software

if [ -d /home/oracle/database ]; then
    echo "Skipping unzipping..."
  else
    su - oracle -c 'unzip /u01/software/linuxamd64_12c_database_1of2.zip'
    su - oracle -c 'unzip /u01/software/linuxamd64_12c_database_2of2.zip'
fi


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


##############################################################
#
# 4. Node-oracledb installation on Linux with a Local Database
#
# Ref : https://github.com/oracle/node-oracledb/blob/master/INSTALL.md#instoh
#
##############################################################

# Install node.js

rpm -q nodejs
if [ $? -ne 0 ]; then
  curl -sL https://rpm.nodesource.com/setup | bash -
  yum install -y nodejs
fi


# Install the driver for Oracle/node.js

su - oracle -c '[ -d node-oracledb ] || git clone https://github.com/oracle/node-oracledb'
cd /home/oracle/node-oracledb/; export ORACLE_HOME=/u01/app/oracle/product/12c; npm install -g


# Setup test

if [ -e /home/oracle/node-oracledb/examples/dbconfig.js ] && [ `grep fred /home/oracle/node-oracledb/examples/dbconfig.js | wc -l` -gt 0 ]; then
  echo "Skipping copy of dbconfig,js, already copied"
else
  if [ -e /home/oracle/node-oracledb/examples/dbconfig.js ]; then  cp /home/oracle/node-oracledb/examples/dbconfig.js /home/oracle/node-oracledb/examples/dbconfig.js.orig; fi
  cp /vagrant/dbconfig.js /home/oracle/node-oracledb/examples/
  chmod 644 /home/oracle/node-oracledb/examples/dbconfig.js
  chown oracle:oinstall /home/oracle/node-oracledb/examples/dbconfig.js
fi


# Run test as Oracle

su - oracle -c 'export NODE_PATH=/usr/lib/node_modules 
export LD_LIBRARY_PATH=/u01/app/oracle/product/12c/lib
export ORACLE_SID=fred
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/12c
export PATH=${PATH}:${ORACLE_HOME}/bin

sqlplus / as sysdba << EOF
alter user hr account unlock;
alter user hr identified by hr;
exit

EOF

node node-oracledb/examples/select1.js'
if [ $? -ne 0 ]; then
  echo "Something went wrong. Node.js test FAILED"
else
  echo "node.js test Succeeded!"
fi


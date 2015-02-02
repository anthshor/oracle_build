#!/bin/bash

# Create grid user on each node of the cluster

/usr/sbin/useradd -g oinstall -G dba grid
echo "grid" | passwd grid --stdin

# Creating the Oracle directory base path

mkdir -p  /u01/app/11.2.0/grid
mkdir -p /u01/app/grid
mkdir -p /u01/app/oracle
chown grid:oinstall /u01/app/11.2.0/grid
chown grid:oinstall /u01/app/grid
chown oracle:oinstall /u01/app/oracle
chmod -R 775 /u01/
chown -R grid:oinstall /u01


# Creating Job Role Separation Operating System Privileges Groups and Users

/usr/sbin/groupadd -g 1020 asmadmin
/usr/sbin/groupadd -g 1022 asmoper
/usr/sbin/groupadd -g 1021 asmdba

# Modifying an Existing Oracle Software Owner and grid User

/usr/sbin/usermod -g oinstall -G dba,asmdba oracle
/usr/sbin/usermod -g oinstall -G asmadmin,asmdba grid

exit

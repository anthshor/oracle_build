Automated build for Oracle Database
-----------------------------------

1. Install oracle-rdbms-server-12cR1-preinstall
2. Install DB software
3. Run DBCA

NB Requires software directory (not included) with Oracle binaries already downloaded and contained within it:
 Anthonys-Mac-mini:oracle_build anthonyshorter$ ls
 Vagrantfile		db_install.rsp		provision.sh		software
 cfgrsp.properties	hosts			readme.txt
 Anthonys-Mac-mini:oracle_build anthonyshorter$ cd software/
 Anthonys-Mac-mini:software anthonyshorter$ ls
 linuxamd64_12c_database_1of2.zip	linuxamd64_12c_database_2of2.zip

Output
------
Log in as oracle:
(environment needs fixing, but is there)

[oracle@vagrant-oracle65 var]$ export ORACLE_SID=fred
[oracle@vagrant-oracle65 var]$ export ORACLE_HOME=/u01/app/oracle/product/12c
[oracle@vagrant-oracle65 var]$ echo $PATH
/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/oracle/bin
[oracle@vagrant-oracle65 var]$ export PATH=$PATH:$ORACLE_HOME/bin
[oracle@vagrant-oracle65 var]$ . oraenv
ORACLE_SID = [fred] ? 
ORACLE_HOME = [/home/oracle] ? /u01/app/oracle/product/12c
The Oracle base has been set to /u01/app/oracle
[oracle@vagrant-oracle65 var]$ sqlplus / as sysdba

SQL*Plus: Release 12.1.0.1.0 Production on Tue Mar 24 09:41:13 2015

Copyright (c) 1982, 2013, Oracle.  All rights reserved.


Connected to:
Oracle Database 12c Enterprise Edition Release 12.1.0.1.0 - 64bit Production
With the Partitioning, OLAP, Advanced Analytics and Real Application Testing options

SQL> select open_mode from v$database;

OPEN_MODE
--------------------
READ WRITE

SQL> 



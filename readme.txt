Automated build for an Oracle Database
--------------------------------------

1. Install oracle-rdbms-server-12cR1-preinstall
2. Install DB software
3. Run DBCA

Requires software directory with Oracle binaries already downloaded and contained within it:
  $ cd software/
  $ ls -l
  total 4838984
  -rw-r--r--  1 anthonyshorter  staff  1361028723 18 Jul  2014 linuxamd64_12c_database_1of2.zip
  -rw-r--r--  1 anthonyshorter  staff  1116527103 18 Jul  2014 linuxamd64_12c_database_2of2.zip

Run
---
$ vagrant up
$ vagrant ssh
[vagrant@vagrant-oracle65 ~]$ sudo su - oracle
[oracle@vagrant-oracle65 ~]$ . oraenv
ORACLE_SID = [oracle] ? fred
The Oracle base has been set to /u01/app/oracle
[oracle@vagrant-oracle65 ~]$ sqlplus / as sysdba

SQL*Plus: Release 12.1.0.1.0 Production on Wed Mar 25 09:39:23 2015

Copyright (c) 1982, 2013, Oracle.  All rights reserved.


Connected to:
Oracle Database 12c Enterprise Edition Release 12.1.0.1.0 - 64bit Production
With the Partitioning, OLAP, Advanced Analytics and Real Application Testing options

SQL> select name,open_mode from v$database;

NAME	  OPEN_MODE
--------- --------------------
FRED	  READ WRITE


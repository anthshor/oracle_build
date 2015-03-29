Automated build for an Oracle Database with node.js
---------------------------------------------------

1. Install oracle-rdbms-server-12cR1-preinstall
2. Install DB software
3. Run DBCA
4. Install node.js 
4.1 Install driver for Oracle
4.2 Test with an example select

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
.
. < lines removed>
.
==> default: [ [ 180, 'Construction' ] ]
==> default: [ { name: 'DEPARTMENT_ID' }, { name: 'DEPARTMENT_NAME' } ]
==> default: node.js test Succeeded!


package {"oracle-rdbms-server-11gR2-preinstall":
  ensure  => installed,
}

exec {"/bin/bash /vagrant/grid_user.sh":
  unless => "/bin/grep -q grid /etc/passwd",
  require => Package["oracle-rdbms-server-11gR2-preinstall"],
}

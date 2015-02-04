package {"oracle-rdbms-server-12cR1-preinstall":
  ensure  => latest,
  allow_virtual => false,
}

package {"openssh":
  ensure => latest,
  allow_virtual => false,
}

exec {"/bin/bash /vagrant/grid_user.sh":
  unless => "/bin/grep -q grid /etc/passwd",
  require => Package["oracle-rdbms-server-12cR1-preinstall"],
}

package {"glibc":
  ensure => latest,
  allow_virtual => false,
}

# Added proxy environment variables to .bash_profile
# for root.

# Proxy

file {'proxy.env':
  path => '/root/proxy.env',
  owner => 'root',
  group => 'root',
  mode => '0744',
  source => '/vagrant/files/proxy.env',
}

exec {'set_env':
  cwd => '/root',
  command => '/bin/cat proxy.env >> .bash_profile; touch .breadcrumb; rm -f proxy.env;',
  require => File["proxy.env"],
  unless => '/usr/bin/test -f .breadcrumb',
}

exec {'cleanup':
  cwd =>'/root',
  command => '/bin/rm -f proxy.env',
  onlyif => '/usr/bin/test -f .breadcrumb',
}

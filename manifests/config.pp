class artifactory::config ($webappdir) {

  File {
    owner => $artifactory::user,
    group => $artifactory::group,
  }

  file { "${artifactory::datadir}/etc/storage.properties":
    content => template('artifactory/storage.properties.erb'),
    mode    => '0750',
    require => [
      Class['artifactory::install'],
      File[$artifactory::datadir]
    ],
    notify  => Class['artifactory::service'],
  }

  file { "${webappdir}/tomcat/conf/server.xml":
    content => template('artifactory/server.xml.erb'),
    mode    => '0644',
    require => [
      Class['artifactory::install']
    ],
    notify  => Class['artifactory::service'],
  }

  file { "${webappdir}/tomcat/conf/Catalina/localhost/artifactory.xml":
    content => template('artifactory/artifactory.xml.erb'),
    mode    => '0644',
    require => [
      Class['artifactory::install']
    ],
    notify  => Class['artifactory::service'],
  }

  file { "${webappdir}/tomcat/bin/setenv.sh":
    content => template('artifactory/setenv.sh.erb'),
    mode => '0755',
  } ->
  file { '/etc/default/artifactory':
    content => template('artifactory/artifactory.default.erb'),
    mode => '0755',
  } ->
  file { '/etc/init.d/artifactory':
    content => template('artifactory/initscript.erb'),
    mode => '0755',
  }
}
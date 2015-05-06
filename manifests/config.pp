class artifactory::config () {

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

  file { '/etc/default/artifactory':
    content => template('artifactory/artifactory.default.erb'),
    mode => '0755',
  } ->
  file { '/etc/init.d/artifactory':
    content => template('artifactory/initscript.erb'),
    mode => '0755',
  }
}
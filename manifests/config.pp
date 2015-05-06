class artifactory::config () {

  File {
    owner => $artifactory::user,
    group => $artifactory::group,
  }

  #file { "${artifactory::datadir}/config":
  #  ensure  => 'directory',
  #  require => [
  #    Class['artifactory::install'],
  #    File[$artifactory::datadir]
  #  ],
  #} ->

  #file { ["${teamcity::datadir}/lib", "${teamcity::datadir}/lib/jdbc", "${teamcity::datadir}/system"]:
  #  ensure  => 'directory',
  #  require => [
  #    Class['teamcity::install'],
  #    File[$teamcity::datadir]
  #  ],
  #} ->

  file { "${artifactory::datadir}/etc/storage.properties":
    content => template('artifactory/storage.properties.erb'),
    mode    => '0750',
    require => [
      Class['artifactory::install'],
      File[$artifactory::datadir]
    ],
    #notify  => Class['artifactory::service'],
  }

  #staging::file { 'postgresql-jbdc41.jar':
  #  source => 'https://jdbc.postgresql.org/download/postgresql-9.3-1103.jdbc41.jar',
  #  target => "${teamcity::datadir}/lib/jdbc/postgresql-9.3-1103.jdbc41.jar"
  #} ->

  #file { '/etc/init/teamcity.conf':
  #  content => template('teamcity/teamcity.conf.erb')
  #}
}
class artifactory::install (
  $version     = $artifactory::version,
  $product     = $artifactory::product,
  $format      = $artifactory::format,
  $installdir  = $artifactory::installdir,
  $datadir     = $artifactory::datadir,
  $user        = $artifactory::user,
  $group       = $artifactory::group,
  $downloadURL = $artifactory::downloadURL,

  $webappdir
) {
  group { $group:
    ensure => present,
  } ->
  user { $user:
    comment          => 'artifactory daemon account',
    shell            => '/bin/bash',
    home             => $datadir,
    password         => '*',
    password_min_age => '0',
    password_max_age => '99999',
    managehome       => true,
  }

  if ! defined(File[$installdir]) {
    file { $installdir:
      ensure => 'directory',
      owner  => $user,
      group  => $group,
    }
  }

  File {
    owner   => $user,
    group   => $group,
  }

  require staging
  $file = "jfrog-artifactory-pro-${version}.${format}"
  staging::file { $file:
    source  => "${downloadURL}/${file}",
    timeout => 1800,
  } ->
  staging::extract { $file:
    target  => $installdir,
    creates => "${webappdir}/etc",
    strip   => 1,
    user    => $user,
    group   => $group,
    notify  => Exec["chown_${webappdir}"],
    before  => File[$datadir],
    require => [
      File[$installdir],
      User[$user] ],
  } ->
  staging::file { 'artifactory_postgresql-jbdc41.jar':
    source => 'https://jdbc.postgresql.org/download/postgresql-9.3-1103.jdbc41.jar',
    target => "${artifactory::webappdir}/tomcat/lib/postgresql-9.3-1103.jdbc41.jar",
  }# ->
  #file { "${artifactory::webappdir}/tomcat/lib/postgresql-9.3-1103.jdbc41.jar":
  #  ensure => 'present ',
  #}

  file { $datadir:
    ensure  => 'directory',
    require => User[$user],
  }->
  exec { "chown_${webappdir}":
    command     => "/bin/chown -R ${user}:${group} ${webappdir}",
    refreshonly => true,
    subscribe   => User[$artifactory::user]
  }

  exec { "chmod_${webappdir}/tomcat/bin":
    command     => "/bin/chmod a+x ${webappdir}/tomcat/bin/*",
    require     => Exec["chown_${webappdir}"],
  }

  exec { "copy_${webappdir}":
    command     => "/bin/cp -r ${webappdir}/* ${datadir}",
    creates     => "${datadir}/etc",
    require     => Exec["chown_${webappdir}"],
  }

  file { "${datadir}/data":
    ensure => 'directory',
    require => File[$datadir],
  }

  file { ["${datadir}/bin", "${datadir}/tomcat", "${datadir}/webapps"]:
    ensure => 'absent',
    force => true,
    require => Exec["copy_${webappdir}"]
  } ~>
  exec { "chwon_${datadir}":
    command     => "/bin/chown -R ${user}:${group} ${datadir}",
    refreshonly => true,
  }

  file { "${webappdir}/etc":
    ensure => 'link',
    target => "${datadir}/etc",
    force => true,
    require => Exec["copy_${webappdir}"],
  }

  file { "${webappdir}/data":
    ensure => 'link',
    target => "${datadir}/data",
    force => true,
    require => Exec["copy_${webappdir}"],
  }

  file { "${webappdir}/logs":
    ensure => 'link',
    target => "${datadir}/logs",
    force => true,
    require => Exec["copy_${webappdir}"],
  }

  file { "${webappdir}/run":
    ensure => 'directory',
  }

  file { "${webappdir}/tomcat/work":
    ensure => 'directory',
  }

  file { "${webappdir}/tomcat/temp":
    ensure => 'directory',
  }

  file { "${webappdir}/logs/tomcat":
    ensure => 'directory',
    require => File["${webappdir}/logs"],
  } ->
  file { "${webappdir}/tomcat/logs":
    ensure => 'link',
    target => "${webappdir}/logs/tomcat",
    force => true,
  }
}

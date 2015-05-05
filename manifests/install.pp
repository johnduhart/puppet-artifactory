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

  require staging
  $file = "artifactory-powerpack-standalone-${version}.${format}"
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
  }

  file { $datadir:
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    require => User[$user],
  }->
  exec { "chown_${webappdir}":
    command     => "/bin/chown -R ${user}:${group} ${webappdir}",
    refreshonly => true,
    subscribe   => User[$artifactory::user]
  } ->
  exec { "copy_${webappdir}":
    command     => "/bin/cp -r ${webappdir}/* ${datadir}",
    creates     => "${datadir}/etc",
  }
}
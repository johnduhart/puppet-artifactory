class artifactory(
  $version      = '4.0.2',
  $product      = 'artifactory',
  $format       = 'zip',
  $installdir   = '/opt/artifactory',
  $datadir      = '/home/artifactory',
  $user         = 'artifactory',
  $group        = 'artifactory',

  # Java Options
  $javahome     = undef,
  $jvm_xms      = '256m',
  $jvm_xmx      = '1024m',
  $jvm_permgen  = '256m',

  # Database Settings
  $dbuser       = 'artifactory',
  $dbpassword   = 'password',
  $dburl        = 'jdbc:postgresql://localhost:5432/artifactory',

  $service_ensure = running,
  $service_enable = true,

  $filesystemdir = '/home/artifactory/data',

  $downloadURL  = undef,
) {
  $webappdir    = "${installdir}/artifactory-pro-${version}"

  anchor { 'artifactory::start': } ->
  class { 'artifactory::install':
    webappdir => $webappdir
  } ->
  class { 'artifactory::config':
    webappdir => $webappdir
  } ~>
  class { 'artifactory::service': } ->
  anchor { 'artifactory::end': }
}

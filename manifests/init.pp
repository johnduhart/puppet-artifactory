class artifactory(
  $version      = '9.0.2',
  $product      = 'artifactory',
  $format       = 'zip',
  $installdir   = '/opt/artifactory',
  $datadir      = '/home/artifactory',
  $user         = 'artifactory',
  $group        = 'artifactory',

  # Java Options
  $jvm_xms      = '256m',
  $jvm_xmx      = '1024m',
  $jvm_permgen  = '256m',

  # Database Settings
  $dbuser       = 'artifactory',
  $dbpassword   = 'password',
  $dburl        = 'jdbc:postgresql://localhost:5432/artifactory',

  $service_ensure = running,
  $service_enable = true,


  $downloadURL  = undef,
) {
  $webappdir    = "${installdir}/jfrog-${product}-${version}"

  anchor { 'artifactory::start': } ->
  class { 'artifactory::install':
    webappdir => $webappdir
  } ->
  #class { 'artifactory::config': } ~>
  #class { 'artifactory::service': } ->
  anchor { 'artifactory::end': }
}
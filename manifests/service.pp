class teamcity::service(
  $service_ensure        = $stash::service_ensure,
  $service_enable        = $stash::service_enable
) {
  service { 'teamcity':
      ensure  => $service_ensure,
      enable  => $service_enable,
      require => File['/etc/init/teamcity.conf'],
    }
}
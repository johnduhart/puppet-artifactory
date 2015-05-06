class artifactory::service(
  $service_ensure        = $artifactory::service_ensure,
  $service_enable        = $artifactory::service_enable
) {
  service { 'artifactory':
      ensure  => $service_ensure,
      enable  => $service_enable,
      require => File['/etc/init.d/artifactory'],
    }
}
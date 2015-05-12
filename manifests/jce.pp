# Adding jce support
class jdk::jce(
  $cookie = 'oraclelicense=accept-securebackup-cookie;gpw_e24=http://edelivery.oracle.com',
  $package = 'jce.zip',
  $url = 'http://download.oracle.com/otn-pub/java/jce/7/UnlimitedJCEPolicyJDK7.zip',
  $home = '/usr/lib/jvm/java-7-oracle/lib/',
  $dest = 'UnlimitedJCEPolicy'
) {

  $cmd = "wget -O /tmp/${package} --no-cookies --no-check-certificate --header 'Cookie: ${cookie}' ${url}"

  ensure_packages('unzip')

  file{"${home}/security":
    ensure => directory,
  } ->

  exec{'download jce':
    command => $cmd,
    user    => 'root',
    path    => '/usr/bin/',
    unless  => "/usr/bin/test -f /tmp/${package}",
  } ->

  exec{'extract jce':
    command => "unzip /tmp/${package} -d /tmp",
    user    => 'root',
    path    => '/usr/bin',
    require => Package['unzip'],
    unless  => "/usr/bin/test -d /tmp/${dest}",
  } ->

  exec{'move jce':
    command => "mv /tmp/${dest}/* ${home}/security",
    user    => 'root',
    path    => ['/usr/bin','/bin',],
    unless  => "/usr/bin/test -f ${home}/security/US_export_policy.jar",
  }

}

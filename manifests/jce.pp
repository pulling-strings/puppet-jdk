# JCE install 
class jdk::jce(
  $cookie = 'oraclelicense=accept-securebackup-cookie;gpw_e24=http://edelivery.oracle.com',
  $package = 'jce.zip',
  $url = 'http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip',
  $home = '/usr/lib/jvm/java-8-oracle/lib/',
  $dest = 'UnlimitedJCEPolicyJDK8'
) {
  if($::jdk::version != '8'){
    fail('this class only supports jdk 8')
  }

  $preqs = $::operatingsystem ? {
    'Ubuntu'          => Package[$jdk::install::ubuntu::installer],
    /(Redhat|Centos)/ => Exec['install jdk']
  }

  if($::operatingsystem == 'Ubuntu'){
    package{'oracle-java8-unlimited-jce-policy':
      ensure  => present,
      require => Package[$jdk::install::ubuntu::installer]
    }
  } else {
    $cmd = "wget -O /tmp/${package} --no-cookies --no-check-certificate --header 'Cookie: ${cookie}' ${url}"

    ensure_packages('unzip')

    file{"${home}/security":
      ensure  => directory,
      require => $preqs
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

}

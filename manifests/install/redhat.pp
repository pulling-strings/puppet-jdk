# Installing jdk 7/8 on redhat based systems 
class jdk::install::redhat {
  $package = $::jdk::version ? {
    '7'     => 'jdk-7u51-linux-x64.rpm',
    '8'     => 'jdk-8u60-linux-x64.tar.gz',
    default => fail("${::jdk::version} not supported!")
  }


  $url = $::jdk::version ? {
    '7'     => "http://download.oracle.com/otn-pub/java/jdk/7u51-b13/${package}",
    '8'     => "http://download.oracle.com/otn-pub/java/jdk/8u60-b27/${package}",
    default => fail("${::jdk::version} not supported!")
  }

  $flags = '--no-cookies --no-check-certificate'
  $cookie = '"Cookie: oraclelicense=accept-securebackup-cookie"'

  ensure_packages(['wget'])

  exec{'download jdk':
    command => "wget -O /tmp/${package} ${flags} --header ${cookie} ${url}",
    user    => 'root',
    path    => '/usr/bin/',
    unless  => "/usr/bin/test -f /tmp/${package}",
    require => Package['wget']
  }

  if ($::jdk::version == '7') {
    exec{'install jdk':
      command => "/bin/rpm -ivh /tmp/${package}",
      cwd     => '/tmp',
      user    => 'root',
      unless  => '/usr/bin/test -d /usr/java',
      require => Exec['download jdk']
    }
  } elsif ($::jdk::version == '8') {
    exec{"tar xzf /tmp/${package} -C /opt":
      user    => root,
      path    => ['/usr/bin','/bin',],
      unless  => '/usr/bin/test -d /opt/jdk1.8.0_60/',
      require => Exec['download jdk']
    } ->
    
    jdk::install::alternative {'javac':
      target => 'jdk1.8.0_60'
    } ->

    jdk::install::alternative {'java':
      target => 'jdk1.8.0_60'
    }

    jdk::install::alternative {'jar':
      target => 'jdk1.8.0_60'
    }
  }

}

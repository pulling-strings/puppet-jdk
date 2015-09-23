# Setting up alterntives for Redhat/Centos
define jdk::install::alternative(
  $target
) {
  exec{"alternatives --install /usr/bin/${name} ${name} /opt/${target}/bin/${name} 2":
    user   => root,
    path   => ['/usr/bin','/bin','/usr/sbin'],
    unless => "test -f /usr/bin/${name} && /usr/bin/${name} -version",
  } ~>

  exec{"alternatives --set ${name} /opt/${target}/bin/${name}":
    user        => root,
    path        => ['/usr/bin','/bin','/usr/sbin'],
    refreshonly => true
  }
}

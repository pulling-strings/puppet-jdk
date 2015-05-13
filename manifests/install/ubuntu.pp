# Debian/Ubuntu setup
class jdk::install::ubuntu {

  apt::ppa { 'ppa:webupd8team/java': }

  $installer= $::jdk::version ? {
    '8'      => 'oracle-java8-installer',
    '7'      => 'oracle-java7-installer',
    '6'      => 'oracle-java6-installer'
  }

  package{$installer:
    ensure  => present,
    require => [Apt::Ppa['ppa:webupd8team/java'],
    Exec['skipping license approval']]
  }

  package{'debconf-utils':
    ensure  => present
  }

  exec{'skipping license approval':
    command => "/bin/echo  '${installer} shared/accepted-oracle-license-v1-1 boolean true' | /usr/bin/debconf-set-selections",
    user    => 'root',
    require => [Apt::Ppa['ppa:webupd8team/java'], Package['debconf-utils']]
  }

}

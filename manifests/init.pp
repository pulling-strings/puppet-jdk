# This puppet module sets up java jdk
# Usage:
#
# include jdk
#
# In order to use jdk 7 (ubuntu only)
# class {'jdk':
#   version => 7
# }
#
# In order to use local rpm url:
# class{'jdk'
#  rpm_url => 'http://..
# }
class jdk($version='6', $rpm_url='') {
  if($::operatingsystem =~ /Ubuntu|Debian/){
    include apt

    apt::ppa { 'ppa:webupd8team/java': }

    $installer= $version ? {
      '7'      => 'oracle-java7-installer',
      default  => 'oracle-java6-installer'
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
      command => "/bin/echo  '$installer shared/accepted-oracle-license-v1-1 boolean true' | /usr/bin/debconf-set-selections",
      user    => 'root',
      require => [Apt::Ppa['ppa:webupd8team/java'], Package['debconf-utils']]
    }

  }

    if($::operatingsystem =~ /RedHat|CentOS/) {
      $package = 'jdk-7u51-linux-x64.rpm'
      $cookie = '"Cookie: oraclelicense=accept-securebackup-cookie"'

      if($rpm_url != '') {
        $url = "${rpm_url}/${package}"
      } else {
        $url = "http://download.oracle.com/otn-pub/java/jdk/7u51-b13/${package}"
      }

      exec{'download jdk':
          command  => "wget -O /tmp/${package} --no-cookies --no-check-certificate --header ${cookie} ${url}",
          user     => 'root',
          path     => '/usr/bin/',
          unless  => "/usr/bin/test -f /tmp/${package}",
      }

      if($version == '6') {
        exec{'chmod jdk package':
          command => "chmod +x /tmp/${package}",
          user    => 'root',
          path    => '/bin',
          require => Exec['download jdk']
        }

        exec{'install jdk':
          command => "yes \"\" | /tmp/${package}",
          cwd     => '/tmp',
          user    => 'root',
          path    => '/usr/bin/',
          unless  => '/usr/bin/test -d /usr/java',
          timeout => 600,
          require => [Exec['download jdk'], Exec['chmod jdk package']]
        }

        exec{'update alternative':
          command => 'alternatives --install /usr/bin/java java /usr/java/jdk1.6.0_38/bin/java 2',
          user    => 'root',
          path    => '/usr/sbin/',
          unless  => '/usr/bin/which java'
        }
      } else {
        exec{'install jdk':
          command => "/bin/rpm -ivh /tmp/${package}",
          cwd     => '/tmp',
          user    => 'root',
          unless  => '/usr/bin/test -d /usr/java',
          require => Exec['download jdk']
        }
      }
    }
}

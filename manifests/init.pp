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
class jdk(
  $version='6',
  $rpm_url='',
  $enable_jce = false
) {

  if($::operatingsystem =~ /Ubuntu|Debian/){
    include ::jdk::install::ubuntu
  }

  if($::operatingsystem =~ /RedHat|CentOS/) {
    include ::jdk::install::redhat
  }

  if $enable_jce {
    include jdk::jce
  }
}

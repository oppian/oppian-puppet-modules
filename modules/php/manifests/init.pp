class php {
  package { php:
    require => Package['apache'],
    notify => Service['httpd']
  }
  
  package { php-mysql: 
    require => Package['php']
  }
  
  file {'/etc/php.ini':
    content => template('php/php.ini.erb'),
    require => Package['php'],
    notify => Service['httpd'],
  }
}

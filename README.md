oppian-puppet-modules
=====================

Generic puppet modules used by Oppian

Modules include:

* varnish
* monit
* nginx
* python
* webapp
* php
* apache


PHP Example
-----------

Here is an example of a simple php website:

```puppet
class free-bets-guide {

  file {'/deploy/docroot/include/config.php':
      ensure  => file,
      content => template('free-bets-guide/config.php.erb'),
  }

  class {"php":}
  
  apache::dotconf { "free-bets-guide":
    content => template("free-bets-guide/free-bets-guide.conf.erb")
  }

}
```

A php template:

```php
<?php

// urls and dirs
define("HOME_DIR", "/deploy/docroot/");
define("HOME_URL", "/");
define("TEMPLATE_DIR", HOME_DIR."templates/");
define("INCLUDE_DIR", HOME_DIR."include");
define("IMAGE_DIR", HOME_URL."images/");

// sql
define("DB_HOST", "<%= cfn_host %>");
define("DB_NAME", "<%= cfn_database %>");
define("DB_USER", "<%= cfn_user %>");
define("DB_PASS", "<%= cfn_password %>");

// general defines
define("ME", $_SERVER["PHP_SELF"]);

// includes
include(INCLUDE_DIR."/db_mysql.php");
include(INCLUDE_DIR."/functions.php");
include(INCLUDE_DIR."/sites.php");
include(INCLUDE_DIR."/log.php");
include(INCLUDE_DIR."/articles.php");


// connect to db
$SQLID = db_connect(DB_HOST, DB_USER, DB_PASS, DB_NAME);

?>
```

Django Example
--------------

Here is an example of Oppian's django deployment:

```puppet
class oppian {

  $project = "oppianproj"

  class { "webapp::python": owner => "root",
                          group => "wheel",
                          src_root => "/deploy",
                          nginx_workers => 1,
                          monit_admin => $cfn_adminemail,
                          monit_interval => 30,
  }
  
  if $cfn_hostname2 {
  	$aliases = [$cfn_hostname2]
  }
  else {
  	$aliases = []
  }

  webapp::python::instance { $project:
    workers => inline_template("<%= (processorcount.to_i * 2 + 1) -%>"),
    listen_port => 8080,
    domain => $cfn_hostname,
    aliases => $aliases,
    django => true,
    requirements => true,
    django_syncdb => true,
    mediaroot => "/deploy/$project/media/",
    mediaprefix => "/m/",
    pythonpath => ["lib/django", "apps", "apps/oppianapp/utils", "lib/django-storages"],
    default_vhost => true,
  }

  file { "/deploy/$project/settings_local.py":
    ensure => file,
    content => template('oppian/settings.py.erb'),
    before => Exec["python::syncdb $project"],
  }
  
  file { "/deploy/$project/media/admin":
  	ensure => link,
  	target => "/deploy/$project/lib/django/django/contrib/admin/media"
  }
  
  file { "/deploy/$project/media/favicon.ico":
  	ensure => link,
  	target => "/deploy/$project/media/images/favicon.ico"
  }

  class {'varnish':}

}
```

Now the `settings_local.py.erb` template:

```
DEBUG = <%= cfn_debug %>
TEMPLATE_DEBUG = DEBUG

DATABASE_ENGINE = 'mysql'        
DATABASE_NAME = '<%= cfn_database %>'
DATABASE_USER = '<%= cfn_user %>'
DATABASE_PASSWORD = '<%= cfn_password %>'
DATABASE_HOST = '<%= cfn_host %>'
DATABASE_PORT = ''           

SITE_DOMAIN = "<%= cfn_hostname %>"

# s3 storage
AWS_STORAGE_BUCKET_NAME = '<%= cfn_s3_bucket %>'

SECRET_KEY = '<%= cfn_secret_key %>'
AWS_ACCESS_KEY_ID = '<%= cfn_aws_key %>'
AWS_SECRET_ACCESS_KEY = '<%= cfn_aws_secret_key %>'
```

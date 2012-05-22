Puppet Nginx Module
===================

Module for configuring Nginx and virtual hosts.

Tested on Debian GNU/Linux 6.0 Squeeze and Ubuntu 10.4 LTS with
Puppet 2.6. Patches for other operating systems welcome.

This module can be used to serve both static sites and
proxy to backend application servers while serving static
media through Nginx.


Installation
------------

Clone this repo to a nginx directory under your Puppet
modules directory:

    git clone git://github.com/uggedal/puppet-module-nginx.git nginx

If you don't have a Puppet Master you can create a manifest file
based on the notes below and run Puppet in stand-alone mode
providing the module directory you cloned this repo to:

    puppet apply --modulepath=modules test_nginx.pp


Usage
-----

To install and configure Nginx, include the module:

    include nginx

You can override defaults in the Nginx config by including
the module with this special syntax:

    class { nginx: workers => 4 }

Setting up virtual hosts is done with the nginx::site resource:

    nginx::site { "home":
      domain => "uggedal.com",
      aliases => ["www.uggedal.com", "ugg.is"],
      default_vhost => true,
      root => "/var/www/home",
    }

If you use a static site generator which needs requests to /some-slug
rewritten to the actual /some-slug.html file:

    nginx::site { "journal":
      domain => "journal.uggedal.com",
      rewrite_missing_html_extension => true,
      root => "/var/www/journal",
    }

You can provide IP addresses or unix sockets to backend application
servers which should be proxied to:

    nginx::site { "mediaqueri.es":
      domain => "mediaqueri.es",
      aliases => ["www.mediaqueri.es"],
      root => "/var/www/mediaqueri.es/static",
      upstreams => ["unix:/var/run/mediaqueri.es.sock"],
    }

Provide a URL media prefix and media root directory if you have a
media directory of static files which should be served directly by
Nginx and not by your application servers. These files will be
cached indefinitely:

    nginx::site { "mediaqueri.es":
      domain => "mediaqueri.es",
      aliases => ["www.mediaqueri.es"],
      root => "/var/www/mediaqueri.es/static",
      mediaroot => "/var/www/mediaqueri.es/mediaqueries/static",
      mediaprefix => "/static",
      upstreams => ["unix:/var/run/mediaqueri.es.sock"],
    }

If you provide a relative `mediaroot` it will be relative to the
`root` directory:

    nginx::site { "journal":
      domain => "journal.uggedal.com",
      root => "/var/www/journal",
      mediaroot => "files/media",
      mediaprefix => "/media",
    }

You can also provide a owner and group which will be the owner of the
virtual host's root directory:

    nginx::site { "journal":
      domain => "journal.uggedal.com",
      rewrite_missing_html_extension => true,
      root => "/var/www/journal",
      owner => "www-mgr",
      group => "www-mgr",
    }

Enable SSL by using the `ssl` argument and providing the location of a
certificate and key. This will also redirect all HTTP requests to HTTPS:

    nginx::site { "home":
      domain => "uggedal.com",
      root => "/var/www/home",
      ssl => true,
      ssl_certificate => "/etc/nginx/cert/uggedal.com.pem",
      ssl_certificate_key => "/etc/nginx/cert/uggedal.com.key",
    }

    file {
      "/etc/nginx/cert/uggedal.com.pem":
        content => "...";
      "/etc/nginx/cert/uggedal.com.key":
        content => "...",
        mode => 600;
    }

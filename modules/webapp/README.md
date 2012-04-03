Puppet Webapp Module tying together Nginx, Gunicorn, and Monit
==============================================================

Helper module for easy configuration of Python WSGI applications
with Virtualenv, Gunicorn, Monit, and Nginx.

Tested on Debian GNU/Linux 6.0 Squeeze and Ubuntu 10.4 LTS with
Puppet 2.6. Patches for other operating systems welcome.


Installation
------------

Clone this repo and all its dependencies to respective directories under
your Puppet modules directory:

    git clone git://github.com/uggedal/puppet-module-webapp.git webapp
    git clone git://github.com/uggedal/puppet-module-python.git python
    git clone git://github.com/uggedal/puppet-module-monit.git monit
    git clone git://github.com/uggedal/puppet-module-nginx.git nginx

If you don't have a Puppet Master you can create a manifest file
based on the notes below and run Puppet in stand-alone mode
providing the module directory you cloned this repo to:

    puppet apply --modulepath=modules test_webapp.pp


Usage
-----

To install Python with development dependencies, Virtualenv, Gunicorn support
directories, Monit, and Nginx simply include the module:

    include webapp::python

You should provide an unprivileged user which will own the Virtualenv files
and Gunicorn processes by including the module with this special syntax:

    class { "webapp::python": owner => "www-mgr", group => "www-mgr" }

By default this module will look for source code under `/usr/local/src/$name`
and create virtualenvs under `/usr/local/venv`. To override this, provide
the following arguments on class instantiation:

    class { "webapp::python": owner => "www-mgr",
                              group => "www-mgr",
                              src_root => "/home/www-mgr/src",
                              venv_root => "/home/www-mgr/venv",
    }

You can also provide Nginx and Monit specific settings:

    class { "webapp::python": owner => "www-mgr",
                              group => "www-mgr",
                              src_root => "/home/www-mgr/src",
                              venv_root => "/home/www-mgr/venv",
                              nginx_workers => 2,
                              monit_admin => "eivind@uggedal.com",
                              monit_interval => 30,
    }

Note that you'll need to define a global search path for the `exec`
resource to make the `webapp::python::instance` resource function
properly. This should ideally be placed in `manifests/site.pp`:

    Exec {
      path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    }

The most basic setup of a Nginx virtualhost, virtualenv, Gunicorn installation
inside the virtualenv, and Monit watching the Gunicorn processes:
    
    webapp::python::instance { "blog":
      domain => "blog.uggedal.com",
      wsgi_module => "blog:app",
    }

You should tweak how Monit is watching your Gunicorn process according to your
application:

    webapp::python::instance { "blog":
      domain => "blog.uggedal.com",
      wsgi_module => "blog:app",
      monit_memory_limit => 300, # In MB
      monit_cpu_limit => 50, # In %
    }

You can provide domain aliases which Nginx redirects to your main domain:

    webapp::python::instance { "blog":
      domain => "blog.uggedal.com",
      aliases => ["journal.uggedal.com"],
      wsgi_module => "blog:app",
    }

If your application is busy you can increase the amount of Gunicorn workers:

    webapp::python::instance { "blog":
      domain => "blog.uggedal.com",
      wsgi_module => "blog:app",
      workers => 4,
    }

Django applications does not use the `wsgi_module`, but are enabled by using
the `django` flag:

    webapp::python::instance { "cms":
      domain => "cms.uggedal.com",
      django => true,
    }

You can optionally provide a specific settings file to use with Django:

    webapp::python::instance { "cms":
      domain => "cms.uggedal.com",
      django => true,
      django_settings => "settings_production.py",
    }

Puppet can manage installation of requirements from a `requirements.txt`
inside your source directory:

    webapp::python::instance { "cms":
      domain => "cms.uggedal.com",
      django => true,
      requirements => true,
    }

If your requirements file isn't named `requirements.txt` you can provide
a name as well:

    webapp::python::instance { "cms":
      domain => "cms.uggedal.com",
      django => true,
      requirements => "requirements_production.txt",
    }

Provide a URL media prefix and media root directory if you have a
media directory of static files which should be served directly by
Nginx and not by your application servers. These files will be
cached indefinitely:

    webapp::python::instance { "cms":
      domain => "cms.uggedal.com",
      django => true,
      mediaprefix => "/media",
      mediaroot => "/usr/local/src/cms/media",
    }

If you provide a relative `mediaroot` it will be relative to the
`/var/www/$name` directory:

    webapp::python::instance { "blog":
      domain => "blog.uggedal.com",
      wsgi_module => "blog:app",
      mediaprefix => "/static",
      mediaroot => "files/static",
    }

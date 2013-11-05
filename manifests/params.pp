# Class:: gitlab::params
#
#
class gitlab::params {

  $git_user               = 'git'
  $git_home               = '/home/git'
  $git_email              = 'git@someserver.net'
  $git_comment            = 'GitLab'
  $gitlab_sources         = 'git://github.com/gitlabhq/gitlabhq.git'
  $gitlab_branch          = '6-2-stable'
  $gitlabshell_sources    = 'git://github.com/gitlabhq/gitlab-shell.git'
  $gitlabshell_branch     = 'v1.7.1'
  $gitlab_http_port       = '80'
  $gitlab_ssl_port        = '443'
  $gitlab_redishost       = 'localhost'
  $gitlab_redisport       = '6379'
  $gitlab_dbtype          = 'mysql'
  $gitlab_dbname          = 'gitladb'
  $gitlab_dbuser          = 'gitladbu'
  $gitlab_dbpwd           = 'changeme'
  $gitlab_dbhost          = 'localhost'
  $gitlab_dbport          = '3306'
  $gitlab_domain          = $::fqdn
  $gitlab_repodir         = $git_home
  $gitlab_ssl             = false
  $gitlab_ssl_cert        = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
  $gitlab_ssl_key         = '/etc/ssl/private/ssl-cert-snakeoil.key'
  $gitlab_ssl_self_signed = false
  $gitlab_projects        = '10'
  $gitlab_username_change = true
  $ldap_enabled           = false
  $ldap_host              = 'ldap.domain.com'
  $ldap_base              = 'dc=domain,dc=com'
  $ldap_uid               = 'uid'
  $ldap_port              = '636'
  $ldap_method            = 'ssl'
  $ldap_bind_dn           = ''
  $ldap_bind_password     = ''

  validate_absolute_path($git_home)
  validate_absolute_path($gitlab_ssl_cert)
  validate_absolute_path($gitlab_ssl_key)

  validate_bool($gitlab_ssl)
  validate_bool($gitlab_ssl_self_signed)
  validate_bool($gitlab_username_change)
  validate_bool($ldap_enabled)

  validate_string($git_user)
  validate_string($git_email)
  validate_string($git_comment)
  validate_string($gitlab_sources)
  validate_string($gitlab_branch)
  validate_string($gitlabshell_sources)
  validate_string($gitlabshell_branch)
  validate_string($gitlab_dbtype)
  validate_string($gitlab_dbname)
  validate_string($gitlab_dbuser)
  validate_string($gitlab_dbpwd)
  validate_string($gitlab_dbhost)
  validate_string($gitlab_dbport)
  validate_string($gitlab_projects)
  validate_string($ldap_host)
  validate_string($ldap_base)
  validate_string($ldap_uid)
  validate_string($ldap_port)
  validate_string($ldap_method)

  $gitlab_without_gems = $gitlab_dbtype ? {
    mysql   => 'postgres',
    pgsql   => 'mysql',
    default => '',
  }

  # determine pre-requisite packages
  case $::osfamily {
    'Debian': {
      # database packages
      $db_packages = $gitlab_dbtype ? {
        mysql => ['libmysql++-dev','libmysqlclient-dev'],
        pgsql => ['libpq-dev', 'postgresql-client'],
      }

      # system packages
      $system_packages = ['libicu-dev', 'python2.7','python-docutils',
                          'libxml2-dev', 'libxslt1-dev','python-dev']
    }
    'RedHat': {
      # database packages
      $db_packages = $gitlab_dbtype ? {
        mysql => ['mysql-devel'],
        pgsql => ['postgresql-devel'],
      }


      $system_packages = ['libicu-devel', 'perl-Time-HiRes','libxml2-devel',
                          'libxslt-devel','python-devel','libcurl-devel',
                          'readline-devel','openssl-devel','zlib-devel',
                          'libyaml-devel','patch','gcc-c++']
    }
    default: {
      err "${::osfamily} not supported yet"
    }
  }


  validate_array($system_packages)

  case $::osfamily {
    'Debian': {
      $install_gitlab_cmd = "bundle install --without development aws test ${gitlab::params::gitlab_without_gems} --deployment"
      $setup_gitlab_database_cmd = "/usr/bin/yes yes | bundle exec rake gitlab:setup RAILS_ENV=production"
      $install_gitlab_shell_cmd = "ruby ${gitlab::params::git_home}/gitlab-shell/bin/install"
      $ruby = "ruby"
      $bundle = "bundle"
    }
    'RedHat': {
      $install_gitlab_cmd = "scl enable ruby193 'bundle install --without development aws test ${gitlab::params::gitlab_without_gems} --deployment'"
      $setup_gitlab_database_cmd = "/usr/bin/yes yes | scl enable ruby193 'bundle exec rake gitlab:setup RAILS_ENV=production'"
      $install_gitlab_shell_cmd = "scl enable ruby193 'ruby ${gitlab::params::git_home}/gitlab-shell/bin/install'"
      $ruby = "scl enable ruby193 ruby"
      $bundle = "scl enable ruby193 bundle"
    }
  }

} # Class:: gitlab::params

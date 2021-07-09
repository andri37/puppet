$src_dir = '/usr/src'
$dokuwiki_archive = "${src_dir}/dokuwiki.tgz"
$dokuwiki_dir = "${src_dir}/dokuwiki-2020-07-29"

class development {
  package { 
    'vim':
      ensure =>  installed;
    'make':
      ensure =>  installed;
    'gcc':
      ensure =>  installed;
  }
}

class hosting {
  package { 
    'apache2':
      ensure =>  installed;
    'php7.3':
      ensure =>  installed;
  }
}

class configure {
  file {
    '/usr/src/dokuwiki.tgz':
      ensure => 'present',
      source => 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz',
  }

  exec {
    'dokuwiki::unarchive':
      cwd     => "${src_dir}",
      command => "tar xavf ${dokuwiki_archive}",
      creates => "${dokuwiki_dir}",
      path    => ['/bin'],
      require => File["${dokuwiki_archive}"],
  }

  file {
    "/var/www/${site_dir}":
      ensure  => 'directory',
      owner   => 'www-data',
      group   => 'www-data',
      # mode    => '0755',
      source  => "${dokuwiki_dir}",
      recurse => true;

    "/etc/apache2/sites-available/${site_dir}.conf":
      ensure  => present,
      content => template('/home/vagrant/puppet/template/site.conf.erb'),
      require => [Package['apache2'],
                File["/var/www/${site_dir}"]];
  }

  exec {
    'enable-vhost':
      command => "a2ensite ${site_dir}",
      path    => ['/usr/bin', '/usr/sbin'],
      require => [File["/etc/apache2/sites-available/${site_dir}.conf"],
                  Package['apache2']];
  }

  service {
    'apache2':
      ensure    => running,
      subscribe => Exec['enable-vhost'],
  }

  host {
    "${site_hostname}":
      ip => '127.0.0.1';
  }
}

node 'control' { 
  #include development
}

node 'server0' {
  $site_hostname = 'politique.wiki'
  $site_dir = 'politique-wiki'
  include hosting
  include configure

  $site_hostname = 'tajine.com'
  $site_dir = 'tajine.com'
  include hosting
  include configure
}

node 'server1' {
  $site_hostname = 'recettes.wiki'
  $site_dir = 'recettes-wiki'
  include hosting
  include configure
}

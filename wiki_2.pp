package {
  'apache2':
    ensure => present; 
  'php7.3':
    ensure => present;
}

file {'get dokuwiki':
  ensure   => 'directory',
  source   => 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz',
  path     => '/usr/src/dokuwiki.tgz',
}

#exec {'Download doc wiki':
#  command  => 'wget -O /usr/src/dokuwiki.tgz \
#  https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz',
#  path     => ['/usr/bin'],
#}

exec {
  'decompress file':
    cwd     => '/usr/src',
    command => 'tar xavf dokuwiki.tgz #&& mv dokuwiki-2020-07-29 dokuwiki',
    path    => '/usr/bin',
    before  => File['rename-dokuwiki'];
}

file {
  'rename-dokuwiki':
    ensure  => 'directory',
    source  => '/usr/src/dokuwiki-2020-07-29',
    path    => '/usr/src/dokuwiki';

  '/usr/src/dokuwiki-2020-07-29':
    ensure  => 'absent',
    purge   => true,
    recurse => true,
    force   => true,
    require => File['rename-dokuwiki'];
 
  '/var/www/recettes':
    ensure  => 'directory',
    owner   => 'www-data',
    mode    => '0755',
    source  => '/usr/src/dokuwiki/',
    recurse => true;

  '/var/www/politique':
    ensure  => 'directory',
    owner   => 'www-data',
    mode    => '0755',
    source  => '/usr/src/dokuwiki/',
    recurse => true;

  '/etc/apache2/sites-available/politique-wiki.conf':
    source  => '/etc/apache2/sites-available/000-default.conf';

  '/etc/apache2/sites-available/recettes-wiki.conf':
    source  => '/etc/apache2/sites-available/000-default.conf';
}

$port = '1080'
['politique-wiki','recettes-wiki'].each |String $site_name| {
exec {
  'conf-change-1':
    command => template('/site.conf.erb'),
    path    => '/etc/apache2/sites-available/${site_name}.conf';
 }
}

exec {
  'enable-vhost-1':
    command => 'a2ensite politique-wiki',
    path    => ['/usr/bin', '/usr/sbin'];

  'enable-vhost-2':
    command => 'a2ensite recettes-wiki',
    path    => ['/usr/bin', '/usr/sbin'];
}

service { 
  'apache2':
    ensure    => running,
    subscribe => [Exec['enable-vhost-1'],Exec['enable-vhost-2']], 
}

host { 
  'recettes-wiki':
    ip => '127.0.0.1';
  'politique-wiki':
    ip => '127.0.0.2';  
}

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
}

file {
  '/usr/src/dokuwiki-2020-07-29':
    ensure  => 'absent',
    purge   => true,
    recurse => true,
    force   => true,
    require => File['rename-dokuwiki'],
}

file { 
  '/var/www/recettes':
    ensure  => 'directory',
    owner   => 'www-data',
    mode    => '0755',
    source  => '/usr/src/dokuwiki/',
    recurse => true,    
}

file {
  '/var/www/politique':
    ensure  => 'directory',
    owner   => 'www-data',
    mode    => '0755',
    source  => '/usr/src/dokuwiki/',
    recurse => true,
}

file {
  '/etc/apache2/sites-available/politique-wiki.conf':
    source  => '/etc/apache2/sites-available/000-default.conf',
}

file {
  '/etc/apache2/sites-available/recettes-wiki.conf':
    source  => '/etc/apache2/sites-available/000-default.conf',
}

exec {
  'conf-change-1':
    command => 'sed -i \'s/html/politique-wiki/g\' /etc/apache2/sites-available/politique-wiki.conf && sed -i \'s/html/recettes-wiki/g\' /etc/apache2/sites-available/recettes-wiki.conf',
    path    => ['/usr/bin','/usr/sbin'],
}

exec {
  'conf-change-2':
    command => 'sed -i \'s/*:80/*:1080/g\' /etc/apache2/sites-available/politique-wiki.conf && sed -i \'s/*:80/*:1080/g\' /etc/apache2/sites-available/recettes-wiki.conf',
    path    => ['/usr/bin','/usr/sbin'],
}

exec { 
  'enable-vhost-1':
    command => 'a2ensite politique-wiki',
    path    => '/usr/bin',
}

exec {
  'enable-vhost-2':
    command => 'a2ensite recettes-wiki',
    path    => ['/usr/bin', '/usr/sbin'],
}

service { 
  'apache2':
    ensure    => running,
    subscribe => [Exec['enable-vhost-1'],Exec['enable-vhost-2']], 
}

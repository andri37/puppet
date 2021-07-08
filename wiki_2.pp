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

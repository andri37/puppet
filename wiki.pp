package {
  'apache2':
    ensure => present;
  'php7.3':
    ensure => present;
}

exec {'Download doc wiki':
  command  => '/usr/bin/wget -O /usr/src/dokuwiki.tgz \
  https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz',
}
exec {'decompress file':
  cwd      => '/usr/src',
  command  => 'tar xavf dokuwiki.tgz && mv dokuwiki-2020-07-29 dokuwiki',
  path     => ['/usr/bin'],
}

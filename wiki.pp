package {
  'apache2':
    ensure => present;
  'php7.3':
    ensure => present;
}

file {'get dokuwiki':
  ensure   => 'present',
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
    command => 'tar xavf dokuwiki.tgz && mv dokuwiki-2020-07-29 dokuwiki',
    path    => '/usr/bin';
 
  'remove tgz':
    cwd     => '/usr/src',
    path    => '/usr/bin',
    command => 'sudo rm -r dokuwiki.tgz';
}

file { '/tmp/hello':
  path  => '/tmp/hello',
  mode    => '0600',
  content => 'Hello World',
  owner   => 'root';
}

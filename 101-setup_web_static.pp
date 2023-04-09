# install nginx

exec { 'update':
  command => 'sudo apt-get update',
  path    => ['/usr/bin', '/bin'],
}

package { 'nginx':
  ensure  => 'installed',
  require => Exec['update'],
}

# create files drwxr-xr-x

exec { 'shared':
  command => 'mkdir -p /data/web_static/shared/',
  path    => ['/usr/bin', '/bin'],
}

exec { 'test':
  command => 'mkdir -p /data/web_static/releases/test/',
  path    => ['/usr/bin', '/bin'],
  require => Exec['shared'],
}

# html

file { '/data/web_static/releases/test/index.html':
  ensure  => file,
  content => "<html>\n\t<head>\n\t</head>\n\t<body>\n\t\tHolberton School\n\t</body>\n</html>\n",
  require => Exec['test'],
}

# create symbolic link

file { '/data/web_static/current':
  ensure  => link,
  target  => '/data/web_static/releases/test',
  require => Exec['test'],
}

# Change ownership and group of files.

exec { 'owner_group':
  command => 'chown -R ubuntu:ubuntu /data/',
  path    => ['/usr/bin', '/bin'],
  require => Exec['shared'],
}

# config

file_line { 'config_file':
  path    => '/etc/nginx/sites-available/default',
  line    => "\tlocation /hbnb_static {\n\t\talias /data/web_static/current/;\n\t}\n",
  after   => '^server {',
  require => Package['nginx'],
}

# start server.

exec { 'restart':
  command => 'sudo service nginx restart',
  path    => ['/usr/bin', '/bin'],
  require => File_line['config_file'],
}

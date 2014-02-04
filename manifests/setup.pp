class mysql::setup(
  $datadir = undef,
  $host    = undef,
  $port    = undef,
  $socket  = undef,
) {

  exec { 'wait-for-mysql':
    command     => "while ! /usr/bin/nc -z ${host} ${port}; do sleep 1; done",
    provider    => shell,
    timeout     => 30,
    refreshonly => true
  }

  ~>
  exec { 'mysql-tzinfo-to-sql':
    command     => "mysql_tzinfo_to_sql /usr/share/zoneinfo | \
      mysql -u root mysql -h${host} -P${port} -S${socket}",
    provider    => shell,
    creates     => "${datadir}/.tz_info_created",
    refreshonly => true
  }

  ~>
  exec { 'grant root user privileges':
    command     => "mysql -uroot --password='' -h${host} -P${port} -S${socket} \
      -e 'grant all privileges on *.* to \'root\'@\'localhost\''",
    unless      => "mysql -uroot -h${host} -P${port} \
      -e \"select * from mysql.user where User = 'root' and Host = 'localhost'\" \
      --password='' | grep root",
    provider    => shell,
    refreshonly => true
  }

}

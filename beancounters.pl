#!/usr/bin/perl
 
###############################################################################
# vzstats.pl
#
# this script reads /proc/user_beancounters on openvz HNs and VEs and displays
# the values in human-readable format (megabytes/kilobytes).
#
# The script can be distributed freely for everybody who finds it usable.
#
# Christian Anton <mail |_at_| christiananton.de> 2008-09-18
 
 
 
#open(BEANS,"/proc/user_beancounters");
open(BEANS,"cat /proc/user_beancounters | grep \" ${ARGV[0]}:\" -A 23  |");
chomp ($arch = `uname -m`);
 
sub check_maxulong {
	my $number = shift;
 
	if ($arch eq "x86_64") {
		if ($number == 9223372036854775807) {
			return 1;
		} else {
			return undef;
		}
	} else {
		if ($number == 2147483647) {
			return 1;
		} else {
			return undef;
		}
	}
}
 
sub recalc_bytes {
	my $bytes = shift;
 
	if (defined(&check_maxulong($bytes))) { return "unlimited"; }
 
	my $kbytes = $bytes / 1024;
	my $ret;
 
	# if over 1mb, show mb values
	if ($kbytes > 1024) {
		my $mbytes = $kbytes / 1024;
		$ret = sprintf("%.2f", $mbytes) . " mb";
		return $ret;
	} else {
		$ret = sprintf("%.2f", $kbytes) . " kb";
		return $ret;
	}
}
 
sub recalc_pages {
	my $pages = shift;
 
	if ($pages == 0) { return "0"; }
	if (defined(&check_maxulong($pages))) { return "unlimited"; }
 
	my $kbytes = $pages * 4;
	my $ret;
 
	if ($kbytes > 1024) {
		my $mbytes = $kbytes / 1024;
		$ret = sprintf("%.2f", $mbytes) . " mb";
		return $ret;
	} else {
		$ret = sprintf("%.2f", $kbytes) . " kb";
		return $ret;
	}
}
 
sub recalc_nothing {
	my $number = shift;
	if (defined(&check_maxulong($number))) { return "unlimited"; }
 
	return $number;
}
 
sub printline {
	my $mode = shift; # 0=normal, 1=bytes, 2=pages
	my $ident = shift;
	my $held = shift;
	my $maxheld = shift;
	my $barrier = shift;
	my $limit = shift;
	my $failcnt = shift;
 
	if ($mode == 0) {
		printf ("%-15s",$ident);
		printf ("%18s",&recalc_nothing($held));
		printf ("%21s",&recalc_nothing($maxheld));
		printf ("%21s",&recalc_nothing($barrier));
		printf ("%21s",&recalc_nothing($limit));
		printf ("%21s",$failcnt);
		print "\n";
	} elsif ($mode == 1) {
		printf ("%-15s",$ident);
		printf ("%18s",&recalc_bytes($held));
		printf ("%21s",&recalc_bytes($maxheld));
		printf ("%21s",&recalc_bytes($barrier));
		printf ("%21s",&recalc_bytes($limit));
		printf ("%21s",$failcnt);
		print "\n";
	} elsif ($mode == 2) {
		printf ("%-15s",$ident);
		printf ("%18s",&recalc_pages($held));
		printf ("%21s",&recalc_pages($maxheld));
		printf ("%21s",&recalc_pages($barrier));
		printf ("%21s",&recalc_pages($limit));
		printf ("%21s",$failcnt);
		print "\n";
	}
}
 
sub work_line {
	my $line = shift;
	my $ident = $line;
	my $held = $line;
	my $maxheld = $line;
	my $barrier = $line;
	my $limit = $line;
	my $failcnt = $line;
 
 
 
	$ident =~ s/^\s+(\w+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)$/$1/;
	$held =~ s/^\s+(\w+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)$/$2/;
	$maxheld =~ s/^\s+(\w+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)$/$3/;
	$barrier =~ s/^\s+(\w+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)$/$4/;
	$limit =~ s/^\s+(\w+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)$/$5/;
	$failcnt =~ s/^\s+(\w+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)$/$6/;
 
	# 0=normal, 1=bytes, 2=pages
	if ($ident eq "dummy") {
		# do nothing, skip this line
	} elsif ($ident =~ /pages/) {
		&printline(2,$ident,$held,$maxheld,$barrier,$limit,$failcnt);
	} elsif ($ident =~ /^num/) {
		&printline(0,$ident,$held,$maxheld,$barrier,$limit,$failcnt);
	} else {
		&printline(1,$ident,$held,$maxheld,$barrier,$limit,$failcnt);
	}
 
}
 
sub print_header {
	my $uid = shift;
 
	print "#####################################################################################################################\n";
	print "BEANS FOR UID $uid\n";
	print "resource                     held              maxheld              barrier                limit              failcnt\n";
}
 
# now eat your beans baby
while (<BEANS>) {
	chomp($line = $_);
 
	# skip processing of headline
	if ($line =~ /^\s+uid/) {
		# do nothing, skip this
	} elsif ($line =~ /^Ver/) {
		# do nothing, skip this
	} elsif ($line =~ /^\s+\d+:\s+kmem/) {
		$uid = $line;
		$line =~ s/^(\s+)(\d+):/$1/;
		$uid =~ s/^(\s+)(\d+):.*$/$2/;
		&print_header($uid);
		&work_line($line);
	} else {
		&work_line($line);
	}
}
 
close(BEANS);

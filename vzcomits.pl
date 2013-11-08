#!/usr/bin/perl
 
##############################################################################
# vzcomits.pl
#
# this script reads /proc/user_beancounters on openvz HNs and VEs and displays
# the values in human-readable format (megabytes/kilobytes).
#
# The script can be distributed freely for everybody who finds it usable.
#
# Christian Anton <mail |_at_| christiananton.de> 2008-09-18
#
# modified by PVCE Andreas Neuhold <nean[at]hd-recording[dot]at> for additional advanced calculations 
#
 
my %beancounters;
my %sumbeancounters;
my %calc;
 
my $ram=$1 if (qx(free -b) =~ /.*Mem:\s*(\d+)\s*/);
my $swap=$1 if (qx(free -b) =~ /.*Swap:\s*(\d+)\s*/);
 
 
open(BEANS,"/proc/user_beancounters");
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
	my $cid = shift;
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
 
	# save everything in hashes
	$beancounters{$cid}{$ident}{"held"}=$held;
	$beancounters{$cid}{$ident}{"maxheld"}=$maxheld;
	$beancounters{$cid}{$ident}{"bar"}=$barrier;
	$beancounters{$cid}{$ident}{"lim"}=$limit;
	$beancounters{$cid}{$ident}{"failcnt"}=$failcnt;
 
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
	my $cid = shift;
 
	print "\n########################################################################\n";
	print "CID $cid\n";
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
		$cid = $line;
		$line =~ s/^(\s+)(\d+):/$1/;
		$cid =~ s/^(\s+)(\d+):.*$/$2/;
 
		&print_header($cid);
		&work_line($cid,$line);
 
	} else {
		&work_line($cid,$line);
 
	}
}
 
close(BEANS);

print "########################################################################\n\n";
print "Total RAM: $ram \nTotal SWAP: $swap\n\n"; 
 
# summarize all values of all containers
foreach my $cid (keys %beancounters) {
	if ($cid > 0 ) {
		#print "\n$cid :\n";
		foreach my $ident (keys %{$beancounters{$cid}}) {
			foreach my $stat (keys %{$beancounters{$cid}{$ident}}) {
				# summarize all values of all containers
				$sumbeancounters{$ident}{$stat} += $beancounters{$cid}{$ident}{$stat};
 
				# summarize all socket buffers
				$sumbeancounters{"buf"}{$stat} += $beancounters{$cid}{$ident}{$stat} if ($ident =~ /.*buf/i);
			}
		}
		# checks
		print "WARNING! CID $cid: numiptent should not be greater than 200-300!\n vzvtl set --numiptent 200:200\n" if ($beancounters{$cid}{"numiptent"}{"lim"} > 200);
		print "WARNING! CID $cid: numsiginfo hould not be greater than 1024!\n vzvtl set --numsiginfo 1024:1024\n" if ($beancounters{$cid}{"numsiginfo"}{"lim"} > 1024);
		print "WARNING! CID $cid: kmemsize barrier to small or numproc to high!\n $beancounters{$cid}{'kmemsize'}{'bar'} > (40960*$beancounters{$cid}{'numproc'}{'held'}+$beancounters{$cid}{'dcachesize'}{'lim'})\n" if ($beancounters{$cid}{"kmemsize"}{"bar"} < (40960*$beancounters{$cid}{"numproc"}{"held"}+$beancounters{$cid}{"dcachesize"}{"lim"}));
		print "WARNING! CID $cid: tcpsndbuf to small or numtcpsock to high!\n($beancounters{$cid}{'tcpsndbuf'}{'lim'}-$beancounters{$cid}{'tcpsndbuf'}{'bar'}) > (2560*$beancounters{$cid}{'numtcpsock'}{'maxheld'})\n" if (($beancounters{$cid}{"tcpsndbuf"}{"lim"}-$beancounters{$cid}{"tcpsndbuf"}{"bar"}) < (2560*$beancounters{$cid}{"numtcpsock"}{"maxheld"}));
		print "WARNING! CID $cid: othersockbuf to small or numothersock to high!\n ($beancounters{$cid}{'othersockbuf'}{'lim'}-$beancounters{$cid}{'othersockbuf'}{'bar'}) > (2560*$beancounters{$cid}{'numothersock'}{'maxheld'})\n" if (($beancounters{$cid}{"othersockbuf"}{"lim"}-$beancounters{$cid}{"othersockbuf"}{"bar"}) < (2560*$beancounters{$cid}{"numothersock"}{"maxheld"}));
 
	}
 
 
}
#print "########################################################################\n\n";
 

 
$calc{"lowmem"}{"util"}=(($sumbeancounters{"kmemsize"}{"held"}+$sumbeancounters{"buf"}{"held"})/($ram*0.4))*100;
$calc{"lowmem"}{"maxutil"}=(($sumbeancounters{"kmemsize"}{"maxheld"}+$sumbeancounters{"buf"}{"maxheld"})/($ram*0.4))*100;
$calc{"lowmem"}{"bar"}=(($sumbeancounters{"kmemsize"}{"bar"}+$sumbeancounters{"buf"}{"bar"})/($ram*0.4))*100;
$calc{"lowmem"}{"comit"}=(($sumbeancounters{"kmemsize"}{"lim"}+$sumbeancounters{"buf"}{"lim"})/($ram*0.4))*100;
$calc{"lowmem"}{"limit"}=(($ram*0.4)/(1024*1024));
 
printf("lowmem current utilization: %.2f%\n", $calc{"lowmem"}{"util"});
printf("lowmem maximum utilization: %.2f%\n", $calc{"lowmem"}{"maxutil"});
printf("lowmem barrier: %.2f%\n", $calc{"lowmem"}{"bar"});
printf("lowmem commitment: %.2f%\n", $calc{"lowmem"}{"comit"});
printf("lowmem limit: %.2fmb\n", $calc{'lowmem'}{'limit'});
 
 
 
$calc{"oomguarpages"}{"min"}=(($ram/($ram+$swap))*100);
$calc{"oomguarpages"}{"max"}=((($ram+($swap*0.5))/($ram+$swap))*100);
$calc{"oomguarpages"}{"util"}=((($sumbeancounters{"oomguarpages"}{"held"}*4096)+$sumbeancounters{"buf"}{"held"})/($ram+$swap))*100;
$calc{"oomguarpages"}{"comit"}=((($sumbeancounters{"oomguarpages"}{"bar"}*4096)+$sumbeancounters{"buf"}{"lim"})/($ram+$swap))*100;
 
printf "\noomguarpages utilization can be between %.2f% and %.2f%\n", $calc{'oomguarpages'}{'min'}, $calc{'oomguarpages'}{'max'};
printf("oomguarpages current utilization: %.2f%\n", $calc{"oomguarpages"}{"util"});
printf("oomguarpages commitment (80-100%): %.2f%\n", $calc{"oomguarpages"}{"comit"});
 
 
 
$calc{"privvmpages"}{"min"}=(($ram/($ram+$swap))*100);
$calc{"privvmpages"}{"max"}=($ram*0.6)/(1024*1024);
$calc{"privvmpages"}{"util"}=((($sumbeancounters{"privvmpages"}{"held"}*4096)+$sumbeancounters{"buf"}{"held"})/($ram+$swap))*100;
$calc{"vmguarpages"}{"comit"}=((($sumbeancounters{"vmguarpages"}{"bar"}*4096)+$sumbeancounters{"buf"}{"lim"})/($ram+$swap))*100;
$calc{"privvmpages"}{"lim"}=((($sumbeancounters{"privvmpages"}{"lim"}*4096)+$sumbeancounters{"buf"}{"lim"})/($ram+$swap))*100;
 
printf("\nprivvmpages of a single container should not be higher than: %.2fmb\n", $calc{'privvmpages'}{'max'});
printf("allocated memory (privvmpages) current utilization: %.2f%\n", $calc{"privvmpages"}{"util"});
printf("allocation (privvmpages) limit: %.2f%\n", $calc{"privvmpages"}{"lim"});
printf("allocation memory guarantee (vmguarpages <100%): %.2f%\n", $calc{"vmguarpages"}{"comit"});
 
# numiptent 200-300
 
 
print "\n########################################################################\n\n";
 
 

#EOF

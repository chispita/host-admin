#!/usr/bin/perl -w
###############################################################################
#                                                                             #
# checkds v. 1.0                                                              #
# Check if deamons are running as they should, otherwise take action.         #
#                                                                             #
# Copyright (C) 2000  Martin B. Jespersen                                     #
#                                                                             #
# This program is free software; you can redistribute it and/or               #
# modify it under the terms of the GNU General Public License                 #
# as published by the Free Software Foundation.                               #
#                                                                             #
# This program is distributed in the hope that it will be useful,             # 
# but WITHOUT ANY WARRANTY; without even the implied warranty of              # 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               # 
# GNU General Public License for more details.                                #
#                                                                             #
###############################################################################


######################################
##  first we set up default values  ##
######################################

## what is our name?
$0 =~ /\/*([^\/]*)$/;
my $PROG_NAME = $1;

## Path to configuration file
my $CONF_FILE="/usr/local/admin/checkds/checkds.conf";

## Where is pidof?
my $PIDOF_CMD = "/sbin/pidof";

## Where is logger located
## Cambiado a fichero de log. queru@queru.org 2005.
my $LOG_FILE = "/var/log/admin/checkds.log";

## Where is sendmail?
my $SENDMAIL_CMD = "/usr/sbin/sendmail";

## who should we send from?
my $MAIL_SENDER=$PROG_NAME;

## what should the subject be?
my $MAIL_SUBJECT="$PROG_NAME Alert!";

## what mail account should we alert to?
my $MAIL_RECEIVER = "root";

######################################

#######################################
##  Lets see what Parameters we got  ##
#######################################

for(@ARGV) {
	if(/^\-\-help$/) {
		&display_help and exit;
	}
	elsif(/^\-\-debug$/) {
		$DEBUG=1;
		$NO_MAIL=1;
		$NO_LOG=1;
		$NO_RESTART=1;
	}
	elsif(/^\-\-no\-log$/) {
		$NO_LOG=1;
	}
	elsif(/^\-\-no\-mail$/) {
		$NO_MAIL=1;
	}
	elsif(/^\-\-no\-restart$/) {
		$NO_RESTART=1;
	}
	elsif(/^\-\-conf\-file\=(.*)$/) {
		$FOUND_CONF_FILE=$1;
	}
	elsif(/^\-\-mail\-to\=(.*)$/) {
		$FOUND_MAIL_RECEIVER=$1;
	}	
}

$CONF_FILE= $FOUND_CONF_FILE if $FOUND_CONF_FILE;
$MAIL_RECEIVER = $FOUND_MAIL_RECEIVER if $FOUND_MAIL_RECEIVER;
#######################################

#############################################
##  Lets see if we can find a config file  ##
#############################################

unless(-e $CONF_FILE) {
	print STDERR "No config file found!\nTry $PROG_NAME --help for details.\n";
	exit;
}

my $checks = [];
my $conf_found_label=0;
my $conf_found_daemon=0;
my $conf_found_cmd=0;
my $this_daemon={};
open CONFIG, "<$CONF_FILE";
print "Parsing config file...\n" if $DEBUG;
while(<CONFIG>) {
	chomp;
	next if /^\s*#|^\s*$/; # we igonre blæank lines and lines starting with #
	if(/^\s*\[(.*)\]/) {
		&display_config_error and exit if $conf_found_label && !$conf_found_daemon && !$conf_found_cmd;
		$conf_found_label=1;
		$this_daemon->{label}=$1;
		print "Found label: $1\n" if $DEBUG;
	}
	elsif(/^\s*daemon\s*=\s*(.*)/) {
		&display_config_error and exit unless $conf_found_label && !$conf_found_daemon;
		$conf_found_daemon=1;
		$this_daemon->{daemon}=$1;		
		print "Found daemon: $1\n" if $DEBUG;
	}
	elsif(/^\s*cmd\s*=\s*(.*)/) {
		&display_config_error and exit unless $conf_found_label && !$conf_found_cmd;
		$conf_found_cmd=1;
		$this_daemon->{cmd}=$1;		
		print "Found cmd: $1\n" if $DEBUG;
	}
	if($conf_found_label && $conf_found_daemon && $conf_found_cmd) {
		$checks->[++$#{$checks}] = {%{$this_daemon}};
		$conf_found_label = $conf_found_daemon = $conf_found_cmd = 0;
	}
}
&display_config_error and exit if $conf_found_label;
close CONFIG;

#############################################

########################################
##  Ok, time to run the actual check  ##
########################################

log_it("info","Running check on ".($#{$checks}+1)." daemons");
for (@{$checks}) {
	print STDERR "Running check for $_->{label}...\n" if $DEBUG;
	next if check($_->{daemon});
	my $mail_msg= "$_->{label} ";
	my $log_msg="$_->{label} is not running!";
	unless($NO_RESTART) {
		system $_->{cmd};
		$log_msg.=" Trying to start it...";
		sleep 5;
		if(!check($_->{daemon})) {
			$log_msg.=" Failed :-(";
			$mail_msg.= "is not running, and could not be restarted automatically.";
		}
		else {
			$log_msg.=" Succeded :-)";
			$mail_msg.= "has been restarted automatically, since it was not running.";	
		}
	}
	log_it("alert",$log_msg);
	mail_admin($mail_msg);
}

########################################

###############################################################################

sub display_config_error {
	print STDERR "Syntax error in config file!\nTry $PROG_NAME --help for details.\n";
}

###############################################################################
# 1. param: the daemon to check for, this should be the name of the binary

sub check {
	$pid = `$PIDOF_CMD -s $_[0]`;
	return $pid =~ /^[0-9]+$/;
}

###############################################################################
# 1. param: syslog priority
# 2. param: syslog message

sub log_it {
	print STDERR "$_[1]\n" if $DEBUG;
	return if $NO_LOG;
	open LOG, ">> $LOG_FILE" and
	print "$_[0] $_[1] $PROG_NAME" and
	close LOG or 
	mail_admin("Fallo al escribir en $LOG_FILE: $!") and 
	die "Fallo al escribir en $LOG_FILE: $!";
}

###############################################################################
# 1. param: Message to send

sub mail_admin {
	my $mail = "From: $MAIL_SENDER <>\nTo: $MAIL_RECEIVER\nSubject: $MAIL_SUBJECT\nX-Priority: 1\n\n$_[0]\n";
	print STDERR $mail if $DEBUG; 
	return if $NO_MAIL;
	open SENDMAIL, "| $SENDMAIL_CMD -t" and
	print SENDMAIL $mail and
	close SENDMAIL	or 
	log_it("alert","Failed to send alert mail to $MAIL_SENDER: $!") and 
	die "Failed to send alert mail to $MAIL_SENDER: $!";
}

###############################################################################

sub display_help {
print <<END;

Usage: $PROG_NAME [options] 
Options:
  --help                         Display this information.

  --debug                        Print debug messages to stderr.
                                 Automatically sets all --no-* parameters.

  --no-restart                   Do not try to restart daemons that are found not to be running.
  --no-log                       Do not write to syslog.
  --no-mail                      Do not send mail alerts.
                                 Ignores --mail-to parameter.

  --mail-to=<address>            Specifies which email address alerts should be sent to.
                                 Default is: $MAIL_RECEIVER

  --conf-file=</path/to/file>    Specifies where the config file is found.
                                 Default is: $CONF_FILE

The config file should be on the following form:

  [label of daemon 1]
  daemon = name of daemon 1
  cmd = command to start daemon 1 if it is not running

  [label of daemon 2]
  ...

The label is what will show up in mails and logs.
The daemon is the binary file itself, excluding path, for example for apache this would be: httpd
The cmd is the command to start thge daemon, for example for apache this could be: apachectl start

END

}

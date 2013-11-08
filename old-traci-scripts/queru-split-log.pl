#!/usr/bin/perl

## Heavily modified by Jean-Michel Dault <jmdault@mandrakesoft.com>
## for use with in the Avanced Extranet Server.
## This script can now be used with the CustomLogs directive, with a pipe.
## When in combination with SetEnv VLOG <path>, it will write the log file
## in the right place. Also, it splits the log automatically with a year
## and month prefix. Finally, we open and re-close the logfile for every
## log entry. It is slower, but it permits us to check for symlinks, and
## flush the buffers so everything is realtime and we don't lose any entry.


#
# This script will take a combined Web server access
# log file and break its contents into separate files.
# It assumes that the first field of each line is the
# virtual host identity (put there by "%v"), and that
# the logfiles should be named that+".log" in the current
# directory.
#
# The combined log file is read from stdin. Records read
# will be appended to any existing log files.
#

use POSIX qw(strftime);

$errorlog="/var/log/apache2/queru-split-log.error.log";
$logs="/var/log/apache2";

while (<STDIN>) {
    #
    # Get the first token from the log record; it's the
    # identity of the virtual host to which the record
    # applies.
    #
    ($vhost) = split /\s/;
    #
    # Normalize the virtual host name to all lowercase.
    # If it's blank, the request was handled by the default
    # server, so supply a default name.  This shouldn't
    # happen, but caution rocks.
    #
    $vhost = lc ($vhost) or "access";
    #

    s/VLOG=(.*)[\/]*$//;
    $date=strftime("%m-%Y", localtime());
    $filename="${logs}/VLOG-${date}-${vhost}.log";
    if (-l $filename) {
    	open ERRORLOG ">>$errorlog";
    	print ERRORLOG "$filename es un enlace simbólico.\n";
   		close(ERRORLOG);
		die "File $filename is a symlink, writing too dangerous, dying!\n";
    }
    open LOGFILE, ">>$filename"
            or {
			    	open ERRORLOG ">>$errorlog";      		
            		print ERRORLOG "Can't open $logs/$filename";
            		close(ERRORLOG);
            		die "Can't open $logs/$filename";
            	}
    #
    # Strip off the first token (which may be null in the
    # case of the default server), and write the edited
    # record to the current log file.
    #
    s/^\S*\s+//;
    print LOGFILE $_;
    close(LOGFILE);
}

exit(0);

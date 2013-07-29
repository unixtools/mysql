#!/usr/bin/perl

use strict;
use Sys::Syslog;
use lib "/local/umrperl/libs";
use UMR::MySQLObject;

my $trace = 0;
my $name  = $0;
$name =~ s|.*/||go;

openlog $name, "ndelay,pid", "local0";

# Short timeout
alarm(5);
$SIG{ALARM} = \&handle_alarm;

my $db = new UMR::MySQLObject();

my $res = $db->SQL_OpenDatabase( "mysql", nopasswd => 1 );
if ( !$res ) {
    syslog( "LOG_INFO", "db connection/status failed" );
    exit(1);
}

if ( -e "/local/mysql/cluster" ) {
    if ($trace) {
        syslog( "LOG_INFO", "checking cluster status" );
    }

    my $qry = "show status like 'wsrep_local_state'";
    my ( $label, $cstat ) = $db->SQL_DoQuery($qry);
    if ( $cstat != 4 )    # synced
    {
        syslog( "LOG_INFO", "db connection/status failed - wsrep_local_state=$cstat" );
        exit(1);
    }
}

if ($trace) {
    syslog( "LOG_INFO", "db connection/status ok" );
}
exit(0);

sub handle_alarm {
    syslog( "LOG_INFO", "request timed out, exiting with failure" );
    exit(1);
}
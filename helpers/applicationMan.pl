#!/usr/bin/perl -w

my $maincont;

open( FH, "<", './controller/MainController.pm' ) or die print $!."\n";

while(<FH>){
	if( /\{##_(.*)/gi ){
		print $1;
	}
}

close(FH);

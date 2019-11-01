package DBManagTest;

use Test::Simple;
use Try::Tiny;
use DBI;

use lib ('/var/www/roleproto-frame/model');
use DBManag; 

sub new {
	my $type = shift;
	my $self = {
		#'modul' => MyTest->new() 
		'modul' => DBManag->new() 
	};

        bless $self, $type;
        $self;
}

sub testOpenDB(){
	my $self = shift;
	
	my @DBDATA = ('comeandgo', 'localhost', 'root', 't00rt00r');

	my $inst = $self->{'modul'};
	ok( $inst->openDB( \@DBDATA ) );	
}

sub testCheckDB(){
	my $self = shift;

	my @DBDATA = ('comeandgo', 'localhost', 'root', 't00rt00r');
	
	my $inst = $self->{'modul'};
	ok( $inst->checkDB( \@DBDATA ) );	
}

DBManagTest->new()->testOpenDB();
DBManagTest->new()->testCheckDB();

1;




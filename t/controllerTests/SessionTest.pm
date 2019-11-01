package SessionTest;

use Test::Simple; #tests => 2;
use Try::Tiny;

use lib ('/var/www/roleproto-frame/controller');


use Session; 
use DBManag;
use Data::Dumper;
use Users;

sub new {
	my $type = shift;
	
	my $self = {
		'modul' => Session->new() 
	};

        bless $self, $type;
        $self;
}

sub testDoLogin {
	my $self = shift;
	#my $cred = shift;

        my $inst = $self->{'modul'};
	
	#CHECK OUTPUTS TO SET eq OR ne OR == 
	warn( " >>>  " .$inst->doLogin( { 'req' => { 'user' => 'wrong@test.com', 'password' => 'wrongpw' } } ) );	
	warn( ">>> " . $inst->doLogin( { 'req' => { 'user' => 'user123@test.com', 'password' => 'badpw123ww' } } ) );	
	ok( $inst->doLogin( { 'req' => { 'user' => 'user123@test.com', 'password' => 'badpw123ww' } } ) );	
	ok( $inst->doLogin( { 'req' => { 'user' => 'wrong@test.com', 'password' => 'wrongpw' } } ) == 0 );	
}

#Run tests
#SessionTest->new()->testDoLogin( { 'req' => { 'user' => 'user123@test.com', 'password' => 'badpw123ww' } } );
SessionTest->new()->testDoLogin();

1;

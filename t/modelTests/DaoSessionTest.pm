package DaoSessionTest;

use Test::Simple; #tests => 2;
use Try::Tiny;
use DBI;

use lib ('/var/www/roleproto-frame');
use pojo::SearchPojo;

use lib ('/var/www/roleproto-frame/model');
#use MyTest;
use DaoSession; 
use DBManag;
use Data::Dumper;
use dto::Users;
use dto::Person;
use dto::Role_Ability;
use dto::Roles;

sub new {
	my $type = shift;
	
	my @DBDATA = ('comeandgo', 'localhost', 'root', 't00rt00r');
	my $DATA = { 'passw' => 'badpw123ww', 'username' => 'user123@test.com', 'table' => 'users', 'salt' => '2dxx' };

	#my $dbh = DBManag->new(\@DBDATA)->openDB( \@DBDATA );
	my $dbm = DBManag->new(\@DBDATA);
	$dbm->openDB();
	
	my $self = {
		#'modul' => MyTest->new() 
		'modul' => DaoSession->new( $dbm->accDbh() ) 
	};

        bless $self, $type;
        $self;
}


#sub testConcate {
#	my $self = shift;
#	ok( $self->{'modul'}->concate('a', 'b') eq 'abc' );
#	ok( $self->{'modul'}->concate('a', 'b') eq 'ab' );
#}


# P.S : Pretty bad was, that the db-instance wasn't delegate in DI manner as a param/arg, but it was instanced into procedural functions, on every place where it was necessary, which decrease the development-process in many ways, like using dbh->rollback for example, to emptying database after running some tests ... so every single function should be tested manually, which is opposite to the TDD. 

# Test all units of the session-modul
sub testSample(){
	my $self = shift;
	
	## FLAG FOR ROLLBACK
	my $sid = 1;

	# TODO put dto-instance as param instead $DATA, $dbh and adapt the code
	my $inst = $self->{'modul'};
	# Try-Catch resp.  evals already a part of the ok-function

	# ADD USER FIRST CAUSE OF FK person 2 users	
	#ok( $inst->addUser( Users->new( 'superuser@mail.com', 'badpw123ww') ) );
	#ok( $inst->addPerson( Person->new( 'Jimmy', 'Timmy', 'chiefprogrammer', 'superuser@mail.com' ) ) );
	#ok( $inst->addUser2Role( Roles->new5( 1 ), Users->new( 'superuser@mail.com', 'badpw123ww2') ) );
	
	#ok( $inst->readCreden( Users->new( 'user123@test.com', 'badpw123ww') ) == 1 ); 
	#ok( $inst->doLogin( $dbh ) );
	#ok ( $sid = $inst->doLogin2( Users->new( 'user123@test.com', 'badpw123ww' ) ) ); #print "qqqqqqqqqqqqqqqqqqqqqqq : " . $sid;
	
	#$sid = $inst->doLogin2( Users->new( 'user123@test.com', 'badpw123ww' ) );
	

	#print "qqqqqqqqqqqqqqqqqqqqqqq : " . $sid;
	#print "SID : " . Dumper $sid."\n\n";
	#ok( $inst->checkSessID( Users->new2( 'user123@test.com', $sid )->accSid($sid) ) );
	
	### TODO TDD MANNER-TESTS CAUSE UNITS DOESN'T EXIST YET, PROJECT-CONCEPTION
	# ok( $inst->logout( $dbh, "username=user123%40test.com;sid=$sid" ) );
	# ok( $inst->updCred( $dbh ) );
	# ok( $inst->delUser( $dbh ) );
	### END TODO 
	
	#ok( print Dumper $inst->insertRole( Roles->new3( "testuser3", "600" ) ) );
	#ok( print Dumper $inst->selRoles() );
	#ok( print Dumper $inst->selCompanies() );
	#ok( print Dumper $inst->listRfids() );
	#ok( print Dumper $inst->listSearchRes( SearchPojo->new2('%aa%')) );
	#ok( print Dumper $inst->selFuncsByRole( "admin" ) );
	#ok( $inst->adaptApplic( Role_Ability->new2("Funct44", "equals+lower"), Roles->new2("manager") ) );
	#ok( $inst->removeFuncFromRole( Role_Ability->new2("Funct44"), Roles->new2("manager") ) );
	# instead finally, which always gonna be run		
	if( $sid == 0 ){
		$inst->{'dbh'}->rollback;
	} else {
		
		$inst->{'dbh'}->commit;
	}
	#$inst->{'dbh'}->rollback;
	$inst->{'dbh'}->disconnect;	
}

#Run tests
DaoSessionTest->new()->testSample();

1;




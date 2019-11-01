package ServDelUser;
use Text::Xslate;
use Try::Tiny;
use Storable qw( freeze thaw );
use lib ('/var/www/roleproto-frame/model');

use dto::Person;
use dto::Users;
use dto::Roles;


use DaoSession;
use DBManag;

use Data::Dumper;
use JSON;
my @DBDATA = ('comeandgo', 'localhost', 'root', 't00rt00r');


my $DBDATA = ['comeandgo', 'localhost', 'root', 't00rt00r'];


#my $DATA = { 'passw' => 'badpw123ww', 'username' => 'user123@test.com', 'table' => 'users', 'salt' => '2dxx' };

#my $dbm = DBManag->new(\@DBDATA);
#$dbm->accDbh( $dbm->openDB() );


sub new {
	
	my $type = shift;
	my $rbac = shift;
	
	my $self = { 'rbac' => $rbac };
#	warn Dumper $self->{'rbac'}->{'buslInst'}; die("(((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((");
	bless $self, $type;
	
	my $dbm = DBManag->new(\@DBDATA);
	$dbm->openDB();

	$self->{'dbm'} = $dbm;
	
	$self;
}


sub delUser {
	
	my $self = shift;
	

	#my $DBDATA = ['comeandgo', 'localhost', 'root', 't00rt00r'];

	#my $dbh = DBI->connect( "DBI:mysql:database=$DBDATA->[0]:$DBDATA->[1]", $DBDATA->[2], $DBDATA->[3], { 'AutoCommit' => 0, 'RaiseError' => 1 } );

	my $dbh = $self->{'dbm'}->accDbh();

	my $req = $self->{'rbac'}->{'http'}->{'req'};
	
	my $type = "Content-type: application/json; charset=utf-8\n\n";
        print $type;

	my $usr = Users->new3( $req->{'email'} );
	

	#my $userRole = UserRole->new( $req->{'email'}, $req->{'role'} );
	#my $pers = Person->new( 'name', 'surname', 'position', 'email' );


	#my $frzUsr = freeze $usr;
	#my $frzPers = freeze $pers;

	#warn Dumper $frzPers . " ------------------------- ";warn ( "--------------------->>>>> :::::: " . $pers->accSurname() . " -- " . $pers->accPosition() );
	
	#print( JSON->new->utf8->encode( $frzPers ) );
	
	
	$ret = sub {

		my %vars;
		my @err;	
		my $daosess;
	
		my $dbh = $self->{'dbm'}->accDbh();
	
		my $usr2 = Users->new3( $self->{'rbac'}->{'http'}->{'req'}->{'email'});
		try {
			
			#my $logSucc = $busL->doLogin2( Users->new( 'user123@test.com', 'badpw123ww' ) );
			
			my $usr = Users->new2( $self->{'rbac'}->{'http'}->{'coo'}->{'user'}, $self->{'rbac'}->{'http'}->{'coo'}->{'sid'} );
			
			$daosess = DaoSession->new( $dbh );
			$daosess->chkSID( $daosess->checkSessID( $usr ) );			
			#$daosess = DaoSession->new( $dbh );
			#$daosess->addUser( $usr );
			#$daosess->addPerson( $pers );
			#my $lDto = $daosess->selRoles();

			#$self->{'rbac'}->{'buslInst'}->delUser( $usr );
			$daosess->delUser( $usr2 );
			warn "INTOOOOOO ADDDDDDDUUUUUUUUUUUUUUUUUUUUUUUUUUUUSERR";
	
			$dbh->commit();
		
		} catch {
			
			push( @err, $_ );
			warn "caught error: $_"; # not $@
			
			if( length ( $usr->accSid() ) > 1 ){
				$ret = "OKEY";
				#$usr->accEmail();
			} 
			$ret = 0;

			$dbh->rollback();


		} finally {
		
			print( JSON->new->utf8->encode( [ { 'errs' => join("," , @err) } ] ) );
		}	
	}->();

	1;
}


sub ajaxCheck {

	my $self = shift;
	my $http = shift;
	
	my $type = "Content-type: application/json; charset=utf-8\n\n";
        print $type;

	print( JSON->new->utf8->encode([ { myjsn => $http } ] ) );
	
	return 1;
	
}
#Test
#ajaxCheck();


1;

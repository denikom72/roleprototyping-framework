package ServRoleManager;
use Text::Xslate;
use Try::Tiny;
use Storable qw( freeze thaw );
use lib ('/var/www/roleproto-frame/model');

use dto::Roles;


use DaoSession;
use DBManag;

use Data::Dumper;
use JSON;
my @DBDATA = ('comeandgo', 'localhost', 'root', 't00rt00r');

sub new {
	
	my $type = shift;
	my $rbac = shift;
	
	my $self = { 'rbac' => $rbac };
	#warn Dumper $rbac; die("(((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((");
	bless $self, $type;
	
	my $dbm = DBManag->new(\@DBDATA);
	$dbm->openDB();

	$self->{'dbm'} = $dbm;
	
	$self;
}

sub roleMan {
	
	my $self = shift;

	my $dbh = $self->{'dbm'}->accDbh();
	my $type = "Content-type: application/json; charset=utf-8\n\n";
        print $type;

	#my $pers = Person->new( 'name', 'surname', 'position', 'email' );


	#my $frzUsr = freeze $usr;
	#my $frzPers = freeze $pers;

	warn  " ------------------------- ";
	#warn ( "--------------------->>>>> :::::: " . $pers->accSurname() . " -- " . $pers->accPosition() );
	#my $die = Dumper $self->{'rbac'};
	#die( " heeerrrrr --> : " . $die );
	#print( JSON->new->utf8->encode( $frzPers ) );
	
	
	$ret = sub {

		my %vars;
		my @err;	
		my $daosess;
		try {
			
			#my $logSucc = $busL->doLogin2( Users->new( 'user123@test.com', 'badpw123ww' ) );
				
			my $usr = Users->new2( $self->{'rbac'}->{'http'}->{'coo'}->{'user'}, $self->{'rbac'}->{'http'}->{'coo'}->{'sid'} );
			
			$daosess = DaoSession->new( $dbh );
			$daosess->chkSID( $daosess->checkSessID( $usr ) );			
			
			## TODO implement switch case and create enum fields "lower" and "equls+lower" fro the role_abil-table 
			if( lc $self->{'rbac'}->{'http'}->{'req'}->{'manRole'} eq 'add' ){			
				
					#die("ADDDDROOOOLLLLEEE");
					my $err = Dumper $self->{'rbac'};
					#warn( " ::::::::::::::::::::::::::::::: -------------- " . $err ); die();
					$daosess->addRole( Roles->new3( $self->{'rbac'}->{'http'}->{'req'}->{'rolename'}, $self->{'rbac'}->{'http'}->{'req'}->{'priority'} ) );
		
			} elsif( lc $self->{'rbac'}->{'http'}->{'req'}->{'manRole'} eq 'remove' ) {
				
					$daosess->delRole( Roles->new3( $self->{'rbac'}->{'http'}->{'req'}->{'rolename'}, $self->{'rbac'}->{'http'}->{'req'}->{'priority'} ) );
					
			}
		
			$dbh->commit();
		
		} catch {
			
			push( @err, $_ );
			warn "caught error: $_"; # not $@

			$dbh->rollback();

		} finally {
		
			print( JSON->new->utf8->encode( [ { 'errs' => join("," , @err) } ] ) );
		}	
	}->();

	1;
}

sub start {
	
	$self = shift;
	$self->manRole();
}

# TODO REMOVE FROM PRODUCTIVE VERSION CAUSE IT IS JUST AN AJAX-COMMUNICATION-TEST
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

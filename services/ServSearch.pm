package ServSearch;
use Text::Xslate;
use Try::Tiny;
use Storable qw( freeze thaw );

use lib('var/www/roleproto-frame');
use pojo::SearchPojo;


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

sub search {
	
	my $self = shift;
	

	#my $DBDATA = ['comeandgo', 'localhost', 'root', 't00rt00r'];

	#my $dbh = DBI->connect( "DBI:mysql:database=$DBDATA->[0]:$DBDATA->[1]", $DBDATA->[2], $DBDATA->[3], { 'AutoCommit' => 0, 'RaiseError' => 1 } );

	my $dbh = $self->{'dbm'}->accDbh();
	#my $err = Dumper $self->{'rbac'};
	#die( $err );
	#my $req = $self->{'rbac'}->{'http'}->{'req'};
	#my $req = $self->{'http'}->{'rbac'}->{'req'};
	
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

	my $searchPj = SearchPojo->new();	
	
	$ret = sub {

		my %vars;
		my @err;	
		my $daosess;
		
		try {
			
			#my $logSucc = $busL->doLogin2( Users->new( 'user123@test.com', 'badpw123ww' ) );
				
			#my $usr = Users->new2( $self->{'rbac'}->{'http'}->{'coo'}->{'user'}, $self->{'rbac'}->{'http'}->{'coo'}->{'sid'} );
			
			#$daosess = DaoSession->new( $dbh );
			
			#$daosess->chkSID( $daosess->checkSessID( $usr ) );			
			

			$daosess = $self->{'rbac'}->{'buslInst'};
			## TODO implement switch case and create enum fields "lower" and "equls+lower" fro the role_abil-table 
				
			#die("ADDDDROOOOLLLLEEE");
			my $rbac = $self->{'rbac'};
			#warn( " ::::::::::::::::::::::::::::::: -------------- " . Dumper $rbac->{'http'} ); die();
			#$searchPj->accSearch( $daosess->listSearchRes( SearchPojo->new('aa') ) );
			
			#print Dumper $daosess->listSearchRes( SearchPojo->new2( "%" . $rbac->{'http'}->{'req'}->{'keywords'} . "%" ) );
			my @JSON;

			map{
				push( @JSON, { "name" => $_->accName(), "surname" => $_->accSurname(), "rolename" => $_->accPosition(), "email" => $_->accEmail(), "role" => $_->accRole() } );
			}@{ $daosess->listSearchRes( SearchPojo->new2( "%" . $rbac->{'http'}->{'req'}->{'keywords'} . "%" ) ) };

			print JSON->new->utf8->encode( \@JSON );
			#$daosess->delRole( Roles->new3( $self->{'rbac'}->{'http'}->{'req'}->{'rolename'}, $self->{'rbac'}->{'http'}->{'req'}->{'priority'} ) );
					
			$dbh->commit();
		
		} catch {
			
			push( @err, $_ );
			warn "caught error: $_"; # not $@

			$dbh->rollback();

		} finally {
		
			print( JSON->new->utf8->encode( [ { 'errs' => join("," , @err) } ] ) ) if $#err > 0;
		}	
	}->();

	1;
}

sub start {
	
	$self = shift;
	$self->search();
	#$self->ajaxCheck()
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

package ServApplicationAdapt;
use Text::Xslate;
use Try::Tiny;
use Storable qw( freeze thaw );
use lib ('/var/www/roleproto-frame/model');

use dto::Role_Ability;
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

	bless $self, $type;
	
	my $dbm = DBManag->new(\@DBDATA);
	$dbm->openDB();

	$self->{'dbm'} = $dbm;
	
	$self;
}

sub adaptAppliConf {
	
	my $self = shift;
	

	my $dbh = $self->{'dbm'}->accDbh();

	my $req = $self->{'rbac'}->{'http'}->{'req'};
	
	my $type = "Content-type: application/json; charset=utf-8\n\n";
        print $type;
	
	$ret = sub {

		my %vars;
		my @err;	
		my $daosess;
		
		try {
			
			$daosess = DaoSession->new( $dbh );
			## TODO implement switch case and create enum fields "lower" and "equls+lower" from the role_abil-table 
			if( $self->{'rbac'}->{'http'}->{'req'}->{'action'} eq 'save' ){			
				map{
					$daosess->adaptApplic( Role_Ability->new2( [ split "_", $_ ]->[0], [ split "_", $_ ]->[1] ), Roles->new2( $req->{'selRole'} ) );
					
				} split( "-", $self->{'rbac'}->{'http'}->{'req'}->{'functionalities'} );
		
			} elsif( $self->{'rbac'}->{'http'}->{'req'}->{'action'} eq 'remove' ) {
				
				map{
					$daosess->removeFuncFromRole( Role_Ability->new2( [ split "_", $_ ]->[0], [ split "_", $_ ]->[1] ), Roles->new2( $req->{'selRole'} ) );
					
				} split( "-", $self->{'rbac'}->{'http'}->{'req'}->{'functionalities'} );
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
	$self->adaptAppliConf();
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

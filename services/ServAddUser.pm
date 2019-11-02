package ServAddUser;
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

$dbh = DBI->connect( "DBI:mysql:database=$DBDATA->[0]:$DBDATA->[1]", $DBDATA->[2], $DBDATA->[3], { 'AutoCommit' => 0, 'RaiseError' => 1 } );


sub new {
	my ( $type, $http ) = ( shift, shift );

	my $self = {};

	bless $self, $type;
	
	$self->{'dbm'} = DBManag->new(\@DBDATA);
	#$self->{'dbm'}->openDB();

	my $usr = Users->new2( $http->{'coo'}->{'user'}, $http->{'coo'}->{'sid'} );

	$self->{'sid'} = DaoSession->new( $self->{'dbm'}->accDbh() );
	warn 'WOOOOORRRRKKKKKKKKKS_________________________________________';
	$self->{'sid'}->chkSID( $self->{'sid'}->checkSessID( $usr ) );
	
	if( $self->{'sid'}->chkSID ){
				
		my @rbacList; 
				
		map {
			push( @rbacList, $_->[0] );
		} @{ $self->{'sid'}->rbac() };
				
		my %rbac = map { $_ => 1 } @rbacList;
		# same as
		# foreach my $item (@rbacList) { $rbac{$item} = 1 }
		# or
		# 
		# @hash{@key} = ();
						

		%vars = 
		(
	       		user => $usr->accEmail(),
			sid => $usr->accSid(),
			role => $self->{'sid'}->rbac()->[0],
			rbac => \%rbac 
	       	);
	} else {
		die('you have no right to use my verry special and wunderfull methods, okeeyyyy');
	}

	$self->{'http'} = $http;
	
	$self;
}

sub addUser {
	
	my $self = shift;
	
	my $dbh = $self->{'dbm'}->accDbh();

	my $req = $self->{'http'}->{'req'};
	
	my $type = "Content-type: application/json; charset=utf-8\n\n";
        print $type;

	my $usr = Users->new( $req->{'email'}, $req->{'password'} );
	
	my $pers = Person->new( $req->{'name'}, $req->{'surname'}, $req->{'position'}, $req->{'email'} );
	
	my $role = Roles->new2( $req->{'selRole'} );

	
	$ret = sub {

		my %vars;
		my @err;	
		my $daosess;
		
		try {
			
			$self->{'sid'}->addUser( $usr );
			$self->{'sid'}->addPerson( $pers );
	
			map{
				if( $_->accName() eq $role->accName() ){
					$role->accId( $_->accId() );
				}
			} @{ $self->{'sid'}->selRoles() };	
			
			$self->{'sid'}->addUser2Role( $role, $usr );
	
			$dbh->commit();
		
		} catch {
			
			push( @err, $_ );
			warn "caught error: $_"; # not $@
			
			if( length ( $usr->accSid() ) > 1 ){
				$ret = "OKEY";
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

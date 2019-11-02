package Session;
use Text::Xslate;
use Try::Tiny;

use lib ('/var/www/roleproto-frame/model');
use lib ('/var/www/roleproto-frame/model/dto');


use dto::Users;
use DaoSession;
use DBManag;

use Data::Dumper;

my @DBDATA = ('comeandgo', 'localhost', 'root', 't00rt00r');

sub new {
	my $type = shift;

	my $self = {};

	bless $self, $type;
	
	my $dbm = DBManag->new(\@DBDATA);
	$dbm->openDB();


	$self->{'dbm'} = $dbm;
	
	$self;
}

sub login {
        my $self = shift;

        print "Content-type: text/html; charset=utf-8\n\n";

        #print "TEST2 : " . $quer->{'bar'};

        my $tx = Text::Xslate->new ( syntax => 'TTerse' );

        %vars = (
                foo => 'World of logins'
        );

        # for files
        print $tx->render('/var/www/roleproto-frame/view/login.tx', \%vars);

}

sub listRoles {
	my $self = shift;
	# Cache result into a var, to not run the query behind it every time again
	$self->{'roles'} = $self->{'rbac'}->{'buslInst'}->selRoles();
	$self->{'roles'};
}

sub doLogin {
        my $self = shift;
	my $cred = shift;
	
	my $ret = 1;
        print "Content-type: text/html; charset=utf-8\n\n";

        my $tx = Text::Xslate->new ( syntax => 'TTerse' );
		
	my $usr = Users->new2( $cred->{'coo'}->{'user'}, $cred->{'coo'}->{'sid'} );
	warn Dumper $usr;
	warn('\n\n----------------\n\n');
	warn Dumper $cred;		
	
	$ret = sub {

		my %vars;
		
		try {
			
			$sid = DaoSession->new( $self->{'dbm'}->accDbh() );
			$sid->chkSID( $sid->checkSessID( $usr ) );
			
			$ret = $sid->chkSID();
			if( !$sid->chkSID() ){
				$ret = 0;
				#TODO : redirect to login site
				print "";
			} 
	
			$ret;
		} catch {
			warn "caught error: $_"; # not $@
			print "error: $_"; # not $@
	
			
			if( $sid->chkSID() ){
				$ret = "OKEY";
			}		
			$ret = 0;
		} finally {
			
		
		        if( $sid->chkSID() ){
				
				
				my $rfid = [];
				
				map {
					push ( $rfid, $_->accRfid() );
				} @{ $sid->listRfids() };
				
				my $comp = [];
				
				map {
					push ( $comp, $_->accName() );
				} @{ $sid->selCompanies() };

				
				my $roles = [];
				
				map {
					push ( $roles, [ $_->accName(), $_->accPriority() ] );
				} @{ $sid->selRoles() };

				my @rbacList; 
				
				map {
					push( @rbacList, $_->[0] );
				} @{ $sid->rbac() };
			
				warn Dumper \@rbacList; 
	
				my %rbac = map { $_ => 1 } @rbacList;
				
				warn Dumper \%rbac;
				# same as
				# foreach my $item (@rbacList) { $rbac{$item} = 1 }
				# or
				# 
				# @hash{@key} = ();
						

				%vars = 
				(
		               		user => $usr->accEmail(),
					sid => $usr->accSid(),
					role => $sid->rbac()->[0],
					rbac => \%rbac,
					roles => $roles, 
					companies => $comp, 
					rfids => $rfid 
			       	);


				print $tx->render('/var/www/roleproto-frame/view/doLogin.tx', \%vars);
			}
		}
	}->();

	return $ret;
}

1;

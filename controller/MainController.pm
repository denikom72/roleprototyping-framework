package MainController;
use Text::Xslate;
use Template::Tiny;

use lib('/var/www/roleproto-frame');
use model::DBManag;
use controller::Session;
use controller::ApplicationMan;
use services::ServSession;
use services::ServAddUser;
use services::ServDelUser;
use services::ServUpdUser;
use services::ServApplicationAdapt;
use services::ServRoleManager;
use services::ServSearch;

use Data::Dumper; 

sub test {
	my $self = shift;
	
        print "Content-type: text/html; charset=utf-8\n\n";
	print "MAIN CONTROLLER TEST SUCCESSFULL";
}

sub chkRbac {
	my $self = {};
	my $http = shift;	
	my @DBDATA = ('comeandgo', 'localhost', 'root', 't00rt00r');

	my %rbac;
	
	$self->{'dbm'} = DBManag->new(\@DBDATA);


	my $usr = Users->new2( $http->{'coo'}->{'user'}, $http->{'coo'}->{'sid'} );

	$self->{'sid'} = DaoSession->new( $self->{'dbm'}->accDbh() );
	$self->{'sid'}->chkSID( $self->{'sid'}->checkSessID( $usr ) );

	
	if( $self->{'sid'}->chkSID ){
				
				
		my @rbacList; 
				
		map {
			push( @rbacList, $_->[0] );
		} @{ $self->{'sid'}->rbac() };
		
		%rbac = map { $_ => 1 } @rbacList;


		# same as
		# foreach my $item (@rbacList) { $rbac{$item} = 1 }
		# or
		# 
		# @hash{@key} = ();
						

		$self->{'vars'} = {
  
	       		http => $http,
			user => $usr->accEmail(),
			sid => $usr->accSid(),
			role => $self->{'sid'}->rbac()->[0],
			dbh => $self->{'dbh'},
			buslInst => $self->{'sid'},
			rbac => \%rbac 
	       	};
	} else {
		die('you have no right to use my verry special and wunderfull methods, okeeyyyy');
	}
	$self->{'vars'};
	
}

# TODO SHOULD BE PRIVATE
sub login {
	# REQUEST_URL, QUERY_STRING, COOKIE
	
	my $http = shift;
	my $sess = Session->new()->login();
}


sub applicationMan {
	# REQUEST_URL, QUERY_STRING, COOKIE
	
	my $http = shift;
	
	my $rbac = chkRbac( $http );
	my $rbc = $rbac->{'rbac'};

	if ( $rbc->{'all'} || $rbc->{'root'} ){	
	
		my $sess = ApplicationMan->new($rbac)->start();
	}
}


sub applicationAdapter {
	# REQUEST_URL, QUERY_STRING, COOKIE
	
	my $http = shift;
	
	my $rbac = chkRbac( $http );
	my $rbc = $rbac->{'rbac'};

	if ( $rbc->{'all'} || $rbc->{'root'} ){	
	
		my $sess = ServApplicationAdapt->new($rbac)->start();
	}
}



sub doLogin {
	
	my $http = shift;
	
	my $rbac = chkRbac( $http );
	my $rbc = $rbac->{'rbac'};

	if ( $rbc->{'all'} || $rbc->{'doLogin'} ){	

		my $sess = Session->new()->doLogin($http);
	}
}


sub servLogin {
	my $http = shift;
	my $servLog = ServSession->new()->doLogin($http);
	#my $servLog = ServSession->new()->ajaxCheck($http);
}



sub servAddUser {
	my $http = shift;

	my $rbac = chkRbac( $http );
	my $rbc = $rbac->{'rbac'};
	
	if( $rbc->{'all'} || $rbc->{'servAddUser'} ){ 

		##_add_new_application_user
		my $servLog = ServAddUser->new($http)->addUser();
	}
}

sub servUpdUser {
	my $http = shift;

	my $rbac = chkRbac( $http );
	my $rbc = $rbac->{'rbac'};
	
	if( $rbc->{'all'} || $rbc->{'servUpdUser'} ){##_add_new_application_user
		
		my $servLog = ServUpdUser->new($rbac)->delUser();
	}
}

sub servDelUser {
	my $http = shift;

	my $rbac = chkRbac( $http );
	my $rbc = $rbac->{'rbac'};
	
	if( $rbc->{'all'} || $rbc->{'servDelUser'} ){##_add_new_application_user
		
		my $servLog = ServDelUser->new($rbac)->delUser();
	}
}



sub servRoleManager {
	my $http = shift;

	my $rbac = chkRbac( $http );
	my $rbc = $rbac->{'rbac'};
	if( $rbc->{'all'} || $rbc->{'servRoleManager'} ){
		
		my $servRoleMan = ServRoleManager->new($rbac)->roleMan();
	}
}


sub servRoleManager2 {
	my $http = shift;

	my $rbac = chkRbac( $http );
	
	my $rbc = $rbac->{'rbac'};
	
	if( $rbc->{'all'} || $rbc->{'servRoleManager'} ){##_add_new_application_user
		
		my $servRoleMan = ServRoleManager->new($rbac)->addRole();
	}
}

sub servCompanyManager {
	my $http = shift;

	my $rbac = chkRbac( $http );
	
	my $rbc = $rbac->{'rbac'};
	
	if( $rbc->{'all'} || $rbc->{'servCompanyManager'} ){##_add_new_application_user
		
		warn "___________________________";
		warn Dumper $rbc;
		print "Content-type: application/json; charset=utf-8\n\n";
		print '[{ bla : \'foo\' }]';
		my $servLog = ServAddUser->new()->ajaxCheck($http);
	}
}

sub servSearch {
	my $http = shift;

	my $rbac = chkRbac( $http );
	
	my $rbc = $rbac->{'rbac'};
	
	if( $rbc->{'all'} || $rbc->{'servSearch'} ){
		my $servLog = ServSearch->new($rbac)->search();
	}
}

1;

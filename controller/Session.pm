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

#my $DATA = { 'passw' => 'badpw123ww', 'username' => 'user123@test.com', 'table' => 'users', 'salt' => '2dxx' };

#my $dbm = DBManag->new(\@DBDATA);
#$dbm->accDbh( $dbm->openDB() );


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
        #print $tx->render('/var/www/roleproto-frame/view/login.tx', { foo => "fooYESFOO"});
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

	#print( "<div><pre>" );
	#print Dumper $cred;
	#print( "</pre></div><br><br><br>" );	
	#warn("FILE AND LINE : ");print ":::::: >>> ";print Dumper $cred;

        #print "TEST2 : " . $quer->{'bar'};
        my $tx = Text::Xslate->new ( syntax => 'TTerse' );
		
	my $usr = Users->new2( $cred->{'coo'}->{'user'}, $cred->{'coo'}->{'sid'} );
	warn Dumper $usr;
	warn('\n\n----------------\n\n');
	warn Dumper $cred;		
	#my $busL = DaoSession->new( $self->{'dbm'}->accDbh() );
		
	#warn("F-L-N : "); print Dumper $busL;
	
	$ret = sub {

		my %vars;
		
		try {
			
			#my $logSucc = $busL->doLogin2( Users->new( 'user123@test.com', 'badpw123ww' ) );
			$sid = DaoSession->new( $self->{'dbm'}->accDbh() );
			$sid->chkSID( $sid->checkSessID( $usr ) );
			
			#warn( "CHECK SESSCHECK : " . $sid );
			#my $logSucc = $busL->doLogin2( Users->new( $cred->{'req'}->{'user'}, $cred->{'req'}->{'password'} ) );
		
			#print $logSucc."  OOOOOOOOOOOOOOOOOOOOOOOOOOO ";
			#print $usr->accSid();
			
			$ret = $sid->chkSID();
			#if( length $logSucc <= 0 ){
			if( !$sid->chkSID() ){
				$ret = 0;
				#TODO : redirect to login site
				print "";
			} 
	
			# Dummy example hashref for tpl-testing 
			#print Dumper %vars; warn("F-L");
		        
			# for files
			$ret;
		} catch {
			warn "ERRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRcaught error: $_"; # not $@
			print "ERRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRcaught error: $_"; # not $@
	
			
			if( $sid->chkSID() ){
				$ret = "OKEY";
				#$usr->accEmail();
			}		
			$ret = 0;
		} finally {
			#produce error so uncomment
			#$ret;
			
		
		        if( $sid->chkSID() ){
				
				#compare db-stored sid and cookie-sid and bind  user-name, later with role in the view and call rights/role for this user  
				# fill and send role in %vars too. Maybe should make own snippet-tpls for button and bind it into it or send as 	
				#warn "RBAC-->" . Dumper $sid->rbac();
				#print "RBAC-->" . Dumper $sid->rbac();
				
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

				#print Dumper \%rbac. " -- <br><br>"; print Dumper \%vars; 	

				print $tx->render('/var/www/roleproto-frame/view/doLogin.tx', \%vars);
			}
			
			#$ret;
		}
	}->();

	return $ret;
}

1;

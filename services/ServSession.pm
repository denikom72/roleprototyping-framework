package ServSession;
use Text::Xslate;
use Try::Tiny;

use lib ('/var/www/roleproto-frame/model');
use dto::Users;
use DaoSession;
use DBManag;

use Data::Dumper;
use JSON;
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


        #print "TEST2 : " . $quer->{'bar'};

        my $tx = Text::Xslate->new ( syntax => 'TTerse' );

        %vars = (
                foo => 'World of logins'
        );

        # for files
        #print $tx->render('/var/www/roleproto-frame/view/login.tx', { foo => "fooYESFOO"});
        print $tx->render('/var/www/roleproto-frame/view/login.tx', \%vars);

}

sub ajaxCheck {
	
	my $type = "Content-type: application/json; charset=utf-8\n\n";
        print $type;

	print( JSON->new->utf8->encode({myjsn => 'JSON_TEST'}) );
	
	return 1;
	
}
#Test
#ajaxCheck();

sub doLogin {
        my $self = shift;
	my $cred = shift;
	
	my $ret = 1;
	
	my $type = "Content-type: application/json; charset=utf-8\n\n";
        print $type;
	#warn("FILE AND LINE : ");print ":::::: >>> ";print Dumper $cred;

        #print "TEST2 : " . $quer->{'bar'};
		
	my $usr = Users->new( $cred->{'req'}->{'user'}, $cred->{'req'}->{'password'} );
	#my $usr = Users->new( 'user123@test.com', 'baw' );
				
	#my $busL = DaoSession->new( $self->{'dbm'}->accDbh() );
		
	#warn("F-L-N : "); print Dumper $busL;
	
	#$sess = DaoSession->new( $dbm->accDbh() )->doLogin2( Users->new( 'user123@test.com', 'badpw123ww' ) );
	$ret = sub {

		my %vars;
		my @err;	
		my $sess;	
		try {
			
			#my $logSucc = $busL->doLogin2( Users->new( 'user123@test.com', 'badpw123ww' ) );
			$sess = DaoSession->new( $self->{'dbm'}->accDbh() )->doLogin2( $usr );
			#$sess = DaoSession->new( $self->{'dbm'}->accDbh() )->doLogin2( Users->new( 'user123@test.com', 'badpw123ww' ) );
			#$sess = DaoSession->new( $self->{'dbm'}->accDbh() )->doLogin2( Users->new( $cred->{'req'}->{'user'}, $cred->{'req'}->{'password'} ) );
			
			$self->{'dbm'}->accDbh()->commit();

			my $sessCookie = $sess->{'sessData'}->[0];
			#warn "STAAAARRRTTTT : ";
			#warn Dumper $sess;		
	
			$usr->accSid( $sessCookie );
			#$usr->accSid( DaoSession->new( $self->{'dbm'}->accDbh() )->doLogin2( $usr ) );
			#my $logSucc = $busL->doLogin2( Users->new( $cred->{'req'}->{'user'}, $cred->{'req'}->{'password'} ) );
		
			#print $logSucc."  OOOOOOOOOOOOOOOOOOOOOOOOOOO ";
			#print $usr->accSid();
			
			$ret = $usr->accSid();
			
			#if( length $logSucc <= 0 ){
			if( length ( $usr->accSid() ) <= 0 ){
				$ret = 0;
				$usr->accEmail('Wrong credentials');
				%vars = 
				(
			               	user => $usr->accEmail(),
					#pw => $usr->accPasswordhash()
					#sid => $usr->accSid()
			       	);
			} else {
				
				$usr->accSid( $sess->{'sessData' } );
				%vars = 
				(
			               	user => $usr->accEmail(),
					sid => $usr->accSid()
			       	);
			} 
	
			# Dummy example hashref for tpl-testing 
			#print Dumper %vars; warn("F-L");
		        
			# for files
			$ret;
		
		} catch {
			
			push( @err, $_ );
			warn "caught error: $_"; # not $@
			
			if( length ( $usr->accSid() ) > 1 ){
				$ret = "OKEY";
				#$usr->accEmail();
			} 
			$ret = 0;

		} finally {
			#produce error so uncomment
			#$ret;
			
		
			print( JSON->new->utf8->encode( [ { 'rets' => $sess->{'sessData' } }, { 'SEEEEEEEEEEE' => "SEEEEEEEE" }, \%vars, { 'errs' => join("," , @err) } ] ) );
			#print( JSON->new->utf8->encode( \%vars ) );
		}	
	}->();
	### IMPORTANT:  Return by SERVICES JUST IMPORTANT FOR UNIT-TESTS ( FOR EXAMPLE : ok( runServiceModul() )  ), CAUSE THE CLIENT TAKE CARE OF THE ERROR-HANDLING, NEED TO PRINT RESSET 
	return $ret;
}

1;

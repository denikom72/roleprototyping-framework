package DaoAddUser;

use Digest::MD5;
use Digest::MD5 qw(md5_hex);
use CGI::Cookie;
use Try::Tiny;
use Data::Dumper;
use JSON;

use lib('/var/www/roleproto-frame/model');
use DBManag;

## CONF-DATA ##

my %TABDATA = ( 'table' => 'users' );
my $salt = "2dxx";

## END CONF-DATA ##

sub new {
	my $type = shift;
	my $dbh = shift;
	
	my $self = {
		'dbh' => $dbh
	};

	bless $self, $type;

	$self->accTabData(\%TABDATA);
	$self->accSalt($salt);
	
	$self;
}

sub accTabData {
	my $self = shift;
	my $tabData = shift;

	if( $tabData ne '' ){
		$self->{'tabData'} = $tabData;
		return 1;
		#return $self;
	}

	$self->{'tabData'};
}


sub accSalt {
	my $self = shift;
	my $salt = shift;

	if( $salt ne '' ){
		$self->{'salt'} = $salt;
		#1;
		return $self;
	}

	$self->{'salt'};
}

sub chkSID {
	
	my $self = shift;
	my $sid = shift;

	if( $sid ne '' ){
		$self->{'sid'} = $sid;
		1;
		#return $self;
	}
	
	$self->{'sid'};
}

 
sub genPassword {

        my $self = shift;
	my @CHARS = ("A" .. "Z", "a" .. "z", 0 .. 9, ("-", "_", "+", "-", ".", ";", "#"));
        my $password = join("", @CHARS[ map {rand @CHARS } (1 .. 10) ]);

        $password;

} 



sub addUser {
	my $self = shift;
	my $usr = shift;
	#print Dumper $usr;
	#print $usr->accEmail() . " mEEEEE";
	my $DATA = $self->accTabData();

	$DATA->{'username'} = $usr->accEmail();
	$DATA->{'passwd'} = $usr->accPasswordhash();

	my %DATA = %{$DATA};
	$DATA{'salt'} = $self->accSalt();
	#print Dumper \%DATA;die();
	if( length $DATA{passwd} < 8 ){
		die( $mess = "pw must have more then 8 characters : " . $DATA{passwd} );
	} else {
		$DATA{username} = lc($DATA{username});
	}
	
	my $hash = md5_hex($DATA{username} . $DATA{passwd} . $DATA{salt});
	
	my $parameter = 'email, passwordhash';
	my $values = '?, ?';
	my @EXECUTE = ($DATA{username}, $hash);
	
	my $sql = "INSERT INTO $DATA{table} ($parameter) VALUES ($values)";
	
	my $sth = $self->{'dbh'}->prepare($sql);
	
	try {
		
		$sth->execute(@EXECUTE);
		1;
	} catch {
		warn $sth->errstr;
		0;
	}
}


sub addPerson {
	my $self = shift;
	my $pers = shift;
	#print Dumper $usr;
	#print $usr->accEmail() . " mEEEEE";
	my $DATA = $self->accTabData();

	$DATA->{'username'} = $usr->accEmail();
	$DATA->{'passwd'} = $usr->accPasswordhash();

	my %DATA = %{$DATA};
	$DATA{'salt'} = $self->accSalt();
	#print Dumper \%DATA;die();
	if( length $DATA{passwd} < 8 ){
		die( $mess = "pw must have more then 8 characters : " . $DATA{passwd} );
	} else {
		$DATA{username} = lc($DATA{username});
	}
	
	my $hash = md5_hex($DATA{username} . $DATA{passwd} . $DATA{salt});
	
	my $parameter = 'email, passwordhash';
	my $values = '?, ?';
	my @EXECUTE = ($DATA{username}, $hash);
	
	my $sql = "INSERT INTO $DATA{table} ($parameter) VALUES ($values)";
	
	my $sth = $self->{'dbh'}->prepare($sql);
	
	try {
		
		$sth->execute(@EXECUTE);
		1;
	} catch {
		warn $sth->errstr;
		0;
	}
}

#read users table to compare credentials. Check password and username/email-address
sub readCreden {
	my $self = shift;
	my $usr = shift;

	my $DATA = $self->accTabData();
	
	$DATA->{'username'} = $usr->accEmail();
	$DATA->{'passwd'} = $usr->accPasswordhash();
	
	$DATA->{'salt'} = $self->accSalt();
	
	
	#print Dumper $DATA;
        
	my $hash = md5_hex($DATA->{username} . $DATA->{passw} . $DATA->{salt});

        my $sql = "SELECT 1 FROM $DATA->{table} WHERE email = ? AND passwordhash = ?";
       
	#print $hash;
 
	my $sth = $self->{'dbh'}->prepare($sql);
        
	my $resp = sub {
		try {
			$sth->execute($DATA->{username}, $hash);
			my @res=$sth->fetchrow_array;
			$res[0];
		} catch {
			my $err = $sth->errstr;
			# print error to logfile, not stdout resp. to webclient, cause it produce another error ( wrong header ... )
			warn ($err . " : WRONG PW OR USERNAME ");
			0;
		}
	}->();

	$resp;
} 



sub doLogin { # Prüft die Logindaten und speichert SID und COOKIE
	my $self = shift;
        # first element of the arg-array must be a hashref

	my $usr = shift;

	my $DATA = $self->accTabData();
	
	$DATA->{'username'} = $usr->accEmail();
	$DATA->{'passwd'} = $usr->accPasswordhash();
	
	my %DATA = %{$DATA};
	$DATA{'salt'} = $self->accSalt();
	
	my @SIDCHARS = ("A" .. "Z", "a" .. "z", 0 .. 9);
	my $sid = join("", @SIDCHARS[ map {rand @SIDCHARS } (1 .. 30) ]);
        
	my %STATUS;

	my $inf = sub { 
		try {
	                $DATA{username} = lc($DATA{username}) || die( $STATUS{code} = 1 );
	
	        	my $stat = $self->readCreden( \%DATA, $dbh );
	               
			if( $stat == 1 ){ 
				
		                my $sql = "UPDATE $DATA{table} SET sid = ? WHERE email = ?;";
				my $sth = $self->{'dbh'}->prepare($sql);
		
		                #$sth->execute($STATUS{sid}, $DATA{username}) || do { $STATUS{code} = 4; $statuszusatz =  $sth->errstr; };
		                $sth->execute($sid, $DATA{username}) || die ( $STATUS{code} = 4 );
		
				$cookie1 = CGI::Cookie->new(-name => "username", -value => "$DATA{username}", -expires => "+30d", -path => "/", -secure => 0, httponly => 1);
				$cookie2 = CGI::Cookie->new(-name => "sid", -value => "$sid", -expires => "+30d", -path => "/", -secure => 0, httponly => 1);
				
		                print "Set-Cookie: $cookie1\n";
		                print "Set-Cookie: $cookie2\n";
			} else {
				$STATUS{text} = $STATI[0];
			}
	
		} catch {
			# if var not exists, print message to logfile, not stdout resp. client, which would produce another error 
			warn $sth->errstr;
		}
	}->();

        return $inf;
} 

sub doLogin2 {
	
	my $self = shift;
	# db-handler instance

	my $usr = shift;
	my $err = shift;

	my $DATA = $self->accTabData();
	
	$DATA->{'username'} = $usr->accEmail();
	$DATA->{'passwd'} = $usr->accPasswordhash();
		
	#warn( "CRRRRRRRRRREEEEEEEEEEEEEEDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDSSS : " . $usr->accPasswordhash() );
	my %DATA = %{$DATA};
	
	$DATA->{'salt'} = $self->accSalt();

	#warn('file-line');	
	#print Dumper $DATA;
	#print "END FILE : " . __FILE__ . "\n\n";
	
	my @SIDCHARS = ("A" .. "Z", "a" .. "z", 0 .. 9);
	my $sid = join("", @SIDCHARS[ map {rand @SIDCHARS } (1 .. 30) ]);
        
	my $warn;

	my $hash = md5_hex($DATA->{username} . $DATA->{passwd} . $DATA->{salt});
	$returns = [];
	my $inf = sub { 
		try {
	                $DATA{username} = lc($DATA{username}) || die( $warn = "empty email" );
	
			my @sql = 
			(
				# DELETE OLD COOKIE
				{ 
					'query' => "UPDATE $DATA{table} SET sid = '' WHERE email = ?;",
					'exec' => [ $DATA{username} ]
				},
				
				# SET NEW COOKIE IF CREDENTIALS ARE RIGHT
				{ 
					'query' => "UPDATE $DATA{table} SET sid = ? WHERE email = ? AND passwordhash LIKE ?;",
					'exec' => [ $sid, $DATA{username}, $hash ]
				},
				
				 	
				{ 
					#'query' => "SELECT ROW_COUNT();", 
					'query' => "SELECT sid, email FROM $DATA{table} WHERE email = ? AND passwordhash LIKE ?;", 
					'exec' => [ $DATA{username}, $hash ]
				}
			);

			#my $sth;
			my $sth;			
			my @results;		
			map{
				$sth = $self->{'dbh'}->prepare( $_->{'query'} );
				
				if( ( $err = $sth->execute( @{ $_->{'exec'} } ) ) != 1  ){
					#die( "DBERR : " . $err );
					my $placeholderTriggerErrorForTryCatch = "";
				}
				# avoid error by using fetchrow_array, after CRUD operations
				@results=$sth->fetchrow_array() if $_->{'query'} =~ m|SELECT |gi;

				#push( @results, \@res );
				#print Dumper @results;
				#$sth->execute( $sid, $DATA{username}, $hash );
			} @sql;
			
			# last query
			
			$cookie1 = CGI::Cookie->new(-name => "username", -value => "$DATA{username}", -expires => "+30d", -path => "/", -secure => 0, httponly => 1);
			$cookie2 = CGI::Cookie->new(-name => "sid", -value => "$results[1]->[0]", -expires => "+30d", -path => "/", -secure => 0, httponly => 1);
			

			#print "Set-Cookie: $cookie1\n";
			#print "Set-Cookie: $cookie2\n";
	
			#print Dumper \@results;
			#for unit-test-purpose
			
			#return $results[1]->[0]; #,
			#return $cookie2;
			return { 
				#sid for ajax, to set by js, instead with print above
				sessData => \@results,
				
				cookies => [ $cookie1, $cookie2 ] 
			};	
			
	
		} catch {
			# if var not exists, print message to logfile, not stdout resp. client, which would produce another error 
			#warn $sth->errstr." ------------------------------------------------ \n\n";
			warn "caught error: $_"; # not $@
			warn $warn;
			0;
		}
	}->();
        return $inf;

}


sub rbac {
	my $self = shift;
	my $usr = shift;

	if( $usr ne '' ){
	my $sql =
	
	"SELECT ra.functionality AS func, r.priority AS prior, r.name AS role, ? AS usr FROM role_ability AS ra 
			
	LEFT JOIN 
		 
	roles AS r ON ra.roleId = r.id 

	WHERE 

	ra.roleId = ( SELECT roleId FROM user_role AS ur WHERE ur.user LIKE ? )";

	my $tSql = "SELECT ra.functionality  AS func, r.priority AS prior, r.name AS role, ? AS usr FROM role_ability AS ra LEFT JOIN roles AS r ON ra.roleId = r.id WHERE ra.roleId = ( SELECT roleId FROM user_role AS ur WHERE ur.user LIKE ? );";
	#my $tSql2 = "SELECT ra.functionality  AS func, r.priority AS prior, r.name AS role, 'foo@muu.com' AS usr FROM role_ability AS ra LEFT JOIN roles AS r ON ra.roleId = r.id WHERE ra.roleId = ( SELECT roleId FROM user_role AS ur WHERE ur.user LIKE 'user123@test.com' );";
	
	my $mess = sub {
		my $sth;
		try {
			$sth = $self->{'dbh'}->prepare($tSql);
			$sth->execute( $usr, $usr );
			#$sth->execute();
			warn("______________________________________\n");	
			warn("______________________________________\n");	
			warn Dumper $sth;	
			
			my $res=$sth->fetchall_arrayref();
			#my %res = %{$res};
			warn "ROLEABILITIIIIIIIIIIIIIIIIIIIIIIEEEEESSS" . Dumper $res;
			$res;
		} catch {
			warn " ERROR : " . $sth->errstr;
			0;	
		}
	}->();

	$self->{'rbac'} = $mess;

	return 1;
	}

	$self->{'rbac'};
}

sub checkSessID {
	my $self = shift;
	my $usr = shift;
	
	my $DATA = $self->accTabData();

	my $cookie = "";
	
	$DATA->{'username'} = $usr->accEmail();
	$DATA->{'sid'} = $usr->accSid();
	
	my %DATA = %{$DATA};
	
	my %COOKIE = %DATA;

	$DATA{'salt'} = $self->accSalt();
	
	my $sql = "SELECT 1 FROM $DATA{table} WHERE email = ? AND sid = ?";
	
	my $mess = sub {
		try {
			my $sth = $self->{'dbh'}->prepare($sql);
			$sth->execute($COOKIE{username}, $COOKIE{sid});
			
			my @res=$sth->fetchrow_array;
			
			if( $res[0] != 1 ){ $res[0] = 0 }
		
			if( $res[0] == 1 ){
				# all rbac and priority information are available by instance->{'rbac'} after running the method above
				$self->rbac($COOKIE{username});
			}
	
			$res[0];
		} catch {
			warn " ERROR : " . $_ . " __  ". $sth->errstr;
			#print " ERROR : " . $_ . " __ " . $sth->errstr;
			0;	
		}
	}->();

	$mess;
} 
                                       

1;

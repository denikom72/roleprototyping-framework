package DaoSession;

use Digest::MD5;
use Digest::MD5 qw(md5_hex);
use CGI::Cookie;
use Try::Tiny;
use Data::Dumper;
use JSON;

use lib('/var/www/roleproto-frame/model');
use DBManag;

# bind dtoS
use dto::Roles;
use dto::Company;
use dto::RfidList;
use dto::SearchRes;
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

sub priorFiltSimple {
	my $self = shift;
	return $self->rbac()->[0]->[4] . $self->rbac()->[0]->[1];
}

sub priorFilt {
	my $self = shift;
	#warn "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ";
	#warn Dumper $self->rbac();
	return " WHERE ( ( SELECT priority FROM roles WHERE name LIKE ? ) " . $self->rbac()->[0]->[4] . $self->rbac()->[0]->[1] . " ) ";
}

sub priorFilt2 {
	my $self = shift;

	return " WHERE priority " . $self->rbac()->[0]->[4] . $self->rbac()->[0]->[1];
}

sub priorFilt3 {
	my $self = shift;
	#warn "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ";
	#die (Dumper $self->rbac());
	return " WHERE (  ?  " . $self->rbac()->[0]->[4] . $self->rbac()->[0]->[1] . " ) ";
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


sub adaptApplic {
	my $self = shift;
	my ( $rolAb, $rol ) = ( shift, shift );

	my $parameter = 'roleId, functionality, priorBehav';
	#my $values = '?, ?, ?';
	
	my @EXECUTE2 = ( $rolAb->accFunctionality(), $rolAb->accPriorBehav(), $rolAb->accPriorBehav(), $rol->accName(), $rolAb->accPriorBehav(), $rolAb->accPriorBehav(),$rolAb->accFunctionality() );
	
	my @EXECUTE = ( $rolAb->accFunctionality(), $rol->accName(), $rolAb->accFunctionality() );

	my $behav = $rolAb->accPriorBehav() eq 'NLL' || $rolAb->accPriorBehav() eq '' ? 'NULL' : "\'" . $rolAb->accPriorBehav() . "\'";

	if( !$rolAb->accPriorBehav() ){
		$rolAb->accPriorBehav('NLL');
	}

	my $sql = ' 
	
	INSERT INTO
			
		role_abil( ' . $parameter . ' )
			
	SELECT ro.id AS rid, ? AS roFunc, ' . $behav . ' AS roPriorBehav 
		
		FROM roles AS ro
			
	WHERE ro.name
			
	        LIKE ?

	ON DUPLICATE KEY UPDATE

		priorBehav = ' . $behav  . ', functionality = ?;
	';
	
	# ifnull, nullif, COALESCE( NULLIF(phone, ''), bar, xoo )  AS foo

	my $sql2 = ' 
	
	INSERT INTO
			
		role_abil( ' . $parameter . ' )
			
	SELECT ro.id AS rid, ? AS roFunc, IF( ? = \'\', \'NULL\', ? ) AS roPriorBehav 
		
		FROM roles AS ro
			
	WHERE ro.name
			
	        LIKE ?

	ON DUPLICATE KEY UPDATE

		priorBehav = CASE WHEN ? = \'\' THEN \'NULL\' ELSE ? END, functionality = ?;
	';

	warn( "SQL -----------> " . $sql );

	warn Dumper @EXECUTE;
	
	try {
		
	
		#cause MYSQL has problems with empty strings and convert NULL inserts into 0 or '', here will just be fired a die
		die(' EMPTY BEHAVIOUR-CONDITION ') if $behav eq 'NULL';
		my $sth = $self->{'dbh'}->prepare($sql);
		$sth->execute(@EXECUTE);
		
	} catch {
		warn " --- ADAPT-APPLICATION-ERROR ::::::: " . $_ ." -- " . $sth->errstr;
		$_;	
	}
	
}


sub addPerson {
	my $self = shift;
	my $pers = shift;
	
	my $DATA = $self->accTabData();
	
	my $parameter = 'name, surname, position, email';
	my $values = '?, ?, ?, ?';
	my @EXECUTE = ( $pers->accName(), $pers->accSurname, $pers->accPosition(), $pers->accEmail() );
	
	my $sql = "INSERT INTO person ($parameter) VALUES ($values)";
	
	
	try {
		
		my $sth = $self->{'dbh'}->prepare($sql);
		$sth->execute(@EXECUTE);
		
	} catch {
		warn $sth->errstr;
		$_;	
	}
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
	
	
	#try {
		
	my $sth = $self->{'dbh'}->prepare($sql);
	$sth->execute(@EXECUTE);
		
	#} catch {
	#	warn $sth->errstr . " _________ " . $_;
	#	$_;
	#}
}

sub removeFuncFromRole {

	my $self = shift;
	my ( $rolAb, $rol ) = ( shift, shift );

	my @EXECUTE = ( $rolAb->accFunctionality(), $rol->accName() );
	
	my $sql = 
	'
		DELETE FROM role_abil

		WHERE functionality LIKE ? 

		AND 

		roleId = ( SELECT ro.id FROM roles AS ro WHERE ro.name LIKE ? );
	';
	
	try {
		
		my $sth = $self->{'dbh'}->prepare($sql);
		$sth->execute(@EXECUTE);
		
	} catch {
		warn " --- removeFuncFromRule -ERROR ::::::: " . $_ ." -- " . $sth->errstr;
		$_;	
	}
}

sub delUser {
	my $self = shift;
	my $usr = shift;
	
	my $parameter = '';
	my $values = '?';
	my @EXECUTE = ( $usr->accEmail() );
	warn "\n\n\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n\n\n"; #die();
	#warn Dumper \@EXECUTE; die(); 
	# NO INNER JOIN NECESSARY, CAUSE 'ON CASCADE' WAS USED BY DB-DESIGNING
	#warn "DELUSER DAO INTOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO";die();
	
	my @CRUD =
	(
				
		# SET NEW COOKIE IF CREDENTIALS ARE RIGHT
		{ 
			'query' => 'DELETE FROM users WHERE email LIKE ?;',
			'exec' => [ $usr->accEmail() ]

		}
	);

	try {
		map{
			my $sth = $self->{'dbh'}->prepare( $_->{'query'} );
					
			$sth->execute( @{ $_->{'exec'} } );
				#die( "DBERR : " . $err );
			
			# avoid error by using fetchrow_array, after CRUD operations
	
			warn "INTO QQQQQQQQQQQQQQQQQUUUUUUUUUUUUUEEEEEEERY\n\n";
			#push( @results, \@res );
			#print Dumper @results;
			#$sth->execute( $sid, $DATA{username}, $hash );
		} @CRUD;

	} catch {

		warn $sth->errstr . " DELUSERERRRRRROR  ___________________ " . $_;
		$_;
	}
	
	#$self->{'dbh'}->commit();
	
	#try {
	
		#my $sth = $self->{'dbh'}->prepare($sql);
		#$sth->execute();
 
		#my $res = $sth->fetchall_arrayref();

		#warn Dumper $res; die();	
		
	#} catch {
	#	warn $sth->errstr . " _________ " . $_;
	#	$_;
	#}
}


sub updUser {
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
	
	
	#try {
		
	my $sth = $self->{'dbh'}->prepare($sql);
	$sth->execute(@EXECUTE);
		
	#} catch {
	#	warn $sth->errstr . " _________ " . $_;
	#	$_;
	#}
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
	
			my @SQL = 
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
			} @SQL;
			
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

sub addRole {
	
	my $self = shift;
	my $role = shift;

	my $parameter = ' name, priority ';
	#my $roles = Roles->new();
	my $sth = "";
	
	my $sql =
	"
		INSERT INTO roles(" . $parameter . ") 
	
		SELECT d.* FROM	(
			SELECT
			? AS 'name',
			? AS 'prior'
		) AS d

		" . $self->priorFilt3() . "
		
		ON DUPLICATE KEY UPDATE priority = ?;
	";

	warn("XXXXXXXXXXXXXXXXXXXXXXXXXXX____________________________________");
	warn $sql;
	#warn $role->accPriority();die( "'''''''''''''''''");

	@EXECUTE = ( $role->accName(), $role->accPriority(), $role->accPriority(), $role->accPriority() );

	try {
		my $sth = $self->{'dbh'}->prepare($sql);

		$sth->execute( @EXECUTE	);

	} catch {
		warn "INSERT ROLES ERROR : " . $_;
	} finally {
		$listOfDto;
	};	
	
	$listOfDto;
}

sub addUser2Role {
	
	my $self = shift;
	my $role = shift;
	my $user = shift;	
	
	warn Dumper $self->rbac();
	#die("__________________________________________");

	my $parameter = ' roleId, user ';
	#my $roles = Roles->new();
	my $sth = "";
	
	my $sql = "
			INSERT INTO user_role(" . $parameter . ")

			SELECT d.* FROM (
				SELECT
				? AS 'rId',
				? AS 'usr'
			) AS d

			" . $self->priorFilt() . "

			ON DUPLICATE KEY UPDATE roleId = d.rId, user = d.usr;
	";

	warn "#################################################";
	warn $sql;
	warn "#################################################";
	
	@EXECUTE = ( $role->accId(), $user->accEmail(), $role->accName() );
	try {
		my $sth = $self->{'dbh'}->prepare($sql);

		$sth->execute( @EXECUTE	);

	} catch {
		warn "INSERT ROLES ERROR : " . $_;
	} finally {
		$listOfDto;
	};	
	
	$listOfDto;
}

sub listSearchRes {
	
	my $self = shift;
	my $argObj = shift;
	my $listOfDto = [];
	#warn " %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% " ; warn Dumper $self->rbac(); die();
	#my $roles = Roles->new();
	my $sth = "";
	my $sql = 
	"
	SELECT 
		pers.name, 

		pers.surname, 
		
		COALESCE( pers.position, 'noPosition' ), 
		
		pers.email, 
		
		( SELECT name FROM roles WHERE id = usrol.roleId ) AS roName, 
		
		perscom.company_id,

		( SELECT priority FROM roles AS ro WHERE id = usrol.roleId ) AS prior 
	FROM 
		users AS us

	LEFT JOIN 
		person AS pers ON us.email = pers.email

	LEFT JOIN 
		person_company AS perscom ON us.email = perscom.email

	LEFT JOIN 
		user_role AS usrol ON us.email = usrol.user

	 HAVING
		prior " . $self->priorFiltSimple() . "
		
		AND

		( 
			pers.name LIKE ? OR pers.surname LIKE ? OR pers.email LIKE ? 
		);

	";

	#die("FOOOOOOOOOOOOOOOOOOOOO");
	my @EXEC;
	
	map {
		push( @EXEC, $argObj->accSearch() );
	}( 0, 1, 2 );

	#my $sql = "SELECT * FROM roles ORDER BY priority ASC;";
	#warn "##################################### " . $sql2;die();	
	try {
		my $sth = $self->{'dbh'}->prepare($sql);

		$sth->execute( @EXEC );

		my $res = $sth->fetchall_arrayref();
		warn "OOOOOOOOOOOOOOOOOOOOOOOOOOOOO "; warn Dumper $res;		
		map {
			#ROLE ID, NAME, PRIORITY
			push( $listOfDto, SearchRes->new2( $_->[0], $_->[1], $_->[2], $_->[3], $_->[4] ) );
		} @{ $res };
	} catch {
		warn "SELROLES ERROR : " . $_;

		warn Dumper $listOfDto; warn " WARN ggggggggggggggggggggggggggggggggggggg";
		$listOfDto;
		
	} finally {
		warn "FINALLY ggggggggggggggggggggggggggggggggggggg";
		warn Dumper $listOfDto; 
	};	
	
	$listOfDto;
}

sub selRoles {
	
	my $self = shift;
	my $listOfDto = [];

	#my $roles = Roles->new();
	my $sth = "";
	my $sql = "SELECT * FROM roles " . $self->priorFilt2() . " ORDER BY priority ASC;";
	#my $sql = "SELECT * FROM roles ORDER BY priority ASC;";
	#warn "##################################### " . $sql2;die();	
	try {
		my $sth = $self->{'dbh'}->prepare($sql);

		$sth->execute();

		my $res = $sth->fetchall_arrayref();
	
		map {
			#ROLE ID, NAME, PRIORITY
			push( $listOfDto, Roles->new4( $_->[0], $_->[1], $_->[2] ) );
		} @{ $res };
	} catch {
		warn "SELROLES ERROR : " . $_;
	} finally {
		$listOfDto;
	};	
	
	$listOfDto;
}

sub selCompanies {
	
	my $self = shift;
	my $listOfDto = [];

	#my $roles = Roles->new();
	my $sth = "";
	my $sql = "SELECT name FROM company ORDER BY id;";	
	
	try {
		my $sth = $self->{'dbh'}->prepare($sql);

		$sth->execute();

		my $res = $sth->fetchall_arrayref();
	
		map {
			push( $listOfDto, Company->new2( $_->[0] ) );
		} @{ $res };
	} catch {
		warn "SELROLES ERROR : " . $_;
	} finally {
		$listOfDto;
	};	
	
	$listOfDto;
}


sub listRfids {
	
	my $self = shift;
	my $listOfDto = [];

	#my $roles = Roles->new();
	my $sth = "";
	my $sql = "SELECT rfid FROM rfidList ORDER BY rfid;";	
	
	try {
		my $sth = $self->{'dbh'}->prepare($sql);

		$sth->execute();

		my $res = $sth->fetchall_arrayref();
	
		map {
			push( $listOfDto, RfidList->new2( $_->[0] ) );
		} @{ $res };
	} catch {
		warn "LISTRFID ERROR : " . $_;
	} finally {
		$listOfDto;
	};	
	
	$listOfDto;
}

sub selFuncsByRole {
	
	my $self = shift;
	my $rolename = shift;
	
	my $listOfDto = [];

	#my $roles = Roles->new();
	my $sth = "";

	my $sql = " SELECT ra.functionality, priorBehav AS func FROM role_abil AS ra WHERE ra.roleId = ( SELECT ro.id FROM roles AS ro WHERE ro.name LIKE ? ); ";

	
	try {
		my $sth = $self->{'dbh'}->prepare($sql);

		$sth->execute($rolename);

		my $res = $sth->fetchall_arrayref();
	
		map {
			#TODO make dto
			#push( $listOfDto,  $_->[0] );
			push( $listOfDto,  $_ );
		} @{ $res };
	} catch {
		warn "SELROLES ERROR : " . $_;
	} finally {
		$listOfDto;
	};	
	
	$listOfDto;
}


sub rbac {
	my $self = shift;
	my $usr = shift;

	if( $usr ne '' ){
	my $sql =
	
	"SELECT ra.functionality AS func, r.priority AS prior, r.name AS role, ? AS usr, ra.priorBehav AS priorBeh FROM role_abil AS ra 
			
	LEFT JOIN 
		 
	roles AS r ON ra.roleId = r.id 

	WHERE 

	ra.roleId = ( SELECT roleId FROM user_role AS ur WHERE ur.user LIKE ? )";

	my $tSql = "
		SELECT ra.functionality  AS func, r.priority AS prior, r.name AS role, ? AS usr, ra.priorBehav AS priorBeh 

		FROM role_abil AS ra LEFT JOIN roles AS r ON ra.roleId = r.id 

		WHERE ra.roleId = ( SELECT roleId FROM user_role AS ur WHERE ur.user LIKE ? );";

	#my $tSql2 = "SELECT ra.functionality  AS func, r.priority AS prior, r.name AS role, 'foo@muu.com' AS usr FROM role_abil AS ra LEFT JOIN roles AS r ON ra.roleId = r.id WHERE ra.roleId = ( SELECT roleId FROM user_role AS ur WHERE ur.user LIKE 'user123@test.com' );";
	
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
			map{
				if( $_->[4] eq 'lower' ){
					$_->[4] = " < ";
				} elsif( $_->[4] eq 'equals:lower' ){
					$_->[4] = " <= ";
				}
			} @{$res};

			$self->{'rbac'} = $res;
		} catch {
			warn " ERROR : " . $sth->errstr;
			0;	
		}
	}->();

	#$self->{'rbac'} = $mess;

	1;
	}

	$self->{'rbac'};
}

sub checkPriorLevel {

}

sub retPriorBehavOnFunc {

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

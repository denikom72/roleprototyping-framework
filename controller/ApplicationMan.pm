package ApplicationMan;
use Text::Xslate;
use Try::Tiny;

use lib ('/var/www/roleproto-frame/model');
use lib ('/var/www/roleproto-frame/model/dto');
use Users;
use DaoSession;
use DBManag;

use Data::Dumper;

my @DBDATA = ('comeandgo', 'localhost', 'root', 't00rt00r');


sub new {
	my $type = shift;
	my $rbac = shift;
	
	my $self = { 'rbac' => $rbac, 'funcListRef' => [] };

	bless $self, $type;
	
	my $dbm = DBManag->new(\@DBDATA);
	$dbm->openDB();

	$self->{'dbm'} = $dbm;
	
	$self;
}


sub listFuncs {
	my $self = shift;
	my $mainContrPath = shift;
	
	opendir(DIR, ".");
	my @dir =  readdir(DIR);
	closedir(DIR);

	#open( my $pwd, "/bin/pwd |"); while( my $line = <$pwd> ){ warn "PWD :>>>> " . $line; }; close( $pwd );

	open( FH, "<", $mainContrPath ) or warn  " : " . $ENV{'pwd'}.$mainContrPath . " " . $!. "\n";

	while(<FH>){
		if( /\$rbc->/gi ){
		if( /\|\|/gi ){
			my @sent = split /\|\|/;

			# split last element, cause the first one will be all or root
			my @fnc = split( /\)\{/, $sent[$#sent]);
			my $func = $fnc[0];
				
	
			warn(">>> ", $func);
			$func =~ s/(^\s*|\s*$)//gi;
			
			$func =~ s/\$\w+->\{\'(\S*)\'\}/$1/gi;
	
			push( @{$self->{'funcListRef'} }, $func ) if $func !~ /(root|all)/gi;
		} else {
			
			my @fnc = split( /\)\{/ );
			my $func = $fnc[0];
			$func =~ s/(^\s*|\s*$)//gi;
			
			$func =~ s/\$\w+->\{\'(\S*)\'\}/$1/gi;
			push( @{$self->{'funcListRef'} }, $func ) if $funct !~ /(root|all)/gi;
		}
		}
	}

	close(FH);
}

sub listRoles {
	my $self = shift;
	# Cache result into a var, to not run the query behind it every time again
	$self->{'roles'} = $self->{'rbac'}->{'buslInst'}->selRoles();
	$self->{'roles'};
}

sub listFuncsByRole {
	my $self = shift;
	my $rolename = shift;
	# Cache result into a var, to not run the query behind it every time again
	$self->{'funcByRole'} = $self->{'rbac'}->{'buslInst'}->selFuncsByRole( $rolename );
	$self->{'funcByRole'};
}

sub start {
	
	my $self = shift;
	my $mainContrPath = "/var/www/roleproto-frame/controller/MainController.pm";
	

        print "Content-type: text/html; charset=utf-8\n\n";

	$self->listFuncs( $mainContrPath );
	
        my $tx = Text::Xslate->new ( syntax => 'TTerse' );
	my $listDto = [];
	my $listFncsByRole = [];

	map {
		push ( $listDto, $_->accName() );
	} @{ $self->listRoles( "admin" ) };

	map {
		push ( $listFncsByRole, $_ );
	} @{ $self->listFuncsByRole($self->{'rbac'}->{'http'}->{'req'}->{'selRole'}) };

	print $tx->render( '/var/www/roleproto-frame/view/applicationMan2.tx', { 'funcs1' => $self->{'funcListRef'}, 'roles' => $listDto , 'funcsByRole' => $listFncsByRole,  'http' => $self->{'rbac'}->{'http'}->{'req'} } );

	print Dumper $listFncsByRole;
	#print Dumper $self->{'rbac'}->{'http'};
}




1;

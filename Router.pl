#!/usr/bin/perl -w
package Router;
use strict;
use CGI;
use Try::Tiny;
use Data::Dumper;
use Text::Xslate;
use lib ('/var/www/roleproto-frame/controller');
use MainController;

my $q = CGI->new();

sub new {
	# MUST GET A HASHREF OF PARAMS 
	my ( $class, $data ) = @_;
	
	my $self = {};
	
	bless $self, $class;
		
	$self;
}


sub URLcleaner {

	my $self = shift;
	
	#my $q = shift;
	my $q = CGI->new();

	warn Dumper $ENV{REQUEST_URI};
	#die(' TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT ');

	my ($url, $query) = split(/\?/, $ENV{REQUEST_URI});
	my @URL = split(/\//, $url); 
	my %FORM;

	# for the case that such kind of url's pass the web-server	
	@URL = map {
		
		$_ =~ s/\<//g;
		$_ =~ s/\>//g;
		$_ =~ s/\%//g;
		$_ =~ s/\"//g;
		$_ =~ s/\'//g;
		$_ =~ s/\r\n/<br>/g; 
		$_ =~ s/\r/<br>/g; 
		$_ =~ s/\\//g;
		$_;
	} @URL;

	for my $key ( $q->param() ) {
		my $val = $q->param($key);

		### Filter bad characters ###
		$val =~ s/\<//g;
		$val =~ s/\>//g;
		$val =~ s/\%//g;
		$val =~ s/\"//g;
		$val =~ s/\'//g;
		$val =~ s/\r\n/<br>/g; 
		$val =~ s/\r/<br>/g; 
		$val =~ s/\\//g;
		
		$FORM{$key} = $val;
	} 
	
	#my $URL = \@URL;

	$url = join "/", @URL;
	$url = '/' if $url eq undef;
	
	my $FORM = \%FORM;

	my $COOKIE = $self->cookieReader();

	return { 'url' => $url, 'req' => $FORM, 'coo' => $COOKIE };		
} 

sub cookieReader {
	my $self = shift;
	
	my $cookie = $ENV{HTTP_COOKIE};
       	#print Dumper $cookie; die(); 
	
	my %COOKIE;

	foreach my $pair (split(/;/, $cookie)) {
                my($key, $value) = split(/=/, $pair);
		#  email validation
		$value =~ s/%40/\@/;
		
		# trim empty space
		map {
			$_ =~ s/(^\s*|\s$)//gi;
		} ( $value, $key );

		#$value =~ s/(^\s*|\s$)//gi;
		#$key =~ s/(^\s*|\s$)//gi;
		
		$COOKIE{$key} = $value;
        }           
	
	\%COOKIE;
}

### CONFIG ###
my %CNF =
( 
	salt => '5fD4!',
	usertable => 'users',
	tpl => "/var/www/roleproto-frame/view",
	url => "http://roleproto-frame",
	db => "comeandgo"
);


### ROUTING-DICTIONARY ###
my $MATCH = { 
	'' => \&MainController::login,
	'/' => \&MainController::login,
	'/login' => \&MainController::login,
	'/test' => \&MainController::test,
	'/doLogin' => \&MainController::doLogin,
	'/servLogin' => \&MainController::servLogin,
	'/servAddUser' => \&MainController::servAddUser,
	'/servUpdateUser' => \&MainController::servUpdUser,
	'/servDeleteUser' => \&MainController::servDelUser,
	'/servSearch' => \&MainController::servSearch,
	'/servRfidMan' => \&MainController::servRfidMan,
	'/servRoleMan' => \&MainController::servRoleManager,
	'/applicationMan' => \&MainController::applicationMan,
	'/applicationAdapter' => \&MainController::applicationAdapter
};


### BOOTSTRAP ###
my $PAR = Router->new()->URLcleaner();
my %PAR = %{$PAR};

my $ARGS = { 'args' => \%PAR };

my $staffExist = 
sub { 
	try {	
		#$MATCH->{ $PAR{'url'} }->( $PAR{'req'} );
		$MATCH->{ $PAR{'url'} }->( $PAR );
		1;
	} catch {
		
		print "Content-type: text/html; charset=utf-8\n\n";
		print "ERROR : " . $_;
		print "<pre> CATCHED ERROR : "; print Dumper $ARGS; print "</pre>";
		my $parStr = join "&", map { $PAR{'req'}->{$_} } keys %{ $PAR{'req'} };
		print "This path doesn't exist : " . $PAR{'url'} . "?" . $PAR{'req'}->{'password'};
		print "This path doesn't exist : " . $PAR{'url'} . "?" . $parStr;
		0;
	}
}->();

package DBManag;
use DBI;
use Data::Dumper;
use Class::Singleton;

@DBMan::ISA = qw( Class::Singleton );

sub new {
	my $type = shift;
	my $dbData = shift;

	my $self = {};

	bless $self, $type;

	$self->accDbData($dbData);
	$self->openDB();
	
	$self;
}

sub accDbData {
	my $self = shift;
	my $dbData = shift;

	if( $dbData ne '' ){
		$self->{'DBDATA'} = $dbData;
		return 1;
	}

	$self->{'DBDATA'};
}

sub accDbh {
	my ( $self, $dbh ) = ( shift, shift );

	if( $dbh ne "" ){
		#TODO : plausibcheck	
		
		$self->{'dbh'} = $dbh;
		return 1;	
	}

	#if( !$self->{'dbh'}->ping() ){	
	#	my $DBDATA = $self->accDbData();	
	#	$self->{'dbh'} = DBI->connect( "DBI:mysql:database=$DBDATA->[0]:$DBDATA->[1]", $DBDATA->[2], $DBDATA->[3], { 'AutoCommit' => 0, 'RaiseError' => 1 } );
	#}
	
	$self->{'dbh'};
}

sub openDB {

	my $self = shift;
	
	my $DBDATA = $self->accDbData();

	#print Dumper $DBDATA;#die();
	
	my $dbh = DBI->connect( "DBI:mysql:database=$DBDATA->[0]:$DBDATA->[1]", $DBDATA->[2], $DBDATA->[3], { 'AutoCommit' => 0, 'RaiseError' => 1, 'PrintError' => 1 } );
	$self->accDbh($dbh);	
	#unnecessary, cause accessor delivery dbh-instance 
	#return $dbh;
} 



1;

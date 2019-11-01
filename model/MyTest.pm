package MyTest;

sub new {
#	my $class = shift;
#	my $inst = {};
#
#	bless $inst, $class;
#	$inst;

	return bless {}, shift;
}


sub concate {
	my $self = shift;

	my( $a, $b ) = @_;
	return $a . $b; 
}

#print Test->new()->concate('muu', 'meeehh');

1;

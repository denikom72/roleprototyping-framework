package Company;

# overload of constructors is not possible, but a workaround 
sub new {
	my $type = shift;
	my $arg = shift;
        
	# if $arg > 0, use accessors, resp. setters to put values
	my $self = {};

        bless $self, $type;
        $self;
}

sub new2 {
	my $type = shift;
	my $arg = shift;
        
	# if $arg > 0, use accessors, resp. setters to put values
	my $self = {};

        bless $self, $type;
        
	$self->accName($arg);

	$self;
}

### IMPORTANT: is not necessary to declare private vars, just make perlish netb.convention - accessors 

sub accName {
        my $self = shift;
        my $val = shift;

        # if delegate $val, then simulate setter
        if( $val ne "" ){

                ## TODO: plausib.check, by perl also type-check ##

                $self->{'name'} = $val;
                return 1;
        }
        # if $val empty, simulate getter
        $self->{'name'};
}


1;

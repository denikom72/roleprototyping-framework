package SearchPojo;

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

	$self->accSearch($arg);

        $self;
}

### IMPORTANT: it's not necessary to declare private vars first and then public getters and setters, just make perlish netb.convention - accessors 

sub accSearch {
        my $self = shift;
        my $val = shift;

        # if delegate $val, then simulate setter
        if( $val ne "" ){

                ## TODO: plausib.check, by perl also type-check ##

                $self->{'search'} = $val;
                return 1;
        }
        # if $val empty, simulate getter
        $self->{'search'};
}


1;

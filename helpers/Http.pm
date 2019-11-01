package Http;

# overload of constructors is not possible, but a workaround 
sub new {
	my $type = shift;
	my $arg = shift;
        
	# if $arg > 0, use accessors, resp. setters to put values
	my $self = {};

        bless $self, $type;
        $self;
}

### IMPORTANT: is not necessary to declare private vars, just make perlish netb.convention - accessors 

sub accUrl {
        my $self = shift;
        my $val = shift;

        # if delegate $val, then simulate setter
        if( $val != "" ){

                ## TODO: plausib.check, by perl also type-check ##

                $self->{'url'} = $val;
                return 1;
        }
        # if $val empty, simulate getter
        $self->{'url'};
}

sub accRequest {
        my $self = shift;
        my $val = shift;

        # if delegate $val, then simulate setter
        if( $val != "" ){

                ## TODO: plausib.check, by perl also type-check ##

                $self->{'request'} = $val;
                return 1;
        }
        # if $val empty, simulate getter
        $self->{'request'};
}

sub accCookies {
        my $self = shift;
        my $val = shift;

        # if delegate $val, then simulate setter
        if( $val != "" ){

                ## TODO: plausib.check, by perl also type-check ##

                $self->{'cookies'} = $val;
                return 1;
        }
        # if $val empty, simulate getter
        $self->{'cookies'};
}


1;

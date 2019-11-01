package Roles;

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
	my $name = shift;
        
	# if $arg > 0, use accessors, resp. setters to put values
	my $self = {};

        bless $self, $type;

        $self->accName( $name );

	$self;
}

sub new3 {
	my $type = shift;
	my $name = shift;
	my $priority = shift;

        
	# if $arg > 0, use accessors, resp. setters to put values
	my $self = {};

        bless $self, $type;

        $self->accName( $name );
        $self->accPriority( $priority );

	$self;
}

sub new4 {
	my $type = shift;
	my $name = shift;
	my $priority = sprintf( "%d", shift );
	my $id = sprintf( "%d", shift );

        
	# if $arg > 0, use accessors, resp. setters to put values
	my $self = {};

        bless $self, $type;

        $self->accId( $id );
        $self->accName( $name );
        $self->accPriority( $priority );

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

sub accPriority {
        my $self = shift;
        my $val = shift;

        # if delegate $val, then simulate setter
        if( $val ne "" ){

                ## TODO: plausib.check, by perl also type-check ##

                $self->{'priority'} = $val;
                return 1;
        }
        # if $val empty, simulate getter
        $self->{'priority'};
}

sub accId {
        my $self = shift;
        my $val = shift;

        # if delegate $val, then simulate setter
        if( $val ne "" ){

                ## TODO: plausib.check, by perl also type-check ##

                $self->{'id'} = $val;
                return 1;
        }
        # if $val empty, simulate getter
        $self->{'id'};
}


1;

package UserRole;

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
	my ( $roleId, $user ) = ( shift, shift );
        
	# if $arg > 0, use accessors, resp. setters to put values
	my $self = {};

        bless $self, $type;
	$self->accRole        

	$self;
}
### IMPORTANT: is not necessary to declare private vars, just make perlish netb.convention - accessors 

sub accRoleId {
        my $self = shift;
        my $val = shift;

        # if delegate $val, then simulate setter
        if( $val ne "" ){

                ## TODO: plausib.check, by perl also type-check ##

                $self->{'roleid'} = $val;
                return 1;
        }
        # if $val empty, simulate getter
        $self->{'roleid'};
}

sub accUser {
        my $self = shift;
        my $val = shift;

        # if delegate $val, then simulate setter
        if( $val ne "" ){

                ## TODO: plausib.check, by perl also type-check ##

                $self->{'user'} = $val;
                return 1;
        }
        # if $val empty, simulate getter
        $self->{'user'};
}


1;

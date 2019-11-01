package SearchRes;

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
	my ( $name, $surname, $posit, $email, $role )  = ( shift, shift, shift, shift, shift );
        
	# if $arg > 0, use accessors, resp. setters to put values
	my $self = {};

        bless $self, $type;

	#warn "XXXXXXXXXXXXXXXXXXXXXXxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx "; warn $role;die();
	$self->accName( $name );
	$self->accSurname( $surname );
	$self->accPosition( $posit );
	$self->accEmail( $email );
	$self->accRole( $role );


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

sub accSurname {
        my $self = shift;
        my $val = shift;

        # if delegate $val, then simulate setter
        if( $val ne "" ){

                ## TODO: plausib.check, by perl also type-check ##

                $self->{'surname'} = $val;
                return 1;
        }
        # if $val empty, simulate getter
        $self->{'surname'};
}

sub accPosition {
        my $self = shift;
        my $val = shift;

        # if delegate $val, then simulate setter
        if( $val ne "" ){

                ## TODO: plausib.check, by perl also type-check ##

                $self->{'position'} = $val;
                return 1;
        }
        # if $val empty, simulate getter
        $self->{'position'};
}

sub accEmail {
        my $self = shift;
        my $val = shift;

        # if delegate $val, then simulate setter
        if( $val ne "" ){

                ## TODO: plausib.check, by perl also type-check ##

                $self->{'email'} = $val;
                return 1;
        }
        # if $val empty, simulate getter
        $self->{'email'};
}

sub accCompany {
        my $self = shift;
        my $val = shift;

        # if delegate $val, then simulate setter
        if( $val ne "" ){

                ## TODO: plausib.check, by perl also type-check ##

                $self->{'company'} = $val;
                return 1;
        }
        # if $val empty, simulate getter
        $self->{'company'};
}

sub accRole {
        my $self = shift;
        my $val = shift;

        # if delegate $val, then simulate setter
        if( $val ne "" ){

                ## TODO: plausib.check, by perl also type-check ##

                $self->{'role'} = $val;
                return 1;
        }
        # if $val empty, simulate getter
        $self->{'role'};
}


1;

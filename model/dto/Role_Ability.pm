package Role_Ability;

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
	my $func = shift;
        my $priorbehav = shift;

	# if $arg > 0, use accessors, resp. setters to put values
	my $self = {};

        bless $self, $type;

        $self->accFunctionality($func);
        $self->accPriorBehav($priorbehav);

	$self;
}

### IMPORTANT: is not necessary to declare private vars, just make perlish netb.convention - accessors 

sub accRoleId {
        my $self = shift;
        my $val = shift;

	$val = sprintf( "%s", $val );

        # if delegate $val, then simulate setter
        if( $val ne "" ){

                ## TODO: plausib.check, by perl also type-check ##

                $self->{'roleid'} = $val;
                return 1;
        }
        # if $val empty, simulate getter
        $self->{'roleid'};
}

sub accFunctionality {
        my $self = shift;
        my $val = shift;
	
        # if delegate $val, then simulate setter
        if( $val ne "" ){

		#PLAUSIB-CHECK
		$val =~ s/(^\s*|\s*$)//gi;
                ## TODO: plausib.check, by perl also type-check ##

                $self->{'functionality'} = $val;
                return 1;
        }
        # if $val empty, simulate getter
        $self->{'functionality'};
}


sub accPriorBehav {
        my $self = shift;
        my $val = shift;

	my %priorBeh = (
		'lower' => '<',
		'equals:lower' => '<='
	);

	# if delegate $val, then simulate setter
        if( $val ne "" ){

                ## TODO: plausib.check, by perl also type-check ##

		#PLAUSIB-CHECK
		$val =~ s/(^\s*|\s*$)//gi;
        
	        $self->{'priorBehav'} = $priorBeh{ $val };
                return 1;
        }
        # if $val empty, simulate getter
        $self->{'priorBehav'};
}

1;

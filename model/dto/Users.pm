package Users;

# overload of constructors is not possible, but a workaround 
sub new {
	my $type = shift;
	my $usr = shift;
        my $pwd = shift;

	# if $arg > 0, use accessors, resp. setters to put values
	my $self = {};
	
        bless $self, $type;
	
	$self->accEmail($usr);
	$self->accPasswordhash($pwd);

        $self;
}

#Overload impossible, just by using switch-number of args, but easyer to build another constructor with other name 
sub new2 {
	my $type = shift;
	my ( $usr, $sid ) = ( shift, shift );

	# if $arg > 0, use accessors, resp. setters to put values
	my $self = {};
	
        bless $self, $type;
	
	$self->accSid($sid);
	$self->accEmail($usr);
        
	$self;
}

sub new3 {
	my $type = shift;
	my ( $usr ) = ( shift );

	# if $arg > 0, use accessors, resp. setters to put values
	my $self = {};
	
        bless $self, $type;
	$self->accEmail($usr);
        
	$self;
}

### IMPORTANT: is not necessary to declare private vars, just make perlish netb.convention - accessors 

sub accEmail {
	my $self = shift;
	my $val = shift;
	# if delegate $val, then simulate setter
	if( $val ne "" ){

		## TODO: plausib.check, by perl also type-check ##

		$val =~ s/(^\s*|\s*$)//gi;
		$self->{'email'} = $val;
		#return $self;
		return 1;
	}
	# if $val empty, simulate getter
	$self->{'email'};
}

sub accPasswordhash {
	my $self = shift;
	my $val = shift;
	
	# if delegate $val, then simulate setter
	if( $val ne "" ){

		## TODO: plausib.check, by perl also type-check ##

		$self->{'passwordhash'} = $val;
		return 1;
	}
	# if $val empty, simulate getter
	$self->{'passwordhash'};
}  
  
sub accSid {
	my $self = shift;
	my $val = shift;
	
	# if delegate $val, then simulate setter
	if( $val ne "" ){

		## TODO: plausib.check, by perl also type-check ##

		$self->{'sid'} = $val;
		return $self;
	}
	# if $val empty, simulate getter
	$self->{'sid'};
}

1;  

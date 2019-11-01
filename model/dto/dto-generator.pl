my $tabCols = [ "Name", "Surname", "Position", "EMail", "Company", "Role" ];

my $tplHead = <<'TPLHEAD';

package TABLENAME_AS_PACKAGENAME;

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

TPLHEAD

print $tplHead;
# Necessary to put in array while looping trough it ( readout data, chop the data from the DATA-Handler )
my @line = <DATA>;

map{
	
	my $coln = $_;
	foreach my $line ( @line ) {
		my $innLine = $line;
		#print $_ . " xxxxxxx --> " . $coln;
		
		#if( $line !~ m/sub acc.*?/gi ){
		#	$coln = lc $coln;
		#}

		if( $innLine !~ m/sub acc.*?/gi ){
			$coln = lc $coln;
		}

		#$line =~ s/{{colname}}/$coln/gi;
		$innLine =~ s/{{colname}}/$coln/gi;
		#print $line;
		print $innLine;
		#$line =~ s/$coln/{{colname}}/gi;
	}
} @{$tabCols};

print("\n1;\n");

__DATA__
sub acc{{colname}} {
        my $self = shift;
        my $val = shift;

        # if delegate $val, then simulate setter
        if( $val ne "" ){

                ## TODO: plausib.check, by perl also type-check ##

                $self->{'{{colname}}'} = $val;
                return 1;
        }
        # if $val empty, simulate getter
        $self->{'{{colname}}'};
}


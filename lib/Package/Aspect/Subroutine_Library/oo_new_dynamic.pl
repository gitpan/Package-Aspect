{
	my %WILD = ();

sub oo_new_dynamic {
        my $class = shift;
        unless (exists($WILD{$class})) {
                unless ($class =~ m,^(\w+)(::\w+)+$,s) {
                        Carp::confess("Invalid package name '$class'");
                }
                local($@);
                eval "use $class;";
                Carp::confess($@) if ($@);
                $WILD{$class} = 1;
        }
        return($class->new(@_));
}

}

1;

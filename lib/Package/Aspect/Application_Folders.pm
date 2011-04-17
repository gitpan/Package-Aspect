package Package::Aspect::Application_Folders;

use strict;
use warnings;
use Carp qw();
use Data::Dumper;
#use parent qw(
#	Object::By::Hash);

#my $exotic_chars = '[\#\^\!\@\$\%\[\]\(\)\{\}\:]';

sub THIS() { 0 }

sub new {
	bless({}, __PACKAGE__);
}

sub extend {
	return($_[THIS]);
}

sub P_KEY() { 1 }
sub P_VALUE() { 2 }
sub register {
	$_[P_VALUE] =~ s,[^/]*/\.\.,,sg;
	$_[P_VALUE] =~ s,//+,/,sg;
	$_[P_VALUE] =~ s,/[^/]*$,,s;
	$_[THIS]{$_[P_KEY]} = $_[P_VALUE];
	return;
}

sub resolve_single {
	my ($this) = @_;

	my $file_name = $_[P_VALUE];
	my $folder = '';
	my $missing = 0;
#	while ($file_name =~ s/^(.*?)(${exotic_chars}{1,2})(\w+_cfg)(${exotic_chars}{1,2})//s) {
	while ($file_name =~ s/^(.*?)\[=(\w+_cfg)=\]//s) {
		$folder .= $1;
		if (exists($this->{$2})) {
			$folder .= $this->{$2};
		} else {
			$missing += 1;
			$folder .= "[=$2=]";
		}
	}
	$folder .= $file_name;

	$folder =~ s,[^/]*/\.\.,,sg;
	$folder =~ s,//+,/,sg;
	$folder =~ s,/$,,s;
	$_[P_VALUE] = $folder;
	if ($missing == 0) {
		$folder =~ s,/[^/]*$,,s;
		$this->{$_[P_KEY]} = $folder;
	}
	return($missing);
}

sub resolve_multiple {
	my ($this, $keys, $symbols) = @_;

	my $max_rounds = $#$keys;
	foreach (0..$max_rounds) {
		my @missed = ();
		while (my $key = shift(@$keys)) {
			next unless ($this->resolve_single(
				$key,
				$symbols->{$key}));
			push(@missed, $key);
		}
		if ($#missed == -1) {
			last;
		} else {
			push(@$keys, @missed);
		}
	}

	return;
}

#my $folders = {'a1_cfg'=>'$$c3_cfg$$/b2', 'c3_cfg'=>'@@e5_cfg@@/d4/', 'e5_cfg'=>'f6'};
#my $this = bless({}, __PACKAGE__);
#resolve_multiple($this, ['a1_cfg', 'c3_cfg', 'e5_cfg'], $folders);
#print STDERR Dumper($folders, $this);

1;

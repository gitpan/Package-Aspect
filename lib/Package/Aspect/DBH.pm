package Package::Aspect::DBH;

use strict;
use warnings;
use Carp qw();
use Data::Dumper;
use DBI;
use parent qw(
	Object::By::Array
);

use Package::Aspect sub{eval shift};
Package::Aspect::reservation(
	my $customized_settings = '::Customized_Settings');

my @connect = ();
my $pid = $$;
my $connection = undef;

#sub P_SETTINGS() { 1 }
sub _init {
	@connect = $customized_settings->extracted_values(
		'dsn', 'login', 'password');
	return;
}

sub extend() {
        $connection = undef if ($pid != $$);
        unless (defined($connection)) {
                $connection = DBI->connect(@connect) ||
                        confess("connect: $DBI::errstr\n");
        }
        return($connection);
}

sub disconnect {
        $connection->disconnect() if (defined($connection));
	$connection = undef;
}

1;

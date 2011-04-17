use ExtUtils::MakeMaker;

WriteMakefile(
	'NAME'		=> 'Package::Aspect',
	'VERSION_FROM'	=> 'lib/Package/Aspect.pm',
	'AUTHOR'	=> 'Winfried Trumper <pub+perl@wt.tuxomania.net>',
	'LICENSE'	=> 'perl',
	'PREREQ_PM'	  => {
		'parent' => 0.01,
		'Test::Simple' => 0.01,
	},
);

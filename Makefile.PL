#!/usr/bin/perl

use ExtUtils::MakeMaker;

WriteMakefile (
	'NAME'          =>      'perl-GPSData',
	'VERSION_FROM'  =>      'lib/Geo/GPS/Data.pm',
	'PREREQ_PM'     =>      {Date::Manip, Test::More},
	'test'          =>      {TEST_VERBOSE=>1},
    ($] >= 5.005 ? (
    ABSTRACT => 'GPS geographical data management.',
	AUTHOR     => 'Nuno Nunes <nfmnunes@cpan.org>'
	) : ()),
);


#!/usr/bin/perl

use ExtUtils::MakeMaker;

WriteMakefile (
    'NAME'          =>      'perl-GPSData',
    'VERSION_FROM'  =>      'lib/Geo/GPS/Data.pm', # finds $VERSION
    'PREREQ_PM'     =>      {Date::Manip, Test::More}, # e.g., Module::Name => 1.1
        'test'          =>      {TEST_VERBOSE=>1},
        ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
            (ABSTRACT => 'GPS geographical data management.',
            AUTHOR     => 'Nuno Nunes <nfmnunes@cpan.org>') : ()),
        );
        

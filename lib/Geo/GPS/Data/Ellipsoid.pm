# Copyright (c) 2003 Nuno Nunes <nfmnunes@cpan.org>.
# All rights reserved. This program is free software; 
# you can redistribute it and/or modify it under the same terms as Perl itself.
#
# $Id: Ellipsoid.pm,v 1.3 2003/04/13 13:27:42 nfn Exp $
#

package Geo::GPS::Data::Ellipsoid;

our $VERSION = '0.04';

sub new {
	my $s = shift;

	bless {}, $s;

	# Ellipsoid types shamelessly stollen from the Geo::Coordinates::UTM module.
	$s->{Ellipsoids} = [
	        { id => 1, name => 'Airy'},
	        { id => 2, name => 'Australian National'},
	        { id => 3, name => 'Bessel 1841'},
	        { id => 4, name => 'Bessel 1841 (Nambia)'},
	        { id => 5, name => 'Clarke 1866'},
	        { id => 6, name => 'Clarke 1880'},
	        { id => 7, name => 'Everest'},
	        { id => 8, name => 'Fischer 1960 (Mercury)'},
	        { id => 9, name => 'Fischer 1968'},
	        { id => 10, name => 'GRS 1967'},
	        { id => 11, name => 'GRS 1980'},
	        { id => 12, name => 'Helmert 1906'},
	        { id => 13, name => 'Hough'},
	        { id => 14, name => 'International'},
	        { id => 15, name => 'Krassovsky'},
	        { id => 16, name => 'Modified Airy'},
	        { id => 17, name => 'Modified Everest'},
	        { id => 18, name => 'Modified Fischer 1960'},
	        { id => 19, name => 'South American 1969'},
	        { id => 20, name => 'WGS 60'},
	        { id => 21, name => 'WGS 66'},
	        { id => 22, name => 'WGS-72'},
	        { id => 23, name => 'WGS-84'},
	];

	return $s;
};

sub id_from_ellipsoid {
	my $s = shift;
	my $a = shift;

	return 0 unless (exists $a->{ellipsoid} && defined $a->{ellipsoid});
	my @res = grep {$_->{name} eq $a->{ellipsoid}} @{$s->{Ellipsoids}};
	return $res[0]->{id};
};

sub ellipsoid_from_id {
	my $s = shift;
	my $a = shift;

	my @res = grep {$_->{id} == $a->{id}} @{$s->{Ellipsoids}};
	return $res[0]->{name};
};

sub list_ellipsoids {
	my $s = shift;

	return $s->{Ellipsoids};
};

1;

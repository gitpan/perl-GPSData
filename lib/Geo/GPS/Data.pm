# Copyright (c) 2003 Nuno Nunes <nfmnunes@cpan.org>.
# All rights reserved. This program is free software; 
# you can redistribute it and/or modify it under the same terms as Perl itself.
#
# $Id: Data.pm,v 1.7 2003/03/26 00:01:31 nfn Exp $
#

package Geo::GPS::Data;

use Data::Dumper;
use Geo::GPS::Data::Waypoint;

our $VERSION = '0.01';

#######################################
sub new {
	my $s = shift;

	return bless {}, $s;
};

#######################################
# TODO: insert_waypoint: Convert coordinates in any valid format to DD.DDDD
sub add_waypoint {
	my $s = shift;
	my $a = shift;

	my $wpt = Geo::GPS::Data::Waypoint->new();
	my $res = $wpt->create($a);
	if ($res) {
		return $wpt
	} else {
		return 0
	}
};

#######################################
sub get_waypoint {
	my $s = shift;
	my $a = shift;

	my $wpt = Geo::GPS::Data::Waypoint->new();
	my $res = $wpt->load($a);
	if ($res) {
		return $wpt
	} else {
		return 0
	}
};

1;

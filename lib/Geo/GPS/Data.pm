# Copyright (c) 2003 Nuno Nunes <nfmnunes@cpan.org>.
# All rights reserved. This program is free software; 
# you can redistribute it and/or modify it under the same terms as Perl itself.
#
# $Id: Data.pm,v 1.9 2003/03/28 00:45:54 nfn Exp $
#

package Geo::GPS::Data;

use Data::Dumper;
use Geo::GPS::Data::Waypoint;

our $VERSION = '0.02';

#######################################
sub new {
	my $s = shift;
	my $a = shift;

	my $data = {};
	if ($a->{storage_params}) {
		$data->{config}{STORAGE_PARAMS} = $a->{storage_params};
	};
	if ($a->{storage}) {
		$data->{config}{STORAGE} = $a->{storage};
	};
	return bless $data, $s;
};

#######################################
# TODO: insert_waypoint: Convert coordinates in any valid format to DD.DDDD
sub add_waypoint {
	my $s = shift;
	my $a = shift;

	my $wpt = Geo::GPS::Data::Waypoint->new({
		storage=>$s->{config}{STORAGE},
		storage_params=>$s->{config}{STORAGE_PARAMS}
	});
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

	my $wpt = Geo::GPS::Data::Waypoint->new({
                storage=>$s->{config}{STORAGE},
                storage_params=>$s->{config}{STORAGE_PARAMS}
        });
	my $res = $wpt->load($a);
	if ($res) {
		return $wpt
	} else {
		return 0
	}
};

1;

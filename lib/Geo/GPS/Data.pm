# Copyright (c) 2003 Nuno Nunes <nfmnunes@cpan.org>.
# All rights reserved. This program is free software;
# you can redistribute it and/or modify it under the same terms as Perl itself.
#
# $Id: Data.pm,v 1.11.2.3 2003/04/11 11:13:29 nfn Exp $
#

package Geo::GPS::Data;

use Geo::GPS::Data::Storage;
use Geo::GPS::Data::Waypoint;
use Geo::GPS::Data::Collection;

our $VERSION = '0.03';

#######################################
sub new {
    my $s = shift;
    my $a = shift;
    
    my $data = {};
    $data->{cache}{STORAGE} = Geo::GPS::Data::Storage->new({
        storage => $a->{storage},
        storage_params => $a->{storage_params}
    });
    
    return bless $data, $s;
};

#######################################
# TODO: insert_waypoint: Convert coordinates in any valid format to DD.DDDD
sub add_waypoint {
    my $s = shift;
    my $a = shift;
    
    $@ = undef;
    if (!(ref($a) eq 'HASH')) {
        $@ = "Geo::GPS::Data: Missing parameters in add_waypoint() call";
        return 0;
    }
    my $wpt = Geo::GPS::Data::Waypoint->new({
        storage => $s->{cache}{STORAGE},
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
    
    $@ = undef;
    if (!(ref($a) eq 'HASH')) {
        $@ = "Geo::GPS::Data: Missing parameters in get_waypoint() call";
        return 0;
    }
    my $wpt = Geo::GPS::Data::Waypoint->new({
        storage=>$s->{cache}{STORAGE},
    });
    my $res = $wpt->load($a);
    if ($res) {
        return $wpt
        } else {
        return 0
    }
};

#######################################
sub add_collection {
    my $s = shift;
    my $a = shift;
    
    $@ = undef;
    if (!(ref($a) eq 'HASH')) {
        $@ = "Geo::GPS::Data: Missing parameters in add_collection() call";
        return 0;
    }
    my $col = Geo::GPS::Data::Collection->new({
        storage=>$s->{cache}{STORAGE},
    });
    my $res = $col->create($a);
    if ($res) {
        return $col
        } else {
        return 0
    }
};

#######################################
sub get_collection {
    my $s = shift;
    my $a = shift;
    
    $@ = undef;
    if (!(ref($a) eq 'HASH')) {
        $@ = "Geo::GPS::Data: Missing parameters in get_collection() call";
        return 0;
    }
    my $col = Geo::GPS::Data::Collection->new({
        storage=>$s->{cache}{STORAGE},
    });
    my $res = $col->load($a);
    if ($res) {
        return $col
        } else {
        return 0
    }
};

1;

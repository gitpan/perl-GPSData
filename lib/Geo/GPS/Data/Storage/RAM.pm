# Copyright (c) 2003 Nuno Nunes <nfmnunes@cpan.org>.
# All rights reserved. This program is free software;
# you can redistribute it and/or modify it under the same terms as Perl itself.
#
# $Id: RAM.pm,v 1.8 2003/04/13 13:27:42 nfn Exp $
#

package Geo::GPS::Data::Storage::RAM;

our $VERSION = '0.04';

use strict;
use Date::Manip;
our @ISA = 'Geo::GPS::Data::Storage';

#######################################
sub new {
    my $s = shift;
    
    my $data;
    $data->{data} = {
        waypoints => {},
        waypoint_types => {
            1 => {
                name => 'none',
                comment => 'Default type',
            }
        },
        collections => {},
        belongs => {},
    };
    $data->{state}{waypoint_counter}=0;
    $data->{state}{collection_counter}=0;
    
    return bless $data, $s;
};

#######################################
sub waypoint_types {
    my $s = shift;
    
    my @reply;
    foreach my $k (keys %{$s->{data}{waypoint_types}}) {
    push @reply, {id => $k, name => $s->{data}{waypoint_types}{$k}{name}, comment => $s->{data}{waypoint_types}{$k}{comment}};
};

return \@reply;
};

#######################################
sub store_waypoint {
my $s = shift;
my $a = shift;

$@=undef;
if (!$a->{name}) {
    $@ = "Geo::GPS::Data::Storage::RAM: Missing data: name";
    return 0;
};
if (!$a->{latitude}) {
    $@ = "Geo::GPS::Data::Storage::RAM: Missing data: latitude";
    return 0;
};
if (!$a->{longitude}) {
    $@ = "Geo::GPS::Data::Storage::RAM: Missing data: longitude";
    return 0;
};
if (!$a->{type_id}) {
    $@ = "Geo::GPS::Data::Storage::RAM: Missing data: type_id";
    return 0;
};
if (!$a->{ellipsoid}) {
    $@ = "Geo::GPS::Data::Storage::RAM: Missing data: ellipsoid";
    return 0;
};
my $date;
if ($a->{date_collected}) {
    $date = &ParseDate($a->{date_collected});
    if ($date) {
        $date = &UnixDate($date, "%q");
        } else {
        $@ = "Geo::GPS::Data::Storage::RAM: Received an invalid date: ".$a->{date_collected};
        return 0;
    }
};

if ($a->{id}) {
    if (exists $s->{data}{waypoints}{$a->{id}}) {
        $s->{data}{waypoints}{$a->{id}}{name} = $a->{name};
        $s->{data}{waypoints}{$a->{id}}{latitude} = $a->{latitude};
        $s->{data}{waypoints}{$a->{id}}{longitude} = $a->{longitude};
        $s->{data}{waypoints}{$a->{id}}{comment} = $a->{comment};
        $s->{data}{waypoints}{$a->{id}}{type_id} = $a->{type_id};
        $s->{data}{waypoints}{$a->{id}}{date_collected} = $date;
        $s->{data}{waypoints}{$a->{id}}{ellipsoid} = $a->{ellipsoid};
        return $a->{id};
        } else {
        $@ = "Geo::GPS::Data::Storage::RAM: No such waypoint: ".$a->{id};
        return 0;
    };
    } else {
    my $wp_id = ++$s->{state}{waypoint_counter};
    $s->{data}{waypoints}{$wp_id}{name} = $a->{name};
    $s->{data}{waypoints}{$wp_id}{latitude} = $a->{latitude};
    $s->{data}{waypoints}{$wp_id}{longitude} = $a->{longitude};
    $s->{data}{waypoints}{$wp_id}{comment} = $a->{comment};
    $s->{data}{waypoints}{$wp_id}{type_id} = $a->{type_id};
    $s->{data}{waypoints}{$wp_id}{date_collected} = $date;
    $s->{data}{waypoints}{$wp_id}{ellipsoid} = $a->{ellipsoid};
    return $wp_id;
}
};

#######################################
sub retrieve_waypoint {
my $s = shift;
my $a = shift;

$@=undef;
if (!$a->{id}) {
    $@ = "Geo::GPS::Data::Storage::RAM: Missing required parameter: id in retrieve_waypoint() call";
    return 0;
};

if (exists $s->{data}{waypoints}{$a->{id}}) {
    my $r;
    $r->{name} = $s->{data}{waypoints}{$a->{id}}{name};
    $r->{latitude} = $s->{data}{waypoints}{$a->{id}}{latitude};
    $r->{longitude} = $s->{data}{waypoints}{$a->{id}}{longitude};
    $r->{comment} = $s->{data}{waypoints}{$a->{id}}{comment};
    $r->{type_id} = $s->{data}{waypoints}{$a->{id}}{type_id};
    $r->{date_collected} = $s->{data}{waypoints}{$a->{id}}{date_collected};
    $r->{ellipsoid} = $s->{data}{waypoints}{$a->{id}}{ellipsoid};
    $r->{id} = $a->{id};
    $r->{date_collected} = &UnixDate($r->{date_collected}, "%c");
    return $r;
    } else {
    $@ = "Geo::GPS::Data::Storage::RAM: Non existing waypoint Id: ".$a->{id};
    return 0;
}
};

#######################################
sub delete_waypoint {
my $s = shift;
my $a = shift;

$@=undef;
if (!$a->{id}) {
    $@ = "Geo::GPS::Data::Storage::RAM: Missing required parameter: id in delete_waypoint() call";
    return 0;
};

if (exists $s->{data}{waypoints}{$a->{id}}) {
    delete $s->{data}{waypoints}{$a->{id}};
    return 1;
    } else {
    $@ = "Geo::GPS::Data::Storage::RAM: Non existing waypoint Id: ".$a->{id};
    return 0;
};
};

#######################################
sub exists_waypoint {
my $s = shift;
my $a = shift;

$@=undef;
if (!$a->{id}) {
    $@ = "Geo::GPS::Data::Storage::RAM: Missing required parameter: id in exists_waypoint() call";
    return 0;
};

return exists $s->{data}{waypoints}{$a->{id}};
};

#######################################
sub store_collection {
my $s = shift;
my $a = shift;

$@=undef;
if (!$a->{name}) {
    $@ = "Geo::GPS::Data::Storage::RAM: Missing data: name";
    return 0;
};
if (!$a->{type}) {
    $@ = "Geo::GPS::Data::Storage::RAM: Missing data: type";
    return 0;
};
if (!$a->{waypoints} || !(ref($a->{waypoints}) eq 'ARRAY' )) {
    $@ = "Geo::GPS::Data::Storage::RAM: Missing or invalid data: waypoint list";
    return 0;
};
my $date;
if ($a->{date_collected}) {
    $date = &ParseDate($a->{date_collected});
    if ($date) {
        $date = &UnixDate($date, "%q");
        } else {
        $@ = "Geo::GPS::Data::Storage::RAM: Received an invalid date: ".$a->{date_collected};
        return 0;
    }
};

if ($a->{id}) {
    if (exists $s->{data}{collections}{$a->{id}}) {
        $s->{data}{collections}{$a->{id}}{name} = $a->{name};
        $s->{data}{collections}{$a->{id}}{comment} = $a->{comment};
        $s->{data}{collections}{$a->{id}}{type} = $a->{type};
        $s->{data}{collections}{$a->{id}}{date_collected} = $date;
        $s->{data}{collections}{$a->{id}}{waypoints} = $a->{waypoints};
        return $a->{id};
        } else {
        $@ = "Geo::GPS::Data::Storage::RAM: No such collection: ".$a->{id};
        return 0;
    };
    } else {
    my $col_id = ++$s->{state}{collection_counter};
    $s->{data}{collections}{$col_id}{name} = $a->{name};
    $s->{data}{collections}{$col_id}{comment} = $a->{comment};
    $s->{data}{collections}{$col_id}{type} = $a->{type};
    $s->{data}{collections}{$col_id}{date_collected} = $date;
    $s->{data}{collections}{$col_id}{waypoints} = $a->{waypoints};
    return $col_id;
}
};

#######################################
sub retrieve_collection {
my $s = shift;
my $a = shift;

$@=undef;
if (!$a->{id}) {
    $@ = "Geo::GPS::Data::Storage::RAM: Missing required parameter: id";
    return 0;
};

if (exists $s->{data}{collections}{$a->{id}}) {
    my $r;
    $r->{name} = $s->{data}{collections}{$a->{id}}{name};
    $r->{comment} = $s->{data}{collections}{$a->{id}}{comment};
    $r->{type_id} = $s->{data}{collections}{$a->{id}}{type_id};
    $r->{date_collected} = $s->{data}{collections}{$a->{id}}{date_collected};
    $r->{waypoints} = $s->{data}{collections}{$a->{id}}{waypoints};
    $r->{id} = $a->{id};
    $r->{date_collected} = &UnixDate($r->{date_collected}, "%c");
    return $r;
    } else {
    $@ = "Geo::GPS::Data::Storage::RAM: Non existing waypoint collection Id: ".$a->{id};
    return 0;
}
};

#######################################
sub delete_collection {
my $s = shift;
my $a = shift;

$@=undef;
if (!$a->{id}) {
    $@ = "Geo::GPS::Data::Storage::RAM: Missing required parameter: id";
    return 0;
};

if (exists $s->{data}{collections}{$a->{id}}) {
    delete $s->{data}{collections}{$a->{id}};
    return 1;
    } else {
    $@ = "Geo::GPS::Data::Storage::RAM: Non existing waypoint collection Id: ".$a->{id};
    return 0;
};
};

#######################################
sub exists_collection {
my $s = shift;
my $a = shift;

$@=undef;
if (!$a->{id}) {
    $@ = "Geo::GPS::Data::Storage::RAM: Missing required parameter: id";
    return 0;
};

return exists $s->{data}{collections}{$a->{id}};
};

1;

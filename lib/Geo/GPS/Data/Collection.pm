# Copyright (c) 2003 Nuno Nunes <nfmnunes@cpan.org>.
# All rights reserved. This program is free software;
# you can redistribute it and/or modify it under the same terms as Perl itself.
#
# $Id: Collection.pm,v 1.3.2.4 2003/04/11 11:11:54 nfn Exp $
#

package Geo::GPS::Data::Collection;

use strict;
use Date::Manip;
use Geo::GPS::Data::Waypoint;

#######################################
sub new {
    my $s = shift;
    my $a = shift;
    
    $@=undef;
    my $data = {};
    if ($a->{storage}) {
        $data->{cache}{STORAGE} = $a->{storage};
        } else {
        $@ = "Geo::GPS::Data::Collection: Mising argument in call to new()";
    }
    return bless $data, $s;
};

#######################################
sub name {
    my $s = shift;
    my $a = shift;
    
    $@ = undef;
    if ($a) {
        if (ref($a) eq 'HASH') {
            if (!exists $a->{name} || !defined $a->{name}) {
                $@ = "Geo::GPS::Data::Collection: Did not receive required parameter: name";
                return 0;
            };
            if (length($a->{name})>40) {
                $@ = "Name too big";
                return 0;
            };
            $s->{data}{name} = $a->{name};
            } else {
            if (!$a) {
                $@ = "Geo::GPS::Data::Collection: Did not receive required parameter: name";
                return 0;
            };
            if (length($a)>40) {
                $@ = "Geo::GPS::Data::Collection: Name too big";
                return 0;
            };
            $s->{data}{name} = $a;
            return 1;
        };
        } else {
        return $s->{data}{name};
    }
};

#######################################
sub comment {
    my $s = shift;
    my $a = shift;
    
    $@=undef;
    if ($a) {
        if (ref($a) eq 'HASH') {
            if (!exists $a->{comment} || !defined $a->{comment}) {
                $s->{data}{comment} = '';
                return 1;
            };
            if (length($a->{comment})>255) {
                $@ = "Geo::GPS::Data::Collection: Comment too big";
                return 0;
            };
            $s->{data}{comment} = $a->{comment};
            } else {
            if (!$a) {
                $s->{data}{comment} = '';
                return 1;
            };
            if (length($a)>255) {
                $@ = "Geo::GPS::Data::Collection: Comment too big";
                return 0;
            };
            $s->{data}{comment} = $a;
        };
        return 1;
        } else {
        return $s->{data}{comment};
    };
};

#######################################
sub date_collected {
    my $s = shift;
    my $a = shift;
    
    $@=undef;
    if ($a) {
        if (ref($a) eq 'HASH') {
            if (!exists $a->{date_collected} || !defined $a->{date_collected}) {
                $s->{data}{date_collected} = '';
                return 1;
            };
            my $date = &ParseDate($a->{date_collected});
            if (!$date) {
                $@ = "Geo::GPS::Data::Collection: Received an invalid date: ".$a->{date_collected};
                return 0;
            };
            $s->{data}{date_collected} = $a->{date_collected};
            return 1;
            } else {
            if (!$a) {
                $s->{data}{date_collected} = '';
                return 1;
            };
            my $date = &ParseDate($a);
            if ($date) {
                $@ = "Geo::GPS::Data::Collection: Received an invalid date: ".$a;
                return 0;
            };
            $s->{data}{date_collected} = $a;
        }
        } else {
        return $s->{data}{date_collected};
    }
};

#######################################
sub id {
    my $s = shift;
    my $a = shift;
    
    $@=undef;
    if ($a) {
        $@ = "Geo::GPS::Data::Collection: Cannot change this field";
        return 0;
    };
    return $s->{data}{id};
};

#######################################
sub create {
    my $s = shift;
    my $a = shift;
    
    # Mandatory items
    $s->name($a) || return 0;
    
    # Optional items
    $s->comment($a) || return 0;
    $s->date_collected($a) || return 0;
    
    # Internal stuff
    $s->{data}{type} = 'generic';
    return 1;
};

#######################################
sub save {
    my $s = shift;
    
    my $store = $s->{cache}{STORAGE};
    my $id = $store->store_collection({
        name => $s->name(),
        type => $s->{data}{type},
        comment => $s->comment(),
        date_collected => $s->date_collected(),
        waypoints => $s->{points},
    }) || return 0;
    $s->{data}{id} = $id;
    return $id;
};

#######################################
sub delete {
    my $s = shift;
    my $a = shift;
    
    my $store = $s->{cache}{STORAGE};
    $store->delete_collection({id => $s->{data}{id}}) || return 0;
    return 1;
};

#######################################
sub load {
    my $s = shift;
    my $a = shift;
    
    $@ = undef;
    if (!exists $a->{id} || !defined $a->{id}) {
        $@ = "Geo::GPS::Data::Collection: Missing required parameter: id";
        return 0;
    }
    
    my $store = $s->{cache}{STORAGE};
    my $b = $store->retrieve_collection($a) || return 0;
    
    $s->{data}{id} = $b->{id};
    # Mandatory items
    $s->name($b) || return 0;
    
    # Optional items
    $s->comment($b) || return 0;
    $s->date_collected($b) || return 0;
    $s->{points} = $b->{waypoints};
    
    # Internal stuff
    $s->{data}{type} = 'generic';
    
    return 1;
};

#######################################
sub next_point {
    my $s = shift;
    
    $@ = undef;
    if (!$s->{points}) {
        $@ = "Geo::GPS::Data::Collection: No waypoints in this collection yet";
        return 0;
    };
    $s->{state}{current_point} = 0 unless $s->{state}{current_point};
    if (exists $s->{points}[$s->{state}{current_point}]) {
        my $wp = Geo::GPS::Data::Waypoint->new({
            storage => $s->{cache}{STORAGE}
        }) || return 0;
        if ($wp->load({id => $s->{points}[$s->{state}{current_point}]})) {
            $s->{state}{current_point}++;
            return $wp;
            } else {
            return 0;
        }
        } else {
        $@ = "Geo::GPS::Data::Collection: Cannot go beyond last point in the collection";
        return 0;
    }
};

#######################################
sub previous_point {
    my $s = shift;
    
    $@ = undef;
    if (!$s->{state}{current_point}) {
        $@ = "Geo::GPS::Data::Collection: No waypoints in this collection yet";
        return 0;
    };
    if (exists $s->{points}[$s->{state}{current_point}-1]) {
        my $wp = Geo::GPS::Data::Waypoint->new({
            storage => $s->{cache}{STORAGE}
        }) || return 0;
        if ($wp->load({id => $s->{points}[$s->{state}{current_point}]})) {
            $s->{state}{current_point}--;
            return $wp;
            } else {
            return 0;
        }
        } else {
        $@ = "Geo::GPS::Data::Collection: Cannot go beyond last point in the collection";
        return 0;
    }
};

#######################################
sub all_points {
    my $s = shift;
    
    my $r;
    foreach (@{$s->{points}}) {
        my $wp = Geo::GPS::Data::Waypoint->new({
            storage => $s->{cache}{STORAGE}
        }) || return 0;
        if ($wp->load({id => $_})) {
            push @$r, $wp;
            } else {
            return 0;
        }
    };
    return $r;
};

#######################################
sub insert_point {
    my $s = shift;
    my $a = shift;
    
    $@ = undef;
    if (!$a->{point} || !$a->{point}->isa('Geo::GPS::Data::Waypoint')) {
        $@ = "Geo::GPS::Data::Collection: Didn't receive a valid waypoint object in insert_waypoint";
        return 0;
    };
    my $store = $s->{cache}{STORAGE};
    if ($store->exists_waypoint({id => $a->{point}->id()})) {
        push @{$s->{points}}, $a->{point}->id();
        } elsif ($@) {
        return 0
        } else {
    $@ = "Geo::GPS::Data::Collection: No such waypoint in storage (id=".$a->id().")";
    return 0
};
return 1;
};

#######################################
sub remove_point {
my $s = shift;
my $a = shift;

$@ = undef;
return 1;
};

#######################################
sub point_belongs {
my $s = shift;
my $a = shift;

$@ = undef;
if (!$a->{point} || !$a->{point}->isa('Geo::GPS::Data::Waypoint')) {
    $@ = "Geo::GPS::Data::Collection: Didn't receive a valid waypoint object in point_belongs";
    return 0;
};

my $id = $a->{point}->id() || return 0;
foreach (@{$s->{points}}) {
    print "Comparing $_ with $id...\n";
    if ($_ == $id) { return 1 }
};
return 0;
};


1;

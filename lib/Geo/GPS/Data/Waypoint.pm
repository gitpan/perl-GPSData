# Copyright (c) 2003 Nuno Nunes <nfmnunes@cpan.org>.
# All rights reserved. This program is free software; 
# you can redistribute it and/or modify it under the same terms as Perl itself.
#
# $Id: Waypoint.pm,v 1.8 2003/03/26 00:13:08 nfn Exp $
#

package Geo::GPS::Data::Waypoint;

use strict;
use Date::Manip;
use Geo::GPS::Data::Storage::MySQL;
use Geo::GPS::Data::Ellipsoid;

#######################################
sub new {
        my $s = shift;

        return bless {}, $s;
};

#######################################
sub _init {
        my $s = shift;

        if (!$s->{_storage}) {
                $s->{_storage} = Geo::GPS::Data::Storage::MySQL->new();
        };
        return $s->{_storage};
};

#######################################
# Reads the waypoint types into an hash and cache it in the object
# TODO: _waypoint_types: Do I need to have a care for expiring the cache? How?
sub _waypoint_types {
        my $s = shift;

        if (!$s->{_waypoint_types}) {
                my $t = Geo::GPS::Data::Storage::MySQL->new();
                $s->{_waypoint_types} = $t->waypoint_types();
        };
        return $s->{_waypoint_types};
};

#######################################
sub name {
	my $s = shift;
	my $a = shift;

	$@=undef;
	if ($a) {
		if (ref($a) eq 'HASH') {
			if (!exists $a->{name} || !defined $a->{name}) {
        			$@ = "Did not receive required parameter: name";
				return 0;
			};
        		if (length($a->{name})>40) {
				$@ = "Name too big";
				return 0;
			};
			$s->{name} = lc($a->{name});
		} else {
			if (!$a) {
				$@ = "Did not receive required parameter: name";
				return 0;
			};
			if (length($a)>40) {
				$@ = "Name too big";
				return 0;				
			};
			$s->{name} = lc($a);
		};
	} else {
		return $s->{name};
	}
};

#######################################
sub latitude {
	my $s = shift;
	my $a = shift;

	$@=undef;
	if ($a) {
		if (ref($a) eq 'HASH') {
			if (!exists $a->{latitude} || !defined $a->{latitude}) {
        			$@ = "Did not receive required parameter: latitude";
				return 0;
			};
			$s->{latitude} = $a->{latitude};
		} else {
			if (!$a) {
				$@ = "Did not receive required parameter: latitude";
				return 0;
			};
			$s->{latitude} = $a;
		};
	} else {
		return $s->{latitude};
	}
};

#######################################
sub longitude {
	my $s = shift;
	my $a = shift;

	$@=undef;
	if ($a) {
		if (ref($a) eq 'HASH') {
			if (!exists $a->{longitude} || !defined $a->{longitude}) {
        			$@ = "Did not receive required parameter: longitude";
				return 0;
			};
			$s->{longitude} = $a->{longitude};
		} else {
			if (!$a) {
				$@ = "Did not receive required parameter: longitude";
				return 0;
			};
			$s->{longitude} = $a;
		};
	} else {
		return $s->{longitude};
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
				$s->{comment} = '';
				return 1;
			};
			if (length($a->{comment})>255) {
				$@ = "Comment too big";
				return 0;
			};
			$s->{comment} = lc($a->{comment});
		} else {
			if (!$a) {
				$s->{comment} = '';
				return 1;
			};
			if (length($a)>255) {
				$@ = "Comment too big";
				return 0;				
			};
			$s->{comment} = lc($a);
		};
		return 1;
	} else {
		return $s->{comment};
	};
};

#######################################
sub type {
	my $s = shift;
	my $a = shift;

	$@=undef;
	my $waypoint_types = $s->_waypoint_types;
	if (!$waypoint_types) {
		$@ = "Error getting waypoint types";
		return 0;
	};
	if ($a) {
		if (ref($a) eq 'HASH') {
			$a->{type_id} = 0 unless $a->{type_id};
			if (!$a->{type_id}) {
				if (exists $a->{type} && defined $a->{type}) {
					my ($type_elem) = grep {lc($_->{name}) eq lc($a->{type})} @{$waypoint_types};
					$s->{type} = $type_elem->{name};
					$s->{type_id} = $type_elem->{id};
					return 1;
				} else {
					$s->{type_id}=1;
					my ($type_elem) = grep {$_->{id} == $s->{type_id}} @{$waypoint_types};
					$s->{type} = $type_elem->{name};
					return 1;
				}
			} else {
				my ($type_elem) = grep {$_->{id} == $a->{type_id}} @{$waypoint_types};
				if ($type_elem) {
					$s->{type} = $type_elem->{name};
					$s->{type_id} = $type_elem->{id};
					return 1;
				}
			};
			if (!$a->{type_id}) {
				$@ = "Could not find right waypoint type";
				return 0;
			}
		} else {
			my ($type_elem) = grep {lc($_->{name}) eq lc($a)} @{$waypoint_types};
			if ($type_elem) {
				$s->{type_id} = $type_elem->{id};
				$s->{type} = $type_elem->{name};
				return 1;
			}
			$@ = "No such waypoint type";
			return 0;
		}
	} else {
		return $s->{type};
	}
};

#######################################
sub date_collected {
	my $s = shift;
	my $a = shift;

	$@=undef;
	if ($a) {
		if (ref($a) eq 'HASH') {
			if (!exists $a->{date_collected} || !defined $a->{date_collected}) {
				$s->{date_collected} = '';
				return 1;
			};
			my $date = &ParseDate($a->{date_collected});
			if (!$date) {
				$@ = "Received an invalid date: ".$a->{date_collected};
				return 0;
			};
			$s->{date_collected} = $a->{date_collected};
			return 1;
		} else {
			if (!$a) {
				$s->{date_collected} = '';
				return 1;
			};
			my $date = &ParseDate($a);
			if ($date) {
				$@ = "Received an invalid date: ".$a;
				return 0;
			};
			$s->{date_collected} = $a;
		}
	} else {
		return $s->{date_collected};
	}
};

#######################################
sub ellipsoid {
	my $s = shift;
	my $a = shift;

	$@=undef;
	if ($a) {
		my $e = Geo::GPS::Data::Ellipsoid->new();
		if (!$e) {
			$@ = "Error getting ellipsoid types";
			return 0;
		};
		if (ref($a) eq 'HASH') {
			if (!exists $a->{ellipsoid} || !defined $a->{ellipsoid}) {
				$@ = "Did not receive required parameter: ellipsoid";
				return 0;
			};
			if (!$e->id_from_ellipsoid({ellipsoid=>$a->{ellipsoid}})) {
				$@ = "Ellipsoid not supported".$a->{ellipsoid};
				return 0;
			};
			$s->{ellipsoid} = $a->{ellipsoid};
			$s->{ellipsoid_id} = $e->id_from_ellipsoid({ellipsoid=>$a->{ellipsoid}});
		} else {
			if (!$e->id_from_ellipsoid({ellipsoid=>$a})) {
				$@ = "Ellipsoid not supported".$a;
				return 0;
			};
			$s->{ellipsoid} = $a;
			$s->{ellipsoid_id} = $e->id_from_ellipsoid({ellipsoid=>$a});
		}
	} else {
		return $s->{ellipsoid};
	}
};

#######################################
sub id {
	my $s = shift;
	my $a = shift;

	$@=undef;
	if ($a) {
		$@ = "Cannot change this field";
		return 0;
	};
	return $s->{id};
};

#######################################
sub create {
	my $s = shift;
	my $a = shift;

	# Compulsory items
	$s->name($a) || return 0;
	$s->latitude($a) || return 0;
	$s->longitude($a) || return 0;
	$s->type($a) || return 0;
	$s->ellipsoid($a) || return 0;
	
	# Optional items
	$s->comment($a) || return 0;
	$s->date_collected($a) || return 0;
	return 1;
};

#######################################
sub save {
        my $s = shift;

        my $store = $s->_init();
	# TODO: What an ugly hack! I should list all the items I whish to
	# send to the function but right now I just don't feel like it... :)
        my $id = $store->store_waypoint($s) || return 0;
	$s->{id} = $id;
        return $id;
};

#######################################
sub delete {
        my $s = shift;

        my $store = $s->_init();
	# TODO: What an ugly hack! I should list all the items I whish to
	# send to the function but right now I just don't feel like it... :)
        my $id = $store->delete_waypoint($s) || return 0;
        return 1;
};

#######################################
sub load {
	my $s = shift;
	my $a = shift;
	
	$@=undef;
	if (!exists $a->{id} || !defined $a->{id}) {
		$@ = "Missing required parameter: id";
		return 0;
	}
		
        my $store = $s->_init();
	my $b = $store->retrieve_waypoint($a) || return 0;
	
	$s->{id} = $b->{id};
	# Compulsory items
	$s->name($b) || return 0;
	$s->latitude($b) || return 0;
	$s->longitude($b) || return 0;
	$s->type($b) || return 0;
	$s->ellipsoid($b) || return 0;
	
	# Optional items
	$s->comment($b) || return 0;
	$s->date_collected($b) || return 0;
	
	return 1;
};

#######################################
sub hash_dump {
	my $s = shift;
	
	my $h;

	$h->{id} = $s->{id} if $s->{id};
	$h->{name} = $s->name() || return 0;
	$h->{latitude} = $s->latitude() || return 0;
	$h->{longitude} = $s->longitude() || return 0;
	$h->{type} = $s->type() || return 0;
	$h->{ellipsoid} = $s->ellipsoid() || return 0;
	$h->{comment} = $s->comment();
	if (($h->{comment} == 0) && $@) { return 0 };
	$h->{date_collected} = $s->date_collected() || return 0;
	if (($h->{date_collected} == 0) && $@) { return 0 };
	
	return $h;
};

1;

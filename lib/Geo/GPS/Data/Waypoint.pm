# Copyright (c) 2003 Nuno Nunes <nfmnunes@cpan.org>.
# All rights reserved. This program is free software; 
# you can redistribute it and/or modify it under the same terms as Perl itself.
#
# $Id: Waypoint.pm,v 1.10 2003/03/28 19:07:29 nfn Exp $
#

package Geo::GPS::Data::Waypoint;

use strict;
use Date::Manip;
use Geo::GPS::Data::Ellipsoid;
use Geo::GPS::Data::Storage;

#######################################
sub new {
        my $s = shift;
	my $a = shift;

	$@=undef;
	my $data = {};
	if ($a->{storage_params}) {
		$data->{config}{STORAGE_PARAMS} = $a->{storage_params};
	};
	if ($a->{storage}) {
		$data->{config}{STORAGE} = $a->{storage};
	}
        return bless $data, $s;
};

#######################################
sub _init {
        my $s = shift;

        if (!$s->{cache}{STORAGE}) {
		$s->{cache}{STORAGE} = Geo::GPS::Data::Storage->new({
			storage => $s->{config}{STORAGE},
			storage_params => $s->{config}{STORAGE_PARAMS}
		});
        };
        return $s->{cache}{STORAGE};
};

#######################################
# Reads the waypoint types into an hash and cache it in the object
sub _waypoint_types {
        my $s = shift;

        if (!$s->{cache}{WAYPOINT_TYPES}) {
		my $st = $s->_init();
                $s->{cache}{WAYPOINT_TYPES} = $st->waypoint_types();
        };
        return $s->{cache}{WAYPOINT_TYPES};
};

#######################################
sub name {
	my $s = shift;
	my $a = shift;

	$@=undef;
	if ($a) {
		if (ref($a) eq 'HASH') {
			if (!exists $a->{name} || !defined $a->{name}) {
        			$@ = "Geo::GPS::Data::Waypoint: Did not receive required parameter: name";
				return 0;
			};
        		if (length($a->{name})>40) {
				$@ = "Name too big";
				return 0;
			};
			$s->{data}{name} = lc($a->{name});
		} else {
			if (!$a) {
				$@ = "Geo::GPS::Data::Waypoint: Did not receive required parameter: name";
				return 0;
			};
			if (length($a)>40) {
				$@ = "Geo::GPS::Data::Waypoint: Name too big";
				return 0;				
			};
			$s->{data}{name} = lc($a);
		};
	} else {
		return $s->{data}{name};
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
        			$@ = "Geo::GPS::Data::Waypoint: Did not receive required parameter: latitude";
				return 0;
			};
			$s->{data}{latitude} = $a->{latitude};
		} else {
			if (!$a) {
				$@ = "Geo::GPS::Data::Waypoint: Did not receive required parameter: latitude";
				return 0;
			};
			$s->{data}{latitude} = $a;
		};
	} else {
		return $s->{data}{latitude};
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
        			$@ = "Geo::GPS::Data::Waypoint: Did not receive required parameter: longitude";
				return 0;
			};
			$s->{data}{longitude} = $a->{longitude};
		} else {
			if (!$a) {
				$@ = "Geo::GPS::Data::Waypoint: Did not receive required parameter: longitude";
				return 0;
			};
			$s->{data}{longitude} = $a;
		};
	} else {
		return $s->{data}{longitude};
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
				$@ = "Geo::GPS::Data::Waypoint: Comment too big";
				return 0;
			};
			$s->{data}{comment} = lc($a->{comment});
		} else {
			if (!$a) {
				$s->{data}{comment} = '';
				return 1;
			};
			if (length($a)>255) {
				$@ = "Geo::GPS::Data::Waypoint: Comment too big";
				return 0;				
			};
			$s->{data}{comment} = lc($a);
		};
		return 1;
	} else {
		return $s->{data}{comment};
	};
};

#######################################
sub type {
	my $s = shift;
	my $a = shift;

	$@=undef;
	my $waypoint_types = $s->_waypoint_types;
	if (!$waypoint_types) {
		$@ = "Geo::GPS::Data::Waypoint: Error getting waypoint types";
		return 0;
	};
	if ($a) {
		if (ref($a) eq 'HASH') {
			$a->{type_id} = 0 unless $a->{type_id};
			if (!$a->{type_id}) {
				if (exists $a->{type} && defined $a->{type}) {
					my ($type_elem) = grep {lc($_->{name}) eq lc($a->{type})} @{$waypoint_types};
					$s->{data}{type} = $type_elem->{name};
					$s->{data}{type_id} = $type_elem->{id};
					return 1;
				} else {
					$s->{data}{type_id}=1;
					my ($type_elem) = grep {$_->{id} == $s->{data}{type_id}} @{$waypoint_types};
					$s->{data}{type} = $type_elem->{name};
					return 1;
				}
			} else {
				my ($type_elem) = grep {$_->{id} == $a->{type_id}} @{$waypoint_types};
				if ($type_elem) {
					$s->{data}{type} = $type_elem->{name};
					$s->{data}{type_id} = $type_elem->{id};
					return 1;
				}
			};
			if (!$a->{type_id}) {
				$@ = "Geo::GPS::Data::Waypoint: Could not find right waypoint type";
				return 0;
			}
		} else {
			my ($type_elem) = grep {lc($_->{name}) eq lc($a)} @{$waypoint_types};
			if ($type_elem) {
				$s->{data}{type_id} = $type_elem->{id};
				$s->{data}{type} = $type_elem->{name};
				return 1;
			}
			$@ = "Geo::GPS::Data::Waypoint: No such waypoint type: $a";
			return 0;
		}
	} else {
		return $s->{data}{type};
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
				$s->{data}{date_collected} = '';
				return 1;
			};
			my $date = &ParseDate($a->{date_collected});
			if (!$date) {
				$@ = "Geo::GPS::Data::Waypoint: Received an invalid date: ".$a->{date_collected};
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
				$@ = "Geo::GPS::Data::Waypoint: Received an invalid date: ".$a;
				return 0;
			};
			$s->{data}{date_collected} = $a;
		}
	} else {
		return $s->{data}{date_collected};
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
			$@ = "Geo::GPS::Data::Waypoint: Error getting ellipsoid types";
			return 0;
		};
		if (ref($a) eq 'HASH') {
			if (!exists $a->{ellipsoid} || !defined $a->{ellipsoid}) {
				$@ = "Geo::GPS::Data::Waypoint: Did not receive required parameter: ellipsoid";
				return 0;
			};
			if (!$e->id_from_ellipsoid({ellipsoid=>$a->{ellipsoid}})) {
				$@ = "Geo::GPS::Data::Waypoint: Ellipsoid not supported".$a->{ellipsoid};
				return 0;
			};
			$s->{data}{ellipsoid} = $a->{ellipsoid};
			$s->{data}{ellipsoid_id} = $e->id_from_ellipsoid({ellipsoid=>$a->{ellipsoid}});
		} else {
			if (!$e->id_from_ellipsoid({ellipsoid=>$a})) {
				$@ = "Geo::GPS::Data::Waypoint: Ellipsoid not supported".$a;
				return 0;
			};
			$s->{data}{ellipsoid} = $a;
			$s->{data}{ellipsoid_id} = $e->id_from_ellipsoid({ellipsoid=>$a});
		}
	} else {
		return $s->{data}{ellipsoid};
	}
};

#######################################
sub id {
	my $s = shift;
	my $a = shift;

	$@=undef;
	if ($a) {
		$@ = "Geo::GPS::Data::Waypoint: Cannot change this field";
		return 0;
	};
	return $s->{data}{id};
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
        my $id = $store->store_waypoint($s->{data}) || return 0;
	$s->{data}{id} = $id;
        return $id;
};

#######################################
sub delete {
        my $s = shift;

        my $store = $s->_init();
        my $id = $store->delete_waypoint($s->{data}) || return 0;
        return 1;
};

#######################################
sub load {
	my $s = shift;
	my $a = shift;
	
	$@=undef;
	if (!exists $a->{id} || !defined $a->{id}) {
		$@ = "Geo::GPS::Data::Waypoint: Missing required parameter: id";
		return 0;
	}
		
        my $store = $s->_init();
	my $b = $store->retrieve_waypoint($a) || return 0;
	
	$s->{data}{id} = $b->{id};
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

	$h->{id} = $s->{data}{id} if $s->{data}{id};
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

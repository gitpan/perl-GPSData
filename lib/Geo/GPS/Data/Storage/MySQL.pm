# Copyright (c) 2003 Nuno Nunes <nfmnunes@cpan.org>.
# All rights reserved. This program is free software; 
# you can redistribute it and/or modify it under the same terms as Perl itself.
#
# $Id: MySQL.pm,v 1.8 2003/03/26 00:29:56 nfn Exp $
#

package Geo::GPS::Data::Storage::MySQL;

use strict;
use Date::Manip;
use DBI;

#######################################
sub new {
	my $s = shift;

	return bless {}, $s;
};

#######################################
sub _init {
        my $s = shift;

        if (!$s->{DBH}) {
                $s->{DBH} = DBI->connect('dbi:mysql:database=gpsdata;host=localhost',
                        'gpstst', 'zbr.zbr', {RaiseError => 1});
        };
        return $s->{DBH};
};

#######################################
sub waypoint_types {
        my $s = shift;

	$@=undef;
        if (!$s->{WAYPOINT_TYPES}) {
                my $dbh = $s->_init;
                eval {
                        my $sth = $dbh->prepare(qq{
                                SELECT LOWER(name) AS name, id
                                FROM waypoint_types
                        });
                        $sth->execute();
			while (my $a = $sth->fetchrow_hashref) {
                        	push @{$s->{WAYPOINT_TYPES}}, $a;
			}
                };
                if ($@) {
                        return 0;
                };
        };
        return $s->{WAYPOINT_TYPES};
};

#######################################
sub store_waypoint {
	my $s = shift;
	my $a = shift;
	
	$@=undef;
	if (!$a->{name}) {
                $@ = "Missing data: name";
                return 0;
        };
	if (!$a->{latitude}) {
                $@ = "Missing data: latitude";
                return 0;
        };
	if (!$a->{longitude}) {
                $@ = "Missing data: longitude";
                return 0;
        };
	if (!$a->{type_id}) {
                $@ = "Missing data: type_id";
                return 0;
        };
	if (!$a->{ellipsoid}) {
                $@ = "Missing data: ellipsoid";
                return 0;
        };
	my $date;
	if ($a->{date_collected}) {
		$date = &ParseDate($a->{date_collected});
		if ($date) {
			$date = &UnixDate($date, "%q");
		} else {
			$@ = "Received an invalid date: ".$a->{date_collected};
			return 0;
		}
	};

	my $dbh = $s->_init();

	if ($a->{id}) {
	        eval {
	                my $sth = $dbh->prepare( qq{
	                        UPDATE waypoints
	                        SET
	                                name = LOWER(?),
	                                latitude = ?,
	                                longitude = ?,
	                                comment = LOWER(?),
	                                type_id = ?,
	                                date_collected = ?,
	                                ellipsoid = ?
	                        WHERE id = ?
	                        });
	                $sth->execute(
	                        $a->{name},
	                        $a->{latitude},
	                        $a->{longitude},
	                        $a->{comment},
	                        $a->{type_id},
	                        $date,
	                        $a->{ellipsoid},
	                        $a->{id}
	                );
	        };
	        if ($@) {
	                return 0;
	        };
		return $a->{id};
	} else {
		my $wp_id;
	        eval {
	                my $sth = $dbh->prepare( qq{
	                                INSERT INTO waypoints
	                                        (id, name, latitude, longitude, comment, type_id, date_collected, ellipsoid)
	                                VALUES
	                                        (0, LOWER(?), ?, ?, LOWER(?), ?, ?, ?)
	                        });
	                $sth->execute(
	                        $a->{name},
	                        $a->{latitude},
	                        $a->{longitude},
	                        $a->{comment},
	                        $a->{type_id},
	                        $date,
	                        $a->{ellipsoid}
	                );
	                $wp_id = $dbh->{mysql_insertid};
	        };
	        if ($@) {
	                return 0;
	        };
	
	        return $wp_id;
	}
};

#######################################
sub retrieve_waypoint {
        my $s = shift;
        my $a = shift;

	$@=undef;
        if (!$a->{id}) {
                $@ = "Missing required parameter: id";
                return 0;
        };

        my $dbh = $s->_init();
        my $r;
        eval {
                my $sth = $dbh->prepare(qq{
                        SELECT  id,
                                name, 
                                latitude,
                                longitude,
                                comment,
                                type_id,
                                date_collected,
                                ellipsoid
                        FROM    waypoints
                        WHERE   id = ?

                });
                $sth->execute($a->{id});
                $r = $sth->fetchall_hashref('id')->{$a->{id}};
        };
        if ($@) {
                return 0;
        };
	$r->{date_collected} = &UnixDate($r->{date_collected}, "%c");
        return $r;
};

#######################################
sub delete_waypoint {
        my $s = shift;
        my $a = shift;

	$@=undef;
        if (!$a->{id}) {
                $@ = "Missing required parameter: id";
                return 0;
        };

        my $dbh = $s->_init();
        my $r;
        eval {
                my $sth = $dbh->prepare(qq{
			DELETE
                        FROM    waypoints
                        WHERE   id = ?

                });
                $sth->execute($a->{id});
        };
        if ($@) {
                return 0;
        };
        return 1;
};

1;

# Copyright (c) 2003 Nuno Nunes <nfmnunes@cpan.org>.
# All rights reserved. This program is free software;
# you can redistribute it and/or modify it under the same terms as Perl itself.
#
# $Id: MySQL.pm,v 1.16.2.2 2003/04/11 11:10:41 nfn Exp $
#

package Geo::GPS::Data::Storage::MySQL;

use strict;
use Date::Manip;
use DBI;
our @ISA = 'Geo::GPS::Data::Storage';

#######################################
sub new {
    my $s = shift;
    my $a = shift;
    
    my $data;
    if ($a->{database}) {
        $data->{config}{_DBNAME}=$a->{database}
        } else {
        $data->{config}{_DBNAME}='gpsdata'
    };
    if ($a->{host}) {
        $data->{config}{_DBHOST}=$a->{host}
        } else {
        $data->{config}{_DBHOST}='localhost'
    };
    if ($a->{username}) {
        $data->{config}{_DBUSERNAME}=$a->{username}
        } else {
        $data->{config}{_DBUSERNAME}='gpstst'
    };
    if ($a->{password}) {
        $data->{config}{_DBPASSWD}=$a->{password}
        } else {
        $data->{config}{_DBPASSWD}='zbr.zbr'
    };
    return bless $data, $s;
};

#######################################
sub _init {
    my $s = shift;
    
    if (!$s->{cache}{DBH}) {
        $s->{cache}{DBH} = DBI->connect(
            'dbi:mysql:database='.$s->{config}{_DBNAME}.';host='.$s->{config}{_DBHOST},
            $s->{config}{_DBUSERNAME},
            $s->{config}{_DBPASSWD},
        {RaiseError => 1});
    };
    return $s->{cache}{DBH};
};

#######################################
sub waypoint_types {
    my $s = shift;
    
    $@=undef;
    if (!$s->{cache}{WAYPOINT_TYPES}) {
        my $dbh = $s->_init;
        eval {
            my $sth = $dbh->prepare(qq{
                SELECT name, id, comment
                FROM waypoint_types
            });
            $sth->execute();
            while (my $a = $sth->fetchrow_hashref) {
                push @{$s->{cache}{WAYPOINT_TYPES}}, $a;
            }
        };
        if ($@) {
            $@ = "Geo::GPS::Data::Storage::MySQL: $@";
            return 0;
        };
    };
    return $s->{cache}{WAYPOINT_TYPES};
};

#######################################
sub store_waypoint {
    my $s = shift;
    my $a = shift;
    
    $@=undef;
    if (!$a->{name}) {
        $@ = "Geo::GPS::Data::Storage::MySQL: Missing data: name";
        return 0;
    };
    if (!$a->{latitude}) {
        $@ = "Geo::GPS::Data::Storage::MySQL: Missing data: latitude";
        return 0;
    };
    if (!$a->{longitude}) {
        $@ = "Geo::GPS::Data::Storage::MySQL: Missing data: longitude";
        return 0;
    };
    if (!$a->{type_id}) {
        $@ = "Geo::GPS::Data::Storage::MySQL: Missing data: type_id";
        return 0;
    };
    if (!$a->{ellipsoid}) {
        $@ = "Geo::GPS::Data::Storage::MySQL: Missing data: ellipsoid";
        return 0;
    };
    my $date;
    if ($a->{date_collected}) {
        $date = &ParseDate($a->{date_collected});
        if ($date) {
            $date = &UnixDate($date, "%q");
            } else {
            $@ = "Geo::GPS::Data::Storage::MySQL: Received an invalid date: ".$a->{date_collected};
            return 0;
        }
    };
    
    my $dbh = $s->_init();
    
    if ($a->{id}) {
        eval {
            my $sth = $dbh->prepare( qq{
                UPDATE waypoints
                SET
                name = ?,
                latitude = ?,
                longitude = ?,
                comment = ?,
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
            $@ = "Geo::GPS::Data::Storage::MySQL: $@";
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
                (0, ?, ?, ?, ?, ?, ?, ?)
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
            $@ = "Geo::GPS::Data::Storage::MySQL: $@";
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
        $@ = "Geo::GPS::Data::Storage::MySQL: Missing required parameter: id";
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
        $@ = "Geo::GPS::Data::Storage::MySQL: $@";
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
        $@ = "Geo::GPS::Data::Storage::MySQL: Missing required parameter: id";
        return 0;
    };
    
    my $dbh = $s->_init();
    eval {
        my $sth = $dbh->prepare(qq{
            DELETE
            FROM    waypoints
            WHERE   id = ?
            
        });
        $sth->execute($a->{id});
    };
    if ($@) {
        $@ = "Geo::GPS::Data::Storage::MySQL: $@";
        return 0;
    };
    return 1;
};

#######################################
sub exists_waypoint {
    my $s = shift;
    my $a = shift;
    
    $@=undef;
    if (!$a->{id}) {
        $@ = "Geo::GPS::Data::Storage::MySQL: Missing required parameter: id";
        return 0;
    };
    
    my $dbh = $s->_init();
    my $r;
    eval {
        my $sth = $dbh->prepare(qq{
            SELECT  *
            FROM    waypoints
            WHERE   id = ?
            
        });
        $sth->execute($a->{id});
        $r = $sth->rows;
    };
    if ($@) {
        $@ = "Geo::GPS::Data::Storage::MySQL: $@";
        return 0;
    };
    return $r;
};

#######################################
sub store_collection {
    my $s = shift;
    my $a = shift;
    
    $@=undef;
    if (!$a->{name}) {
        $@ = "Geo::GPS::Data::Storage::MySQL: Missing data: name";
        return 0;
    };
    if (!$a->{type}) {
        $@ = "Geo::GPS::Data::Storage::MySQL: Missing data: type";
        return 0;
    };
    if (!$a->{waypoints} || !(ref($a->{waypoints}) eq 'ARRAY' )) {
        $@ = "Geo::GPS::Data::Storage::MySQL: Missing or invalid data: waypoint list";
        return 0;
    };
    my $date;
    if ($a->{date_collected}) {
        $date = &ParseDate($a->{date_collected});
        if ($date) {
            $date = &UnixDate($date, "%q");
            } else {
            $@ = "Geo::GPS::Data::Storage::MySQL: Received an invalid date: ".$a->{date_collected};
            return 0;
        }
    };
    
    my $dbh = $s->_init();
    
    if ($a->{id}) {
        eval {
            my $sth = $dbh->prepare( qq{
                UPDATE collections
                SET
                name = ?,
                type = ?,
                comment = ?,
                date_collected = ?,
                WHERE id = ?
            });
            $sth->execute(
                $a->{name},
                $a->{type},
                $a->{comment},
                $date,
                $a->{id}
            );
            
            $sth = $dbh->prepare( qq{
                DELETE FROM belongs
                WHERE collection_id = ?
            });
            $sth->execute(
                $a->{id}
            );
            
            $sth = $dbh->prepare( qq{
                INSERT INTO belongs
                (waypoint_id, collection_id)
                VALUES	(?, ?)
            });
            foreach my $p (@{$a->{waypoints}}) {
                $sth->execute(
                    $p,
                    $a->{id}
                )
            }
        };
        if ($@) {
            $@ = "Geo::GPS::Data::Storage::MySQL: $@";
            return 0;
        };
        return $a->{id};
        } else {
        my $col_id;
        eval {
            my $sth = $dbh->prepare( qq{
                INSERT INTO collections
                (id, name, type, comment, date_collected)
                VALUES
                (0, ?, ?, ?, ?)
            });
            $sth->execute(
                $a->{name},
                $a->{type},
                $a->{comment},
                $date,
            );
            $col_id = $dbh->{mysql_insertid};
            
            $sth = $dbh->prepare( qq{
                INSERT INTO belongs
                (waypoint_id, collection_id)
                VALUES  (?, ?)
            });
            foreach my $p (@{$a->{waypoints}}) {
                $sth->execute(
                    $p,
                    $col_id
                )
            }
        };
        if ($@) {
            $@ = "Geo::GPS::Data::Storage::MySQL: $@";
            return 0;
        };
        
        return $col_id;
    }
};

#######################################
sub retrieve_collection {
    my $s = shift;
    my $a = shift;
    
    $@=undef;
    if (!$a->{id}) {
        $@ = "Geo::GPS::Data::Storage::MySQL: Missing required parameter: id";
        return 0;
    };
    
    my $dbh = $s->_init();
    my $r;
    eval {
        my $sth = $dbh->prepare(qq{
            SELECT  id,
            name,
            type,
            comment,
            date_collected
            FROM    collections
            WHERE   id = ?
            
        });
        $sth->execute($a->{id});
        $r = $sth->fetchall_hashref('id')->{$a->{id}};
        $sth = $dbh->prepare(qq{
            SELECT  waypoint_id
            FROM    belongs
            WHERE   collection_id = ?
        });
        $sth->execute($a->{id});
        my @tmp;
        while (@tmp = $sth->fetchrow_array()) {
            push @{$r->{waypoints}}, $tmp[0]
        }
    };
    if ($@) {
        $@ = "Geo::GPS::Data::Storage::MySQL: $@";
        return 0;
    };
    $r->{date_collected} = &UnixDate($r->{date_collected}, "%c");
    return $r;
};

#######################################
sub delete_collection {
    my $s = shift;
    my $a = shift;
    
    $@=undef;
    if (!$a->{id}) {
        $@ = "Geo::GPS::Data::Storage::MySQL: Missing required parameter: id";
        return 0;
    };
    
    my $dbh = $s->_init();
    eval {
        my $sth = $dbh->prepare(qq{
            DELETE
            FROM    collections
            WHERE   id = ?
            
        });
        $sth->execute($a->{id});
        $sth = $dbh->prepare(qq{
            DELETE
            FROM	belongs
            WHERE	collection_id = ?
        });
        $sth->execute($a->{id});
    };
    if ($@) {
        $@ = "Geo::GPS::Data::Storage::MySQL: $@";
        return 0;
    };
    return 1;
};

#######################################
sub exists_collection {
    my $s = shift;
    my $a = shift;
    
    $@=undef;
    if (!$a->{id}) {
        $@ = "Geo::GPS::Data::Storage::MySQL: Missing required parameter: id";
        return 0;
    };
    
    my $dbh = $s->_init();
    my $r;
    eval {
        my $sth = $dbh->prepare(qq{
            SELECT  *
            FROM    collections
            WHERE   id = ?
            
        });
        $sth->execute($a->{id});
        return $sth->rows;
    };
    if ($@) {
        $@ = "Geo::GPS::Data::Storage::MySQL: $@";
        return 0;
    };
    return 1;
};


1;

# Copyright (c) 2003 Nuno Nunes <nfmnunes@cpan.org>.
# All rights reserved. This program is free software; 
# you can redistribute it and/or modify it under the same terms as Perl itself.
#
# $Id: Storage.pm,v 1.3 2003/03/30 21:55:59 nfn Exp $
#

package Geo::GPS::Data::Storage;

use strict;

#######################################
sub new {
        my $s = shift;
        my $a = shift;

        $@=undef;
	$a->{storage} = 'RAM' unless $a->{storage};
	if ($a->{storage} eq 'RAM') {
		use Geo::GPS::Data::Storage::RAM;
		return Geo::GPS::Data::Storage::RAM->new();
	} elsif ($a->{storage} eq 'MySQL') {
		use Geo::GPS::Data::Storage::MySQL;
		return Geo::GPS::Data::Storage::MySQL->new($a->{storage_params});
	} else {
		$@ = "Geo::GPS::Data::Storage: Unknown storage option: ".$a->{storage};
		return 0;
	}
};

#######################################
sub waypoint_types {
	my $s = shift;
	
	$@ = 'Geo::GPS::Data::Storage Internal Error: This method was not implemented in the storage class you requested';
	return 0;
};

#######################################
sub store_waypoint {
	my $s = shift;
	
	$@ = 'Geo::GPS::Data::Storage Internal Error: This method was not implemented in the storage class you requested';
	return 0;
};

#######################################
sub retrieve_waypoint {
	my $s = shift;
	
	$@ = 'Geo::GPS::Data::Storage Internal Error: This method was not implemented in the storage class you requested';
	return 0;
};

#######################################
sub delete_waypoint {
	my $s = shift;
	
	$@ = 'Geo::GPS::Data::Storage Internal Error: This method was not implemented in the storage class you requested';
	return 0;
};

#######################################
sub exists_waypoint {
	my $s = shift;

	$@ = 'Geo::GPS::Data::Storage Internal Error: This method was not implemented in the storage class you requested';
        return 0;
};

#######################################
sub store_collection {
	my $s = shift;
	
	$@ = 'Geo::GPS::Data::Storage Internal Error: This method was not implemented in the storage class you requested';
	return 0;
};

#######################################
sub retrieve_collection {
	my $s = shift;
	
	$@ = 'Geo::GPS::Data::Storage Internal Error: This method was not implemented in the storage class you requested';
	return 0;
};

#######################################
sub delete_collection {
	my $s = shift;
	
	$@ = 'Geo::GPS::Data::Storage Internal Error: This method was not implemented in the storage class you requested';
	return 0;
};

#######################################
sub exists_collection {
	my $s = shift;

	$@ = 'Geo::GPS::Data::Storage Internal Error: This method was not implemented in the storage class you requested';
        return 0;
};

1;

# Copyright (c) 2003 Nuno Nunes <nfmnunes@cpan.org>.
# All rights reserved. This program is free software; 
# you can redistribute it and/or modify it under the same terms as Perl itself.
#
# $Id: Storage.pm,v 1.1 2003/03/28 19:08:32 nfn Exp $
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

1;

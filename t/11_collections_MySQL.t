#$Id: 11_collections_MySQL.t,v 1.4.2.1 2003/04/13 13:38:11 nfn Exp $

use Test::More tests=>39;

# This is an ugly hack used to make sure the test doesn't crash due to a
# mal-configuration of the machine it runs on. If there is no TimeZone
# configured it will die, so just for the sake of the tests I force a
# TimeZone of GMT.
$ENV{TZ} = 'GMT';

####
BEGIN { use_ok(Geo::GPS::Data); };

my $DB_NAME = 'gpsdata';
my $DB_HOST = 'localhost';
my $DB_USER = 'gpstst';
my $DB_PASS = 'zbr.zbr';

my $mysql_ok=1;
eval{
	use DBI;

	DBI->connect(
            'dbi:mysql:database='.$DB_NAME.';host='.$DB_HOST,
            $DB_USER,
            $DB_PASS,
        {RaiseError => 1}
	);	
};
if ($@) {$mysql_ok=0;};

SKIP: {
	skip "mysql gpsdatabase not found", 38 unless $mysql_ok;
	
	####
	my $d = Geo::GPS::Data->new({
		storage=>'MySQL',
		storage_params=>{
			host    =>$DB_HOST,
			database=>$DB_NAME,
			username=>$DB_USER,
			password=>$DB_PASS
		}
	});
	isa_ok($d, 'Geo::GPS::Data');
	
	####
	my $first_date = scalar localtime;
	my @wps_raw;
	push @wps_raw, {
	        'name'=> 'Test_Waypoint_1',
	        'latitude' => 41.123,
	        'longitude' => -1.123,
	        'date_collected' => $first_date,
	        'type_id' => 1,
	        'ellipsoid' => 'WGS-84'
	};
	push @wps_raw, {
	        'name'=> 'Test_Waypoint_2',
	        'latitude' => 42.123,
	        'longitude' => -2.123,
	        'date_collected' => $first_date,
	        'type_id' => 1,
	        'ellipsoid' => 'WGS-84'
	};
	push @wps_raw, {
	        'name'=> 'Test_Waypoint_3',
	        'latitude' => 43.123,
	        'longitude' => -3.123,
	        'date_collected' => $first_date,
	        'type_id' => 1,
	        'ellipsoid' => 'WGS-84'
	};
	push @wps_raw, {
	        'name'=> 'Test_Waypoint_4',
	        'latitude' => 44.123,
	        'longitude' => -4.123,
	        'date_collected' => $first_date,
	        'type_id' => 1,
	        'ellipsoid' => 'WGS-84'
	};
	my @wps;
	foreach (@wps_raw) {
		my $wp_object;
		ok ($wp_object = $d->add_waypoint($_), 'add_waypoint()') || diag($@);
		ok (my $id = $wp_object->save(), 'save()ing waypoint') || diag($@);
		push @wps, {id=>$id, point=>$wp_object};
	}
	
	####
	my $second_date = scalar localtime;
	my $col_raw = {
		name => 'Test Collection',
		date_collected => $second_date,
		comment => 'Nice random collection just for testing.'
	};
	ok (my $col_object = $d->add_collection($col_raw), 'add_collection()') || diag($@);
	
	####
	isa_ok($col_object, 'Geo::GPS::Data::Collection');
	
	####
	ok ($col_object->name('Nametest1'), 'name()') || diag($@);
	
	####
	ok ($col_object->name({name=>'nametest2'}), 'name() 2nd version') || diag($@);
	
	####
	foreach (@wps) {
		ok ($col_object->insert_point({point => $_->{point}}), 'insert_point()') || diag($@);
	}
	
	####
	foreach (@wps) {
		my $n = $_->{id};
		ok (my $p = $col_object->next_point(), 'next_point()') || diag($@);
		is ($p->id(), $n, "Waypoint $n should have ID=$n") || diag("It seems that waypoint #$n isn't what we expected...");
	};
	
	####
	ok (!$col_object->next_point(), 'next_point() beyond existing points') || diag($@);
	
	####
	ok (my $full_col = $col_object->all_points(), 'getting all_points()') || diag($@);
	foreach (@$full_col){
		isa_ok ($_, 'Geo::GPS::Data::Waypoint');
	};
	
	####
	ok ($col_object->point_belongs({point => @wps[0]->{point}}), 'point_belongs()') || diag($@);
	
	####
	ok ($col_object->save(), 'save()ing the collection') || diag($@);
	
	####
	ok (my $col_object2 = $d->get_collection({id => $col_object->id()}), 'retrieving the collection from storage') || diag($@);
	
	####
	isa_ok ($col_object2, 'Geo::GPS::Data::Collection') || diag("It seems we did ont get back a collection type object...");
	
	####
	#TODO: OUCH!!!! Must see how I can do this in a civilized way...
	is_deeply ($col_object->{data}, $col_object2->{data}, 'Retrieved object correctly from storage');
	
	####
	#TODO: OUCH!!!! Must see how I can do this in a civilized way...
	is_deeply ($col_object->{points}, $col_object2->{points}, 'Retrieved object correctly from storage');
	
	####
	ok ($col_object->delete(), 'deleting collection from storage') || diag($@);
}	
#$Id: 10_waypoints_MySQL.t,v 1.9.2.1 2003/04/13 13:38:11 nfn Exp $

use Test::More tests=>9;

# This is an ugly hack used to make sure the test doesn't crash due to a
# mal-configuration of the machine it runs on. If there is no TimeZone
# configured it will die, so just for the sake of the tests I force a
# TimeZone of GMT.
$ENV{TZ} = 'GMT';

####
BEGIN {
	use_ok(Geo::GPS::Data);
};

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
	skip "mysql gpsdatabase not found", 8 unless $mysql_ok;

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
	my $wp = {
	        'name'=> 'Test_Waypoint_1',
	        'latitude' => 41.123,
	        'longitude' => -1.123,
	        'date_collected' => $first_date,
	        'type_id' => 1,
	        'ellipsoid' => 'WGS-84'
	};
	ok (my $wp_object = $d->add_waypoint($wp), 'add_waypoint()') || diag($@);
	
	####
	isa_ok($wp_object, 'Geo::GPS::Data::Waypoint');
	
	####
	ok ($wp_object->save(), 'save()') || diag($@);
	
	####
	ok (my $wp_object_2 = $d->get_waypoint({id => $wp_object->id()}), 'get_waypoint()') || diag($@);
	
	####
	isa_ok($wp_object_2, 'Geo::GPS::Data::Waypoint');
	
	####
	is_deeply ($wp_object->hash_dump(), $wp_object_2->hash_dump(), 'correctly retrieve waypoint');
	
	####
	ok ($wp_object->delete(), 'delete from storage') || diag($@);
}
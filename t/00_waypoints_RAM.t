#$Id: 00_waypoints_RAM.t,v 1.5 2003/04/13 13:27:42 nfn Exp $

use Test::More tests=>9;

# This is an ugly hack used to make sure the test doesn't crash due to a
# mal-configuration of the machine it runs on. If there is no TimeZone
# configured it will die, so just for the sake of the tests I force a
# TimeZone of GMT.
$ENV{TZ} = 'GMT';

####
BEGIN { use_ok(Geo::GPS::Data); };

####
my $d = Geo::GPS::Data->new();
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
ok (!$wp_object->type('wong_type'), 'invalid type()');

####
ok ($wp_object->type('none'), 'type()') || diag($@);

####
ok ($wp_object->name('Nametest1'), 'name()') || diag($@);

####
ok ($wp_object->name({name=>'nametest2'}), 'name() 2nd version') || diag($@);

####
ok ($wp_object->hash_dump(), 'hash_dump()') || diag($@);

#$Id: 00_waypoints.t,v 1.4 2003/03/28 00:46:32 nfn Exp $

use Test::More tests=>9;

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

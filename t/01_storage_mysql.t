#$Id: 01_storage_mysql.t,v 1.2 2003/03/26 00:40:05 nfn Exp $

#use Test::More tests=>9;
use Test::More skip_all => "Must test for the database existence first";

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
ok ($wp_object->save(), 'save()') || diag($@);

####
ok (my $wp_object_2 = $d->get_waypoint({id => $wp_object->id()}), 'get_waypoint()') || diag($@);

####
isa_ok($wp_object_2, 'Geo::GPS::Data::Waypoint');

####
is_deeply ($wp_object->hash_dump(), $wp_object_2->hash_dump(), 'correctly retrieve waypoint');

####
ok ($wp_object->delete(), 'delete from storage') || diag($@);

# $Id: schema.sql,v 1.5 2003/03/26 00:24:59 nfn Exp $

CREATE DATABASE IF NOT EXISTS gpsdata;

USE gpsdata;

DROP TABLE IF EXISTS waypoints;

CREATE TABLE waypoints (
	id integer UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name char(40) NOT NULL,
	latitude double NOT NULL,
	longitude double NOT NULL,
	ellipsoid char(40) NOT NULL,
	comment varchar(255),
	type_id integer UNSIGNED NOT NULL,
	date_collected datetime,
	INDEX (name)
);

DROP TABLE IF EXISTS waypoint_types;

CREATE TABLE waypoint_types (
	id integer UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name char(40) NOT NULL,
	comment varchar(255)
);

DROP TABLE IF EXISTS groups;

CREATE TABLE groups (
	id integer UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
        name char(40) NOT NULL,
	type char(10) NOT NULL,
        comment varchar(255),
	date_collected datetime
);

DROP TABLE IF EXISTS belongs;

CREATE TABLE belongs (
	waypoint_id integer UNSIGNED NOT NULL,
	group_id integer UNSIGNED NOT NULL,
	sequence integer UNSIGNED NOT NULL,
	PRIMARY KEY (waypoint_id, group_id, sequence)
);

INSERT INTO waypoint_types VALUES (0, 'None', 'Default type');

GRANT ALL ON gpsdata.* TO gpstst IDENTIFIED BY 'zbr.zbr';

FLUSH PRIVILEGES;

exit

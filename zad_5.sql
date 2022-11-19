create database cwiczenia_5;

create extension postgis;


-- zad 1
create table public.objects(
    id int not null primary key ,
    name varchar(50) not null ,
    geom geometry not null
);



insert into objects values (1, 'object1', st_collect( array [st_geomfromtext('linestring(0 1, 1 1)'),
                                                             st_geomfromtext('circularstring(1 1, 2 0, 3 1)'),
                                                             st_geomfromtext('circularstring(3 1, 4 2, 5 1)'),
                                                             st_geomfromtext('linestring(5 1, 6 1)')]));



insert into objects values (2, 'object2', st_collect( array [st_geomfromtext('linestring(10 6, 14 6)'),
                                                             st_geomfromtext('circularstring(14 6, 16 4, 14 2)'),
                                                             st_geomfromtext('circularstring(14 2, 12 0, 10 2)'),
                                                             st_geomfromtext('linestring(10 2, 10 6)'),
                                                             st_geomfromtext('circularstring(11 1, 12 3, 13 2)'),
                                                             st_geomfromtext('circularstring(13 2, 12 1, 11 2)')]));



insert into objects values (3, 'object3', st_geomfromtext('polygon((7 15, 10 17, 12 13, 7 15))'));



insert into objects values (4, 'object4', st_collect( array [st_geomfromtext('linestring(20 20, 25 25)'),
                                                             st_geomfromtext('linestring(25 25, 27 24)'),
                                                             st_geomfromtext('linestring(27 24, 25 22)'),
                                                             st_geomfromtext('linestring(25 22, 26 21)'),
                                                             st_geomfromtext('linestring(26 21, 22 19)'),
                                                             st_geomfromtext('linestring(22 19, 20.5 19.5)')]));



insert into objects values (5, 'object5', st_collect( array [st_geomfromtext('point(30 30 59)'),
                                                             st_geomfromtext('point(38 32 234)')]));



insert into objects values (6, 'object6', st_collect( array [st_geomfromtext('linestring(1 1, 3 2)'),
                                                             st_geomfromtext('point(4 2)')]));


-- Zad 2
select st_area(st_buffer(st_shortestline( o3.geom, o4.geom), 5))
from
(select * from objects where id = 3) as o3,
(select * from objects where id = 4) as o4;


-- Zad 3
update objects
set geom = st_geomfromtext('polygon((20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5, 20 20))')
where id = 4;


-- Zad 4
insert into objects values (7, 'object7', (select st_collect( array [o3.geom, o4.geom])
                                           from
                                               (select * from objects where id = 3) as o3,
                                               (select * from objects where id = 4) as o4));


-- Zad 5
select st_area(st_buffer(geom, 5)) as buffer_area
from objects
where st_hasarc(geom) = false;


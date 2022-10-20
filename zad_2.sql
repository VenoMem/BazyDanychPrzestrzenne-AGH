create database cwiczenia_2;

create extension postgis;

create schema cwiczenia_02;


create table cwiczenia.buildings(
    id int not null primary key unique ,
    geo geometry not null ,
    name varchar(50)
)

create table cwiczenia.roads(
    id int not null primary key unique ,
    geo geometry not null ,
    name varchar(50)
)

create table cwiczenia.poi(
    id int not null primary key unique ,
    geo geometry not null ,
    name varchar(50)
)


insert into cwiczenia.poi values
                              (1,'POINT(1 3.5)','G'),
                              (2,'POINT(5.5 1.5)','H'),
                              (3,'POINT(9.5 6)','I'),
                              (4,'POINT(6.5 6)','J'),
                              (5,'POINT(6 9.5)','K')

insert into cwiczenia.roads values
                                (1,'LINESTRING(0 4.5, 12 4.5)', 'RoadX'),
                                (2,'LINESTRING(7.5 0, 7.5 10.5)', 'RoadY')

insert into cwiczenia.buildings values
                                (1,'POLYGON((8 1.5, 8 4, 10.5 4, 10.5 1.5, 8 1.5))', 'BuildingA'),
                                (2,'POLYGON((4 5, 4 7, 6 7, 6 5, 4 5))', 'BuildingB'),
                                (3,'POLYGON((3 6, 3 8, 5 8, 5 6, 3 6))', 'BuildingC'),
                                (4,'POLYGON((9 8, 9 9, 10 9, 10 8, 9 8))', 'BuildingD'),
                                (5,'POLYGON((1 1, 1 2, 2 2, 2 1, 1 1))', 'BuildingF')

-- Zad A
select sum(st_length(geo)) as roadsLength from cwiczenia.roads


-- Zad B
select st_astext(geo) as wkt, st_area(geo) as area, st_perimeter(geo) as perimiter
from cwiczenia.buildings
where name='BuildingA'


-- Zad C
select name, st_area(geo) as area
from cwiczenia.buildings
order by name asc


-- Zad D
with tmp as (
    select name, perimiter, rank() over (order by area desc) as position
    from(
        select name, st_perimeter(geo) as perimiter, st_area(geo) as area
        from cwiczenia.buildings
    ) as p
)

select name, perimiter
from tmp
where position <=2


-- Zad E
select st_distance(gb.geo, gp.geo) as disatnce
from (select name, geo
      from cwiczenia.buildings
      where name = 'BuildingC') as gb,

      (select name, geo
      from cwiczenia.poi
      where name = 'K') as gp


-- Zad F
-- Adding buffer to BuildingB -> Counting intersection ->
-- Counting intersection area -> Subtracting intersection area from BuildingC area

select (st_area(buildingc.geo) - st_area(st_intersection(buildingc.geo, st_buffer(buildingb.geo, 0.5)))) as area
from (select geo
      from cwiczenia.buildings
      where name = 'BuildingB') as buildingb,

      (select geo
      from cwiczenia.buildings
      where name = 'BuildingC') as buildingc


-- Zad G
select name
from
    (select name, st_y(st_centroid(geo)) as y from cwiczenia.buildings) as tmp,

    (select st_y(st_centroid(geo)) as y from cwiczenia.roads where name='RoadX') as road
where tmp.y > road.y


-- Zad H
-- Counting intersection of the given polygon with BuildingC -> Counting areas of the Polygon and BuildingC ->
-- Adding up Polygon and BuildingC area and subtracting 2x area of their Intersection

select (st_area('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')+st_area(geo)-2*st_area(st_intersection(geo,'POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'))) as area
from cwiczenia.buildings
where name='BuildingC'
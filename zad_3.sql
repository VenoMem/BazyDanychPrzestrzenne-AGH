create database cwiczenia_3;

create extension postgis;

-- Zad 1
--shp2pgsql -s 4326 *\T2018_KAR_GERMANY\T2018_KAR_BUILDINGS.shp public.t2018_buildings | psql -d cwiczenia_3 -h localhost -U postgres
--shp2pgsql -s 4326 *\T2019_KAR_GERMANY\T2019_KAR_BUILDINGS.shp public.t2019_buildings | psql -d cwiczenia_3 -h localhost -U postgres

select t9.*
    from public.t2018_buildings t8
    right join public.t2019_buildings t9  on t8.geom = t9.geom
    where t8.gid is NULL


-- Zad 2
-- shp2pgsql -s 4326 *\T2018_KAR_GERMANY\T2018_KAR_POI_TABLE.shp public.t2018_poi | psql -d cwiczenia_3 -h localhost -U postgres
-- shp2pgsql -s 4326 *\T2019_KAR_GERMANY\T2019_KAR_POI_TABLE.shp public.t2019_poi | psql -d cwiczenia_3 -h localhost -U postgres

with
new_poi as  (select t9.*
                    from public.t2018_poi t8
                    right join public.t2019_poi t9 on t8.geom = t9.geom
                    where t8.gid is NULL),

buffer as (select t9.gid, t9.polygon_id, st_buffer(t9.geom, 0.005) as geom
                        from public.t2018_buildings t8
                        right join public.t2019_buildings t9  on t8.geom = t9.geom
                        where t8.gid is NULL)

select type, count(type)
    from new_poi, buffer
    where st_contains(buffer.geom, new_poi.geom) = true
    group by type


-- Zad 3
-- shp2pgsql -s 3068 *\T2019_KAR_GERMANY\T2019_KAR_STREETS.shp public.streets_reprojected | psql -d cwiczenia_3 -h localhost -U postgres

select find_srid('public', 'streets_reprojected', 'geom')


-- Zad 4
create table input_points(
    id int not null primary key ,
    name varchar(50) not null ,
    geom geometry not null
)

insert into input_points values
                             (1,'a','POINT(8.36093 49.03174)'),
                             (2,'b','POINT(8.39876 49.00644)')


-- Zad 5
select find_srid('public', 'input_points', 'geom')

select UpdateGeometrySRID('public', 'input_points', 'geom', 3068);


-- Zad 6
-- shp2pgsql -s 4326 *\T2019_KAR_GERMANY\T2019_KAR_STREET_NODE.shp public.street_nodes | psql -d cwiczenia_3 -h localhost -U postgres

select UpdateGeometrySRID('public', 'input_points', 'geom', 4326)

with
line as (select st_makeline(geom) as geom from input_points),
buffor as (select st_buffer(geom, 0.002) as geom from line)

select street_nodes.*
    from buffor, street_nodes
    where st_contains(buffor.geom, street_nodes.geom)


-- Zad 7
-- shp2pgsql -s 4326 *\T2019_KAR_GERMANY\T2019_KAR_LAND_USE_A.shp public.parks | psql -d cwiczenia_3 -h localhost -U postgres

select count(type) as amount
    from t2019_poi, (select st_buffer(geom, 0.003) as geom from parks) as p
    where st_contains(p.geom, t2019_poi.geom) and t2019_poi.type = 'Sporting Goods Store'


-- Zad 8
--shp2pgsql -s 4326 *\T2019_KAR_GERMANY\T2019_KAR_RAILWAYS.shp public.railways | psql -d cwiczenia_3 -h localhost -U postgres
--shp2pgsql -s 4326 *\T2019_KAR_GERMANY\T2019_KAR_WATER_LINES.shp public.canals | psql -d cwiczenia_3 -h localhost -U postgres

create table Rail_Canals_Intersection as (
select distinct (st_intersection(r.geom, c.geom)) as geom
    from railways as r, canals as c)



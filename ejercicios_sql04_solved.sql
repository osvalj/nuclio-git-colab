USE ventas_sql4;

-- 01. lista los clientes que han comprado almeno una vez
select distinct c.id_cliente, c.nombre,c.apellido
from clientes c
	inner join ventas v
		on c.id_cliente = v.id_cliente
order by c.id_cliente
;

-- lista los clientes sin compra
select *
from clientes c
	left join ventas v
		on c.id_cliente = v.id_cliente
where v.id_cliente is null
order by c.id_cliente
;

select provincia, count(distinct id_cliente) as n_clientes
from clientes
group by provincia;
-- 02. ranking de las provincias con más clientes, solo las provincias que tienen como minimo una venta
with cli as 
(
select provincia, count(id_cliente) as n_clientes
from clientes
group by provincia
)
select distinct c.provincia, n_clientes 
from clientes c 
	inner join ventas vt
		on c.id_cliente = vt.id_cliente
	inner join cli 
		on c.provincia = cli.provincia
order by n_clientes desc
;

-- lista las provincias sin ventas (si hay)
with p as 
(
select distinct c.provincia
from clientes c
	inner join ventas v
		on c.id_cliente = v.id_cliente
)
select c.provincia, count(id_cliente) as n_cliente
from clientes c
	left join p 
		on c.provincia = p.provincia
where p.provincia is null
group by c.provincia
;

-- 03. lista los vendedores con más ventas
select 
	v.id_vendedor, nombre, apellido, sum(1) as ventas, count(id_transaccion) as ventas2
from vendedores v
	inner join ventas vt 
		on v.id_vendedor = vt.id_vendedor
group by v.id_vendedor, nombre, apellido
order by ventas desc
;

-- vendedores sin ventas
select 
	v.id_vendedor, nombre, apellido , sum(1) as ventas, count(id_transaccion) as ventas2 -- ojo al resultado
from vendedores v
	left join ventas vt 
		on v.id_vendedor = vt.id_vendedor
where vt.id_vendedor is null
group by v.id_vendedor, nombre, apellido
order by ventas desc
;

-- 04. lista las sucursales que han vendido más
select 
	s.nombre, count(id_transaccion) as ventas
from vendedores v
	left join ventas vt 
		on v.id_vendedor = vt.id_vendedor
	left join sucursales s
		on v.id_sucursal = s.id_sucursal
 group by s.nombre
 order by ventas desc
;

-- 05. lista los productos que han comprado los top 3 clientes
with top3 as 
(
select c.id_cliente, nombre, apellido, count(id_transaccion) n_ventas
from clientes c
	inner join ventas v
		on c.id_cliente = v.id_cliente
group by c.id_cliente, nombre, apellido
order by n_ventas desc
limit 3
)
select distinct  
	p.nombre_producto
from top3 
	inner join ventas v 
		on v.id_cliente = top3.id_cliente
	inner join productos p
		on v.id_producto = p.id_producto
;


-- 06. cual es el mes donde hay más ventas
select 
	month(fecha_transaccion) as mes,
    count(id_transaccion) as n_ventas
from ventas
group by month(fecha_transaccion)
order by n_ventas desc
;

-- 07. Ejecutar una consulta que devuelva el importe y margen total por vendedor pero solo de los vendedores que han tenido mas de una venta 
select 
	v.id_vendedor, v.nombre, v.apellido, 
	count(id_transaccion) n_ventas, sum(importe) as importe, sum(margen) as margen
from ventas vt
	inner join vendedores v
		on vt.id_vendedor = v.id_vendedor
	inner join productos p
		on p.id_producto = vt.id_producto
group by v.id_vendedor, v.nombre, v.apellido
having count(id_transaccion) > 1
;

select 
	v.id_vendedor, v.nombre, v.apellido, p.nombre_producto, 
	count(id_transaccion) n_ventas, sum(importe) as importe, sum(margen) as margen
from ventas vt
	inner join vendedores v
		on vt.id_vendedor = v.id_vendedor
	inner join productos p
		on p.id_producto = vt.id_producto
group by v.id_vendedor, v.nombre, v.apellido, p.nombre_producto
having count(id_transaccion) > 1
;

/* 08. Ejecutar una consulta devuelva el total de importe, margen y cantidad de ventas por cliente (nombre y apellido) de clientes del vendedor 2.
Clientes que hayan tenido seguramente el vendedor 2 (pero podrian haber tenido tambien otro vendedor).
Para obtener los datos de los clientes realizar una subconsulta que agrupe las ventas por id_cliente y devuelva el importe, margen y cantidad y 
que esa subconsulta sea la tabla a combinar con la tabla de vendedores. 
*/
with t1 as
(
select
	c.id_cliente
from ventas vt
	inner join clientes c	
		on vt.id_cliente = c.id_cliente
where vt.id_vendedor = 2
)
select 
	t1.id_cliente, count(id_transaccion) as tot_v,
    sum(importe) as importe, sum(margen) as margen
from t1
	inner join ventas v
		on t1.id_cliente= v.id_cliente
	inner join productos p 
		on v.id_producto = p.id_producto
group by t1.id_cliente
order by t1.id_cliente
;

-- 09. lista las provincias con más ventas  
select 
	c.provincia, count(id_transaccion) n_ventas
from ventas vt
	right join clientes c
		on vt.id_cliente = c.id_cliente
group by c.provincia
order by n_ventas desc
;

/* 10. lista un detalle por mes y por provincia de las ventas y de los productos vendido: 
indicando cuantos clientes han comprado ese productos y cuantos vendedores han vendido ese producto
*/
select 
	month(fecha_transaccion) as mes,
    c.provincia,
    p.nombre_producto,
    count(id_transaccion) as n_ventas,
    count(distinct vt.id_cliente) as n_clientes,
    count(distinct vt.id_vendedor) as n_vendedores
from ventas vt
	left join clientes c
		on vt.id_cliente = c.id_cliente
	left join productos p 
		on vt.id_producto = p.id_producto

group by 
	month(fecha_transaccion),
    c.provincia,
    p.nombre_producto
order by c.provincia, nombre_producto, mes
;

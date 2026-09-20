
use inditex;
#1. Muestra los artículos con descuento ordenados por el porcentaje de descuento de forma ascendente
-- 1º Realizamos un descuento en aquellos articulos cuyo precio sea superior a 20 euros  
set sql_safe_updates=0;
update producto 
set descuento = 50
where precio > 20;

-- 2º calculamos el precio final con el nuevo descuento
update producto
set precioFinal = precio - (precio*descuento / 100);

-- ahora seleccionaos los articulos y su precio final ordenador por el porcentaje de forma ascendente y el nombre en forma descendente
select nomP, precio, descuento, precioFinal
from producto
order by descuento desc,  nomP asc; 

#2. Muestra el nombre y los apellidos del cliente que ha realizado la compra más reciente
select concat(nom_c, " ", ap1_c, " ", ap2_c, "") nombreC, fecCompra
from cliente cl inner join compra c on cl.DNI_c=c.id_cliente
where c.fecCompra=(select fecCompra 
				   from compra 
                   order by fecCompra desc 
				   limit 1);
                
#3. Encuentra los clientes que no han realizado compras
select concat(nom_c, " ", ap1_c, " ", ap2_c, "") nombreC
from cliente
where DNI_c not in (select id_cliente
				    from compra);
                    
#4. Calcula el precio del producto más caro, el más barato y la media de los dos
select max(precio), min(precio), (max(precio) + min(precio))/2 media_precios
from producto;                  

#5. Obtén el telefono de todas las tiendas que se encuentren en Gran Via   
select tlfT
from telefonotienda tlf inner join tienda t on tlf.codT=t.CodT
where t.direcT like '%Gran Via%';

#6. Obtén el nombre de los productos suministrados por el proveedor procedente de Turquía 
select nomP
from producto p inner join proveedor pr on p.cod_pr = pr.cod_pr
where pais_pr = 'Turquía';

#8. Nombre de los artículos de los que se han vendido 3 o más unidades en una compra
select nomP
from producto p inner join seVende sV on p.codP=sV.codP
	inner join compra c ON sV.n_factura=c.n_factura
where sv.numUnidades >= 3; 

#9. Calcula el cliente que más dinero se ha gastado y el nombre de la tienda en la que se ha realizado dicho gasto.
-- Primero calculamos una vista en la que se guarde el gasto pro cliente y en qué tienda se ha realizado
create view Gastos_Cliente as
select DNI_c, concat(nom_c, " ", ap1_c, " ", ap2_c, "") nombreC, CodT, sum(numUnidades*precio) totalGasto 
from cliente cl inner join compra c on cl.DNI_c = c.id_cliente
	inner join tienda t on c.id_tienda=t.CodT 
	inner join producto p on c.id_producto = p.codP 
    inner join seVende sV on p.codP=sV.codP
group by DNI_c, CodT;

-- Despues seleccionamos el cliente que más dinero ha gastado y en qué tienda ha sido. Para ello comparamos el gastato total de cada cleinte
-- con el máximo del gasto total, y el que coincida será el que más dinero se ha gastado. 
select nombreC, nomT, totalGasto
from Gastos_Cliente gpc inner join tienda t on gpc.CodT=t.CodT
where totalGasto = (select max(totalGasto)
					from Gastos_Cliente);


#10. Obtén el el nombre del cliente y el numero de años transcurridos desde la ultima fecha de compra de cada uno de ellos.
select nom_c, year(curdate())-year(max(fecCompra)) annosTranscurridos -- le restamos al año de la fecha actual el año de la ultima fecha de comrpa de cada cliente que es el max(fecCompra)
from cliente cl inner join compra c on cl.DNI_c = c.id_cliente
group by cl.nom_c;

#11. Nombre de los productos que sólo han sido suministrados por el proveedor de Portugal
select nomP
from producto p inner join proveedor pr on p.cod_pr=pr.cod_pr
where pais_pr like 'Portugal' and nomP not in(select nomP
from producto p inner join proveedor pr      on p.cod_pr=pr.cod_pr
                                              			    where pais_pr not like 'Portugal');
                                              
#12. Obtén los productos que han sido vendidos en al menos una compra, junto con la cantidad total de unidades vendidas de cada producto.
select p.codP, p.nomP, sum(numUnidades) totalUdsVendidas
from producto p inner join seVende sv on p.CodP = sv.CodP inner join compra c
on sv.n_factura = c.n_factura
group by p.codP, p.nomP 
order by totalUdsVendidas desc;

#13. Calcula el proveedor que ha suministrado el producto con más unidades vendidas en total. 
# Además, muestra la cantidad total de unidades vendidas de ese producto, el nombre del producto.

-- Primero, creamos una vista para obtenemos el numero de unidades vendidas de cada producto 
create view unidadesVendidas as 
	select p.nomP, p.codP, sum(numUnidades) numVendidas
	from producto p inner join seVende sV on p.codP=sV.codP
    inner join compra c on sV.codP=c.id_producto
	group by codP;
    
-- Ahora seleccionamos el proveedor que ha suministrado el producto mas vendido
select cod_pr, numVendidas
from unidadesVendidas uV inner join producto p on uV.codP = p.codP
	inner join compra c on p.codP=c.id_producto
group by cod_pr, numVendidas
having numVendidas = (select numVendidas
						   from unidadesVendidas
                           order by numVendidas desc
                           limit 1); 

#14. Muestra todos los productos vendidos después del 1 de enero de 2024
select nomP , fecCompra, numUnidades 
from producto p inner join seVende sv on p.CodP = sv.CodP inner join compra c 
on sv.n_factura = c.n_factura 
where fecCompra > '2024-01-01' ;


#15. Encuentra los clientes que no han realizado compras 
select DNI_c, concat(nom_c, ' ', ap1_c, ' ', ap2_c, ' ') nombreCliente 
from cliente cl left join compra c on cl.DNI_c = c.id_cliente 
where id_cliente is null 
order by nombreCliente;

#16. Modifica el precio de todos los productos comprados en 2020 para aumentar un 10% el precio del producto comprado
update producto p inner join compra c on p.codP = c.id_producto 
set p.precio = p.precio * 1.1
where year(c.fecCompra) = 2020;


#17. Elimina aquellos productos de los que se hayan vendido menos de 3 unidades
delete from producto 
where codP in (select codP
	              from seVende
               	group by codP
              	having sum(numUnidades) < 3);

#18. Lista los datos clientes que se hayan gastado más de 100 euros en inditex 
select DNI_c, concat(nom_c, ' ', ap1_c, ' ', ap2_c,' ') nombreC, telf_C telefonoCliente , direc_c direcCliente, sum(numUnidades * precio) gastoTotal 
from cliente cl inner join compra c on cl.DNI_c = c.id_cliente 
	inner join producto p on c.id_producto = p.codP 
    inner join seVende sv on p.codP = sv.codP 
group by c.id_cliente having sum(numUnidades * precio) > 100 
order by gastoTotal desc;

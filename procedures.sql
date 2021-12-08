-- Realizar un SP que permita realizar un AM (Alta y Modificación) de la tabla categoría.
-- Si el producto existe debe modificar los datos del mismo (categoría y descripción), sino debe darlo de alta.

DELIMITER $$
CREATE PROCEDURE sp_AM (IN THIS_CATEGORIA VARCHAR(50), IN THIS_DESCRIPCION VARCHAR(50))
BEGIN
DECLARE AUX VARCHAR(50);
SELECT categorias.categoria INTO AUX FROM categorias
WHERE categorias.categoria = THIS_CATEGORIA;

IF AUX LIKE THIS_CATEGORIA
THEN UPDATE categorias SET descripcion = THIS_DESCRIPCION WHERE categorias.categoria = THIS_CATEGORIA;

ELSE
INSERT INTO categorias (id, categoria, descripcion) VALUES (NULL, THIS_CATEGORIA, THIS_DESCRIPCION);
END IF;
END
$$


--Parte A
--Crear un SP que genere una tabla productos_old, donde aloje los valores unitarios de un producto
-- antes de ser manipulado.

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_ej_dos ()

BEGIN

CREATE TABLE `productos_old` (
  `id` int(11) NOT NULL AUTO_INCREMENT, 
  id_producto INT NOT NULL,	
  `producto` varchar(40) NOT NULL,
  `proveedor_id` int(11) DEFAULT NULL,
  `categoria_id` int(11) DEFAULT NULL,
  `cantidad_por_unidad` varchar(20) DEFAULT NULL,
  `precio_unidad` decimal(19,4) DEFAULT NULL,
  `unidades_existencia` smallint(6) DEFAULT NULL,
  `unidades_pedido` smallint(6) DEFAULT NULL,
  `nivel_nuevo_pedido` int(11) DEFAULT NULL,
  `suspendido` tinyint(1) NOT NULL DEFAULT 0,
PRIMARY KEY (id));

INSERT INTO productos_old (id, id_producto, producto, proveedor_id, categoria_id, cantidad_por_unidad, precio_unidad, unidades_existencia, unidades_pedido, nivel_nuevo_pedido, suspendido) VALUES
(NULL, id_producto, producto, proveedor_id, categoria_id, cantidad_por_unidad, precio_unidad, unidades_existencia, unidades_pedido, nivel_nuevo_pedido, suspendido);

END
$$

-- Parte B
-- Al realizar un “update” en la tabla productos, se generar una tabla auxiliar donde se alojen los históricos
-- del producto.

DELIMITER $$
CREATE TRIGGER ejer_dos BEFORE UPDATE ON productos

FOR EACH ROW
BEGIN
INSERT INTO productos_old (id, id_producto, producto, proveedor_id, categoria_id, cantidad_por_unidad, precio_unidad, unidades_existencia, unidades_pedido, nivel_nuevo_pedido, suspendido) VALUES

(NULL, old.id, old.producto, old.proveedor_id, old.categoria_id, old.cantidad_por_unidad, old.precio_unidad, old.unidades_existencia, old.unidades_pedido, old.nivel_nuevo_pedido, old.suspendido );
END
$$

--Casos de prueba

-- 1)	UPDATE `productos` SET `nivel_nuevo_pedido` = '200' WHERE `productos`.`id` = 1;
-- 2)	UPDATE `productos` SET `nivel_nuevo_pedido` = '300' WHERE `productos`.`id` = 2;
-- 3)	UPDATE `productos` SET `nivel_nuevo_pedido` = '400' WHERE `productos`.`id` = 3;

--Funciones
--Crear una funcion para saber si un producto es menor de $5, entre 5 y 10 o más de 10

DROP FUNCTION IF EXISTS MASCAROVARIOS;
DELIMITER //

CREATE FUNCTION MASCAROVARIOS(productoid INT)
	RETURNS VARCHAR (50)
    
 BEGIN   
    DECLARE masCaro DECIMAL DEFAULT 0;
    DECLARE precioalto VARCHAR (50);

    SELECT precio_unidad INTO masCaro
    FROM productos
    WHERE productos.id = productoid;

    IF masCaro < 5 
    	THEN SET precioalto = 'Menor de 5';
     ELSEIF masCaro BETWEEN 5 AND 10 THEN
        SET precioalto = 'Entre 5 y 10';
    ELSEIF masCaro > 10	THEN
        SET precioalto = 'Mayor a 10';
    END IF;
    
    RETURN precioalto;
END;//
DELIMITER ;

-- Triggers
-- Hacer un trigger que cuando se actualice una tupla en la tabla categoría,
-- guarde los valores antiguos en la tabla categorias_borradas

DROP TRIGGER IF EXISTS updatecategoria;

DELIMITER $$

CREATE TRIGGER  updatecategoria
BEFORE update on categorias
    
 FOR EACH ROW BEGIN
 
 INSERT INTO categoria_borradas(id,categoria,descripcion) values (old.id, old.categoria, old.descripcion);

END$$;
DELIMITER ;

-- Caso de prueba
-- UPDATE categorias SET categoria="otraPrueba" where id=1;


-- Referencia aplicada a la realidad

DELIMITER $$
CREATE PROCEDURE turnoCumplido(IN TURNOID INT)
BEGIN
UPDATE turno SET cumplido = '1' WHERE turno.idTurno = TURNOID;
END$$
DELIMITER ;
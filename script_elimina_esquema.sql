USE GD1C2024;
GO

DROP TABLE GeDeDe.Aplicacion_Descuento;
DROP TABLE GeDeDe.Descuento;
DROP TABLE GeDeDe.Pago;
DROP TABLE GeDeDe.Medio_Pago;
DROP TABLE GeDeDe.Detalle_Pago;
DROP TABLE GeDeDe.Item_Factura;
DROP TABLE GeDeDe.Promocion_Producto;
DROP TABLE GeDeDe.Promocion;
DROP TABLE GeDeDe.Regla;
DROP TABLE GeDeDe.Producto;
DROP TABLE GeDeDe.Marca;
DROP TABLE GeDeDe.Subcategoria;
DROP TABLE GeDeDe.Categoria;
DROP TABLE GeDeDe.Envio;
DROP TABLE GeDeDe.Cliente;
DROP TABLE GeDeDe.Factura;
DROP TABLE GeDeDe.Empleado;
DROP TABLE GeDeDe.Caja;
DROP TABLE GeDeDe.Tipo_Caja;
DROP TABLE GeDeDe.Sucursal;
DROP TABLE GeDeDe.Super;
GO

IF EXISTS (SELECT * 
    FROM sys.objects 
    WHERE type = 'P' 
    AND name = 'CREATE_DDL' 
    AND SCHEMA_NAME(schema_id) = 'GeDeDe')
BEGIN
	DROP PROCEDURE [GeDeDe].CREATE_DDL
END;

IF EXISTS (SELECT * 
    FROM sys.objects 
    WHERE type = 'P' 
    AND name = 'CREATE_DML' 
    AND SCHEMA_NAME(schema_id) = 'GeDeDe')
BEGIN
	DROP PROCEDURE [GeDeDe].CREATE_DML
END;
GO

DROP SCHEMA GeDeDe;
GO
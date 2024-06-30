USE GD1C2024;

PRINT 'Inicializando la creacion del modelo de Business Intelligence'
GO

IF OBJECT_ID('[GeDeDe].[BI_CLEAN]', 'P') IS NOT NULL
    DROP PROCEDURE [GeDeDe].[BI_CLEAN];
GO


CREATE PROCEDURE [GeDeDe].[BI_CLEAN]
AS
BEGIN
--DROP PREVENTIVO DE FUNCIONES----------------------------------------------------------------
IF EXISTS(SELECT [name] FROM sys.objects WHERE [name] = 'obtenerRangoEtario')
	DROP FUNCTION GeDeDe.obtenerRangoEtario

IF EXISTS(SELECT [name] FROM sys.objects WHERE [name] = 'obtenerEdad')
	DROP FUNCTION GeDeDe.obtenerEdad

IF EXISTS(SELECT [name] FROM sys.objects WHERE [name] = 'obtenerTurnos')
	DROP FUNCTION GeDeDe.obtenerTurnos

IF EXISTS(SELECT [name] FROM sys.objects WHERE [name] = 'obtenerCuatrimestre')
	DROP FUNCTION GeDeDe.obtenerCuatrimestre

--DROP PREVENTIVO DE TABLAS--

-- DROP PREVENTIVO DE TABLAS FÁCTICAS---------------------------------------------------------
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BI_fact_Ventas')
    DROP TABLE GeDeDe.BI_fact_Ventas;

-- DROP PREVENTIVO DE TABLAS DIMENSIONALES --
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BI_dim_Tiempo')
    DROP TABLE GeDeDe.BI_dim_Tiempo;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BI_dim_Sucursal')
    DROP TABLE GeDeDe.BI_dim_Sucursal;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BI_dim_Ubicacion')
    DROP TABLE GeDeDe.BI_dim_Ubicacion;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BI_dim_Rango_Etario')
    DROP TABLE GeDeDe.BI_dim_Rango_Etario;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BI_dim_Turnos')
    DROP TABLE GeDeDe.BI_dim_Turnos;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BI_dim_Medio_Pago')
    DROP TABLE GeDeDe.BI_dim_Medio_Pago;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BI_dim_Categoria_Subcategoria')
    DROP TABLE GeDeDe.BI_dim_Categoria_Subcategoria;

-- DROPS PREVENTIVOS DE VISTAS----------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BI_TicketPromedioMensual' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_BI_TicketPromedioMensual];
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BI_CantidadUnidadesPromedio' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_BI_CantidadUnidadesPromedio];

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BI_VentasPorRangoEtario' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_BI_VentasPorRangoEtario];

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BI_VentasPorProducto' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_BI_VentasPorProducto];

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BI_PorcentajeVentasPorRangoEtarioYCaja' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_BI_PorcentajeVentasPorRangoEtarioYCaja];

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BI_CantidadVentasPorTurnoLocalidadMes' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_BI_CantidadVentasPorTurnoLocalidadMes];

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BI_PorcentajeDescuentoPorMesAnio' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_BI_PorcentajeDescuentoPorMesAnio];

--DROP PREVENTIVO DE PROCEDURES---------------------------------------------------------------

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'BI_Migrar_Medios_de_Pago' and schema_id = SCHEMA_ID('GeDeDe'))
	DROP PROCEDURE [GeDeDe].[BI_Migrar_Medios_de_Pago];

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'BI_Migrar_Sucursales' and schema_id = SCHEMA_ID('GeDeDe'))
	DROP PROCEDURE [GeDeDe].[BI_Migrar_Sucursales];

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'BI_Migrar_Ventas' and schema_id = SCHEMA_ID('GeDeDe'))
	DROP PROCEDURE [GeDeDe].[BI_Migrar_Ventas];

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'BI_Migrar_Envios' and schema_id = SCHEMA_ID('GeDeDe'))
	DROP PROCEDURE [GeDeDe].[BI_Migrar_Envios];

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'BI_Migrar_Pagos' and schema_id = SCHEMA_ID('GeDeDe'))
	DROP PROCEDURE [GeDeDe].[BI_Migrar_Pagos];

END
GO

EXECUTE [GeDeDe].[BI_CLEAN]
----------------------------------------------------------------------------------------------

--CREACIÓN DE FUNCIONES AUXILIARES------------------------------------------------------------
GO

/*
    @param una fecha de nacimiento (datetime2)
    @returns la edad al dia de hoy (int)
*/


CREATE FUNCTION GeDeDe.obtenerEdad(@dateofbirth datetime2(3))
RETURNS int
AS
BEGIN
	DECLARE @age int;

IF (MONTH(@dateofbirth)!=MONTH(GETDATE()))
	SET @age = DATEDIFF(MONTH, @dateofbirth, GETDATE())/12;
ELSE IF(DAY(@dateofbirth) > DAY(GETDATE()))
	SET @age = (DATEDIFF(MONTH, @dateofbirth, GETDATE())/12)-1;
ELSE
BEGIN
	SET @age = DATEDIFF(MONTH, @dateofbirth, GETDATE())/12;
END
	RETURN @age;
END
GO
/*
 Rango etario empleados/clientes

    @param una edad int
    @returns rango etario al que pertenece
*/
CREATE FUNCTION GeDeDe.obtenerRangoEtario (@age int)
RETURNS NVARCHAR(255)
AS
BEGIN
	DECLARE @returnvalue NVARCHAR(255);

IF (@age < 25)
BEGIN
	SET @returnvalue = '[<25)';
END
ELSE IF (@age >= 25 AND @age < 35)
BEGIN
	SET @returnvalue = '[25 - 35)';
END
ELSE IF (@age >= 35 AND @age <= 50)
BEGIN
	SET @returnvalue = '[35 - 50]';
END
ELSE IF(@age > 50)
BEGIN
	SET @returnvalue = '(>50]';
END

	RETURN @returnvalue;
END
GO
/*
 Obtener cuatrimestre

    @param una fecha con horas/min/seg un datetime
    @returns int de 1 a 4 con el correspondiente cuatrimestre
*/
CREATE FUNCTION [GeDeDe].obtenerCuatrimestre (@Fecha DATETIME)
RETURNS INT
AS
BEGIN
    DECLARE @Cuatrimestre INT;
    
    SET @Cuatrimestre = CASE 
        WHEN MONTH(@Fecha) IN (1, 2, 3, 4) THEN 1
        WHEN MONTH(@Fecha) IN (5, 6, 7, 8) THEN 2
        WHEN MONTH(@Fecha) IN (9, 10, 11, 12) THEN 3
    END;

    RETURN @Cuatrimestre;
END;
GO

/*
 Rango de turnos

    @param una fecha con horas/min/seg un datetime
    @returns rango turno al que pertenece
*/
CREATE FUNCTION GeDeDe.obtenerTurnos (@fecha datetime)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @returnvalue NVARCHAR(255);
    DECLARE @hora int;

    SET @hora = DATEPART(hour, @fecha);

    IF (@hora >= 8 AND @hora < 12)
    BEGIN
        SET @returnvalue = '08:00 - 12:00';
    END
    ELSE IF (@hora >= 12 AND @hora < 16)
    BEGIN
        SET @returnvalue = '12:00 - 16:00';
    END
    ELSE IF (@hora >= 16 AND @hora < 20)
    BEGIN
        SET @returnvalue = '16:00 - 20:00';
    END
    ELSE
    BEGIN
        SET @returnvalue = 'Fuera de Horario';
    END

    RETURN @returnvalue;
END

/*
 Rango etario empleados/clientes

    @param una edad int
    @returns rango etario al que pertenece
*/

GO

--CREACIÓN DE TABLAS DIMENSIONALES--
-- Tabla dimensional de tiempo
CREATE TABLE [GeDeDe].[BI_dim_Tiempo] (
    CODIGO_TIEMPO INT IDENTITY(1,1) PRIMARY KEY,
    Año INT,
    Cuatrimestre INT,
    Mes INT
);
GO
-- Tabla dimensional de ubicación
CREATE TABLE [GeDeDe].[BI_dim_Ubicacion] (
    CODIGO_UBICACION INT IDENTITY(1,1) PRIMARY KEY,
    Provincia NVARCHAR(255),
    Localidad NVARCHAR(255)
);
GO
-- Tabla dimensional de sucursal
CREATE TABLE [GeDeDe].[BI_dim_Sucursal] (
    CODIGO_SUCURSAL DECIMAL(18,0) PRIMARY KEY,
    Nombre NVARCHAR(255),
    CODIGO_UBICACION INT,
    FOREIGN KEY (CODIGO_UBICACION) REFERENCES [GeDeDe].[BI_dim_Ubicacion](CODIGO_UBICACION)
);
GO
-- Tabla dimensional de rango etario
CREATE TABLE [GeDeDe].[BI_dim_Rango_Etario] (
    CODIGO_RANGO_ETARIO INT IDENTITY(1,1) PRIMARY KEY,
    Descripcion NVARCHAR(255)
);
GO
-- Tabla dimensional de turnos
CREATE TABLE [GeDeDe].[BI_dim_Turnos] (
    CODIGO_TURNO INT IDENTITY(1,1) PRIMARY KEY,
    Turno NVARCHAR(255)
);
GO
-- Tabla dimensional de medio de pago
CREATE TABLE [GeDeDe].[BI_dim_Medio_Pago] (
    CODIGO_MEDIO_PAGO DECIMAL(18,0) PRIMARY KEY,
    Descripcion NVARCHAR(255),
    Tipo NVARCHAR(255)
);
GO
-- Tabla dimensional de categoria/subcategoria
CREATE TABLE [GeDeDe].[BI_dim_Categoria_Subcategoria] (
    CODIGO_CATEGORIA_SUBCATEGORIA INT IDENTITY(1,1) PRIMARY KEY,
    Categoria NVARCHAR(255),
    Subcategoria NVARCHAR(255)
);
GO
--CREACIÓN DE TABLAS FÁCTICAS--
CREATE TABLE [GeDeDe].[BI_fact_Ventas] (
	CODIGO_VENTAS INT IDENTITY(1,1) PRIMARY KEY,
    CODIGO_TIEMPO INT NOT NULL,
    CODIGO_UBICACION INT NOT NULL,
	CODIGO_MEDIO_PAGO DECIMAL(18,0) NOT NULL,
    CODIGO_TURNO INT NOT NULL,
    CODIGO_RANGO_ETARIO_VENDEDOR INT NOT NULL,
    CODIGO_CATEGORIA_SUBCATEGORIA INT NOT NULL,
	CANTIDAD INT,
    TIPO_CAJA NVARCHAR(255),
    DESCUENTO_APLICADO DECIMAL(18, 2),
    TOTAL DECIMAL(18, 2)
);

--ALTER TABLE [GeDeDe].[BI_fact_Ventas]
--ADD CONSTRAINT PK_BI_fact_Ventas PRIMARY KEY (CODIGO_TIEMPO, CODIGO_UBICACION, CODIGO_MEDIO_PAGO, CODIGO_TURNO, CODIGO_RANGO_ETARIO_VENDEDOR, CODIGO_CATEGORIA_SUBCATEGORIA);

ALTER TABLE [GeDeDe].[BI_fact_Ventas]
ADD CONSTRAINT FK_BI_fact_Ventas_CODIGO_TIEMPO FOREIGN KEY (CODIGO_TIEMPO) REFERENCES [GeDeDe].[BI_dim_Tiempo](CODIGO_TIEMPO),
    CONSTRAINT FK_BI_fact_Ventas_CODIGO_UBICACION FOREIGN KEY (CODIGO_UBICACION) REFERENCES [GeDeDe].[BI_dim_Ubicacion](CODIGO_UBICACION),
    CONSTRAINT FK_BI_fact_Ventas_CODIGO_MEDIO_PAGO FOREIGN KEY (CODIGO_MEDIO_PAGO) REFERENCES [GeDeDe].[BI_dim_Medio_Pago](CODIGO_MEDIO_PAGO),
    CONSTRAINT FK_BI_fact_Ventas_CODIGO_TURNO FOREIGN KEY (CODIGO_TURNO) REFERENCES [GeDeDe].[BI_dim_Turnos](CODIGO_TURNO),
    CONSTRAINT FK_BI_fact_Ventas_CODIGO_RANGO_ETARIO_VENDEDOR FOREIGN KEY (CODIGO_RANGO_ETARIO_VENDEDOR) REFERENCES [GeDeDe].[BI_dim_Rango_Etario](CODIGO_RANGO_ETARIO),
    CONSTRAINT FK_BI_fact_Ventas_CODIGO_CATEGORIA_SUBCATEGORIA FOREIGN KEY (CODIGO_CATEGORIA_SUBCATEGORIA) REFERENCES [GeDeDe].[BI_dim_Categoria_Subcategoria](CODIGO_CATEGORIA_SUBCATEGORIA);

--CREACION DE VISTAS--
GO
/*
1.  Ticket  Promedio  mensual.  Valor  promedio  de  las  ventas  (en  $)  según  la 
localidad,  año  y  mes.  Se  calcula  en  función  de  la  sumatoria  del  importe  de  las 
ventas sobre el total de las mismas. 
*/
CREATE VIEW [GeDeDe].[vw_BI_TicketPromedioMensual] AS
SELECT 
    v.CODIGO_UBICACION,
    t.Año,
    t.Mes,
    AVG(v.TOTAL) AS TicketPromedioMensual,
    SUM(v.TOTAL) / COUNT(DISTINCT t.CODIGO_TIEMPO) AS ValorPromedioVentas
FROM 
    [GeDeDe].[BI_fact_Ventas] v
INNER JOIN 
    [GeDeDe].[BI_dim_Tiempo] t ON v.CODIGO_TIEMPO = t.CODIGO_TIEMPO
GROUP BY 
    v.CODIGO_UBICACION, t.Año, t.Mes;
GO
/*
2. Cantidad  unidades  promedio.  Cantidad  promedio  de  artículos  que  se  venden 
en  función  de  los  tickets  según  el  turno  para  cada  cuatrimestre  de  cada  año.  Se 
obtiene  sumando  la  cantidad  de  artículos  de  todos  los  tickets  correspondientes 
sobre  la  cantidad  de  tickets.  Si  un  producto  tiene  más  de  una  unidad  en  un  ticket, 
para el indicador se consideran todas las unidades. 
*/
CREATE VIEW [GeDeDe].[vw_BI_CantidadUnidadesPromedio] AS
SELECT
    t.Año,
    t.Cuatrimestre,
    tu.Turno,
    SUM(fv.CANTIDAD) / COUNT(DISTINCT fv.CODIGO_VENTAS) AS CantidadUnidadesPromedio
FROM
    [GeDeDe].[BI_fact_Ventas] fv
    JOIN [GeDeDe].[BI_dim_Tiempo] t ON fv.CODIGO_TIEMPO = t.CODIGO_TIEMPO
    JOIN [GeDeDe].[BI_dim_Turnos] tu ON fv.CODIGO_TURNO = tu.CODIGO_TURNO
GROUP BY
    t.Año,
    t.Cuatrimestre,
    tu.Turno
ORDER BY
    1,
    2,
    3;

GO
-- Índice para BI_fact_Ventas por CODIGO_TIEMPO y CODIGO_UBICACION
CREATE INDEX IX_BI_fact_Ventas_TIEMPO_UBICACION ON GeDeDe.BI_fact_Ventas (CODIGO_TIEMPO, CODIGO_UBICACION);
GO
-- Índice para BI_fact_Ventas por CODIGO_TIEMPO y CODIGO_PRODUCTO
CREATE INDEX IX_BI_fact_Ventas_TIEMPO__CATEGORIA_SUBCATEGORIA ON GeDeDe.BI_fact_Ventas (CODIGO_TIEMPO, CODIGO_CATEGORIA_SUBCATEGORIA);
GO
-- Índice para BI_fact_Ventas por CODIGO_TIEMPO y CODIGO_TURNO
CREATE INDEX IX_BI_fact_Ventas_TIEMPO_TURNO ON GeDeDe.BI_fact_Ventas (CODIGO_TIEMPO, CODIGO_TURNO);
GO



--CREACION PROCEDURES DE MIGRACION--

CREATE PROCEDURE [GeDeDe].[BI_Migrar_Medios_de_Pago]
AS
BEGIN
	INSERT INTO [GeDeDe].[BI_dim_Medio_Pago] (CODIGO_MEDIO_PAGO, Descripcion, Tipo)
	SELECT medio_pago_codigo, medio_pago_detalle, medio_pago_tipo
	FROM [GeDeDe].Medio_Pago
END
GO

CREATE PROCEDURE [GeDeDe].[BI_Migrar_Sucursales]
AS
BEGIN
	DECLARE sucursal_cursor CURSOR FOR SELECT sucu_codigo, sucu_nombre, sucu_localidad, sucu_provincia FROM [GeDeDe].[Sucursal]

	DECLARE @Sucu_Codigo DECIMAL(18,0)
	DECLARE @Sucu_Nombre NVARCHAR(255)
	DECLARE @Sucu_Localidad NVARCHAR(255)
	DECLARE @Sucu_Provincia NVARCHAR(255)
	DECLARE @CODIGO_UBICACION INT
	
	OPEN sucursal_cursor
	FETCH sucursal_cursor into @Sucu_Codigo, @Sucu_Nombre, @Sucu_Localidad, @Sucu_Provincia;
	
	WHILE(@@FETCH_STATUS = 0)
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM [GeDeDe].BI_dim_Ubicacion WHERE (Provincia = @Sucu_Provincia AND Localidad = @Sucu_Localidad))
			BEGIN
				INSERT INTO [GeDeDe].[BI_dim_Ubicacion] (Provincia, Localidad) VALUES (@Sucu_Provincia, @Sucu_Localidad)
			END

			SELECT @CODIGO_UBICACION = CODIGO_UBICACION FROM [GeDeDe].[BI_dim_Ubicacion] WHERE Provincia = @Sucu_Provincia AND Localidad = @Sucu_Localidad

			INSERT INTO [GeDeDe].[BI_dim_Sucursal] (CODIGO_SUCURSAL, Nombre, CODIGO_UBICACION) VALUES (@Sucu_Codigo, @Sucu_Nombre, @CODIGO_UBICACION)
			
			FETCH sucursal_cursor into @Sucu_Codigo, @Sucu_Nombre, @Sucu_Localidad, @Sucu_Provincia;
		END

	CLOSE sucursal_cursor;
	DEALLOCATE sucursal_cursor;
END
GO

CREATE PROCEDURE [GeDeDe].[BI_Migrar_Ventas]
AS
BEGIN
	PRINT 'Migracion de Ventas'
	DECLARE @Factura_Fecha_Hora Datetime, @Medio_Pago Decimal(18,0), @Empleado_Fecha_Nacimiento Date, @Producto_Id Decimal(18,0), @Producto_Cantidad decimal(18,0), @Tipo_Caja NVARCHAR(255), @Item_Descuento decimal(18,2), @Item_Precio_Total decimal(18,2);
    DECLARE @Factura_Anio Int, @Factura_Cuatrimestre Int, @Factura_Mes Int, @Edad INT, @Rango_Etario_Descripcion NVARCHAR(255), @Turno NVARCHAR(255), @Categoria_Descripcion NVARCHAR(255), @Subcategoria_Descripcion NVARCHAR(255);
	DECLARE @CODIGO_RANGO_ETARIO_VENDEDOR Int, @CODIGO_TIEMPO INT, @CODIGO_UBICACION INT, @CODIGO_TURNO INT, @CODIGO_CATEGORIA_SUBCATEGORIA INT;
	DECLARE ventas_cursor CURSOR FOR
		SELECT f.fact_fecha_hora, bi_suc.CODIGO_UBICACION , p.pago_medio_pago, e.empl_fecha_nacimiento, cate.cate_descripcion, subc.cate_descripcion, i.item_cantidad, tc.tipo_caja_nombre, i.item_descuento_promo, i.item_precio_total
		FROM [GeDeDe].[Item_Factura] I
				JOIN [GeDeDe].[Factura] F ON CAST(F.fact_tipo AS NVARCHAR(255)) + CAST(F.fact_sucursal AS NVARCHAR(255)) + CAST(F.fact_nro AS NVARCHAR(255)) + CAST(F.fact_caja AS NVARCHAR(255))
                          = CAST(I.item_fact_tipo AS NVARCHAR(255)) + CAST(I.item_fact_sucursal AS NVARCHAR(255)) + CAST(I.item_fact_nro AS NVARCHAR(255)) + CAST(I.item_fact_caja AS NVARCHAR(255))
				JOIN [GeDeDe].[Cliente] C ON F.fact_cliente = C.clie_codigo
				JOIN [GeDeDe].[Empleado] E ON F.fact_vendedor = E.empl_codigo
				JOIN [GeDeDe].[Pago] p ON CAST(F.fact_tipo AS NVARCHAR(255)) + CAST(F.fact_sucursal AS NVARCHAR(255)) + CAST(F.fact_nro AS NVARCHAR(255))
                          = CAST(p.pago_fact_tipo AS NVARCHAR(255)) + CAST(p.pago_fact_sucursal AS NVARCHAR(255)) + CAST(p.pago_fact_nro AS NVARCHAR(255))
				JOIN [GeDeDe].[Caja] ca on f.fact_caja = ca.caja_codigo and f.fact_sucursal = ca.caja_sucursal
				JOIN [GeDeDe].[Tipo_Caja] tc on ca.caja_tipo = tc.tipo_caja_codigo
				
				JOIN [GeDeDe].[Producto] prod on prod.prod_codigo = I.item_producto
				JOIN [GeDeDe].[Categoria] cate on prod.prod_categoria = cate.cate_codigo
				JOIN [GeDeDe].[Categoria] subc on prod.prod_subcategoria = subc.cate_codigo
				JOIN [GeDeDe].[BI_dim_Sucursal] bi_suc on f.fact_sucursal = bi_suc.CODIGO_SUCURSAL
		group by f.fact_fecha_hora, bi_suc.CODIGO_UBICACION , p.pago_medio_pago, e.empl_fecha_nacimiento, cate.cate_descripcion, subc.cate_descripcion, i.item_cantidad, tc.tipo_caja_nombre, i.item_descuento_promo, i.item_precio_total;
		
	OPEN ventas_cursor;

	FETCH ventas_cursor into @Factura_Fecha_Hora, @CODIGO_UBICACION, @Medio_Pago, @Empleado_Fecha_Nacimiento, @Categoria_Descripcion, @Subcategoria_Descripcion, @Producto_Cantidad, @Tipo_Caja, @Item_Descuento, @Item_Precio_Total;

	WHILE (@@FETCH_STATUS = 0)
		BEGIN
			/*Tiempo*/
			SET @Factura_Anio = YEAR(@Factura_Fecha_Hora);
			SET @Factura_Mes = MONTH(@Factura_Fecha_Hora);
			SET @Factura_Cuatrimestre = [GeDeDe].obtenerCuatrimestre(@Factura_Fecha_Hora);
			IF NOT EXISTS (SELECT 1 FROM [GeDeDe].BI_dim_Tiempo WHERE BI_dim_Tiempo.Cuatrimestre = @Factura_Cuatrimestre and BI_dim_Tiempo.Año = @Factura_Anio and BI_dim_Tiempo.Mes = @Factura_Mes)
			BEGIN
				INSERT INTO [GeDeDe].[BI_dim_Tiempo] (Cuatrimestre, Año, Mes) VALUES (@Factura_Cuatrimestre, @Factura_Anio, @Factura_Mes)
			END
			SELECT @CODIGO_TIEMPO = CODIGO_TIEMPO  FROM [GeDeDe].BI_dim_Tiempo WHERE BI_dim_Tiempo.Cuatrimestre = @Factura_Cuatrimestre and BI_dim_Tiempo.Año = @Factura_Anio and BI_dim_Tiempo.Mes = @Factura_Mes
			
			/*Turno*/
			SET @Turno = [GeDeDe].obtenerTurnos(@Factura_Fecha_Hora);
			IF NOT EXISTS (SELECT 1 FROM [GeDeDe].BI_dim_Turnos WHERE BI_dim_Turnos.Turno = @Turno)
			BEGIN
				INSERT INTO [GeDeDe].[BI_dim_Turnos] (Turno) VALUES (@Turno)
			END
			SELECT @CODIGO_TURNO = CODIGO_TURNO  FROM [GeDeDe].BI_dim_Turnos WHERE BI_dim_Turnos.Turno = @Turno ;
			/*Rango Etario*/
			SET @Edad = [GeDeDe].obtenerEdad(@Empleado_Fecha_Nacimiento)
			SET @Rango_Etario_Descripcion = [GeDeDe].obtenerRangoEtario(@Edad)
			IF NOT EXISTS (SELECT 1 FROM [GeDeDe].BI_dim_Rango_Etario WHERE (BI_dim_Rango_Etario.Descripcion = @Rango_Etario_Descripcion))
			BEGIN
				INSERT INTO [GeDeDe].[BI_dim_Rango_Etario] (Descripcion) VALUES (@Rango_Etario_Descripcion)
			END
			SELECT @CODIGO_RANGO_ETARIO_VENDEDOR = CODIGO_RANGO_ETARIO  FROM [GeDeDe].BI_dim_Rango_Etario WHERE (BI_dim_Rango_Etario.Descripcion = @Rango_Etario_Descripcion)
			
			/*Categoria Subcategoria*/
			
			IF NOT EXISTS (SELECT 1 FROM [GeDeDe].BI_dim_Categoria_Subcategoria WHERE (BI_dim_Categoria_Subcategoria.Categoria = @Categoria_Descripcion and BI_dim_Categoria_Subcategoria.Subcategoria = @Subcategoria_Descripcion))
			BEGIN
				INSERT INTO [GeDeDe].[BI_dim_Categoria_Subcategoria] (Categoria, Subcategoria) VALUES (@Categoria_Descripcion, @Subcategoria_Descripcion)
			END
			SELECT @CODIGO_CATEGORIA_SUBCATEGORIA = CODIGO_CATEGORIA_SUBCATEGORIA from [GeDeDe].BI_dim_Categoria_Subcategoria WHERE (BI_dim_Categoria_Subcategoria.Categoria = @Categoria_Descripcion and BI_dim_Categoria_Subcategoria.Subcategoria = @Subcategoria_Descripcion)

			
			INSERT INTO [GeDeDe].[BI_fact_Ventas] (CODIGO_TIEMPO, CODIGO_UBICACION, CODIGO_MEDIO_PAGO, CODIGO_TURNO, CODIGO_RANGO_ETARIO_VENDEDOR, CODIGO_CATEGORIA_SUBCATEGORIA, CANTIDAD, TIPO_CAJA, DESCUENTO_APLICADO, TOTAL) 
			VALUES (@CODIGO_TIEMPO, @CODIGO_UBICACION, @Medio_Pago, @CODIGO_TURNO, @CODIGO_RANGO_ETARIO_VENDEDOR, @CODIGO_CATEGORIA_SUBCATEGORIA, @Producto_Cantidad, @Tipo_Caja, @Item_Descuento, @Item_Precio_Total);
			
			FETCH ventas_cursor into @Factura_Fecha_Hora, @CODIGO_UBICACION, @Medio_Pago, @Empleado_Fecha_Nacimiento, @Categoria_Descripcion, @Subcategoria_Descripcion, @Producto_Cantidad, @Tipo_Caja, @Item_Descuento, @Item_Precio_Total;
		END
	
	CLOSE ventas_cursor;
	DEALLOCATE ventas_cursor;
END
GO

CREATE PROCEDURE [GeDeDe].[BI_Migrar_Envios]
AS
BEGIN
 print 'Migracion de Envios'
END
GO

CREATE PROCEDURE [GeDeDe].[BI_Migrar_Pagos]
AS
BEGIN
 print 'Migracion de Pagos'
END
GO

--EJECUCIÓN DE PROCEDURES: MIGRACIÓN DE MODELO OLTP A MODELO BI


 BEGIN TRANSACTION
 BEGIN TRY
	EXECUTE [GeDeDe].[BI_Migrar_Medios_de_Pago]
	EXECUTE [GeDeDe].[BI_Migrar_Sucursales]
	EXECUTE [GeDeDe].[BI_Migrar_Ventas]
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
	THROW 50001, 'Error al cargar el modelo de BI, ninguna tabla fue cargada',1;
END CATCH

 IF (EXISTS (SELECT 1 FROM [GeDeDe].[Medio_Pago])
   AND EXISTS (SELECT 1 FROM [GeDeDe].[Sucursal]))

   BEGIN
	PRINT 'Modelo de BI creado y cargado correctamente.';
	COMMIT TRANSACTION;
   END
	 ELSE
   BEGIN
    ROLLBACK TRANSACTION;
	THROW 50002, 'Hubo un error al cargar una o más tablas. Rollback Transaction: ninguna tabla fue cargada en la base.',1;
   END

GO


--CREACION TRIGGERS EN LAS TABLAS DEL OTRO SCHEMA PARA EL MANTENIMIENTO--
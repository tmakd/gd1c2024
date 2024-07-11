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

IF EXISTS(SELECT [name] FROM sys.objects WHERE [name] = 'cumplioEntrega')
	DROP FUNCTION GeDeDe.cumplioEntrega

--DROP PREVENTIVO DE TABLAS--

-- DROP PREVENTIVO DE TABLAS TEMPORALES
IF OBJECT_ID('tempdb.dbo.#envios_temporal') IS NOT NULL
BEGIN
	DROP TABLE #envios_temporal
END

IF OBJECT_ID('tempdb.dbo.#ventas_temporal') IS NOT NULL
BEGIN
	DROP TABLE #ventas_temporal
END

IF OBJECT_ID('tempdb.dbo.#promociones_temporal') IS NOT NULL
BEGIN
	DROP TABLE #promociones_temporal
END

IF OBJECT_ID('tempdb.dbo.#pagos_temporal') IS NOT NULL
BEGIN
	DROP TABLE #pagos_temporal
END

-- DROP PREVENTIVO DE TABLAS FÁCTICAS---------------------------------------------------------
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BI_fact_Ventas')
    DROP TABLE GeDeDe.BI_fact_Ventas;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BI_fact_Pagos')
    DROP TABLE GeDeDe.BI_fact_Pagos;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BI_fact_Envios')
    DROP TABLE GeDeDe.BI_fact_Envios;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BI_fact_Descuento_Promocion')
    DROP TABLE GeDeDe.BI_fact_Descuento_Promocion;

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
	
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BI_dim_Factura')
    DROP TABLE GeDeDe.BI_dim_Factura;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BI_dim_Categoria_Subcategoria')
    DROP TABLE GeDeDe.BI_dim_Categoria_Subcategoria;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BI_dim_Tipo_Caja')
    DROP TABLE GeDeDe.BI_dim_Tipo_Caja;


-- DROPS PREVENTIVOS DE VISTAS----------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BI_TicketPromedioMensual' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_BI_TicketPromedioMensual];
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BI_CantidadUnidadesPromedio' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_BI_CantidadUnidadesPromedio];

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BI_PorcentajeVentasPorRangoEtario' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_BI_PorcentajeVentasPorRangoEtario];

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BI_VentasPorTurnoYLocalidad' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_BI_VentasPorTurnoYLocalidad];

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BI_PorcentajeDescuentoPorMes' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_BI_PorcentajeDescuentoPorMes];
	
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BI_CategoriasTotalDescuento' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_BI_CategoriasTotalDescuento]; --   <-- se debe hacer un select top 3 / order by en el select de la vista para obtener el ranking 

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BI_Sucursales_Pagos_Cuotas' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_BI_Sucursales_Pagos_Cuotas]; 
	
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BI_Promedio_Cuota_Rango_Etareo' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_BI_Promedio_Cuota_Rango_Etareo]; 

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BI_Porcentaje_Descuento_Medio_Pago_Cuatrimestre' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_BI_Porcentaje_Descuento_Medio_Pago_Cuatrimestre]; 

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BI_PorcentajeDeCumplimientoDeEnvios' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_BI_PorcentajeDeCumplimientoDeEnvios];

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BI_CantidadDeEnviosPorRangoEtario' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_BI_CantidadDeEnviosPorRangoEtario];

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BI_LocalidadesConMayorCostoDeEnvio' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_BI_LocalidadesConMayorCostoDeEnvio];

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

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'BI_Migrar_Tipos_de_Caja' and schema_id = SCHEMA_ID('GeDeDe'))
	DROP PROCEDURE [GeDeDe].[BI_Migrar_Tipos_de_Caja];

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

/*  Envio cumple entrega
	@param fecha de entrega, fecha programada y hora final de entrega
	@returns 1 o 0 en caso de que haya cumplido o no
*/

CREATE FUNCTION GeDeDe.cumplioEntrega (@fecha_programada datetime, @fecha_entrega datetime, @hora_fin decimal(18,0))
RETURNS BIT AS
BEGIN

	IF(DAY(@fecha_entrega) = DAY(@fecha_programada) AND DATEPART(HOUR, @fecha_entrega) <= CAST(@hora_fin AS INT)
		OR @fecha_entrega < @fecha_programada)
	RETURN 1
	RETURN 0
END

GO

--CREACIÓN DE TABLAS DIMENSIONALES--
-- Tabla dimensional de tipo caja
CREATE TABLE [GeDeDe].[BI_dim_Tipo_Caja](
	CODIGO_TIPO_CAJA DECIMAL(18,0) PRIMARY KEY,
	DESCRIPCION NVARCHAR(255)
);
GO

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
-- Tabla dimensional de Factura
CREATE TABLE [GeDeDe].[BI_dim_Factura] (
    CODIGO_FACTURA INT IDENTITY(1,1) PRIMARY KEY,
    Tipo NVARCHAR(255),
    Numero DECIMAL(18,0),
	Sucursal DECIMAL(18,0),
	Caja DECIMAL(18,0)
);
GO
--CREACIÓN DE TABLAS FÁCTICAS--
CREATE TABLE [GeDeDe].[BI_fact_Ventas] (
    CODIGO_TIEMPO INT NOT NULL,
    CODIGO_UBICACION INT NOT NULL,
	CODIGO_RANGO_ETARIO_VENDEDOR INT NOT NULL,
	CODIGO_TIPO_CAJA DECIMAL(18,0) NOT NULL,
    CODIGO_TURNO INT NOT NULL,
    
    CANTIDAD_FACTURAS INT,
	VALOR_TOTAL_FACTURAS DECIMAL(18,2),
	CANTIDAD_ARTICULOS INT
);

ALTER TABLE [GeDeDe].[BI_fact_Ventas]
ADD CONSTRAINT PK_BI_fact_ventas PRIMARY KEY (CODIGO_TIEMPO, CODIGO_UBICACION, CODIGO_RANGO_ETARIO_VENDEDOR, CODIGO_TIPO_CAJA, CODIGO_TURNO);
GO

/*
ALTER TABLE [GeDeDe].[BI_fact_Ventas]
ADD CONSTRAINT FK_BI_fact_Ventas_CODIGO_FACTURA FOREIGN KEY (CODIGO_FACTURA) REFERENCES [GeDeDe].[BI_dim_Factura](CODIGO_FACTURA),
	CONSTRAINT FK_BI_fact_Ventas_CODIGO_TIEMPO FOREIGN KEY (CODIGO_TIEMPO) REFERENCES [GeDeDe].[BI_dim_Tiempo](CODIGO_TIEMPO),
    CONSTRAINT FK_BI_fact_Ventas_CODIGO_UBICACION FOREIGN KEY (CODIGO_UBICACION) REFERENCES [GeDeDe].[BI_dim_Ubicacion](CODIGO_UBICACION),
    CONSTRAINT FK_BI_fact_Ventas_CODIGO_MEDIO_PAGO FOREIGN KEY (CODIGO_MEDIO_PAGO) REFERENCES [GeDeDe].[BI_dim_Medio_Pago](CODIGO_MEDIO_PAGO),
    CONSTRAINT FK_BI_fact_Ventas_CODIGO_TURNO FOREIGN KEY (CODIGO_TURNO) REFERENCES [GeDeDe].[BI_dim_Turnos](CODIGO_TURNO),
    CONSTRAINT FK_BI_fact_Ventas_CODIGO_RANGO_ETARIO_VENDEDOR FOREIGN KEY (CODIGO_RANGO_ETARIO_VENDEDOR) REFERENCES [GeDeDe].[BI_dim_Rango_Etario](CODIGO_RANGO_ETARIO),
    CONSTRAINT FK_BI_fact_Ventas_CODIGO_CATEGORIA_SUBCATEGORIA FOREIGN KEY (CODIGO_CATEGORIA_SUBCATEGORIA) REFERENCES [GeDeDe].[BI_dim_Categoria_Subcategoria](CODIGO_CATEGORIA_SUBCATEGORIA);
GO
*/

CREATE TABLE [GeDeDe].[BI_fact_Envios](
    CODIGO_TIEMPO INT NOT NULL,
    CODIGO_RANGO_ETARIO_CLIENTE INT NOT NULL,
    CODIGO_SUCURSAL DECIMAL(18,0) NOT NULL,
    CLIENTE_UBICACION INT NOT NULL,
	ENVIOS_A_TIEMPO INT NOT NULL,
    CANTIDAD_ENVIOS INT NOT NULL,
    COSTO DECIMAL(18,2)
);

/*ALTER TABLE [GeDeDe].[BI_fact_Envios]
ADD CONSTRAINT PK_BI_fact_Envios_CODIGO_ENVIO PRIMARY KEY(CODIGO_ENVIO),
    CONSTRAINT FK_BI_fact_Envios_CODIGO_TIEMPO FOREIGN KEY (CODIGO_TIEMPO) REFERENCES [GeDeDe].[BI_dim_Tiempo](CODIGO_TIEMPO),
    CONSTRAINT FK_BI_fact_Envios_CODIGO_RANGO_ETARIO_CLIENTE FOREIGN KEY(CODIGO_RANGO_ETARIO_CLIENTE) REFERENCES [GeDeDe].[BI_dim_Rango_Etario](CODIGO_RANGO_ETARIO),
    CONSTRAINT FK_BI_fact_Envios_CODIGO_SUCURSAL FOREIGN KEY (CODIGO_SUCURSAL) REFERENCES [GeDeDe].[BI_dim_Sucursal](CODIGO_SUCURSAL),
    CONSTRAINT FK_BI_fact_Envios_CLIENTE_UBICACION  FOREIGN KEY(CLIENTE_UBICACION) REFERENCES [GeDeDe].[BI_dim_Ubicacion](CODIGO_UBICACION);
GO*/

ALTER TABLE [GeDeDe].[BI_fact_envios]
ADD CONSTRAINT PK_BI_fact_envios PRIMARY KEY (CODIGO_TIEMPO, CODIGO_RANGO_ETARIO_CLIENTE, CODIGO_SUCURSAL, CLIENTE_UBICACION);
GO

CREATE TABLE [GeDeDe].[BI_fact_Pagos] (
    CODIGO_PAGO INT IDENTITY(1,1) PRIMARY KEY,
    CODIGO_FACTURA INT NOT NULL,
	CODIGO_TIEMPO INT NOT NULL,
    CODIGO_SUCURSAL DECIMAL(18,0) NOT NULL,
    CODIGO_MEDIO_PAGO DECIMAL(18,0) NOT NULL,
    CODIGO_RANGO_ETARIO_CLIENTE INT NOT NULL,
    CUOTAS INT NULL, -- Campo para indicar el número de cuotas (null si no tiene cuotas)
    MONTO DECIMAL(18, 2),
    DESCUENTO_APLICADO DECIMAL(18, 2),
    TOTAL_PAGO DECIMAL(18, 2)
);

ALTER TABLE [GeDeDe].[BI_fact_Pagos]
ADD CONSTRAINT FK_BI_fact_Pagos_CODIGO_FACTURA FOREIGN KEY (CODIGO_FACTURA) REFERENCES [GeDeDe].[BI_dim_Factura](CODIGO_FACTURA),
	CONSTRAINT FK_BI_fact_Pagos_CODIGO_TIEMPO FOREIGN KEY (CODIGO_TIEMPO) REFERENCES [GeDeDe].[BI_dim_Tiempo](CODIGO_TIEMPO),
	CONSTRAINT FK_BI_fact_Pagos_CODIGO_SUCURSAL FOREIGN KEY (CODIGO_SUCURSAL) REFERENCES [GeDeDe].[BI_dim_Sucursal](CODIGO_SUCURSAL),
	CONSTRAINT FK_BI_fact_Pagos_CODIGO_MEDIO_PAGO FOREIGN KEY (CODIGO_MEDIO_PAGO) REFERENCES [GeDeDe].[BI_dim_Medio_Pago](CODIGO_MEDIO_PAGO),
	CONSTRAINT FK_BI_fact_Pagos_CODIGO_RANGO_ETARIO_CLIENTE FOREIGN KEY (CODIGO_RANGO_ETARIO_CLIENTE) REFERENCES [GeDeDe].[BI_dim_Rango_Etario](CODIGO_RANGO_ETARIO);

GO
CREATE TABLE #envios_temporal(
	CODIGO_ENVIO DECIMAL(18,0) PRIMARY KEY,
	CODIGO_TIEMPO INT ,
    CODIGO_RANGO_ETARIO_CLIENTE INT,
    CODIGO_SUCURSAL DECIMAL(18,0) ,
    CLIENTE_UBICACION INT ,
	ENVIOS_A_TIEMPO INT ,
	COSTO DECIMAL(18,2),
	CANTIDAD_ENVIOS INT 
);
GO
CREATE TABLE #ventas_temporal(
	CODIGO_TIEMPO INT,
    CODIGO_UBICACION INT,
	CODIGO_RANGO_ETARIO_VENDEDOR INT,
	CODIGO_TIPO_CAJA DECIMAL(18,0),
    CODIGO_TURNO INT,
    
    CANTIDAD_FACTURAS INT,
	VALOR_TOTAL_FACTURAS DECIMAL(18,2),
	CANTIDAD_ARTICULOS INT
);
GO

CREATE TABLE #promociones_temporal (
	CODIGO_TIEMPO INT,
	CODIGO_CATEGORIA_SUBCATEGORIA INT,
	FACTURA VARCHAR(255), 
	VALOR_DESCUENTO_POR_PROMOCION DECIMAL(18,2),
	VALOR_TOTAL_DESCUENTO_APLICADO DECIMAL(18,2),
	VALOR_TOTAL_FACTURAS DECIMAL(18,2)
);
GO

CREATE TABLE [GeDeDe].[BI_fact_Descuento_Promocion] (
	CODIGO_TIEMPO INT, -- PK FK
	CODIGO_CATEGORIA_SUBCATEGORIA INT, -- PK FK
	VALOR_DESCUENTO_POR_PROMOCION DECIMAL(18,2),
	VALOR_TOTAL_DESCUENTO_APLICADO DECIMAL(18,2),
	VALOR_TOTAL_FACTURAS DECIMAL(18,2)
);
GO;

ALTER TABLE [GeDeDe].[BI_fact_Descuento_Promocion]
ADD CONSTRAINT PK_BI_fact_Descuento_Promocion PRIMARY KEY (CODIGO_TIEMPO, CODIGO_CATEGORIA_SUBCATEGORIA);


--CREACION DE VISTAS--

/*
1.  Ticket  Promedio  mensual.  Valor  promedio  de  las  ventas  (en  $)  según  la 
localidad,  año  y  mes.  Se  calcula  en  función  de  la  sumatoria  del  importe  de  las 
ventas sobre el total de las mismas. 
*/
CREATE VIEW [GeDeDe].[vw_BI_TicketPromedioMensual] AS
SELECT 
    u.Localidad,
    t.Año,
    t.Mes,
    --AVG(v.TOTAL) AS TicketPromedioMensual,
    SUM(v.valor_total_facturas) / sum(v.cantidad_facturas) AS ValorPromedioVentas
FROM 
    [GeDeDe].[BI_fact_Ventas] v
INNER JOIN 
    [GeDeDe].[BI_dim_Tiempo] t ON v.CODIGO_TIEMPO = t.CODIGO_TIEMPO
INNER JOIN 
    [GeDeDe].[BI_dim_Ubicacion] u ON v.CODIGO_UBICACION = u.CODIGO_UBICACION
GROUP BY 
    u.Localidad, t.Año, t.Mes;
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
    sum(fv.cantidad_articulos)/sum(fv.cantidad_facturas) AS CantidadUnidadesPromedio
FROM
    [GeDeDe].[BI_fact_Ventas] fv
    JOIN [GeDeDe].[BI_dim_Tiempo] t ON fv.CODIGO_TIEMPO = t.CODIGO_TIEMPO
    JOIN [GeDeDe].[BI_dim_Turnos] tu ON fv.CODIGO_TURNO = tu.CODIGO_TURNO
GROUP BY
    t.Año,
    t.Cuatrimestre,
    tu.Turno
GO
/*
3.  Porcentaje  anual  de  ventas  registradas  por  rango  etario  del  empleado  según  el 
tipo  de  caja  para  cada  cuatrimestre.  Se  calcula  tomando  la  cantidad  de  ventas 
correspondientes sobre el total de ventas anual
*/
CREATE VIEW [GeDeDe].[vw_BI_PorcentajeVentasPorRangoEtario] AS
SELECT 
    t.Año,
    t.Cuatrimestre,
    r.Descripcion AS RangoEtario,
    tc.DESCRIPCION AS TipoCaja,
    CAST(CAST(sum(v.cantidad_facturas) AS DECIMAL(18,2))*100/(SELECT sum(v2.cantidad_facturas) from [GeDeDe].[BI_fact_Ventas] v2
								JOIN [GeDeDe].[BI_dim_Tiempo] t2 ON v2.CODIGO_TIEMPO = t2.CODIGO_TIEMPO
								WHERE t2.Año = t.Año) AS DECIMAL(5,2)) AS PorcentajeAnualVentas
FROM
    [GeDeDe].[BI_fact_Ventas] v
INNER JOIN 
    [GeDeDe].[BI_dim_Tiempo] t ON v.CODIGO_TIEMPO = t.CODIGO_TIEMPO
INNER JOIN 
    [GeDeDe].[BI_dim_Rango_Etario] r ON v.CODIGO_RANGO_ETARIO_VENDEDOR = r.CODIGO_RANGO_ETARIO
INNER JOIN
	[GeDeDe].[BI_dim_Tipo_Caja] tc ON v.CODIGO_TIPO_CAJA = tc.CODIGO_TIPO_CAJA
GROUP BY 
    t.Año, t.Cuatrimestre, r.Descripcion, tc.DESCRIPCION;
GO
/*
4. Cantidad  de  ventas  registradas  por  turno  para  cada  localidad  según  el  mes  de 
cada año.
*/
CREATE VIEW [GeDeDe].[vw_BI_VentasPorTurnoYLocalidad] AS
SELECT 
    t.Año,
    t.Mes,
    u.Localidad,
    tu.Turno,
    sum(v.cantidad_facturas) AS CantidadVentasRegistradas
FROM 
    [GeDeDe].[BI_fact_Ventas] v
INNER JOIN 
    [GeDeDe].[BI_dim_Tiempo] t ON v.CODIGO_TIEMPO = t.CODIGO_TIEMPO
INNER JOIN 
    [GeDeDe].[BI_dim_Ubicacion] u ON v.CODIGO_UBICACION = u.CODIGO_UBICACION
INNER JOIN 
    [GeDeDe].[BI_dim_Turnos] tu ON v.CODIGO_TURNO = tu.CODIGO_TURNO
GROUP BY 
    t.Año, t.Mes, u.Localidad, tu.Turno;
GO

/*
5.  Porcentaje  de  descuento  aplicados  en  función  del  total  de  los  tickets  según  el 
mes de cada año. 

CREATE VIEW [GeDeDe].[vw_BI_PorcentajeDescuentoPorMes] AS
SELECT
    t.Año,
    t.Mes,
    SUM(v.DESCUENTO_APLICADO) AS TotalDescuento,
    SUM(v.TOTAL) AS TotalVentas,
    (SUM(v.DESCUENTO_APLICADO) / SUM(v.TOTAL)) * 100 AS PorcentajeDescuento
FROM
    [GeDeDe].[BI_fact_Ventas] v
INNER JOIN
    [GeDeDe].[BI_dim_Tiempo] t ON v.CODIGO_TIEMPO = t.CODIGO_TIEMPO
GROUP BY
    t.Año, t.Mes;

GO


6.  Las  tres  categorías  de  productos  con  mayor  descuento  aplicado  a  partir  de 
promociones para cada cuatrimestre de cada año. 

CREATE VIEW [GeDeDe].[vw_BI_CategoriasTotalDescuento] AS
SELECT 
    t.Año,
    t.Cuatrimestre,
    c.Categoria,
    SUM(v.DESCUENTO_APLICADO) AS TotalDescuento
FROM 
    [GeDeDe].[BI_fact_Ventas] v
INNER JOIN 
    [GeDeDe].[BI_dim_Tiempo] t ON v.CODIGO_TIEMPO = t.CODIGO_TIEMPO
INNER JOIN 
    [GeDeDe].[BI_dim_Categoria_Subcategoria] c ON v.CODIGO_CATEGORIA_SUBCATEGORIA = c.CODIGO_CATEGORIA_SUBCATEGORIA
GROUP BY 
    t.Año, t.Cuatrimestre, c.Categoria
HAVING
    SUM(v.DESCUENTO_APLICADO) > 0
GO*/
/*envios*/
/*7.  Porcentaje  de  cumplimiento  de  envíos  en  los  tiempos  programados  por 
sucursal por año/mes (desvío)*/
CREATE VIEW [GeDeDe].[vw_BI_PorcentajeDeCumplimientoDeEnvios] AS
SELECT 
    e.CODIGO_SUCURSAL,
    t.Año,
    t.Mes,
    CAST(CAST(sum(e.ENVIOS_A_TIEMPO) AS DECIMAL(18,2))*100/sum(e.CANTIDAD_ENVIOS) AS DECIMAL(5,2)) 'Porcentaje de cumplimiento'
FROM 
    [GeDeDe].[BI_fact_Envios] e
INNER JOIN 
    [GeDeDe].[BI_dim_Tiempo] t ON e.CODIGO_TIEMPO = t.CODIGO_TIEMPO
GROUP BY 
    e.CODIGO_SUCURSAL, t.Año, t.Mes;
GO
/*
8.  Cantidad  de  envíos  por  rango  etario  de  clientes  para  cada  cuatrimestre  de 
cada año.
*/
CREATE VIEW [GeDeDe].[vw_BI_CantidadDeEnviosPorRangoEtario]
AS
SELECT 
	r.Descripcion 'Rango Etario',
	sum(cantidad_envios) 'Cantidad de envios'
FROM GeDeDe.BI_fact_envios e JOIN GeDeDe.BI_dim_Rango_Etario r ON e.CODIGO_RANGO_ETARIO_CLIENTE = r.CODIGO_RANGO_ETARIO
GROUP BY e.CODIGO_RANGO_ETARIO_CLIENTE, r.Descripcion
GO

/*
9.  Las 5 localidades (tomando la localidad del cliente) con mayor costo de envío.
*/
CREATE VIEW [GeDeDe].[vw_BI_LocalidadesConMayorCostoDeEnvio]
AS
SELECT TOP 5 u.Localidad 'Localidad',
		sum(COSTO) 'Costo de envio'
FROM GeDeDe.BI_fact_envios e JOIN GeDeDe.BI_dim_Ubicacion u ON e.CLIENTE_UBICACION = u.CODIGO_UBICACION
GROUP BY u.Localidad
ORDER BY 2 DESC
GO


/*fin envios*/
/*
10.  Las  3  sucursales  con  el  mayor  importe  de  pagos  en  cuotas,  según  el  medio  de 
pago,  mes  y  año.  Se  calcula  sumando  los  importes  totales  de  todas  las  ventas  en 
cuotas.
*/
CREATE VIEW [GeDeDe].[vw_BI_Sucursales_Pagos_Cuotas] AS
SELECT 
    p.CODIGO_SUCURSAL,
    t.Año,
    t.Mes, 
    p.CODIGO_MEDIO_PAGO,
    SUM(p.MONTO) AS ImportePagosCuotas
FROM 
    [GeDeDe].[BI_fact_Pagos] p
INNER JOIN 
    [GeDeDe].[BI_dim_Tiempo] t ON p.CODIGO_TIEMPO = t.CODIGO_TIEMPO
WHERE 
    p.CUOTAS IS NOT NULL -- Solo consideramos pagos en cuotas
GROUP BY 
    p.CODIGO_SUCURSAL, t.Año, t.Mes, p.CODIGO_MEDIO_PAGO;

GO
/*
11.  Promedio de importe de la cuota en función del rango etareo del cliente. 
*/
CREATE VIEW [GeDeDe].[vw_BI_Promedio_Cuota_Rango_Etareo] AS
SELECT 
    p.CODIGO_RANGO_ETARIO_CLIENTE,
    AVG(p.MONTO / p.CUOTAS) AS PromedioImporteCuota
FROM 
    [GeDeDe].[BI_fact_Pagos] p
WHERE 
    p.CUOTAS IS NOT NULL -- Consideramos solo los pagos que tienen cuotas
GROUP BY 
    p.CODIGO_RANGO_ETARIO_CLIENTE;
GO
/*
12.  Porcentaje  de  descuento  aplicado  por  cada  medio  de  pago  en  función  del  valor 
de  total  de  pagos  sin  el  descuento,  por  cuatrimestre.  Es  decir,  total  de  descuentos 
sobre el total de pagos más el total de descuentos. 
*/
CREATE VIEW [GeDeDe].[vw_BI_Porcentaje_Descuento_Medio_Pago_Cuatrimestre] AS
SELECT 
    p.CODIGO_MEDIO_PAGO,
    t.Año,
    t.Cuatrimestre,
    SUM(p.DESCUENTO_APLICADO) / SUM(p.TOTAL_PAGO) AS PorcentajeDescuento
FROM 
    [GeDeDe].[BI_fact_Pagos] p
INNER JOIN 
    [GeDeDe].[BI_dim_Tiempo] t ON p.CODIGO_TIEMPO = t.CODIGO_TIEMPO
GROUP BY 
    p.CODIGO_MEDIO_PAGO, t.Año, t.Cuatrimestre;
GO

-- Índice para BI_fact_Ventas por CODIGO_TIEMPO y CODIGO_UBICACION
CREATE INDEX IX_BI_fact_Ventas_TIEMPO_UBICACION ON GeDeDe.BI_fact_Ventas (CODIGO_TIEMPO, CODIGO_UBICACION);
GO
-- Índice para BI_fact_Ventas por CODIGO_TIEMPO y CODIGO_PRODUCTO
--CREATE INDEX IX_BI_fact_Ventas_TIEMPO__CATEGORIA_SUBCATEGORIA ON GeDeDe.BI_fact_Ventas (CODIGO_TIEMPO, CODIGO_CATEGORIA_SUBCATEGORIA);
GO
-- Índice para BI_fact_Ventas por CODIGO_TIEMPO y CODIGO_TURNO
CREATE INDEX IX_BI_fact_Ventas_TIEMPO_TURNO ON GeDeDe.BI_fact_Ventas (CODIGO_TIEMPO, CODIGO_TURNO);
GO



--CREACION PROCEDURES DE MIGRACION--

CREATE PROCEDURE [GeDeDe].[BI_Migrar_Tipos_de_Caja]
AS
BEGIN
	INSERT INTO [GeDeDe].[BI_dim_Tipo_Caja] (CODIGO_TIPO_CAJA, DESCRIPCION)
	SELECT tipo_caja_codigo, tipo_caja_nombre
	FROM GeDeDe.Tipo_Caja
END
GO

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
	
	declare @factura_anio int, @factura_mes int, @factura_cuatrimestre int
	declare @total_factura decimal(18,2), @cantidad_articulos decimal(18,0), @fecha_hora_factura datetime, @fecha_vendedor datetime,
	@caja decimal(18,0), @turno nvarchar(255), @edad int, @rango_etario_descripcion nvarchar(255), @sucursal decimal(18,0)
	declare @CODIGO_TIEMPO INT, @codigo_turno int, @codigo_rango_etario_vendedor int, @CODIGO_UBICACION INT, @CODIGO_TIPO_CAJA DECIMAL(18,0)
	
	DECLARE ventas_cursor CURSOR FOR
		SELECT fact_total_ticket,sum(item_cantidad), fact_fecha_hora, empl_fecha_nacimiento, fact_caja, fact_sucursal
		FROM GeDeDe.Item_Factura 
		JOIN GeDeDe.Factura on item_fact_caja = fact_caja and item_fact_nro = fact_nro 
		and item_fact_sucursal = fact_sucursal and item_fact_tipo = fact_tipo
		JOIN GeDeDe.Empleado on fact_vendedor = empl_codigo
		group by fact_total_ticket, fact_fecha_hora, empl_fecha_nacimiento, fact_caja, fact_nro, fact_tipo, fact_sucursal

	OPEN ventas_cursor;
	FETCH NEXT FROM ventas_cursor into @total_factura, @cantidad_articulos, @fecha_hora_factura, @fecha_vendedor, @caja, @sucursal
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
			/*Tiempo*/
			SET @Factura_Anio = YEAR(@fecha_hora_factura);
			SET @Factura_Mes = MONTH(@fecha_hora_factura);
			SET @Factura_Cuatrimestre = [GeDeDe].obtenerCuatrimestre(@fecha_hora_factura);
			IF NOT EXISTS (SELECT 1 FROM [GeDeDe].BI_dim_Tiempo WHERE BI_dim_Tiempo.Cuatrimestre = @Factura_Cuatrimestre and BI_dim_Tiempo.Año = @Factura_Anio and BI_dim_Tiempo.Mes = @Factura_Mes)
			BEGIN
				INSERT INTO [GeDeDe].[BI_dim_Tiempo] (Cuatrimestre, Año, Mes) VALUES (@Factura_Cuatrimestre, @Factura_Anio, @Factura_Mes)
			END
			SELECT @CODIGO_TIEMPO = CODIGO_TIEMPO  FROM [GeDeDe].BI_dim_Tiempo WHERE BI_dim_Tiempo.Cuatrimestre = @Factura_Cuatrimestre and BI_dim_Tiempo.Año = @Factura_Anio and BI_dim_Tiempo.Mes = @Factura_Mes
			
			/*Tipo Caja*/
			SELECT @CODIGO_TIPO_CAJA = caja_tipo from GeDeDe.Caja where @caja = caja_codigo

			/* Ubicacion */
			SELECT @CODIGO_UBICACION = CODIGO_UBICACION FROM GeDeDe.BI_dim_Sucursal WHERE @sucursal = CODIGO_SUCURSAL

			/*Turno*/
			SET @Turno = [GeDeDe].obtenerTurnos(@fecha_hora_factura);
			IF NOT EXISTS (SELECT 1 FROM [GeDeDe].BI_dim_Turnos WHERE BI_dim_Turnos.Turno = @Turno)
			BEGIN
				INSERT INTO [GeDeDe].[BI_dim_Turnos] (Turno) VALUES (@Turno)
			END
			SELECT @CODIGO_TURNO = CODIGO_TURNO  FROM [GeDeDe].BI_dim_Turnos WHERE BI_dim_Turnos.Turno = @Turno ;

			/*Rango Etario*/
			SET @Edad = [GeDeDe].obtenerEdad(@fecha_vendedor)
			SET @Rango_Etario_Descripcion = [GeDeDe].obtenerRangoEtario(@Edad)
			IF NOT EXISTS (SELECT 1 FROM [GeDeDe].BI_dim_Rango_Etario WHERE (BI_dim_Rango_Etario.Descripcion = @Rango_Etario_Descripcion))
			BEGIN
				INSERT INTO [GeDeDe].[BI_dim_Rango_Etario] (Descripcion) VALUES (@Rango_Etario_Descripcion)
			END
			SELECT @CODIGO_RANGO_ETARIO_VENDEDOR = CODIGO_RANGO_ETARIO  FROM [GeDeDe].BI_dim_Rango_Etario WHERE (BI_dim_Rango_Etario.Descripcion = @Rango_Etario_Descripcion)
			
			INSERT INTO #ventas_temporal(CODIGO_TIEMPO, CODIGO_UBICACION, CODIGO_RANGO_ETARIO_VENDEDOR, CODIGO_TIPO_CAJA, CODIGO_TURNO, CANTIDAD_FACTURAS, VALOR_TOTAL_FACTURAS, CANTIDAD_ARTICULOS) 
			VALUES (@CODIGO_TIEMPO, @CODIGO_UBICACION, @codigo_rango_etario_vendedor, @CODIGO_TIPO_CAJA, @codigo_turno, 1, @total_factura, @cantidad_articulos)
			FETCH NEXT FROM ventas_cursor into @total_factura, @cantidad_articulos, @fecha_hora_factura, @fecha_vendedor, @caja, @sucursal
		END
	CLOSE ventas_cursor;
	DEALLOCATE ventas_cursor;

	INSERT INTO GeDeDe.BI_fact_Ventas(CODIGO_TIEMPO, CODIGO_UBICACION, CODIGO_RANGO_ETARIO_VENDEDOR, CODIGO_TIPO_CAJA, CODIGO_TURNO, CANTIDAD_FACTURAS, VALOR_TOTAL_FACTURAS, CANTIDAD_ARTICULOS)
	SELECT CODIGO_TIEMPO, CODIGO_UBICACION, CODIGO_RANGO_ETARIO_VENDEDOR, CODIGO_TIPO_CAJA, CODIGO_TURNO,
	sum(CANTIDAD_FACTURAS), sum(VALOR_TOTAL_FACTURAS), sum(CANTIDAD_ARTICULOS)
	FROM #ventas_temporal
	group by CODIGO_TIEMPO, CODIGO_UBICACION, CODIGO_RANGO_ETARIO_VENDEDOR, CODIGO_TIPO_CAJA, CODIGO_TURNO
END
GO

CREATE PROCEDURE [GeDeDe].[BI_Migrar_Envios]
AS
BEGIN
	print 'Migracion de Envios'

	DECLARE @codigo_envio DECIMAL(18,0), @fecha_programada datetime, @fecha_entrega datetime, @costo_envio decimal(18,2),
	@estado_envio nvarchar(255), @fecha_nacimiento date, @localidad nvarchar(255), @provincia nvarchar(255), @edad int,
	@rango_etario nvarchar(255), @anio_fecha int, @mes_fecha int, @cuatrimestre_fecha int,
	@hora_inicio decimal(18,0), @hora_fin decimal(18,0), @envios_a_tiempo int
	DECLARE @codigo_sucursal int, @codigo_rango_etario int, @codigo_tiempo int, @codigo_ubicacion int
	

	DECLARE cursor_envios CURSOR FOR
	SELECT DISTINCT
		envi_codigo,
		envi_fecha_programada,
		envi_fecha_entrega,
		envi_horario_inicio,
		envi_horario_fin,
		envi_estado,
		envi_costo,
		envi_fact_sucursal,
		clie_fecha_nacimiento,
		clie_localidad,
		clie_provincia
	FROM GeDeDe.Envio JOIN GeDeDe.Cliente ON envi_cliente = clie_codigo

	OPEN cursor_envios 
	FETCH NEXT FROM cursor_envios INTO @codigo_envio, @fecha_programada, @fecha_entrega, @hora_inicio, @hora_fin, @estado_envio, @costo_envio, 
	@codigo_sucursal, @fecha_nacimiento, @localidad, @provincia
	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @envios_a_tiempo = 0

		select @edad = GeDeDe.obtenerEdad(@fecha_nacimiento)
		select @rango_etario = GeDeDe.obtenerRangoEtario(@edad)

		IF NOT EXISTS(SELECT 1 FROM GeDeDe.BI_dim_Ubicacion WHERE Provincia = @provincia AND Localidad = @localidad)
		INSERT INTO GeDeDe.BI_dim_Ubicacion(Localidad, Provincia)
		VALUES(@localidad, @provincia)

		set @anio_fecha = year(@fecha_entrega)
		set @mes_fecha = month(@fecha_entrega)
		select @cuatrimestre_fecha = GeDeDe.obtenerCuatrimestre(@fecha_entrega)

		IF NOT EXISTS(SELECT 1 FROM GeDeDe.BI_dim_Tiempo where Cuatrimestre = @cuatrimestre_fecha and Mes = @mes_fecha and Año = @anio_fecha)
		INSERT INTO GeDeDe.BI_dim_Tiempo(Año, Cuatrimestre, Mes)
		VALUES(@anio_fecha, @cuatrimestre_fecha, @mes_fecha)

		IF(GeDeDe.cumplioEntrega(@fecha_programada, @fecha_entrega, @hora_fin) = 1)
		set @envios_a_tiempo = 1

		select @codigo_tiempo = CODIGO_TIEMPO from GeDeDe.BI_dim_Tiempo where Año = @anio_fecha and Cuatrimestre = @cuatrimestre_fecha and Mes = @mes_fecha
		select @codigo_ubicacion = CODIGO_UBICACION from GeDeDe.BI_dim_Ubicacion WHERE Provincia = @provincia AND Localidad = @localidad
		select @codigo_rango_etario = CODIGO_RANGO_ETARIO from GeDeDe.BI_dim_Rango_Etario WHERE @rango_etario = Descripcion

		INSERT INTO #envios_temporal(CODIGO_ENVIO, CODIGO_TIEMPO, CODIGO_SUCURSAL, CODIGO_RANGO_ETARIO_CLIENTE, CLIENTE_UBICACION, ENVIOS_A_TIEMPO, COSTO, CANTIDAD_ENVIOS)
		values(@codigo_envio, @codigo_tiempo, @codigo_sucursal, @codigo_rango_etario, @codigo_ubicacion, @envios_a_tiempo, @costo_envio, 1)

		FETCH NEXT FROM cursor_envios INTO @codigo_envio, @fecha_programada, @fecha_entrega, @hora_inicio, @hora_fin, @estado_envio, @costo_envio, 
		@codigo_sucursal, @fecha_nacimiento, @localidad, @provincia
	END
	CLOSE cursor_envios
	deallocate cursor_envios

	INSERT INTO GeDeDe.BI_fact_envios (CLIENTE_UBICACION, CODIGO_TIEMPO, CODIGO_RANGO_ETARIO_CLIENTE, CODIGO_SUCURSAL, ENVIOS_A_TIEMPO, CANTIDAD_ENVIOS, COSTO)
	SELECT CLIENTE_UBICACION, CODIGO_TIEMPO, CODIGO_RANGO_ETARIO_CLIENTE, CODIGO_SUCURSAL,
			SUM(ENVIOS_A_TIEMPO), SUM(CANTIDAD_ENVIOS), SUM(COSTO)
	FROM #envios_temporal
	GROUP BY CLIENTE_UBICACION, CODIGO_TIEMPO, CODIGO_SUCURSAL, CODIGO_RANGO_ETARIO_CLIENTE
END
GO

CREATE PROCEDURE [GeDeDe].[BI_Migrar_Categoria_Subcategoria]
AS
BEGIN
	print 'Migracion de Categoria Subcategoria'
	INSERT INTO [GeDeDe].[BI_dim_Categoria_Subcategoria] (Categoria, Subcategoria)
	SELECT c2.cate_descripcion, c1.cate_descripcion
	FROM [GeDeDe].Subcategoria
		join [GeDeDe].Categoria c1 on c1.cate_codigo = subc_codigo
		join [GeDeDe].Categoria c2 on c2.cate_codigo = subc_categoria

END;
select * from #promociones_temporal;
CREATE PROCEDURE [GeDeDe].[BI_Migrar_Promocion_Descuentos]
AS
BEGIN
	print 'Migracion de Promocion Descuento'
	DECLARE @TOTAL_TICKET DECIMAL(18,2), @DESCUENTO_PROMOCION DECIMAL(18,2), @DESCUENTO_MEDIO_PAGO DECIMAL(18,2), @FACTURA VARCHAR(255) ,@CATEGORIA_CODIGO DECIMAL(18,0), @SUBCATEGORIA_CODIGO DECIMAL(18,0), @FACT_FECHA DATETIME
	DECLARE @ANIO INT, @MES INT, @CUATRIMESTRE INT, @CODIGO_TIEMPO INT, @CODIGO_CAT_SUB INT
	DECLARE @CATEGORIA_DESC NVARCHAR(255), @SUBC_DESC NVARCHAR(255)
	DECLARE @DESCUENTO_TOTAL DECIMAL(18,2)
	DECLARE C_1 CURSOR FOR
	SELECT fact_total_ticket, fact_total_descuento_aplicado, fact_tipo+cast(fact_sucursal as varchar(50))+ cast(fact_nro as varchar(50)) + cast(fact_caja as varchar(50)) ,fact_descuento_aplicado_mp, prod_categoria, prod_subcategoria, fact_fecha_hora
	FROM [GeDeDe].Factura
	join [GeDeDe].Item_Factura on fact_tipo= item_fact_tipo and fact_sucursal = item_fact_sucursal and fact_nro = item_fact_nro and fact_caja = item_fact_caja
	join [GeDeDe].Producto on item_producto = prod_codigo

	OPEN C_1

	FETCH NEXT FROM C_1 INTO @TOTAL_TICKET, @DESCUENTO_PROMOCION, @FACTURA, @DESCUENTO_MEDIO_PAGO, @CATEGORIA_CODIGO, @SUBCATEGORIA_CODIGO, @FACT_FECHA 

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @ANIO = YEAR(@FACT_FECHA)
		SET @MES = MONTH(@FACT_FECHA)
		SET @CUATRIMESTRE = GeDeDe.obtenerCuatrimestre(@FACT_FECHA)

		-- TIEMPO
		IF NOT EXISTS(SELECT 1 FROM GeDeDe.BI_dim_Tiempo where Cuatrimestre = @CUATRIMESTRE and Mes = @MES and Año = @ANIO)
        INSERT INTO GeDeDe.BI_dim_Tiempo(Año, Cuatrimestre, Mes)
        VALUES(@ANIO, @CUATRIMESTRE, @MES)

		select @CODIGO_TIEMPO = CODIGO_TIEMPO from GeDeDe.BI_dim_Tiempo where Año = @ANIO and Cuatrimestre = @CUATRIMESTRE and Mes = @MES

		-- CATEGORIA Y SUBCATEGORIA
		
		select @CATEGORIA_DESC = cate_descripcion from [GeDeDe].Categoria where cate_codigo = @CATEGORIA_CODIGO;

		select @SUBC_DESC = cate_descripcion from [GeDeDe].Categoria where cate_codigo = @SUBCATEGORIA_CODIGO;
		
		select @CODIGO_CAT_SUB = CODIGO_CATEGORIA_SUBCATEGORIA 
		from GeDeDe.BI_dim_Categoria_Subcategoria where Categoria = @CATEGORIA_DESC AND Subcategoria = @SUBC_DESC

		SET @DESCUENTO_TOTAL = @DESCUENTO_PROMOCION + @DESCUENTO_MEDIO_PAGO

		INSERT INTO #promociones_temporal (CODIGO_TIEMPO, CODIGO_CATEGORIA_SUBCATEGORIA, FACTURA ,VALOR_DESCUENTO_POR_PROMOCION, VALOR_TOTAL_DESCUENTO_APLICADO, VALOR_TOTAL_FACTURAS)
		VALUES (@CODIGO_TIEMPO, @CODIGO_CAT_SUB, @FACTURA, @DESCUENTO_PROMOCION, @DESCUENTO_TOTAL, @TOTAL_ticket)
		
		FETCH NEXT FROM C_1 INTO @TOTAL_TICKET, @DESCUENTO_PROMOCION, @FACTURA, @DESCUENTO_MEDIO_PAGO, @CATEGORIA_CODIGO, @SUBCATEGORIA_CODIGO, @FACT_FECHA
	END

	CLOSE C_1
	DEALLOCATE C_1

	INSERT INTO [GeDeDe].BI_fact_Descuento_Promocion (CODIGO_TIEMPO, CODIGO_CATEGORIA_SUBCATEGORIA, VALOR_DESCUENTO_POR_PROMOCION, VALOR_TOTAL_DESCUENTO_APLICADO, VALOR_TOTAL_FACTURAS)
	SELECT  CODIGO_TIEMPO, CODIGO_CATEGORIA_SUBCATEGORIA,

	FROM #promociones_temporal
	group by CODIGO_TIEMPO, CODIGO_CATEGORIA_SUBCATEGORIA
END;

CREATE PROCEDURE [GeDeDe].[BI_Migrar_Pagos]
AS
BEGIN
 print 'Migracion de Pagos'
	DECLARE @TIPO NVARCHAR(255), @NUMERO DECIMAL(18,0), @SUCURSAL DECIMAL(18,0), @CAJA DECIMAL(18,0), @PAGO_FECHA_HORA DATETIME, @MEDIO_PAGO DECIMAL(18,0), @CLIENTE_FECHA_NACIMIENTO DATE, @CUOTAS DECIMAL(18,0), @MONTO DECIMAL(18,2), @DESCUENTO_APLICADO_MEDIO_PAGO DECIMAL(18,2), @TOTAL_PAGO DECIMAL(18,2)
	DECLARE @Pago_Anio Int, @Pago_Cuatrimestre Int, @Pago_Mes Int, @Edad INT, @Rango_Etario_Descripcion NVARCHAR(255)
	DECLARE @CODIGO_FACTURA INT, @CODIGO_TIEMPO INT, @CODIGO_SUCURSAL INT, @CODIGO_RANGO_ETARIO_CLIENTE INT
	DECLARE pagos_cursor CURSOR FOR 
		SELECT p.pago_fact_tipo, p.pago_fact_sucursal, p.pago_fact_nro, p.pago_fact_caja, p.pago_fecha_hora, p.pago_medio_pago, c.clie_fecha_nacimiento, d.deta_pago_tarjeta_cuotas, CAST(p.pago_importe / (ISNULL(d.deta_pago_tarjeta_cuotas,1)) AS DECIMAL(18,2) ) monto, f.fact_descuento_aplicado_mp, p.pago_importe
		FROM [GeDeDe].Pago p
			JOIN [GeDeDe].[Detalle_Pago] d
				on p.pago_detalle = d.deta_pago_codigo
			JOIN [GeDeDe].Cliente c
				on d.deta_pago_cliente = c.clie_codigo
			JOIN [GeDeDe].[Factura] f
				ON CAST(F.fact_tipo AS NVARCHAR(255)) + CAST(F.fact_sucursal AS NVARCHAR(255)) + CAST(F.fact_nro AS NVARCHAR(255))
                          = CAST(p.pago_fact_tipo AS NVARCHAR(255)) + CAST(p.pago_fact_sucursal AS NVARCHAR(255)) + CAST(p.pago_fact_nro AS NVARCHAR(255))
	OPEN pagos_cursor

	FETCH NEXT FROM pagos_cursor into @Tipo, @SUCURSAL, @NUMERO, @CAJA, @PAGO_FECHA_HORA, @MEDIO_PAGO, @CLIENTE_FECHA_NACIMIENTO, @CUOTAS, @MONTO, @DESCUENTO_APLICADO_MEDIO_PAGO, @TOTAL_PAGO
	
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM [GeDeDe].BI_dim_Factura WHERE BI_dim_Factura.Tipo = @Tipo and BI_dim_Factura.Caja = @CAJA and BI_dim_Factura.Sucursal = @Sucursal and BI_dim_Factura.Numero = @NUMERO)
			BEGIN
				INSERT INTO [GeDeDe].[BI_dim_Factura] (Tipo, Caja, Sucursal, Numero) VALUES (@Tipo, @CAJA, @Sucursal, @NUMERO)
			END
			SELECT @CODIGO_FACTURA = CODIGO_FACTURA FROM [GeDeDe].BI_dim_Factura f WHERE f.Tipo = @TIPO and f.Sucursal = @SUCURSAL and f.Numero = @NUMERO and f.Caja = @CAJA
			
			/*Tiempo*/
			SET @Pago_Anio = YEAR(@PAGO_FECHA_HORA);
			SET @Pago_Mes = MONTH(@PAGO_FECHA_HORA);
			SET @Pago_Cuatrimestre = [GeDeDe].obtenerCuatrimestre(@PAGO_FECHA_HORA);
			IF NOT EXISTS (SELECT 1 FROM [GeDeDe].BI_dim_Tiempo WHERE BI_dim_Tiempo.Cuatrimestre = @Pago_Cuatrimestre and BI_dim_Tiempo.Año = @Pago_Anio and BI_dim_Tiempo.Mes = @Pago_Mes)
			BEGIN
				INSERT INTO [GeDeDe].[BI_dim_Tiempo] (Cuatrimestre, Año, Mes) VALUES (@Pago_Cuatrimestre, @Pago_Anio, @Pago_Mes)
			END
			SELECT @CODIGO_TIEMPO = CODIGO_TIEMPO  FROM [GeDeDe].BI_dim_Tiempo WHERE BI_dim_Tiempo.Cuatrimestre = @Pago_Cuatrimestre and BI_dim_Tiempo.Año = @Pago_Anio and BI_dim_Tiempo.Mes = @Pago_Mes

			SET @Edad = [GeDeDe].obtenerEdad(@CLIENTE_FECHA_NACIMIENTO)
			SET @Rango_Etario_Descripcion = [GeDeDe].obtenerRangoEtario(@Edad)
			SELECT @CODIGO_RANGO_ETARIO_CLIENTE = CODIGO_RANGO_ETARIO  FROM [GeDeDe].BI_dim_Rango_Etario WHERE (BI_dim_Rango_Etario.Descripcion = @Rango_Etario_Descripcion)

			INSERT INTO [GeDeDe].[BI_fact_Pagos] (CODIGO_FACTURA, CODIGO_TIEMPO, CODIGO_SUCURSAL, CODIGO_MEDIO_PAGO, CODIGO_RANGO_ETARIO_CLIENTE, CUOTAS, MONTO, DESCUENTO_APLICADO, TOTAL_PAGO)
			VALUES (@CODIGO_FACTURA, @CODIGO_TIEMPO, @SUCURSAL, @MEDIO_PAGO, @CODIGO_RANGO_ETARIO_CLIENTE, @CUOTAS, @MONTO, @DESCUENTO_APLICADO_MEDIO_PAGO, @TOTAL_PAGO)
			
			FETCH NEXT FROM pagos_cursor into @Tipo, @SUCURSAL, @NUMERO, @CAJA, @PAGO_FECHA_HORA, @MEDIO_PAGO, @CLIENTE_FECHA_NACIMIENTO, @CUOTAS, @MONTO, @DESCUENTO_APLICADO_MEDIO_PAGO, @TOTAL_PAGO
		END
	CLOSE pagos_cursor;
	DEALLOCATE pagos_cursor;
END
GO
--EJECUCIÓN DE PROCEDURES: MIGRACIÓN DE MODELO OLTP A MODELO BI


 BEGIN TRANSACTION
 BEGIN TRY
	EXECUTE [GeDeDe].[BI_Migrar_Categoria_Subcategoria]
	EXECUTE [GeDeDe].[BI_Migrar_Tipos_de_Caja]
	EXECUTE [GeDeDe].[BI_Migrar_Medios_de_Pago]
	EXECUTE [GeDeDe].[BI_Migrar_Sucursales]
	EXECUTE [GeDeDe].[BI_Migrar_Ventas]
	EXECUTE [GeDeDe].[BI_Migrar_Envios]
	EXECUTE [GeDeDe].[BI_Migrar_Pagos]
	EXECUTE [GeDeDe].[BI_Migrar_Promocion_Descuentos]
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
	THROW 50001, 'Error al cargar el modelo de BI, ninguna tabla fue cargada',1;
END CATCH

 IF --(EXISTS (SELECT 1 FROM [GeDeDe].[BI_dim_Categoria_Subcategoria])
      (EXISTS (SELECT 1 FROM [GeDeDe].[BI_dim_Factura])
   AND EXISTS (SELECT 1 FROM [GeDeDe].[BI_dim_Tipo_Caja])
   AND EXISTS (SELECT 1 FROM [GeDeDe].[BI_dim_Medio_Pago])
   AND EXISTS (SELECT 1 FROM [GeDeDe].[BI_dim_Rango_Etario])
   AND EXISTS (SELECT 1 FROM [GeDeDe].[BI_dim_Sucursal])
   AND EXISTS (SELECT 1 FROM [GeDeDe].[BI_dim_Tiempo])
   AND EXISTS (SELECT 1 FROM [GeDeDe].[BI_dim_Turnos])
   AND EXISTS (SELECT 1 FROM [GeDeDe].[BI_dim_Ubicacion])
   AND EXISTS (SELECT 1 FROM [GeDeDe].[BI_fact_Pagos])
   AND EXISTS (SELECT 1 FROM [GeDeDe].[BI_fact_Ventas])
   AND EXISTS (SELECT 1 FROM [GeDeDe].[BI_fact_Envios])
   )

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
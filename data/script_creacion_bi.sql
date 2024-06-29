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

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BI_dim_Producto')
    DROP TABLE GeDeDe.BI_dim_Producto;

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
	SET @returnvalue = '[<25]';
END
ELSE IF (@age >= 25 AND @age < 35)
BEGIN
	SET @returnvalue = '[25 - 35]';
END
ELSE IF (@age >= 35 AND @age <= 50)
BEGIN
	SET @returnvalue = '[35 - 50]';
END
ELSE IF(@age > 50)
BEGIN
	SET @returnvalue = '+50';
END

	RETURN @returnvalue;
END
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
    Fecha DATE,
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
-- Tabla dimensional de productos (categoria/subcategoria implicita)
CREATE TABLE [GeDeDe].[BI_dim_Producto] (
    CODIGO_PRODUCTO INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(255),
    Marca NVARCHAR(255),
    Categoria NVARCHAR(255),
    Subcategoria NVARCHAR(255)
);
GO
--CREACIÓN DE TABLAS FÁCTICAS--
CREATE TABLE [GeDeDe].[BI_fact_Ventas] (
    CODIGO_TIEMPO INT NOT NULL,
    CODIGO_UBICACION INT NOT NULL,
	CODIGO_MEDIO_PAGO DECIMAL(18,0) NOT NULL,
    CODIGO_TURNO INT NOT NULL,
    CODIGO_RANGO_ETARIO_VENDEDOR INT NOT NULL,
    CODIGO_PRODUCTO INT NOT NULL,
	CANTIDAD INT,
    TIPO_CAJA NVARCHAR(255),
    DESCUENTO_APLICADO DECIMAL(18, 2),
    TOTAL DECIMAL(18, 2)
);

ALTER TABLE [GeDeDe].[BI_fact_Ventas]
ADD CONSTRAINT PK_BI_fact_Ventas PRIMARY KEY (CODIGO_TIEMPO, CODIGO_UBICACION, CODIGO_MEDIO_PAGO, CODIGO_TURNO, CODIGO_RANGO_ETARIO_VENDEDOR, CODIGO_PRODUCTO);

ALTER TABLE [GeDeDe].[BI_fact_Ventas]
ADD CONSTRAINT FK_BI_fact_Ventas_CODIGO_TIEMPO FOREIGN KEY (CODIGO_TIEMPO) REFERENCES [GeDeDe].[BI_dim_Tiempo](CODIGO_TIEMPO),
    CONSTRAINT FK_BI_fact_Ventas_CODIGO_UBICACION FOREIGN KEY (CODIGO_UBICACION) REFERENCES [GeDeDe].[BI_dim_Ubicacion](CODIGO_UBICACION),
    CONSTRAINT FK_BI_fact_Ventas_CODIGO_MEDIO_PAGO FOREIGN KEY (CODIGO_MEDIO_PAGO) REFERENCES [GeDeDe].[BI_dim_Medio_Pago](CODIGO_MEDIO_PAGO),
    CONSTRAINT FK_BI_fact_Ventas_CODIGO_TURNO FOREIGN KEY (CODIGO_TURNO) REFERENCES [GeDeDe].[BI_dim_Turnos](CODIGO_TURNO),
    CONSTRAINT FK_BI_fact_Ventas_CODIGO_RANGO_ETARIO_VENDEDOR FOREIGN KEY (CODIGO_RANGO_ETARIO_VENDEDOR) REFERENCES [GeDeDe].[BI_dim_Rango_Etario](CODIGO_RANGO_ETARIO),
    CONSTRAINT FK_BI_fact_Ventas_CODIGO_PRODUCTO FOREIGN KEY (CODIGO_PRODUCTO) REFERENCES [GeDeDe].[BI_dim_Producto](CODIGO_PRODUCTO);

--CREACION DE VISTAS--
GO
CREATE VIEW [GeDeDe].[vw_BI_TicketPromedioMensual] AS
SELECT
    U.Localidad,
    T.Año,
    T.Mes,
    AVG(F.Total) AS TicketPromedio
FROM
    [GeDeDe].[BI_fact_Ventas] F
JOIN [GeDeDe].[BI_dim_Ubicacion] U ON F.CODIGO_UBICACION = U.CODIGO_UBICACION
JOIN [GeDeDe].[BI_dim_Tiempo] T ON F.CODIGO_TIEMPO = T.CODIGO_TIEMPO
GROUP BY
    U.Localidad,
    T.Año,
    T.Mes;
GO
-- Vista para la Cantidad Unidades Promedio
CREATE VIEW [GeDeDe].[vw_BI_CantidadUnidadesPromedio] AS
SELECT
    T.Año,
    T.Cuatrimestre,
    Tr.Turno,
    AVG(F.Cantidad) AS CantidadUnidadesPromedio
FROM
    [GeDeDe].[BI_fact_Ventas] F
JOIN [GeDeDe].[BI_dim_Tiempo] T ON F.CODIGO_TIEMPO = T.CODIGO_TIEMPO
JOIN [GeDeDe].[BI_dim_Turnos] Tr ON F.CODIGO_TURNO = Tr.CODIGO_TURNO
GROUP BY
    T.Año,
    T.Cuatrimestre,
    Tr.Turno;

GO
-- Vista para las Ventas por Rango Etario
CREATE VIEW [GeDeDe].[vw_BI_VentasPorRangoEtario] AS
SELECT
    R.Descripcion AS RangoEtario,
    T.Año,
    T.Mes,
    SUM(F.Total) AS VentasTotales
FROM
    [GeDeDe].[BI_fact_Ventas] F
JOIN [GeDeDe].[BI_dim_Rango_Etario] R ON F.CODIGO_RANGO_ETARIO_VENDEDOR = R.CODIGO_RANGO_ETARIO
JOIN [GeDeDe].[BI_dim_Tiempo] T ON F.CODIGO_TIEMPO = T.CODIGO_TIEMPO
GROUP BY
    R.Descripcion,
    T.Año,
    T.Mes;

GO
-- Vista para las Ventas por Producto
CREATE VIEW [GeDeDe].[vw_BI_VentasPorProducto] AS
SELECT
    P.Nombre AS Producto,
    P.Categoria,
    P.Subcategoria,
    T.Año,
    T.Cuatrimestre,
    SUM(F.Total) AS VentasTotales
FROM
    [GeDeDe].[BI_fact_Ventas] F
JOIN [GeDeDe].[BI_dim_Producto] P ON F.CODIGO_PRODUCTO = P.CODIGO_PRODUCTO
JOIN [GeDeDe].[BI_dim_Tiempo] T ON F.CODIGO_TIEMPO = T.CODIGO_TIEMPO
GROUP BY
    P.Nombre,
    P.Categoria,
    P.Subcategoria,
    T.Año,
    T.Cuatrimestre;

GO

GO
-- Índice para BI_fact_Ventas por CODIGO_TIEMPO y CODIGO_UBICACION
CREATE INDEX IX_BI_fact_Ventas_TIEMPO_UBICACION ON GeDeDe.BI_fact_Ventas (CODIGO_TIEMPO, CODIGO_UBICACION);
GO
-- Índice para BI_fact_Ventas por CODIGO_TIEMPO y CODIGO_PRODUCTO
CREATE INDEX IX_BI_fact_Ventas_TIEMPO_PRODUCTO ON GeDeDe.BI_fact_Ventas (CODIGO_TIEMPO, CODIGO_PRODUCTO);
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
	FETCH NEXT sucursal_cursor into @Sucu_Codigo, @Sucu_Nombre, @Sucu_Localidad, @Sucu_Provincia;
	
	WHILE(@@FETCH_STATUS = 0)
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM [GeDeDe].BI_dim_Ubicacion WHERE (Provincia = @Sucu_Provincia AND Localidad = @Sucu_Localidad))
			BEGIN
				INSERT INTO [GeDeDe].[BI_dim_Ubicacion] (Provincia, Localidad) VALUES (@Sucu_Provincia, @Sucu_Localidad)
			END

			SELECT @CODIGO_UBICACION = CODIGO_UBICACION FROM [GeDeDe].[BI_dim_Ubicacion] WHERE Provincia = @Sucu_Provincia AND Localidad = @Sucu_Localidad

			INSERT INTO [GeDeDe].[BI_dim_Sucursal] (CODIGO_SUCURSAL, Nombre, CODIGO_UBICACION) VALUES (@Sucu_Codigo, @Sucu_Nombre, @CODIGO_UBICACION)
			
			FETCH NEXT sucursal_cursor into @Sucu_Codigo, @Sucu_Nombre, @Sucu_Localidad, @Sucu_Provincia;
		END

	CLOSE sucursal_cursor;
	DEALLOCATE sucursal_cursor;
END
GO

CREATE PROCEDURE [GeDeDe].[BI_Migrar_Ventas]
AS
BEGIN
	print 'Migracion de Ventas'
	DECLARE @Producto_ID INT, @Cliente_ID INT, @Empleado_ID INT, @Caja_ID INT, @Localidad_ID INT, @Fecha_Hora_Venta DATE, @Cantidad INT, @Precio DECIMAL(10, 2), @Descuento DECIMAL(10, 2);
    DECLARE @Edad INT, @Rango_Etario VARCHAR(50), @Turno NVARCHAR(255);

	DECLARE ventas_cursor CURSOR FOR
		SELECT fact_fecha_hora, I.item_producto
			FROM [GeDeDe].[Item_Factura] I
				JOIN [GeDeDe].[Factura] F ON CAST(F.fact_tipo AS NVARCHAR(255)) + CAST(F.fact_sucursal AS NVARCHAR(255)) + CAST(F.fact_nro AS NVARCHAR(255)) + CAST(F.fact_caja AS NVARCHAR(255))
                          = CAST(I.item_fact_tipo AS NVARCHAR(255)) + CAST(I.item_fact_sucursal AS NVARCHAR(255)) + CAST(I.item_fact_nro AS NVARCHAR(255)) + CAST(I.item_fact_caja AS NVARCHAR(255))
				JOIN [GeDeDe].[Cliente] C ON F.fact_cliente = C.clie_codigo
				JOIN [GeDeDe].[Empleado] E ON F.fact_vendedor = E.empl_codigo;
				-- JOIN [GeDeDe].

	OPEN ventas_cursor;

	-- FETCH NEXT ventas_cursor into 
	
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
			print 'migrando ventas'
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
USE GD1C2024;

PRINT 'Inicializando la creacion del modelo de Business Intelligence'

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
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_TicketPromedioMensual' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_TicketPromedioMensual];
GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_CantidadUnidadesPromedio' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_CantidadUnidadesPromedio];
GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_VentasPorRangoEtario' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_VentasPorRangoEtario];
GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_VentasPorProducto' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_VentasPorProducto];
GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_PorcentajeVentasPorRangoEtarioYCaja' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_PorcentajeVentasPorRangoEtarioYCaja];
GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_CantidadVentasPorTurnoLocalidadMes' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_CantidadVentasPorTurnoLocalidadMes];
GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_PorcentajeDescuentoPorMesAnio' AND schema_id = SCHEMA_ID('GeDeDe'))
    DROP VIEW [GeDeDe].[vw_PorcentajeDescuentoPorMesAnio];
GO

--DROP PREVENTIVO DE PROCEDURES---------------------------------------------------------------

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'BI_Migrar_Medios_de_Pago' and schema_id = SCHEMA_ID('GeDeDe'))
	DROP PROCEDURE [GeDeDe].[BI_Migrar_Medios_de_Pago];
GO
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'BI_Migrar_Sucursales' and schema_id = SCHEMA_ID('GeDeDe'))
	DROP PROCEDURE [GeDeDe].[BI_Migrar_Sucursales];
GO
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'BI_Migrar_Ventas' and schema_id = SCHEMA_ID('GeDeDe'))
	DROP PROCEDURE [GeDeDe].[BI_Migrar_Ventas];
GO
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'BI_Migrar_Envios' and schema_id = SCHEMA_ID('GeDeDe'))
	DROP PROCEDURE [GeDeDe].[BI_Migrar_Envios];
GO
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'BI_Migrar_Pagos' and schema_id = SCHEMA_ID('GeDeDe'))
	DROP PROCEDURE [GeDeDe].[BI_Migrar_Pagos];
GO
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
RETURNS varchar(10)
AS
BEGIN
	DECLARE @returnvalue varchar(10);

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
RETURNS varchar(50)
AS
BEGIN
    DECLARE @returnvalue varchar(50);
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

-- Tabla dimensional de ubicación
CREATE TABLE [GeDeDe].[BI_dim_Ubicacion] (
    CODIGO_UBICACION INT IDENTITY(1,1) PRIMARY KEY,
    Provincia NVARCHAR(255),
    Localidad NVARCHAR(255)
);

-- Tabla dimensional de sucursal
CREATE TABLE [GeDeDe].[BI_dim_Sucursal] (
    CODIGO_SUCURSAL DECIMAL(18,0) PRIMARY KEY,
    Nombre NVARCHAR(255),
    CODIGO_UBICACION INT,
    FOREIGN KEY (CODIGO_UBICACION) REFERENCES [GeDeDe].[BI_dim_Ubicacion](CODIGO_UBICACION)
);

-- Tabla dimensional de rango etario
CREATE TABLE [GeDeDe].[BI_dim_Rango_Etario] (
    CODIGO_RANGO_ETARIO INT IDENTITY(1,1) PRIMARY KEY,
    Descripcion NVARCHAR(255)
);

-- Tabla dimensional de turnos
CREATE TABLE [GeDeDe].[BI_dim_Turnos] (
    CODIGO_TURNO INT IDENTITY(1,1) PRIMARY KEY,
    Turno NVARCHAR(255)
);

-- Tabla dimensional de medio de pago
CREATE TABLE [GeDeDe].[BI_dim_Medio_Pago] (
    CODIGO_MEDIO_PAGO DECIMAL(18,0) PRIMARY KEY,
    Descripcion NVARCHAR(255),
    Tipo NVARCHAR(255)
);

-- Tabla dimensional de productos (categoria/subcategoria implicita)
CREATE TABLE [GeDeDe].[BI_dim_Producto] (
    CODIGO_PRODUCTO INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(255),
    Marca NVARCHAR(255),
    Categoria NVARCHAR(255),
    Subcategoria NVARCHAR(255)
);


--CREACIÓN DE TABLAS FÁCTICAS--
CREATE TABLE [GeDeDe].[BI_fact_Ventas] (
    CODIGO_VENTA INT IDENTITY(1,1) PRIMARY KEY,
    CODIGO_TIEMPO INT,
    CODIGO_SUCURSAL DECIMAL(18,0),
    CODIGO_PRODUCTO INT,
    CODIGO_MEDIO_PAGO DECIMAL(18,0),
    CODIGO_TURNO INT,
    CODIGO_UBICACION INT,
    tipoCaja NVARCHAR(50),
    descuento DECIMAL(12, 2),
    CODIGO_RANGO_ETARIO_VENDEDOR INT,
    Cantidad INT,
    Total DECIMAL(18, 2),
    FOREIGN KEY (CODIGO_TIEMPO) REFERENCES [GeDeDe].[BI_dim_Tiempo](CODIGO_TIEMPO),
    FOREIGN KEY (CODIGO_SUCURSAL) REFERENCES [GeDeDe].[BI_dim_Sucursal](CODIGO_SUCURSAL),
    FOREIGN KEY (CODIGO_PRODUCTO) REFERENCES [GeDeDe].[BI_dim_Producto](CODIGO_PRODUCTO),
    FOREIGN KEY (CODIGO_MEDIO_PAGO) REFERENCES [GeDeDe].[BI_dim_Medio_Pago](CODIGO_MEDIO_PAGO),
    FOREIGN KEY (CODIGO_TURNO) REFERENCES [GeDeDe].[BI_dim_Turnos](CODIGO_TURNO),
    FOREIGN KEY (CODIGO_UBICACION) REFERENCES [GeDeDe].[BI_dim_Ubicacion](CODIGO_UBICACION),
    FOREIGN KEY (CODIGO_RANGO_ETARIO_VENDEDOR) REFERENCES [GeDeDe].[BI_dim_Rango_Etario](CODIGO_RANGO_ETARIO)
);

--CREACION DE VISTAS--
GO
CREATE VIEW [GeDeDe].[vw_TicketPromedioMensual] AS
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
CREATE VIEW [GeDeDe].[vw_CantidadUnidadesPromedio] AS
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
CREATE VIEW [GeDeDe].[vw_VentasPorRangoEtario] AS
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
CREATE VIEW [GeDeDe].[vw_VentasPorProducto] AS
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
-- Vista para el Porcentaje Anual de Ventas por Rango Etario del Empleado y Tipo de Caja por Cuatrimestre
CREATE VIEW [GeDeDe].[vw_PorcentajeVentasPorRangoEtarioYCaja] AS
WITH VentasPorRangoEtario AS (
    SELECT
        R.Descripcion AS RangoEtario,
        F.TipoCaja,
        T.Año,
        T.Cuatrimestre,
        SUM(F.Total) AS VentasPorRangoEtarioYCaja
    FROM
        [GeDeDe].[BI_fact_Ventas] F
    JOIN [GeDeDe].[BI_dim_Rango_Etario] R ON F.CODIGO_RANGO_ETARIO_VENDEDOR = R.CODIGO_RANGO_ETARIO
    JOIN [GeDeDe].[BI_dim_Tiempo] T ON F.CODIGO_TIEMPO = T.CODIGO_TIEMPO
    GROUP BY
        R.Descripcion,
        F.TipoCaja,
        T.Año,
        T.Cuatrimestre
),
VentasTotalesAnuales AS (
    SELECT
        T.Año,
        T.Cuatrimestre,
        SUM(F.Total) AS VentasTotalesAnuales
    FROM
        [GeDeDe].[BI_fact_Ventas] F
    JOIN [GeDeDe].[BI_dim_Tiempo] T ON F.CODIGO_TIEMPO = T.CODIGO_TIEMPO
    GROUP BY
        T.Año,
        T.Cuatrimestre
)
SELECT
    RangoEtario,
    TipoCaja,
    V.Año,
    V.Cuatrimestre,
    CAST((V.VentasPorRangoEtarioYCaja * 100.0 / T.VentasTotalesAnuales) AS DECIMAL(10, 2)) AS PorcentajeVentas
FROM
    VentasPorRangoEtario V
JOIN VentasTotalesAnuales T ON V.Año = T.Año AND V.Cuatrimestre = T.Cuatrimestre;

GO
-- Vista para la Cantidad de Ventas por Turno para cada Localidad según el Mes de cada Año
CREATE VIEW [GeDeDe].[vw_CantidadVentasPorTurnoLocalidadMes] AS
SELECT
    U.Localidad,
    T.Año,
    T.Mes,
    Tr.Turno,
    COUNT(F.CODIGO_VENTA) AS CantidadVentas
FROM
    [GeDeDe].[BI_fact_Ventas] F
JOIN [GeDeDe].[BI_dim_Tiempo] T ON F.CODIGO_TIEMPO = T.CODIGO_TIEMPO
JOIN [GeDeDe].[BI_dim_Turnos] Tr ON F.CODIGO_TURNO = Tr.CODIGO_TURNO
JOIN [GeDeDe].[BI_dim_Ubicacion] U ON F.CODIGO_UBICACION = U.CODIGO_UBICACION
GROUP BY
    U.Localidad,
    T.Año,
    T.Mes,
    Tr.Turno;

GO
-- Vista para el Porcentaje de Descuento Aplicado según el Total de los Tickets por Mes de cada Año
CREATE VIEW [GeDeDe].[vw_PorcentajeDescuentoPorMesAnio] AS
SELECT
    T.Año,
    T.Mes,
    SUM(F.Descuento) / SUM(F.Total) * 100 AS PorcentajeDescuento
FROM
    [GeDeDe].[BI_fact_Ventas] F
JOIN [GeDeDe].[BI_dim_Tiempo] T ON F.CODIGO_TIEMPO = T.CODIGO_TIEMPO
GROUP BY
    T.Año,
    T.Mes;

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
	print 'Migracion de Ventas'
	DECLARE @Venta_ID INT, @Producto_ID INT, @Cliente_ID INT, @Empleado_ID INT, @Caja_ID INT, @Localidad_ID INT, @Fecha_Hora_Venta DATE, @Cantidad INT, @Precio DECIMAL(10, 2), @Descuento DECIMAL(10, 2);
    DECLARE @Edad INT, @Rango_Etario VARCHAR(50), @Turno_ID INT;

	DECLARE ventas_cursor CURSOR FOR
		SELECT * FROM Item_Factura I
			join Factura F on F.fact_tipo+F.fact_sucursal+F.fact_nro+F.fact_caja = I.item_fact_tipo+I.item_fact_sucursal+I.item_fact_nro+I.item_fact_caja
			/*join Cliente c on F.fact_*/
	
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
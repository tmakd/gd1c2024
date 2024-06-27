USE GD1C2024;

PRINT 'Inicializando la creacion del modelo de Business Intelligence'

--DROP PREVENTIVO DE FUNCIONES--
IF EXISTS(SELECT [name] FROM sys.objects WHERE [name] = 'obtenerRangoEdad')
	DROP FUNCTION DROP_TABLE.obtenerRangoEdad

IF EXISTS(SELECT [name] FROM sys.objects WHERE [name] = 'obtenerEdad')
	DROP FUNCTION DROP_TABLE.obtenerEdad

IF EXISTS(SELECT [name] FROM sys.objects WHERE [name] = 'obtenerTurnos')
	DROP FUNCTION DROP_TABLE.obtenerTurnos

--DROP PREVENTIVO DE TABLAS--

--DROP PREVENTIVO DE PROCEDURES--

--DROP PREVENTIVO DE VISTAS--

--CREACIÓN DE FUNCIONES AUXILIARES--
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
CREATE FUNCTION GeDeDe.obtenerRangoEdad (@age int) 
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
        SET @returnvalue = 'Fuera de Turno';
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

/*
● Tiempo (año, cuatrimestre, mes)
● Ubicación (Provincia/Localidad)
● Sucursal
● Rango etario empleados/clientes
○ < 25
○ 25 - 35
○ 35 - 50
○ > 50
● Turnos
○ 08:00 - 12:00
○ 12:00 - 16:00
○ 16:00 - 20:00
● Medio de Pago
● Categoria/SubCatergoria de Producto
*/
CREATE TABLE  GeDeDe.BI_dim_tiempos(
	CODIGO_TIEMPO int IDENTITY PRIMARY KEY,
	AÑO int,
	CUATRIMESTRE int,
	MES int not null
);

CREATE TABLE  GeDeDe.BI_dim_sucursales(
	CODIGO_SUCURSAL int PRIMARY KEY,
	DIRECCION nvarchar(255) not null,
	NOMBRE nvarchar(255) not null,
	-- MAIL nvarchar(255) null,
	-- TELEFONO decimal(18,0) null,
	PROVINCIA nvarchar(255) null
);

CREATE TABLE  GeDeDe.BI_dim_medios_pago(
	CODIGO_MEDIO_PAGO int PRIMARY KEY,
	DETALLE nvarchar(255) not null,
	TIPO nvarchar(255) not null,
);

CREATE TABLE  GeDeDe.BI_dim_categorias(
	CODIGO_CATEGORIA int PRIMARY KEY,
	DESCRIPCION nvarchar(255) not null,
);

--CREACIÓN DE TABLAS PUENTE (BRIDGE)--

--CREACIÓN DE TABLAS FÁCTICAS--

--CREACION DE VISTAS--

--> Ticket Promedio mensual (tiempo-promedio(fact_total)

--> Cantidad unidades promedio

--> Porcentaje anual de ventas

--> Cantidad de ventas registradas por turno (turno-cantidad de ventas)

--> Porcentaje de descuento aplicados en función del total de los tickets 

-->  Las tres categorías de productos con mayor descuento aplicado

-->  Porcentaje de cumplimiento de envíos 

--> Cantidad de envíos por rango etario de clientes 

--> Las 5 localidades (tomando la localidad del cliente) con mayor costo de envío

--> Las 3 sucursales con el mayor importe de pagos en cuotas, según el medio de
-- pago, mes y año. Se calcula sumando los importes totales de todas las ventas en
-- cuotas.
--> Promedio de importe de la cuota en función del rango etareo del cliente.
--> Porcentaje de descuento aplicado por cada medio de pago en función del valor
-- de total de pagos sin el descuento, por cuatrimestre. Es decir, total de descuentos
-- sobre el total de pagos más el total de descuentos

--CREACION PROCEDURES DE MIGRACION--

--EJECUCIÓN DE PROCEDURES: MIGRACIÓN DE MODELO OLTP A MODELO BI


/*
 BEGIN TRANSACTION
 BEGIN TRY
	-- EXECUTE GeDeDe.BI_migrar_discos_rigidos
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
	THROW 50001, 'Error al cargar el modelo de BI, ninguna tabla fue cargada',1;
END CATCH

 IF (EXISTS (SELECT 1 FROM GeDeDe.)
   AND EXISTS (SELECT 1 FROM GeDeDe.accesorios)
   
   BEGIN
	PRINT 'Modelo de BI creado y cargado correctamente.';
	COMMIT TRANSACTION;
   END
	 ELSE
   BEGIN
    ROLLBACK TRANSACTION;
	THROW 50002, 'Hubo un error al cargar una o más tablas. Todos los cambios fueron deshechos, ninguna tabla fue cargada en la base.',1;
   END
   
GO
*/
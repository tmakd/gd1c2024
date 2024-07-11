USE GD1C2024;
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'GeDeDe')
BEGIN
    EXEC('CREATE SCHEMA [GeDeDe]');
END
GO

IF OBJECT_ID('[GeDeDe].[CLEAN]', 'P') IS NOT NULL
    DROP PROCEDURE [GeDeDe].[CLEAN];
GO

IF OBJECT_ID('[GeDeDe].[CREATE_DDL]', 'P') IS NOT NULL
    DROP PROCEDURE [GeDeDe].[CREATE_DDL];
GO

IF OBJECT_ID('[GeDeDe].[CREATE_DML]', 'P') IS NOT NULL
    DROP PROCEDURE [GeDeDe].[CREATE_DML];
GO

CREATE PROCEDURE [GeDeDe].[CLEAN]
AS
BEGIN
	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Aplicacion_Descuento')
		DROP TABLE GeDeDe.Aplicacion_Descuento;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Descuento')
		DROP TABLE GeDeDe.Descuento;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Pago')
		DROP TABLE GeDeDe.Pago;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Medio_Pago')
		DROP TABLE GeDeDe.Medio_Pago;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Detalle_Pago')
		DROP TABLE GeDeDe.Detalle_Pago;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Item_Factura')
		DROP TABLE GeDeDe.Item_Factura;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Promocion_Producto')
		DROP TABLE GeDeDe.Promocion_Producto;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Promocion')
		DROP TABLE GeDeDe.Promocion;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Regla')
		DROP TABLE GeDeDe.Regla;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Producto')
		DROP TABLE GeDeDe.Producto;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Marca')
		DROP TABLE GeDeDe.Marca;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Subcategoria')
		DROP TABLE GeDeDe.Subcategoria;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Categoria')
		DROP TABLE GeDeDe.Categoria;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Envio')
		DROP TABLE GeDeDe.Envio;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Factura')
		DROP TABLE GeDeDe.Factura;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Cliente')
		DROP TABLE GeDeDe.Cliente;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Empleado')
		DROP TABLE GeDeDe.Empleado;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Caja')
		DROP TABLE GeDeDe.Caja;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Tipo_Caja')
		DROP TABLE GeDeDe.Tipo_Caja;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Sucursal')
		DROP TABLE GeDeDe.Sucursal;

	IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Super')
		DROP TABLE GeDeDe.Super;
END
GO

CREATE PROCEDURE [GeDeDe].[CREATE_DDL]
AS
BEGIN
-- CREACION DE TABLAS
CREATE TABLE [GeDeDe].[Super] (
supe_cuit DECIMAL(18,0) NOT NULL,
supe_nombre NVARCHAR(255),
supe_razon_social NVARCHAR(255),
supe_iibb NVARCHAR(255),
supe_domicilio NVARCHAR(255),
supe_fecha_inicio_actividad DATETIME,
supe_condicion_fiscal NVARCHAR(255),
supe_localidad NVARCHAR(255),
supe_provincia NVARCHAR(255),
);

CREATE TABLE [GeDeDe].[Sucursal] (
sucu_codigo DECIMAL(18,0) IDENTITY(1,1),
sucu_super DECIMAL(18,0), -- FK
sucu_nombre NVARCHAR(255),
sucu_localidad NVARCHAR(255),
sucu_direccion NVARCHAR(255),
sucu_provincia NVARCHAR(255)
);

CREATE TABLE [GeDeDe].[Tipo_Caja] (
tipo_caja_codigo DECIMAL(18,0) IDENTITY(1,1),
tipo_caja_nombre NVARCHAR(255)
);

CREATE TABLE [GeDeDe].[Caja] (
caja_sucursal DECIMAL(18,0) NOT NULL,
caja_codigo DECIMAL(18,0) NOT NULL, -- FK
caja_tipo DECIMAL(18,0) NOT NULL -- FK
);

CREATE TABLE [GeDeDe].[Empleado] (
empl_codigo DECIMAL(18,0) IDENTITY(1,1),
empl_sucursal DECIMAL(18,0), -- FK
empl_nombre NVARCHAR(255),
empl_apellido NVARCHAR(255),
empl_dni DECIMAL(18,0),
empl_fecha_registro DATETIME,
empl_telefono DECIMAL(18,0),
empl_mail NVARCHAR(255),
empl_fecha_nacimiento DATE
);

CREATE TABLE [GeDeDe].[Cliente]  (
clie_codigo DECIMAL(18,0) IDENTITY(1,1),
clie_nombre NVARCHAR(255),
clie_apellido NVARCHAR(255),
clie_dni DECIMAL(18,0),
clie_fecha_registro DATETIME,
clie_telefono DECIMAL(18,0),
clie_mail NVARCHAR(255),
clie_fecha_nacimiento DATE,
clie_domicilio NVARCHAR(255),
clie_localidad NVARCHAR(255),
clie_provincia NVARCHAR(255)
);

CREATE TABLE [GeDeDe].[Factura] (
fact_tipo NVARCHAR(255) NOT NULL, -- PK
fact_nro DECIMAL(18,0) NOT NULL, -- PK
fact_sucursal DECIMAL(18,0) NOT NULL, -- PK, FK
fact_caja DECIMAL(18,0) NOT NULL, -- FK
fact_vendedor DECIMAL(18,0) NOT NULL, -- FK
fact_cliente DECIMAL(18,0) NULL, -- FK
fact_fecha_hora DATETIME,
fact_subtotal_productos DECIMAL(18,2),
fact_total_descuento_aplicado DECIMAL(18,2),
fact_descuento_aplicado_mp DECIMAL(18,2),
fact_total_envio DECIMAL(18,2),
fact_total_ticket DECIMAL(18,2)
);


CREATE TABLE [GeDeDe].[Marca] (
marc_codigo DECIMAL(18,0) IDENTITY(1,1),
marc_descripcion NVARCHAR(255)
);

CREATE TABLE [GeDeDe].[Categoria]  (
cate_codigo DECIMAL(18,0) IDENTITY(1,1),
cate_descripcion NVARCHAR(255)
);

CREATE TABLE [GeDeDe].[Subcategoria]  (
subc_codigo DECIMAL(18,0) NOT NULL, --FK
subc_categoria DECIMAL(18,0) NOT NULL -- FK
);

CREATE TABLE [GeDeDe].[Producto]  (
prod_codigo DECIMAL(18,0) IDENTITY(1,1),
prod_marca DECIMAL(18,0), -- FK
prod_subcategoria DECIMAL(18,0), -- FK
prod_categoria DECIMAL(18,0), -- FK
prod_nombre NVARCHAR(255),
prod_descripcion NVARCHAR(255),
prod_precio DECIMAL(18,2)
);

CREATE TABLE [GeDeDe].[Regla]  (
regl_codigo DECIMAL(18,0) IDENTITY(1,1),
regl_descripcion NVARCHAR(255),
regl_descuento_aplicable_producto DECIMAL(18,2),
regl_cant_aplicable_regla DECIMAL(18,2),
regl_cant_aplicable_descuento DECIMAL(18,2),
regl_cant_maxima DECIMAL(18,0),
regl_misma_marca DECIMAL(18,0),
regl_mismo_producto DECIMAL(18,0)
);

CREATE TABLE [GeDeDe].[Promocion]  (
prom_codigo DECIMAL(18,0) NOT NULL,
prom_regla DECIMAL(18,0), -- FK
prom_descripcion NVARCHAR(255),
prom_fecha_inicio DATETIME,
prom_fecha_fin DATETIME
);

CREATE TABLE [GeDeDe].[Promocion_Producto]  (
prod_codigo DECIMAL(18,0) NOT NULL, -- PK FK
prom_codigo DECIMAL(18,0) NOT NULL, -- PK FK
);

CREATE TABLE [GeDeDe].[Item_Factura]  (
item_fact_tipo NVARCHAR(255) NOT NULL, -- FK
item_fact_sucursal DECIMAL(18,0) NOT NULL, -- FK
item_fact_nro DECIMAL(18,0) NOT NULL, -- FK
item_fact_caja DECIMAL(18,0) NOT NULL, -- FK
item_producto DECIMAL(18,0) NOT NULL, -- FK
item_promo_aplicada DECIMAL(18,0), -- FK
item_cantidad DECIMAL(18,0),
item_precio_unitario DECIMAL(18,0),
item_precio_total DECIMAL(18,2),
item_descuento_promo DECIMAL(18,2)
);

CREATE TABLE [GeDeDe].[Envio] (
envi_codigo DECIMAL(18,0) IDENTITY(1,1),
envi_fact_tipo NVARCHAR(255), -- FK
envi_fact_nro DECIMAL(18,0), --FK
envi_fact_sucursal DECIMAL(18,0), --FK
envi_fact_caja DECIMAL(18,0), --FK
envi_cliente DECIMAL(18,0), --FK
envi_fecha_programada DATETIME,
envi_costo DECIMAL(18,2),
envi_horario_inicio DECIMAL(18,0),
envi_horario_fin DECIMAL(18,0),
envi_fecha_entrega DATETIME,
envi_estado NVARCHAR(255)
);

CREATE TABLE [GeDeDe].[Medio_Pago] (
medio_pago_codigo DECIMAL(18,0) IDENTITY(1,1),
medio_pago_detalle NVARCHAR(255),
medio_pago_tipo NVARCHAR(255)
);

CREATE TABLE [GeDeDe].[Descuento] (
descu_codigo DECIMAL(18,0) NOT NULL,
descu_medio_pago DECIMAL(18,0), -- FK
descu_descripcion NVARCHAR(255),
descu_fecha_inicio DATETIME,
descu_fecha_fin DATETIME,
descu_porcentaje_descuento DECIMAL(18,2),
descu_tope DECIMAL(18,2)
);

CREATE TABLE [GeDeDe].[Pago] (
pago_codigo DECIMAL(18,0) IDENTITY(1,1),
pago_medio_pago DECIMAL(18,0), -- FK
pago_fact_tipo NVARCHAR(255), -- FK
pago_fact_sucursal DECIMAL(18,0), -- FK
pago_fact_caja DECIMAL(18,0), -- FK
pago_fact_nro DECIMAL(18,0), -- FK
pago_detalle DECIMAL(18,0), -- FK
pago_fecha_hora DATETIME,
pago_importe DECIMAL(18,2)
);

CREATE TABLE [GeDeDe].[Detalle_Pago] (
deta_pago_codigo DECIMAL(18,0) IDENTITY(1,1),
deta_pago_cliente DECIMAL(18,0), -- FK
deta_pago_tarjeta_nro NVARCHAR(255),
deta_pago_tarjeta_cuotas DECIMAL(18,0),
deta_pago_tarjeta_fecha_vencimiento DATETIME
);

CREATE TABLE [GeDeDe].[Aplicacion_Descuento] (
apli_descuento_pago DECIMAL(18,0) NOT NULL,
apli_descuento_codigo_descuento DECIMAL(18,0) NOT NULL,
apli_descuento_monto DECIMAL(18,2)
);
-- CREACION DE PKS
ALTER TABLE [GeDeDe].[Super]
ADD CONSTRAINT PK_Super PRIMARY KEY (supe_cuit);

ALTER TABLE [GeDeDe].[Sucursal]
ADD CONSTRAINT PK_Sucursal PRIMARY KEY (sucu_codigo);

ALTER TABLE [GeDeDe].[Tipo_Caja]
ADD CONSTRAINT PK_Tipo_Caja PRIMARY KEY (tipo_caja_codigo);

ALTER TABLE [GeDeDe].[Caja]
ADD CONSTRAINT PK_Caja PRIMARY KEY (caja_sucursal, caja_codigo);

ALTER TABLE [GeDeDe].[Empleado]
ADD CONSTRAINT PK_Empleado PRIMARY KEY (empl_codigo);

ALTER TABLE [GeDeDe].[Cliente]
ADD CONSTRAINT PK_Cliente PRIMARY KEY (clie_codigo);

ALTER TABLE [GeDeDe].[Factura]
ADD CONSTRAINT PK_Factura PRIMARY KEY (fact_tipo, fact_nro, fact_sucursal, fact_caja);

ALTER TABLE [GeDeDe].[Marca]
ADD CONSTRAINT PK_Marca PRIMARY KEY (marc_codigo);

ALTER TABLE [GeDeDe].[Categoria]
ADD CONSTRAINT PK_Categoria PRIMARY KEY (cate_codigo);

ALTER TABLE [GeDeDe].[Subcategoria]
ADD CONSTRAINT PK_Subcategoria PRIMARY KEY (subc_codigo, subc_categoria);

ALTER TABLE [GeDeDe].[Producto]
ADD CONSTRAINT PK_Producto PRIMARY KEY (prod_codigo);

ALTER TABLE [GeDeDe].[Regla]
ADD CONSTRAINT PK_Regla PRIMARY KEY (regl_codigo);

ALTER TABLE [GeDeDe].[Promocion]
ADD CONSTRAINT PK_Promocion PRIMARY KEY (prom_codigo);

ALTER TABLE [GeDeDe].[Promocion_Producto]
ADD CONSTRAINT PK_Promocion_Producto PRIMARY KEY (prod_codigo, prom_codigo);

ALTER TABLE [GeDeDe].[Item_Factura]
ADD CONSTRAINT PK_Item_Factura PRIMARY KEY (item_fact_tipo, item_fact_nro, item_fact_sucursal, item_producto, item_fact_caja);

ALTER TABLE [GeDeDe].[Envio]
ADD CONSTRAINT PK_Envio PRIMARY KEY (envi_codigo);

ALTER TABLE [GeDeDe].[Medio_Pago]
ADD CONSTRAINT PK_Medio_Pago PRIMARY KEY (medio_pago_codigo);

ALTER TABLE [GeDeDe].[Descuento]
ADD CONSTRAINT PK_Descuento PRIMARY KEY (descu_codigo);

ALTER TABLE [GeDeDe].[Pago]
ADD CONSTRAINT PK_Pago PRIMARY KEY (pago_codigo);

ALTER TABLE [GeDeDe].[Detalle_Pago]
ADD CONSTRAINT PK_Detalle_Pago PRIMARY KEY (deta_pago_codigo);

ALTER TABLE [GeDeDe].[Aplicacion_Descuento]
ADD CONSTRAINT PK_Aplicacion_Descuento PRIMARY KEY (apli_descuento_pago, apli_descuento_codigo_descuento);

-- CREACION DE FK
ALTER TABLE [GeDeDe].[Sucursal]
ADD CONSTRAINT FK_Sucursal_Super
FOREIGN KEY (sucu_super) REFERENCES [GeDeDe].[Super](supe_cuit);

ALTER TABLE [GeDeDe].[Caja]
ADD CONSTRAINT FK_Caja_Tipo_Caja FOREIGN KEY (caja_tipo) REFERENCES [GeDeDe].Tipo_Caja(tipo_caja_codigo);

ALTER TABLE [GeDeDe].[Caja]
ADD CONSTRAINT FK_Caja_Sucursal FOREIGN KEY (caja_sucursal) REFERENCES [GeDeDe].Sucursal(sucu_codigo);

ALTER TABLE [GeDeDe].[Empleado]
ADD CONSTRAINT FK_Empleado_Sucursal
FOREIGN KEY (empl_sucursal) REFERENCES [GeDeDe].Sucursal(sucu_codigo);

ALTER TABLE [GeDeDe].[Factura]
ADD CONSTRAINT FK_Factura_Sucursal
FOREIGN KEY (fact_sucursal) REFERENCES [GeDeDe].Sucursal(sucu_codigo);

ALTER TABLE [GeDeDe].[Factura]
ADD CONSTRAINT FK_Factura_Caja
FOREIGN KEY (fact_sucursal, fact_caja) REFERENCES [GeDeDe].Caja(caja_sucursal, caja_codigo);

ALTER TABLE [GeDeDe].[Factura]
ADD CONSTRAINT FK_Factura_Empleado
FOREIGN KEY (fact_vendedor) REFERENCES [GeDeDe].Empleado(empl_codigo);

ALTER TABLE [GeDeDe].[Factura]
ADD CONSTRAINT FK_Factura_Cliente
FOREIGN KEY (fact_cliente) REFERENCES [GeDeDe].Cliente(clie_codigo);

ALTER TABLE [GeDeDe].[Subcategoria]
ADD CONSTRAINT FK_Subcategoria_Categoria
FOREIGN KEY (subc_categoria) REFERENCES [GeDeDe].Categoria(cate_codigo);

ALTER TABLE [GeDeDe].[Subcategoria]
ADD CONSTRAINT FK_Subcategoria_SubCategoria
FOREIGN KEY (subc_codigo) REFERENCES [GeDeDe].Categoria(cate_codigo);

ALTER TABLE [GeDeDe].[Producto]
ADD CONSTRAINT FK_Producto_Marca
FOREIGN KEY (prod_marca) REFERENCES [GeDeDe].Marca(marc_codigo);

ALTER TABLE [GeDeDe].[Producto]
ADD CONSTRAINT FK_Producto_Subcategoria
FOREIGN KEY (prod_subcategoria, prod_categoria) REFERENCES [GeDeDe].Subcategoria(subc_codigo, subc_categoria);

ALTER TABLE [GeDeDe].[Promocion]
ADD CONSTRAINT FK_Promocion_Regla
FOREIGN KEY (prom_regla) REFERENCES [GeDeDe].Regla(regl_codigo);

ALTER TABLE [GeDeDe].[Promocion_Producto] 
ADD CONSTRAINT FK_Promocion_Producto_Producto
FOREIGN KEY (prod_codigo) REFERENCES [GeDeDe].Producto(prod_codigo);

ALTER TABLE [GeDeDe].[Promocion_Producto] 
ADD CONSTRAINT FK_Promocion_Producto_Promocion
FOREIGN KEY (prom_codigo) REFERENCES [GeDeDe].Promocion(prom_codigo);

ALTER TABLE [GeDeDe].[Item_Factura]
ADD CONSTRAINT FK_Item_Factura_Factura
FOREIGN KEY (item_fact_tipo, item_fact_nro, item_fact_sucursal, item_fact_caja) REFERENCES [GeDeDe].Factura(fact_tipo, fact_nro, fact_sucursal, fact_caja);

ALTER TABLE [GeDeDe].[Item_Factura]
ADD CONSTRAINT FK_Item_Factura_Producto
FOREIGN KEY (item_producto) REFERENCES [GeDeDe].Producto(prod_codigo);

ALTER TABLE [GeDeDe].[Item_Factura]
ADD CONSTRAINT FK_Item_Factura_Promocion
FOREIGN KEY (item_promo_aplicada) REFERENCES [GeDeDe].Promocion(prom_codigo);

ALTER TABLE [GeDeDe].[Envio]
ADD CONSTRAINT FK_Envio_Factura
FOREIGN KEY (envi_fact_tipo, envi_fact_nro, envi_fact_sucursal, envi_fact_caja) REFERENCES [GeDeDe].Factura(fact_tipo, fact_nro, fact_sucursal, fact_caja);

ALTER TABLE [GeDeDe].[Envio]
ADD CONSTRAINT FK_Envio_Cliente
FOREIGN KEY (envi_cliente) REFERENCES [GeDeDe].Cliente(clie_codigo);

ALTER TABLE [GeDeDe].[Descuento]
ADD CONSTRAINT FK_Descuento_Medio_Pago
FOREIGN KEY (descu_medio_pago) REFERENCES [GeDeDe].Medio_Pago(medio_pago_codigo);

ALTER TABLE [GeDeDe].[Detalle_Pago]
ADD CONSTRAINT FK_Detalle_Pago_Cliente
FOREIGN KEY (deta_pago_cliente) REFERENCES [GeDeDe].Cliente(clie_codigo);

ALTER TABLE [GeDeDe].[Pago]
ADD CONSTRAINT FK_Pago_Medio_Pago
FOREIGN KEY (pago_medio_pago) REFERENCES [GeDeDe].Medio_Pago(medio_pago_codigo);

ALTER TABLE [GeDeDe].[Pago]
ADD CONSTRAINT FK_Pago_Factura
FOREIGN KEY (pago_fact_tipo, pago_fact_nro, pago_fact_sucursal, pago_fact_caja) REFERENCES [GeDeDe].Factura(fact_tipo, fact_nro, fact_sucursal, fact_caja);

ALTER TABLE [GeDeDe].[Pago]
ADD CONSTRAINT FK_Pago_Detalle_Pago
FOREIGN KEY (pago_detalle) REFERENCES [GeDeDe].Detalle_Pago(deta_pago_codigo);

ALTER TABLE [GeDeDe].[Aplicacion_Descuento]
ADD CONSTRAINT FK_Aplicacion_Descuento_Pago
FOREIGN KEY (apli_descuento_pago) REFERENCES [GeDeDe].Pago(pago_codigo);

ALTER TABLE [GeDeDe].[Aplicacion_Descuento]
ADD CONSTRAINT FK_Aplicacion_Descuento_Descuento
FOREIGN KEY (apli_descuento_codigo_descuento) REFERENCES [GeDeDe].Descuento(descu_codigo);
END;
GO

CREATE PROCEDURE [GeDeDe].[CREATE_DML]
AS
BEGIN
	print 'Cargando tabla Super'
    BEGIN
        -- Insertar datos seleccionados desde la tabla Maestra a la tabla Super
        INSERT INTO [GD1C2024].[GeDeDe].[Super] (supe_nombre, supe_razon_social, supe_cuit, supe_iibb, supe_domicilio, supe_fecha_inicio_actividad, supe_condicion_fiscal, supe_localidad, supe_provincia)
        SELECT DISTINCT SUPER_NOMBRE, SUPER_RAZON_SOC, CAST(REPLACE(SUPER_CUIT, '-', '') AS DECIMAL(18,0)), SUPER_IIBB, SUPER_DOMICILIO, SUPER_FECHA_INI_ACTIVIDAD, SUPER_CONDICION_FISCAL, SUPER_LOCALIDAD, SUPER_PROVINCIA
        FROM [GD1C2024].[gd_esquema].[Maestra];
    END;
	print 'Cargando tabla Sucursal'
    BEGIN
        -- Insertar datos seleccionados desde la tabla Maestra a la tabla Sucursal
        INSERT INTO [GD1C2024].[GeDeDe].[Sucursal] (sucu_super, sucu_nombre, sucu_direccion, sucu_localidad, sucu_provincia)
        SELECT distinct CAST(REPLACE([SUPER_CUIT], '-', '') AS DECIMAL(18,0)) ,[SUCURSAL_NOMBRE] ,[SUCURSAL_DIRECCION] ,[SUCURSAL_LOCALIDAD] ,[SUCURSAL_PROVINCIA]
        FROM [GD1C2024].[gd_esquema].[Maestra]
    END;
	print 'Cargando tabla Caja_Tipo'
    BEGIN
        -- Insertar datos seleccionados desde la tabla Maestra a la tabla Caja_tipo
        INSERT INTO [GD1C2024].[GeDeDe].[Tipo_Caja] (tipo_caja_nombre)
        SELECT distinct [CAJA_TIPO]
        FROM [GD1C2024].[gd_esquema].[Maestra]
        where [CAJA_TIPO] is not null
    END;
	print 'Cargando tabla Caja'
    BEGIN
        -- Insertar datos seleccionados desde la tabla Maestra a la tabla Caja
        INSERT INTO [GD1C2024].[GeDeDe].[Caja] (caja_codigo, caja_tipo, caja_sucursal)
        SELECT [CAJA_NUMERO], [Tipo_Caja].tipo_caja_codigo, Sucursal.sucu_codigo
          FROM [GD1C2024].[gd_esquema].[Maestra]
          inner join [GD1C2024].[GeDeDe].[Sucursal] on [SUCURSAL_NOMBRE] = sucu_nombre
          inner join [GD1C2024].[GeDeDe].[Tipo_Caja] on [Maestra].[CAJA_TIPO] = [Tipo_Caja].tipo_caja_nombre
          WHERE [Maestra].CAJA_NUMERO IS NOT NULL
          group by [CAJA_NUMERO], [Tipo_Caja].tipo_caja_codigo, sucu_codigo
    END;
	print 'Cargando tabla Marca'
    BEGIN
        -- Insertar datos seleccionados desde la tabla Maestra a la tabla Marca
        INSERT INTO [GD1C2024].[GeDeDe].[Marca] (marc_descripcion)
        SELECT distinct [PRODUCTO_MARCA]
        FROM [GD1C2024].[gd_esquema].[Maestra]
        where PRODUCTO_MARCA is not null
    END;
	print 'Cargando tabla Categoria y Subcategoria'
    BEGIN
        -- Insertar datos seleccionados desde la tabla Maestra a la tabla Categoria (Categorias + Subcategorias)
        INSERT INTO [GD1C2024].[GeDeDe].[Categoria] (cate_descripcion)
        SELECT DISTINCT [PRODUCTO_CATEGORIA] AS categoria FROM [GD1C2024].[gd_esquema].[Maestra] where [PRODUCTO_CATEGORIA] is not null
        UNION
        SELECT DISTINCT [PRODUCTO_SUB_CATEGORIA] AS categoria FROM [GD1C2024].[gd_esquema].[Maestra] where [PRODUCTO_SUB_CATEGORIA] is not null;

    END;
	print 'Cargando tabla muchos a muchos categoria - subcategoria'
    BEGIN
        -- Insertar datos seleccionados desde la tabla Maestra combinado con los datos de Categoria, insertar en sub categoria las relaciones.
        INSERT INTO [GD1C2024].[GeDeDe].[Subcategoria] (subc_codigo, subc_categoria)
        SELECT Subc.cate_codigo, Catego.cate_codigo
          FROM [GD1C2024].[gd_esquema].[Maestra] INNER JOIN [GD1C2024].[GeDeDe].Categoria as Subc  on [PRODUCTO_SUB_CATEGORIA] = Subc.cate_descripcion
          INNER JOIN [GD1C2024].[GeDeDe].[Categoria] as Catego on [PRODUCTO_CATEGORIA] = Catego.cate_descripcion
          GROUP BY Subc.cate_codigo , Catego.cate_codigo;
    END;
	print 'Cargando tabla Producto'
    BEGIN
        -- Insertar datos seleccionados desde la tabla Maestra a la tabla Producto
        INSERT INTO [GD1C2024].[GeDeDe].[Producto] (prod_marca, prod_nombre, prod_descripcion, prod_precio, prod_subcategoria, prod_categoria)
        SELECT distinct [GD1C2024].[GeDeDe].Marca.marc_codigo,
        [PRODUCTO_NOMBRE]
        ,[PRODUCTO_DESCRIPCION]
        ,[PRODUCTO_PRECIO]
        ,Subc.cate_codigo
        ,Cate.cate_codigo
        FROM [GD1C2024].[gd_esquema].[Maestra]
        INNER JOIN [GD1C2024].[GeDeDe].Marca on PRODUCTO_MARCA = Marca.marc_descripcion
        INNER JOIN [GD1C2024].[GeDeDe].Categoria Subc on [PRODUCTO_SUB_CATEGORIA] = Subc.cate_descripcion
        INNER JOIN [GD1C2024].[GeDeDe].Categoria Cate on [PRODUCTO_CATEGORIA] = Cate.cate_descripcion
        where producto_nombre is not null
    END;
	print 'Cargando tabla Empleado'
    BEGIN
        -- Insertar datos seleccionados desde la tabla Maestra a la tabla Empleado
        INSERT INTO [GD1C2024].[GeDeDe].[Empleado] (empl_nombre, empl_apellido, empl_dni, empl_fecha_registro, empl_telefono, empl_mail, empl_fecha_nacimiento, empl_sucursal)
        SELECT [EMPLEADO_NOMBRE]
              ,[EMPLEADO_APELLIDO]
              ,[EMPLEADO_DNI]
              ,[EMPLEADO_FECHA_REGISTRO]
              ,[EMPLEADO_TELEFONO]
              ,[EMPLEADO_MAIL]
              ,[EMPLEADO_FECHA_NACIMIENTO]
        	  ,sucu_codigo
          FROM [GD1C2024].[gd_esquema].[Maestra]
          INNER JOIN [GD1C2024].[GeDeDe].Sucursal on [SUCURSAL_NOMBRE] = Sucursal.sucu_nombre
          WHERE [EMPLEADO_DNI] IS NOT NULL
          group by sucu_codigo
        	  ,[EMPLEADO_NOMBRE]
              ,[EMPLEADO_APELLIDO]
              ,[EMPLEADO_DNI]
              ,[EMPLEADO_FECHA_REGISTRO]
              ,[EMPLEADO_TELEFONO]
              ,[EMPLEADO_MAIL]
              ,[EMPLEADO_FECHA_NACIMIENTO]
    END;
	print 'Cargando tabla Cliente'
    BEGIN
        INSERT INTO [GD1C2024].[GeDeDe].[Cliente] (clie_nombre, clie_apellido, clie_dni, clie_fecha_registro, clie_telefono, clie_mail, clie_fecha_nacimiento, clie_domicilio, clie_localidad, clie_provincia)
        SELECT distinct [CLIENTE_NOMBRE]
              ,[CLIENTE_APELLIDO]
              ,[CLIENTE_DNI]
              ,[CLIENTE_FECHA_REGISTRO]
              ,[CLIENTE_TELEFONO]
              ,[CLIENTE_MAIL]
              ,[CLIENTE_FECHA_NACIMIENTO]
              ,[CLIENTE_DOMICILIO]
              ,[CLIENTE_LOCALIDAD]
              ,[CLIENTE_PROVINCIA]
          FROM [GD1C2024].[gd_esquema].[Maestra]
          where cliente_apellido is not null
    END;
	print 'Cargando tabla Regla'
    BEGIN
       INSERT INTO [GD1C2024].[GeDeDe].[Regla] (regl_descripcion, regl_descuento_aplicable_producto, regl_cant_aplicable_regla, regl_cant_aplicable_descuento, regl_cant_maxima, regl_misma_marca, regl_mismo_producto)
       SELECT distinct [REGLA_DESCRIPCION]
             ,[REGLA_DESCUENTO_APLICABLE_PROD]
             ,[REGLA_CANT_APLICABLE_REGLA]
             ,[REGLA_CANT_APLICA_DESCUENTO]
             ,[REGLA_CANT_MAX_PROD]
       	     ,[REGLA_APLICA_MISMA_MARCA]
             ,[REGLA_APLICA_MISMO_PROD]
         FROM [GD1C2024].[gd_esquema].[Maestra]
         where promo_codigo is not null
    END;
	print 'Cargando tabla Promocion'
    BEGIN
        INSERT INTO [GD1C2024].[GeDeDe].[Promocion] (prom_codigo, prom_regla, prom_descripcion, prom_fecha_inicio, prom_fecha_fin)
        SELECT distinct [PROMO_CODIGO]
        	  ,[GD1C2024].[GeDeDe].Regla.regl_codigo
              ,[PROMOCION_DESCRIPCION]
              ,[PROMOCION_FECHA_INICIO]
              ,[PROMOCION_FECHA_FIN]
          FROM [GD1C2024].[gd_esquema].[Maestra]
          inner join [GD1C2024].[GeDeDe].Regla on REGLA_DESCRIPCION = Regla.regl_descripcion
          where promo_codigo is not null
    END;
	print 'Cargando tabla Promocion_Producto'
    BEGIN
    INSERT INTO [GD1C2024].[GeDeDe].[Promocion_Producto] (prod_codigo, prom_codigo)
    SELECT distinct Producto.prod_codigo ,[PROMO_CODIGO]
      FROM [GD1C2024].[gd_esquema].[Maestra]
      join [GD1C2024].[GeDeDe].Categoria on [PRODUCTO_CATEGORIA] = Categoria.cate_descripcion
      join [GD1C2024].[GeDeDe].Categoria as Cat_Subcategoria on [PRODUCTO_SUB_CATEGORIA] = Cat_Subcategoria.cate_descripcion
      inner join [GD1C2024].[GeDeDe].Producto on [PRODUCTO_DESCRIPCION] = Producto.prod_descripcion
    	and [PRODUCTO_NOMBRE] = Producto.prod_nombre
    	and [PRODUCTO_PRECIO] = Producto.prod_precio
    	and Categoria.cate_codigo = Producto.prod_categoria
    	and Cat_Subcategoria.cate_codigo = Producto.prod_subcategoria
      where promo_codigo is not null AND PROMO_CODIGO IS NOT NULL;

    END;
	print 'Cargando tabla Factura'
	
    BEGIN
		SELECT TICKET_TIPO_COMPROBANTE, TICKET_NUMERO, [CLIENTE_DNI], SUCURSAL_NOMBRE into #Ticket_Cliente
		FROM [GD1C2024].[gd_esquema].[Maestra]
		WHERE [CLIENTE_DNI] IS NOT NULL AND [TICKET_TIPO_COMPROBANTE] IS NOT NULL AND [TICKET_NUMERO] IS NOT NULL

        INSERT INTO [GD1C2024].[GeDeDe].[Factura] (fact_nro, fact_sucursal, fact_caja, fact_vendedor, fact_cliente, fact_fecha_hora, fact_tipo, fact_subtotal_productos, fact_total_descuento_aplicado, fact_descuento_aplicado_mp, fact_total_envio, fact_total_ticket)
        SELECT distinct [TICKET_NUMERO] -- fact_nro
        	  ,[GD1C2024].[GeDeDe].Sucursal.sucu_codigo -- fact_sucursal
        	  ,[CAJA_NUMERO]	-- fact_caja
        	  ,[GD1C2024].[GeDeDe].Empleado.empl_codigo	-- fact_vendedor
			  ,(SELECT c.clie_codigo 
			  FROM #Ticket_Cliente tc
				JOIN [GD1C2024].[GeDeDe].[Cliente] c on c.clie_dni = tc.CLIENTE_DNI
			  WHERE tc.TICKET_TIPO_COMPROBANTE = m1.TICKET_TIPO_COMPROBANTE and tc.TICKET_NUMERO = m1.TICKET_NUMERO and tc.SUCURSAL_NOMBRE = m1.SUCURSAL_NOMBRE)
              ,[TICKET_FECHA_HORA] -- fact_fecha_hora
              ,[TICKET_TIPO_COMPROBANTE] -- fact_tipo
              ,[TICKET_SUBTOTAL_PRODUCTOS] -- fact_subtotal_productos
              ,[TICKET_TOTAL_DESCUENTO_APLICADO] -- fact_descuento_aplicado
              ,[TICKET_TOTAL_DESCUENTO_APLICADO_MP] -- fact_descuento_aplicado_mp
              ,[TICKET_TOTAL_ENVIO] -- fact_total_envio
              ,[TICKET_TOTAL_TICKET] -- fact_total_ticket

        	   FROM [GD1C2024].[gd_esquema].[Maestra] m1
        	   inner join [GD1C2024].[GeDeDe].Empleado on [EMPLEADO_DNI] = Empleado.empl_dni
        	   inner join [GD1C2024].[GeDeDe].Sucursal on [SUCURSAL_NOMBRE] = Sucursal.sucu_nombre

    END;
	print 'Cargando tabla Item_Factura'
    BEGIN
    INSERT INTO [GD1C2024].[GeDeDe].[Item_Factura] (item_fact_tipo, item_fact_sucursal, item_fact_nro, item_fact_caja, item_producto, item_promo_aplicada, item_cantidad, item_precio_unitario, item_precio_total, item_descuento_promo)
    SELECT 			[TICKET_TIPO_COMPROBANTE],
    						[GD1C2024].[GeDeDe].Sucursal.sucu_codigo,
    						[TICKET_NUMERO],
                            [CAJA_NUMERO],
                            [GD1C2024].[GeDeDe].Producto.prod_codigo,
                            [PROMO_CODIGO],
                            sum(ISNULL([TICKET_DET_CANTIDAD],0)) AS cantidad,
                            sum(ISNULL([TICKET_DET_PRECIO],0)) as precio,
                            sum(ISNULL([TICKET_DET_TOTAL],0)) as total,
                            sum(ISNULL([PROMO_APLICADA_DESCUENTO],0)) as promo_aplicada_descuento
            FROM [GD1C2024].[gd_esquema].[Maestra]
            inner join [GD1C2024].[GeDeDe].Sucursal on [SUCURSAL_NOMBRE] = Sucursal.sucu_nombre
    		inner join [GD1C2024].[GeDeDe].Categoria on [PRODUCTO_CATEGORIA] = Categoria.cate_descripcion
    		inner join [GD1C2024].[GeDeDe].Categoria as SubCategoria on [PRODUCTO_SUB_CATEGORIA] = SubCategoria.cate_descripcion
            inner join [GD1C2024].[GeDeDe].Producto on [PRODUCTO_NOMBRE] = Producto.prod_nombre AND Categoria.cate_codigo = Producto.prod_categoria and SubCategoria.cate_codigo = Producto.prod_subcategoria
    		GROUP BY [TICKET_TIPO_COMPROBANTE],
    						[GD1C2024].[GeDeDe].Sucursal.sucu_codigo,
    						[TICKET_NUMERO],
                            [CAJA_NUMERO],
                            [GD1C2024].[GeDeDe].Producto.prod_codigo,
                            [PROMO_CODIGO]

    END;
	print 'Cargando tabla Envio'
    BEGIN
    INSERT INTO [GD1C2024].[GeDeDe].[Envio] (envi_fact_tipo, envi_fact_sucursal, envi_fact_nro, envi_fact_caja, envi_cliente, envi_fecha_programada, envi_costo, envi_horario_inicio, envi_horario_fin, envi_fecha_entrega, envi_estado)
    SELECT distinct [TICKET_TIPO_COMPROBANTE],
                    [GD1C2024].[GeDeDe].Sucursal.sucu_codigo,
                    [TICKET_NUMERO],
                    [CAJA_NUMERO],
                    [GD1C2024].[GeDeDe].Cliente.clie_codigo,
                    [ENVIO_FECHA_PROGRAMADA],
                    [ENVIO_COSTO],
                    [ENVIO_HORA_INICIO],
                    [ENVIO_HORA_FIN],
                    [ENVIO_FECHA_ENTREGA],
                    [ENVIO_ESTADO]
    FROM [GD1C2024].[gd_esquema].[Maestra]
    inner join [GD1C2024].[GeDeDe].Sucursal on [SUCURSAL_NOMBRE] = Sucursal.sucu_nombre
    inner join [GD1C2024].[GeDeDe].Cliente on [CLIENTE_DNI] = Cliente.clie_dni
                                             and [CLIENTE_MAIL] = Cliente.clie_mail;

    END;
	print 'Cargando tabla Medio_Pago'
    BEGIN
        INSERT INTO [GD1C2024].[GeDeDe].[Medio_Pago] (medio_pago_detalle, medio_pago_tipo)
        SELECT distinct [PAGO_MEDIO_PAGO]
              ,[PAGO_TIPO_MEDIO_PAGO]
          FROM [GD1C2024].[gd_esquema].[Maestra]
          where PAGO_MEDIO_PAGO is not null

    END;
	print 'Cargando tabla Descuento'
    BEGIN
	
    INSERT INTO [GD1C2024].[GeDeDe].[Descuento] (descu_codigo, descu_medio_pago, descu_descripcion, descu_fecha_inicio, descu_fecha_fin, descu_porcentaje_descuento, descu_tope)
    SELECT [DESCUENTO_CODIGO]
      ,Medio_Pago.medio_pago_codigo
      ,[DESCUENTO_DESCRIPCION]
      ,[DESCUENTO_FECHA_INICIO]
      ,[DESCUENTO_FECHA_FIN]
      ,[DESCUENTO_PORCENTAJE_DESC]
      ,[DESCUENTO_TOPE]
     FROM [GD1C2024].[gd_esquema].[Maestra]
     INNER JOIN [GD1C2024].[GeDeDe].Medio_Pago on [PAGO_MEDIO_PAGO] = Medio_Pago.medio_pago_detalle
     WHERE DESCUENTO_CODIGO IS NOT NULL
    GROUP BY [DESCUENTO_CODIGO]
      ,[DESCUENTO_DESCRIPCION]
      ,[DESCUENTO_FECHA_INICIO]
      ,[DESCUENTO_FECHA_FIN]
      ,[DESCUENTO_PORCENTAJE_DESC]
      ,[DESCUENTO_TOPE]
      ,Medio_Pago.medio_pago_codigo
    END;

    BEGIN
	print 'Cargando tabla Detalle_Pago'

	
            INSERT INTO [GD1C2024].[GeDeDe].[Detalle_Pago] (deta_pago_cliente, deta_pago_tarjeta_nro, deta_pago_tarjeta_cuotas, deta_pago_tarjeta_fecha_vencimiento)
            SELECT distinct (
						SELECT c.clie_codigo
						FROM Cliente c
							join #Ticket_Cliente tc on tc.CLIENTE_DNI = c.clie_dni
						where tc.TICKET_TIPO_COMPROBANTE = m.TICKET_TIPO_COMPROBANTE and tc.SUCURSAL_NOMBRE = m.SUCURSAL_NOMBRE and tc.TICKET_NUMERO = m.TICKET_NUMERO
								),--cliente
                                [PAGO_TARJETA_NRO],--tarjetaNro
                                [PAGO_TARJETA_CUOTAS],--cuotas
                                [PAGO_TARJETA_FECHA_VENC]--vencimiento
            FROM [GD1C2024].[gd_esquema].[Maestra] m
            LEFT JOIN [GD1C2024].[GeDeDe].Cliente on Cliente.clie_dni = [CLIENTE_DNI]
			where PAGO_TARJETA_NRO is not null


    print 'Cargando tabla Pago'

		SELECT TICKET_TIPO_COMPROBANTE, TICKET_NUMERO, SUCURSAL_NOMBRE, CAJA_NUMERO into #Ticket_Caja
		FROM [GD1C2024].[gd_esquema].[Maestra]
		WHERE [TICKET_TIPO_COMPROBANTE] IS NOT NULL AND [TICKET_NUMERO] IS NOT NULL and SUCURSAL_NOMBRE is not null and CAJA_NUMERO is not null


        INSERT INTO [GD1C2024].[GeDeDe].[Pago] (pago_medio_pago, pago_fact_tipo, pago_fact_sucursal, pago_fact_caja , pago_fact_nro, pago_fecha_hora, pago_importe,pago_detalle)
        SELECT distinct 	[GD1C2024].[GeDeDe].Medio_Pago.medio_pago_codigo,--medio de pago
                            [GD1C2024].[GeDeDe].Factura.fact_tipo,--tipo fact
                            [GD1C2024].[GeDeDe].Factura.fact_sucursal, --fact sucu
                            (
							select top 1 CAJA_NUMERO
							from #Ticket_Caja tc 
							where tc.TICKET_TIPO_COMPROBANTE = m.TICKET_TIPO_COMPROBANTE and tc.SUCURSAL_NOMBRE = m.SUCURSAL_NOMBRE and tc.TICKET_NUMERO = m.TICKET_NUMERO
							), --fact caja 
                            [GD1C2024].[GeDeDe].Factura.fact_nro, --fact nro
                            m.[PAGO_FECHA],-- pago F/H
                            m.[PAGO_IMPORTE],--pago importe
                            [GD1C2024].[GeDeDe].Detalle_Pago.deta_pago_codigo --detalle
        FROM [GD1C2024].[gd_esquema].[Maestra] m
        INNER JOIN [GD1C2024].[GeDeDe].Medio_Pago on m.PAGO_MEDIO_PAGO = Medio_Pago.medio_pago_detalle
        INNER JOIN [GD1C2024].[GeDeDe].Sucursal on sucu_nombre = m.[SUCURSAL_NOMBRE]
        INNER JOIN [GD1C2024].[GeDeDe].Factura on m.[TICKET_TIPO_COMPROBANTE] = fact_tipo  and [sucu_codigo] = fact_sucursal AND m.[TICKET_NUMERO] = fact_nro
        LEFT JOIN [GD1C2024].[GeDeDe].Detalle_Pago on  Detalle_Pago.deta_pago_tarjeta_nro = m.[PAGO_TARJETA_NRO]
        where pago_importe is not null

    END;
    BEGIN
	print 'Cargando tabla Aplicacion_Descuento'
    INSERT INTO [GD1C2024].[GeDeDe].[Aplicacion_Descuento] (apli_descuento_pago, apli_descuento_codigo_descuento, apli_descuento_monto)
    SELECT 	Pago.pago_codigo,
            [DESCUENTO_CODIGO]
          ,[PAGO_DESCUENTO_APLICADO]
      FROM [GD1C2024].[gd_esquema].[Maestra]
      inner join [GD1C2024].[GeDeDe].Medio_Pago on
      [PAGO_MEDIO_PAGO] = Medio_Pago.medio_pago_detalle
      inner join [GD1C2024].[GeDeDe].Medio_Pago as TipoMP on
      [PAGO_TIPO_MEDIO_PAGO] = Medio_Pago.medio_pago_tipo
      inner join [GD1C2024].[GeDeDe].Detalle_Pago on PAGO_TARJETA_NRO = Detalle_Pago.deta_pago_tarjeta_nro and PAGO_TARJETA_CUOTAS = Detalle_Pago.deta_pago_tarjeta_cuotas and PAGO_TARJETA_FECHA_VENC = Detalle_Pago.deta_pago_tarjeta_fecha_vencimiento
      INNER JOIN [GD1C2024].[GeDeDe].Pago ON
            [PAGO_FECHA] = Pago.pago_fecha_hora
          and [GD1C2024].[gd_esquema].[Maestra].[PAGO_IMPORTE] = Pago.pago_importe
          and Medio_Pago.medio_pago_detalle = [GD1C2024].[gd_esquema].[Maestra].[PAGO_MEDIO_PAGO]
          and [GD1C2024].[gd_esquema].[Maestra].[PAGO_TIPO_MEDIO_PAGO] = TipoMP.medio_pago_tipo
          and [GD1C2024].[gd_esquema].[Maestra].[PAGO_TARJETA_NRO] = Detalle_Pago.deta_pago_tarjeta_nro
          and [PAGO_TARJETA_CUOTAS] = Detalle_Pago.deta_pago_tarjeta_cuotas
          and [PAGO_TARJETA_FECHA_VENC] = Detalle_Pago.deta_pago_tarjeta_fecha_vencimiento
      WHERE [DESCUENTO_CODIGO] IS NOT NULL AND PAGO_DESCUENTO_APLICADO IS NOT NULL
      GROUP BY [DESCUENTO_CODIGO],
            Pago.pago_codigo
          ,[PAGO_DESCUENTO_APLICADO]
    END;
END;
GO


/* Ejecutamos los SP en una transaccion, para pasar de un estado consistente a otro consistente.*/
 BEGIN TRANSACTION
 BEGIN TRY
	EXEC [GeDeDe].[CLEAN]
	EXEC [GeDeDe].[CREATE_DDL];
	EXEC [GeDeDe].[CREATE_DML];
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
	THROW 50001, 'Error al cargar el modelo OLTP, ninguna tabla fue cargada',1;
END CATCH

 IF (EXISTS (SELECT 1 FROM [GeDeDe].[Medio_Pago])
   AND EXISTS (SELECT 1 FROM [GeDeDe].[Sucursal]))

   BEGIN
	PRINT 'Modelo OLTP creado y cargado correctamente.';
	COMMIT TRANSACTION;
   END
	 ELSE
   BEGIN
    ROLLBACK TRANSACTION;
	THROW 50002, 'Hubo un error al cargar una o más tablas. Rollback Transaction: ninguna tabla fue cargada en la base.',1;
   END

GO


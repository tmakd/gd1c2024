USE GD1C2024_Migrada;
GO

CREATE PROCEDURE GD1C2024_MIGRACION_DDL
AS
BEGIN

	-- Crear la tabla Super
	CREATE TABLE Super (
		supe_cuit DECIMAL(18,0) PRIMARY KEY,
		supe_nombre NVARCHAR(255),
		supe_razon_social NVARCHAR(255),
		supe_iibb NVARCHAR(255),
		supe_domicilio NVARCHAR(255),
		supe_fecha_inicio_actividad DATETIME,
		supe_condicion_fiscal NVARCHAR(255),
		supe_localidad NVARCHAR(255),
		supe_provincia NVARCHAR(255),
	);

	-- Crear la tabla Sucursal
	CREATE TABLE Sucursal (
		sucu_codigo DECIMAL(18,0) PRIMARY KEY,
		sucu_super DECIMAL(18,0), -- FK
		sucu_nombre NVARCHAR(255),
		sucu_localidad NVARCHAR(255),
		sucu_direccion NVARCHAR(255),
		sucu_provincia NVARCHAR(255)
	);
	-- Creamos la constraint fk en sucu_super -> super_codigo
	ALTER TABLE Sucursal
	ADD CONSTRAINT FK_Sucursal_Super
	FOREIGN KEY (sucu_super) REFERENCES Super(supe_cuit);

	-- Crear la tabla Tipo_Caja
	CREATE TABLE Tipo_Caja (
		caja_tipo NVARCHAR(255) PRIMARY KEY
	);

	-- Crear la tabla Caja
	CREATE TABLE Caja (
		caja_codigo DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
		caja_tipo NVARCHAR(255), -- FK
		caja_sucursal DECIMAL(18,0)
	);

	-- Agregar la restricci�n FK_Caja_Tipo_Caja a la tabla Caja
	ALTER TABLE Caja
	ADD CONSTRAINT FK_Caja_Tipo_Caja FOREIGN KEY (caja_tipo) REFERENCES Tipo_Caja(caja_tipo);

	-- Agregar la restricci�n FK_Caja_Sucursal a la tabla Caja
	ALTER TABLE Caja
	ADD CONSTRAINT FK_Caja_Sucursal FOREIGN KEY (caja_sucursal) REFERENCES Sucursal(sucu_codigo);

	-- Crear la tabla Empleado
	CREATE TABLE Empleado (
		empl_codigo DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
		empl_sucursal DECIMAL(18,0), -- FK
		empl_nombre NVARCHAR(255),
		empl_apellido NVARCHAR(255),
		empl_dni DECIMAL(18,0),
		empl_fecha_registro DATETIME,
		empl_telefono DECIMAL(18,0),
		empl_mail NVARCHAR(255),
		empl_fecha_nacimiento DATE
	);

	ALTER TABLE Empleado
	ADD CONSTRAINT FK_Empleado_Sucursal
	FOREIGN KEY (empl_sucursal) REFERENCES Sucursal(sucu_codigo);


	-- Crear la tabla Factura
	CREATE TABLE Factura (
		fact_nro DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
		fact_sucursal DECIMAL(18,0), -- FK
		fact_caja DECIMAL(18,0), -- FK
		fact_vendedor DECIMAL(18,0), -- FK
		fact_fecha_hora DATETIME,
		fact_tipo nvarchar(255),
		fact_subtotal_productos DECIMAL(18,2),
		fact_total_descuento_aplicado DECIMAL(18,2),
		fact_descuento_aplicado_mp DECIMAL(18,2),
		fact_total_envio DECIMAL(18,2),
		fact_total_ticket DECIMAL(18,2)
	);

	ALTER TABLE Factura
	ADD CONSTRAINT FK_Factura_Sucursal
	FOREIGN KEY (fact_sucursal) REFERENCES Sucursal(sucu_codigo);

	ALTER TABLE Factura
	ADD CONSTRAINT FK_Factura_Caja
	FOREIGN KEY (fact_caja) REFERENCES Caja(caja_codigo);

	ALTER TABLE Factura
	ADD CONSTRAINT FK_Factura_Empleado
	FOREIGN KEY (fact_vendedor) REFERENCES Empleado(empl_codigo);

	-- Crear la tabla Marca
	CREATE TABLE Marca (
		marc_codigo DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
		marc_descripcion NVARCHAR(255)
	);

	-- Crear la tabla Categoria
	CREATE TABLE Categoria  (
		cate_codigo DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
		cate_descripcion NVARCHAR(255)
	);

	-- Crear la tabla Subcategoria
	CREATE TABLE Subcategoria  (
		subc_codigo DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
		subc_categoria DECIMAL(18,0)
	);

	ALTER TABLE Subcategoria
	ADD CONSTRAINT FK_Subcategoria_Categoria
	FOREIGN KEY (subc_categoria) REFERENCES Categoria(cate_codigo);

	-- Crear la tabla Producto
	CREATE TABLE Producto  (
		prod_codigo DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
		prod_marca DECIMAL(18,0), -- FK
		prod_subcategoria DECIMAL(18,0), -- FK
		prod_descripcion NVARCHAR(255),
		prod_precio DECIMAL(18,2)
	);

	ALTER TABLE Producto
	ADD CONSTRAINT FK_Producto_Marca
	FOREIGN KEY (prod_marca) REFERENCES Marca(marc_codigo);

	ALTER TABLE Producto
	ADD CONSTRAINT FK_Producto_Subcategoria
	FOREIGN KEY (prod_subcategoria) REFERENCES Subcategoria(subc_codigo);

	-- Crear la tabla Regla
	CREATE TABLE Regla  (
		regl_codigo DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
		regl_descripcion NVARCHAR(255),
		regl_descuento DECIMAL(18,2),
		regl_cant_aplicable_regla DECIMAL(18,2),
		regl_cant_aplicable_descuento DECIMAL(18,2),
		regl_cant_maxima DECIMAL(18,0),
		regl_misma_marca DECIMAL(18,0),
		regl_mismo_producto DECIMAL(18,0)
	);

	-- Crear la tabla Promocion
	CREATE TABLE Promocion  (
		prom_codigo DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
		prom_regla DECIMAL(18,0), -- FK
		prom_descripcion NVARCHAR(255),
		prom_fecha_inicio DATETIME,
		prom_fecha_fin DATETIME
	);

	ALTER TABLE Promocion
	ADD CONSTRAINT FK_Promocion_Regla
	FOREIGN KEY (prom_regla) REFERENCES Regla(regl_codigo);

	-- Crear la tabla Promocion_Producto
	CREATE TABLE Promocion_Producto  (
		prod_codigo DECIMAL(18,0), -- PK FK
		prom_codigo DECIMAL(18,0), -- PK FK
		PRIMARY KEY (prod_codigo, prom_codigo)
	);

	ALTER TABLE Promocion_Producto
	ADD CONSTRAINT FK_Promocion_Producto_Producto
	FOREIGN KEY (prod_codigo) REFERENCES Producto(prod_codigo);

	ALTER TABLE Promocion_Producto
	ADD CONSTRAINT FK_Promocion_Producto_Promocion
	FOREIGN KEY (prom_codigo) REFERENCES Promocion(prom_codigo);

	-- Crear la tabla Item_Factura
	CREATE TABLE Item_Factura  (
		item_nro DECIMAL(18,0), -- FK
		item_producto DECIMAL(18,0), -- FK
		PRIMARY KEY (item_nro, item_producto),
		item_promo_aplicada DECIMAL(18,0), -- FK
		item_cantidad DECIMAL(18,0),
		item_precio_unitario DECIMAL(18,0),
		item_precio_total DECIMAL(18,2),
		item_descuento_promo DECIMAL(18,2)
	);

	ALTER TABLE Item_Factura
	ADD CONSTRAINT FK_Item_Factura_Factura
	FOREIGN KEY (item_nro) REFERENCES Factura(fact_nro);


	ALTER TABLE Item_Factura
	ADD CONSTRAINT FK_Item_Factura_Producto
	FOREIGN KEY (item_producto) REFERENCES Producto(prod_codigo);

	ALTER TABLE Item_Factura
	ADD CONSTRAINT FK_Item_Factura_Promocion
	FOREIGN KEY (item_promo_aplicada) REFERENCES Promocion(prom_codigo);

	-- Crear la tabla Cliente
	CREATE TABLE Cliente  (
		clie_codigo DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
		clie_nombre NVARCHAR(255),
		clie_apellido NVARCHAR(255),
		clie_dni DECIMAL(18,0),
		clie_fecha_registro DATETIME, -- podria ser timestamp
		clie_telefono DECIMAL(18,0),
		clie_mail NVARCHAR(255),
		clie_fecha_nacimiento DATE,
		clie_domicilio NVARCHAR(255),
		clie_localidad NVARCHAR(255),
		clie_provincia NVARCHAR(255)
	);

	-- Crear la tabla Envio
	CREATE TABLE Envio (
		envi_codigo DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
		envi_factura DECIMAL(18,0), -- FK
		envi_cliente DECIMAL(18,0), --FK
		envi_fecha_programada DATETIME,
		envi_costo DECIMAL(18,2),
		envi_horario_inicio DECIMAL(18,0),
		envi_horario_fin DECIMAL(18,0),
		envi_fecha_entrega DATETIME,
		envi_estado NVARCHAR(255)
	);

	ALTER TABLE Envio
	ADD CONSTRAINT FK_Envio_Factura
	FOREIGN KEY (envi_factura) REFERENCES Factura(fact_nro);

	ALTER TABLE Envio
	ADD CONSTRAINT FK_Envio_Cliente
	FOREIGN KEY (envi_cliente) REFERENCES Cliente(clie_codigo);

	-- Crear la tabla Medio_Pago
	CREATE TABLE Medio_Pago (
		medio_pago_codigo DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
		medio_pago_detalle NVARCHAR(255),
		medio_pago_tipo NVARCHAR(255)
	);

	-- Crear la tabla Descuento
	CREATE TABLE Descuento (
		descu_codigo DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
		descu_medio_pago DECIMAL(18,0), -- FK
		descu_descripcion NVARCHAR(255),
		descu_fecha_inicio DATETIME,
		descu_fecha_fin DATETIME,
		descu_porcentaje_descuento DECIMAL(18,2),
		descu_tope DECIMAL(18,2)
	);

	ALTER TABLE Descuento
	ADD CONSTRAINT FK_Descuento_Medio_Pago
	FOREIGN KEY (descu_medio_pago) REFERENCES Medio_Pago(medio_pago_codigo);

	-- Crear la tabla Pago
	CREATE TABLE Pago (
		pago_codigo DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
		pago_medio_pago DECIMAL(18,0), -- FK
		pago_nro_factura DECIMAL(18,0), -- FK
		pago_detalle DECIMAL(18,0), -- FK
		pago_fecha_hora DATETIME,
		pago_importe DECIMAL(18,2)
	);

	-- Crear la tabla Detalle_Pago
	CREATE TABLE Detalle_Pago (
		deta_pago_codigo DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
		deta_pago_pago DECIMAL(18,0), -- FK
		deta_pago_cliente DECIMAL(18,0), -- FK
		deta_pago_tarjeta_nro NVARCHAR(255),
		deta_pago_tarjeta_cuotas DECIMAL(18,0),
		deta_pago_tarjeta_fecha_vencimiento DATETIME
	);

	ALTER TABLE Detalle_Pago
	ADD CONSTRAINT FK_Detalle_Pago_Pago
	FOREIGN KEY (deta_pago_pago) REFERENCES Pago(pago_codigo);


	ALTER TABLE Detalle_Pago
	ADD CONSTRAINT FK_Detalle_Pago_Cliente
	FOREIGN KEY (deta_pago_cliente) REFERENCES Cliente(clie_codigo);

	-- el orden de el alter table de pago es porque es doblemente referenciada con detalle_pago

	ALTER TABLE Pago
	ADD CONSTRAINT FK_Pago_Medio_Pago
	FOREIGN KEY (pago_medio_pago) REFERENCES Medio_Pago(medio_pago_codigo);

	ALTER TABLE Pago
	ADD CONSTRAINT FK_Pago_Factura
	FOREIGN KEY (pago_nro_factura) REFERENCES Factura(fact_nro);

	ALTER TABLE Pago
	ADD CONSTRAINT FK_Pago_Detalle_Pago
	FOREIGN KEY (pago_detalle) REFERENCES Detalle_Pago(deta_pago_codigo);

	-- Crear la tabla Aplicacion_Descuento
	CREATE TABLE Aplicacion_Descuento (
		apli_descuento_pago DECIMAL(18,0),
		apli_descuento_codigo_descuento DECIMAL(18,0),
		PRIMARY KEY(apli_descuento_pago, apli_descuento_codigo_descuento),
		apli_descuento_monto DECIMAL(18,2)
	);

	ALTER TABLE Aplicacion_Descuento
	ADD CONSTRAINT FK_Aplicacion_Descuento_Pago
	FOREIGN KEY (apli_descuento_pago) REFERENCES Pago(pago_codigo);

	ALTER TABLE Aplicacion_Descuento
	ADD CONSTRAINT FK_Aplicacion_Descuento_Descuento
	FOREIGN KEY (apli_descuento_codigo_descuento) REFERENCES Descuento(descu_codigo);
END;
GO
USE GD1C2024_Migrada;
GO

CREATE PROCEDURE GD1C2024_MIGRACION_DML
AS
BEGIN
    BEGIN
        -- Insertar datos seleccionados desde la tabla Maestra a la tabla Super
        INSERT INTO [GD1C2024_Migrada].dbo.Super (supe_nombre, supe_razon_social, supe_cuit, supe_iibb, supe_domicilio, supe_fecha_inicio_actividad, supe_condicion_fiscal, supe_localidad, supe_provincia)
        SELECT DISTINCT SUPER_NOMBRE, SUPER_RAZON_SOC, CAST(REPLACE(SUPER_CUIT, '-', '') AS DECIMAL(18,0)), SUPER_IIBB, SUPER_DOMICILIO, SUPER_FECHA_INI_ACTIVIDAD, SUPER_CONDICION_FISCAL, SUPER_LOCALIDAD, SUPER_PROVINCIA
        FROM [GD1C2024].gd_esquema.Maestra;
    END;
    BEGIN
        -- Insertar datos seleccionados desde la tabla Maestra a la tabla Sucursal
        INSERT INTO [GD1C2024_Migrada].dbo.Sucursal (sucu_super, sucu_nombre, sucu_direccion, sucu_localidad, sucu_provincia)
        SELECT distinct CAST(REPLACE([SUPER_CUIT], '-', '') AS DECIMAL(18,0)) ,[SUCURSAL_NOMBRE] ,[SUCURSAL_DIRECCION] ,[SUCURSAL_LOCALIDAD] ,[SUCURSAL_PROVINCIA]
        FROM [GD1C2024].[gd_esquema].[Maestra]
    END;
    BEGIN
        -- Insertar datos seleccionados desde la tabla Maestra a la tabla Caja_tipo
        INSERT INTO [GD1C2024_Migrada].dbo.Tipo_Caja (tipo_caja_nombre)
        SELECT distinct [CAJA_TIPO]
        FROM [GD1C2024].[gd_esquema].[Maestra]
        where [CAJA_TIPO] is not null
    END;
    BEGIN
        -- Insertar datos seleccionados desde la tabla Maestra a la tabla Caja
        INSERT INTO [GD1C2024_Migrada].dbo.Caja (caja_codigo, caja_tipo, caja_sucursal)
        SELECT [CAJA_NUMERO], [Tipo_Caja].tipo_caja_codigo, Sucursal.sucu_codigo
          FROM [GD1C2024].[gd_esquema].[Maestra]
          inner join [GD1C2024_Migrada].[dbo].[Sucursal] on [SUCURSAL_NOMBRE] = sucu_nombre
          inner join [GD1C2024_Migrada].[dbo].[Tipo_Caja] on [Maestra] .[CAJA_TIPO] = [Tipo_Caja].tipo_caja_nombre
          WHERE [Maestra].CAJA_NUMERO IS NOT NULL
          group by [CAJA_NUMERO], [Tipo_Caja].tipo_caja_codigo, sucu_codigo
    END;
    BEGIN
        -- Insertar datos seleccionados desde la tabla Maestra a la tabla Marca
        INSERT INTO [GD1C2024_Migrada].dbo.Marca (marc_descripcion)
        SELECT distinct [PRODUCTO_MARCA]
        FROM [GD1C2024].[gd_esquema].[Maestra]
        where PRODUCTO_MARCA is not null
    END;
    BEGIN
        -- Insertar datos seleccionados desde la tabla Maestra a la tabla Categoria (Categorias + Subcategorias)
        INSERT INTO [GD1C2024_Migrada].dbo.Categoria (cate_descripcion)
        SELECT DISTINCT [PRODUCTO_CATEGORIA] AS categoria FROM [GD1C2024].[gd_esquema].[Maestra] where [PRODUCTO_CATEGORIA] is not null
        UNION
        SELECT DISTINCT [PRODUCTO_SUB_CATEGORIA] AS categoria FROM [GD1C2024].[gd_esquema].[Maestra] where [PRODUCTO_SUB_CATEGORIA] is not null;

    END;
    BEGIN
        -- Insertar datos seleccionados desde la tabla Maestra combinado con los datos de Categoria, insertar en sub categoria las relaciones.
        INSERT INTO [GD1C2024_Migrada].dbo.Subcategoria (subc_codigo, subc_categoria)
        SELECT Subc.cate_codigo, Catego.cate_codigo
          FROM [GD1C2024].[gd_esquema].[Maestra] INNER JOIN [GD1C2024_Migrada].dbo.Categoria as Subc  on [PRODUCTO_SUB_CATEGORIA] = Subc.cate_descripcion
          INNER JOIN [GD1C2024_Migrada].dbo.Categoria as Catego on [PRODUCTO_CATEGORIA] = Catego.cate_descripcion
          GROUP BY Subc.cate_codigo , Catego.cate_codigo;
    END;
    BEGIN
        -- Insertar datos seleccionados desde la tabla Maestra a la tabla Producto
        INSERT INTO [GD1C2024_Migrada].dbo.Producto (prod_marca, prod_nombre, prod_descripcion, prod_precio, prod_subcategoria, prod_categoria)
        SELECT distinct [GD1C2024_Migrada].dbo.Marca.marc_codigo,
        [PRODUCTO_NOMBRE]
        ,[PRODUCTO_DESCRIPCION]
        ,[PRODUCTO_PRECIO]
        ,Subc.cate_codigo
        ,Cate.cate_codigo
        FROM [GD1C2024].[gd_esquema].[Maestra]
        INNER JOIN [GD1C2024_Migrada].dbo.Marca on PRODUCTO_MARCA = Marca.marc_descripcion
        INNER JOIN [GD1C2024_Migrada].dbo.Categoria Subc on [PRODUCTO_SUB_CATEGORIA] = Subc.cate_descripcion
        INNER JOIN [GD1C2024_Migrada].dbo.Categoria Cate on [PRODUCTO_CATEGORIA] = Cate.cate_descripcion
        where producto_nombre is not null
    END;
    BEGIN
        -- Insertar datos seleccionados desde la tabla Maestra a la tabla Empleado
        INSERT INTO [GD1C2024_Migrada].dbo.Empleado (empl_nombre, empl_apellido, empl_dni, empl_fecha_registro, empl_telefono, empl_mail, empl_fecha_nacimiento, empl_sucursal)
        SELECT [EMPLEADO_NOMBRE]
              ,[EMPLEADO_APELLIDO]
              ,[EMPLEADO_DNI]
              ,[EMPLEADO_FECHA_REGISTRO]
              ,[EMPLEADO_TELEFONO]
              ,[EMPLEADO_MAIL]
              ,[EMPLEADO_FECHA_NACIMIENTO]
        	  ,sucu_codigo
          FROM [GD1C2024].[gd_esquema].[Maestra]
          INNER JOIN [GD1C2024_Migrada].dbo.Sucursal on [SUCURSAL_NOMBRE] = Sucursal.sucu_nombre
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

    BEGIN
        INSERT INTO [GD1C2024_Migrada].dbo.Cliente (clie_nombre, clie_apellido, clie_dni, clie_fecha_registro, clie_telefono, clie_mail, clie_fecha_nacimiento, clie_domicilio, clie_localidad, clie_provincia)
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

    BEGIN
       INSERT INTO [GD1C2024_Migrada].dbo.Regla (regl_descripcion, regl_descuento_aplicable_producto, regl_cant_aplicable_regla, regl_cant_aplicable_descuento, regl_cant_maxima, regl_misma_marca, regl_mismo_producto)
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

    BEGIN
        INSERT INTO [GD1C2024_Migrada].dbo.Promocion (prom_codigo, prom_regla, prom_descripcion, prom_fecha_inicio, prom_fecha_fin)
        SELECT distinct [PROMO_CODIGO]
        	  ,[GD1C2024_Migrada].dbo.Regla.regl_codigo
              ,[PROMOCION_DESCRIPCION]
              ,[PROMOCION_FECHA_INICIO]
              ,[PROMOCION_FECHA_FIN]
          FROM [GD1C2024].[gd_esquema].[Maestra]
          inner join [GD1C2024_Migrada].dbo.Regla on REGLA_DESCRIPCION = Regla.regl_descripcion
          where promo_codigo is not null
    END;

    /*
    BEGIN
    --          TODO:  INSERT INTO [GD1C2024_Migrada].dbo.Promocion_Producto (prod_codigo, prom_codigo)

    END;

    BEGIN
        INSERT INTO [GD1C2024_Migrada].dbo.Factura (fact_nro, fact_sucursal, fact_caja, fact_vendedor, fact_fecha_hora, fact_tipo, fact_subtotal_productos, fact_total_descuento_aplicado, fact_descuento_aplicado_mp, fact_total_envio, fact_total_ticket)
        SELECT distinct [TICKET_NUMERO] -- fact_nro
        	  ,[GD1C2024_Migrada].dbo.Sucursal.sucu_codigo -- fact_sucursal
        	  ,[CAJA_NUMERO]	-- fact_caja
        	  ,[GD1C2024_Migrada].dbo.Empleado.empl_codigo	-- fact_vendedor
              ,[TICKET_FECHA_HORA] -- fact_fecha_hora
              ,[TICKET_TIPO_COMPROBANTE] -- fact_tipo
              ,[TICKET_SUBTOTAL_PRODUCTOS] -- fact_subtotal_productos
              ,[TICKET_TOTAL_DESCUENTO_APLICADO] -- fact_descuento_aplicado
              ,[TICKET_TOTAL_DESCUENTO_APLICADO_MP] -- fact_descuento_aplicado_mp
              ,[TICKET_TOTAL_ENVIO] -- fact_total_envio
              ,[TICKET_TOTAL_TICKET] -- fact_total_ticket

        	   FROM [GD1C2024].[gd_esquema].[Maestra]
        	   inner join [GD1C2024_Migrada].dbo.Empleado on [EMPLEADO_DNI] = Empleado.empl_dni
        	   inner join [GD1C2024_Migrada].dbo.Sucursal on [SUCURSAL_NOMBRE] = Sucursal.sucu_nombre;
    END;
    BEGIN
    --          TODO:  INSERT INTO [GD1C2024_Migrada].dbo.Item_Factura (item_nro, item_producto, item_promo_aplicada, item_cantidad, item_precio_unitario, item_precio_total, item_descuento_promo)

    END;
    BEGIN
    --          TODO:  INSERT INTO [GD1C2024_Migrada].dbo.Envio (envi_codigo, envi_factura, envi_cliente, envi_fecha_programada, envi_costo, envi_horario_inicio, envi_horario_fin, envi_fecha_entrega, envi_estado)

    END;
    */
    BEGIN
        INSERT INTO [GD1C2024_Migrada].dbo.Medio_Pago (medio_pago_detalle, medio_pago_tipo)
        SELECT distinct [PAGO_MEDIO_PAGO]
              ,[PAGO_TIPO_MEDIO_PAGO]
          FROM [GD1C2024].[gd_esquema].[Maestra]
          where PAGO_MEDIO_PAGO is not null

    END;
/*
    BEGIN
--          TODO:  INSERT INTO [GD1C2024_Migrada].dbo.Descuento (descu_codigo, descu_medio_pago, descu_descripcion, descu_fecha_inicio, descu_fecha_fin, descu_porcentaje_descuento, descu_tope)

    END;
    BEGIN
--          TODO:  INSERT INTO [GD1C2024_Migrada].dbo.Pago (pago_medio_pago, pago_fact_tipo, pago_fact_sucursal, pago_fact_nro, pago_fecha_hora, pago_importe)
-- PAGO_DETALLE
--          TODO:  INSERT INTO [GD1C2024_Migrada].dbo.Detalle_Pago (deta_pago_pago, deta_pago_cliente, deta_pago_tarjeta_nro, deta_pago_tarjeta_cuotas, deta_pago_tarjeta_fecha_vencimiento)

--          TODO:  UPDATE [GD1C2024_Migrada].dbo.Pago (pago_detalle)
-- Fijarse si es necesario hacer nullable la tabla antes y aca sacarselo.
    END;
    BEGIN
--          TODO:  INSERT INTO [GD1C2024_Migrada].dbo.Aplicacion_Descuento (apli_descuento_pago, apli_descuento_codigo_descuento, apli_descuento_monto)

    END;
    */
END;
GO
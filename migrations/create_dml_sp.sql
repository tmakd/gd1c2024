USE GD1C2024_Migrada;
GO

CREATE PROCEDURE GD1C2024_MIGRACION_DML
AS
BEGIN
	-- realizamos la migracion de la tabla Super
    BEGIN
        -- Insertar datos seleccionados desde la tabla Maestra a la tabla Super
        INSERT INTO [GD1C2024_Migrada].dbo.Super (supe_nombre, supe_razon_social, supe_cuit, supe_iibb, supe_domicilio, supe_fecha_inicio_actividad, supe_condicion_fiscal, supe_localidad, supe_provincia)
        SELECT DISTINCT SUPER_NOMBRE, SUPER_RAZON_SOC, CAST(REPLACE(SUPER_CUIT, '-', '') AS DECIMAL(18,0)), SUPER_IIBB, SUPER_DOMICILIO, SUPER_FECHA_INI_ACTIVIDAD, SUPER_CONDICION_FISCAL, SUPER_LOCALIDAD, SUPER_PROVINCIA
        FROM [GD1C2024].gd_esquema.Maestra;
    END;
END;
GO
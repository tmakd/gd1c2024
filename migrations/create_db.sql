USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'GD1C2024_GeDeDe')
BEGIN
    -- Si la base de datos de migracion existe, elimanala. antes hago un alter database para cerrar las conexiones
    ALTER DATABASE GD1C2024_GeDeDe SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE GD1C2024_GeDeDe;
END

-- Crear una base de datos
CREATE DATABASE GD1C2024_GeDeDe;
GO
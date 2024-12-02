-- Création de la BD
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'TestDB')
BEGIN
    CREATE DATABASE TestDB;
END
GO

USE TestDB;
GO

-- Création du Schema
CREATE SCHEMA ecole;
GO

-- Création de la Table
CREATE TABLE ecole.cours (
	sigle INT IDENTITY (1, 1) PRIMARY KEY,
	nom VARCHAR (255) NOT NULL
);
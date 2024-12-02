USE TestDB;

SET NOCOUNT ON;

SET IDENTITY_INSERT ecole.cours ON;  

INSERT INTO ecole.cours(sigle,nom) VALUES(123,'Informatique')
INSERT INTO ecole.cours(sigle,nom) VALUES(456,'Francais')
INSERT INTO ecole.cours(sigle,nom) VALUES(789,'Mathematique')

SET IDENTITY_INSERT ecole.cours OFF;  


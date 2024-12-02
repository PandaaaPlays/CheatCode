USE classicmodels;

DROP PROCEDURE IF EXISTS ps_delete_product;

DELIMITER $$

CREATE PROCEDURE ps_delete_product (
	 IN p_product_code VARCHAR(15)
)
BEGIN

	/*********************************************************************************************************
	Procédure Stockée 'ps_delete_product'
	----------------------------------------------------------------------------------------------------------
	Résumé      :	Suppression d'un produit.
	----------------------------------------------------------------------------------------------------------
	Description :	...
	----------------------------------------------------------------------------------------------------------
	/!\ NOTE /!\:	...
	----------------------------------------------------------------------------------------------------------
	Dépendances	:	...

	*********************************************************************************************************/

	DELETE FROM orderdetails WHERE productCode = p_product_code;
    DELETE FROM products WHERE productCode = p_product_code;  

END;
$$

DELIMITER ; 
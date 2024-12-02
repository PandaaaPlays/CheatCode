USE classicmodels;

DROP PROCEDURE IF EXISTS ps_update_product;

DELIMITER $$

CREATE PROCEDURE ps_update_product (
	 IN p_product_code VARCHAR(15), 
	 IN p_product_name VARCHAR(70),	
	 IN p_product_line VARCHAR(50),
	 IN p_product_scale VARCHAR(10),
	 IN p_product_vendor VARCHAR(50),
	 IN p_product_description TEXT,
	 IN p_quantity_in_stock SMALLINT(6),
	 IN p_buy_price DECIMAL(10, 2),
	 IN p_MSRP DECIMAL(10, 2)
)
BEGIN

	/*********************************************************************************************************
	Procédure Stockée 'ps_update_product'
	----------------------------------------------------------------------------------------------------------
	Résumé      :	Modification d'un produit.
	----------------------------------------------------------------------------------------------------------
	Description :	...
	----------------------------------------------------------------------------------------------------------
	/!\ NOTE /!\:	...
	----------------------------------------------------------------------------------------------------------
	Dépendances	:	...

	*********************************************************************************************************/

	UPDATE products
    SET productName = p_product_name	
	  , productLine = p_product_line
	  , productScale = p_product_scale
	  , productVendor = p_product_vendor
	  , productDescription = p_product_description
	  , quantityInStock = p_quantity_in_stock
	  , buyPrice = p_buy_price
	  , MSRP = p_MSRP
    WHERE productCode = p_product_code;  

END;
$$

DELIMITER ; 
USE classicmodels;

DROP PROCEDURE IF EXISTS ps_add_product;

DELIMITER $$

CREATE PROCEDURE ps_add_product (
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
	Procédure Stockée 'ps_add_product'
	----------------------------------------------------------------------------------------------------------
	Résumé      :	Ajout d'un produit.
	----------------------------------------------------------------------------------------------------------
	Description :	...
	----------------------------------------------------------------------------------------------------------
	/!\ NOTE /!\:	...
	----------------------------------------------------------------------------------------------------------
	Dépendances	:	...

	*********************************************************************************************************/

	INSERT INTO products(
		productCode
	  ,	productName
	  , productLine
	  , productScale
	  , productVendor
	  , productDescription
	  , quantityInStock
	  , buyPrice
	  , MSRP
	) VALUES (
		p_product_code
	  , p_product_name
	  , p_product_line
	  , p_product_scale
	  , p_product_vendor
	  , p_product_description
	  , p_quantity_in_stock
	  , p_buy_price
	  , p_MSRP
	);

END;
$$

DELIMITER ; 
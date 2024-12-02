package ca.usherbrooke.java_mariadb_webapp.Product;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends CrudRepository<Product, String> {

    // Vue de tous les produits.
    @Query(value = "SELECT * FROM vw_products", nativeQuery = true)
    List<Product> getAllProducts();

    // PS pour ajouter un produit.
    @Query(value = "CALL ps_add_product(:productCode, :productName, :productLine, :productScale, :productVendor, " +
            ":productDescription, :quantityInStock, :buyPrice, :MSRP)"
            , nativeQuery = true)
    void addProduct(@Param("productCode") String productCode,
                    @Param("productName") String productName,
                    @Param("productLine") String productLine,
                    @Param("productScale") String productScale,
                    @Param("productVendor") String productVendor,
                    @Param("productDescription") String productDescription,
                    @Param("quantityInStock") Integer quantityInStock,
                    @Param("buyPrice") Double buyPrice,
                    @Param("MSRP") Double MSRP);

    @Query(value = "CALL ps_delete_product(:productCode)", nativeQuery = true)
    void deleteProduct(@Param("productCode") String productCode);

    // PS pour modifier un produit.
    @Query(value =
            "CALL ps_update_product(:productCode, :productName, :productLine, :productScale, :productVendor, " +
                    ":productDescription, :quantityInStock, :buyPrice, :MSRP)"
            , nativeQuery = true)
    void updateProduct(@Param("productCode") String productCode,
                    @Param("productName") String productName,
                    @Param("productLine") String productLine,
                    @Param("productScale") String productScale,
                    @Param("productVendor") String productVendor,
                    @Param("productDescription") String productDescription,
                    @Param("quantityInStock") Integer quantityInStock,
                    @Param("buyPrice") Double buyPrice,
                    @Param("MSRP") Double MSRP);

    Optional<Product> findProductByProductCode(String productCode);
}

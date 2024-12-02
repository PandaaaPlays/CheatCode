package ca.usherbrooke.java_mariadb_webapp.ProductLines;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductLineRepository extends CrudRepository<ProductLine, String> {

    // Vue de toutes les lignes de produits.
    @Query(value = "SELECT * FROM vw_product_lines", nativeQuery = true)
    List<ProductLine> getAllProductLines();
}

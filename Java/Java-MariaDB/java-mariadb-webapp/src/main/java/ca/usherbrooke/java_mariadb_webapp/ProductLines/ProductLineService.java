package ca.usherbrooke.java_mariadb_webapp.ProductLines;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ProductLineService {
    private final ProductLineRepository productLineRepository;

    @Autowired
    public ProductLineService(ProductLineRepository productLineRepository) {
        this.productLineRepository = productLineRepository;
    }

    // Liste de toutes les lignes de produits.
    @Transactional
    public List<ProductLine> getAllProductLines() {
        return productLineRepository.getAllProductLines();
    }
}

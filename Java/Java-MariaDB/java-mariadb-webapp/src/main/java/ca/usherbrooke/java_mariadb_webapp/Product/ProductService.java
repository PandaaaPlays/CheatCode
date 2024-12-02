package ca.usherbrooke.java_mariadb_webapp.Product;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ProductService {
    private final ProductRepository productRepository;

    @Autowired
    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    // Liste de tous les produits.
    @Transactional
    public List<Product> getAllProducts() {
        return productRepository.getAllProducts();
    }

    // Ajout d'un produit (SQL) a partir de l'objet java créé par la page HTML.
    @Transactional
    public void addProduct(Product product) {
        productRepository.addProduct(
                product.getProductCode(),
                product.getProductName(),
                product.getProductLine(),
                product.getProductScale(),
                product.getProductVendor(),
                product.getProductDescription(),
                product.getQuantityInStock(),
                product.getBuyPrice(),
                product.getMSRP()
        );
    }

    // Suppression d'un produit.
    @Transactional
    public void deleteProduct(String productCode) {
        productRepository.deleteProduct(productCode);
    }

    // Récupération d'un produit par son code (création d'un objet java).
    @Transactional
    public Product getProductByCode(String productCode) {
        return productRepository.findProductByProductCode(productCode).orElse(null);
    }

    // Modification d'un produit (SQL) à partir d'un produit java généré par le HTML.
    @Transactional
    public void updateProduct(Product product) {
        productRepository.updateProduct(
                product.getProductCode(),
                product.getProductName(),
                product.getProductLine(),
                product.getProductScale(),
                product.getProductVendor(),
                product.getProductDescription(),
                product.getQuantityInStock(),
                product.getBuyPrice(),
                product.getMSRP()
        );
    }
}

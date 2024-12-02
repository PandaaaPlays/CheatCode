package ca.usherbrooke.java_mariadb_webapp.Product;

import ca.usherbrooke.java_mariadb_webapp.ProductLines.ProductLineService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class ProductController {

    private final ProductService productService;
    private final ProductLineService productLineService;

    @Autowired
    public ProductController(ProductService productService, ProductLineService productLineService) {
        this.productService = productService;
        this.productLineService = productLineService;
    }

    // Menu principal avec les produits.
    @GetMapping("/view")
    public String getView(Model model) {
        model.addAttribute("product", productService.getAllProducts());
        return "main";
    }

    // Formulaire d'ajout de produit.
    @GetMapping("/add-form")
    public String showProductForm(Model model) {
        model.addAttribute("product", new Product());
        model.addAttribute("productLines", productLineService.getAllProductLines());
        return "add";
    }

    // Ajout d'un produit.
    @PostMapping("/add")
    public String addProduct(Product product) {
        productService.addProduct(product);
        return "redirect:/view";
    }

    // Suppression d'un produit.
    @PostMapping("/delete/{productCode}")
    public String deleteProduct(@PathVariable String productCode) {
        productService.deleteProduct(productCode);
        return "redirect:/view";
    }

    // Formulaire de modification d'un produit.
    @GetMapping("/edit-form/{productCode}")
    public String showEditForm(@PathVariable String productCode, Model model) {
        Product product = productService.getProductByCode(productCode);
        model.addAttribute("product", product);
        model.addAttribute("productLines", productLineService.getAllProductLines());
        return "edit";
    }

    // Modification d'un produit.
    @PostMapping("/edit")
    public String editProduct(Product product) {
        productService.updateProduct(product);
        return "redirect:/view";
    }
}

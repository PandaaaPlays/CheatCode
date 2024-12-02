package ca.usherbrooke.java_mariadb_webapp.ProductLines;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "productlines", schema = "classicmodels")
public class ProductLine {

    @Id
    @Column(name = "productLine")
    private String productLine;

    public String getProductLine() {
        return productLine;
    }

    public void setProductLine(String productLine) {
        this.productLine = productLine;
    }

}

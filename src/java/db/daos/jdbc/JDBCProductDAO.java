package db.daos.jdbc;

import db.daos.ProductDAO;
import db.entities.Product;
import db.exceptions.DAOException;
import db.exceptions.UniqueConstraintException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * The JDBC implementation of the {@link ProductDAO} interface.
 */
public class JDBCProductDAO extends JDBCDAO<Product, Integer> implements ProductDAO {

    /**
     * The default constructor of the class.
     *
     * @param con the connection to the persistence system.
     */
    public JDBCProductDAO(Connection con) {
        super(con);
    }

    /**
     * Persists the new {@code Product} passed as parameter to the storage
     * system.
     *
     * @param product the new {@code product} to persist.
     * @return the id of the new persisted record.
     * @throws DAOException if an error occurred during the persist action.
     */
    @Override
    public Integer insert(Product product) throws DAOException {
        if (product == null) {
            throw new DAOException("product is not valid", new NullPointerException("product is null"));
        }
        try (PreparedStatement ps = CON.prepareStatement("INSERT INTO products (name, notes, logo, photo, product_category, owner) VALUES (?,?,?,?,?,?)", Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, product.getName());
            ps.setString(2, product.getNotes());
            ps.setString(3, product.getLogoPath());
            ps.setString(4, product.getPhotoPath());
            ps.setInt(5, product.getProductCategoryId());
            ps.setInt(6, product.getOwnerId());

            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) {
                product.setId(rs.getInt(1));
            }

            return product.getId();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to insert the new product", ex);
        }
    }

    /**
     * Persists the alredy existing {@code Product} passed as parameter to the
     * storage system.
     *
     * @param product the {@code product} to persist.
     * @throws DAOException if an error occurred during the persist action.
     */
    @Override
    public void update(Product product) throws DAOException {
        if (product == null) {
            throw new DAOException("product is not valid", new NullPointerException("product is null"));
        }

        Integer productId = product.getId();
        if (productId == null) {
            throw new DAOException("product is not valid", new NullPointerException("product id is null"));
        }

        try (PreparedStatement ps = CON.prepareStatement("UPDATE products SET name = ?, notes = ?, logo = ?, photo = ?, productCategory = ?, owner = ? WHERE id = ?")) {

            ps.setString(1, product.getName());
            ps.setString(2, product.getNotes());
            ps.setString(3, product.getLogoPath());
            ps.setString(4, product.getPhotoPath());
            ps.setInt(5, product.getProductCategoryId());
            ps.setInt(6, product.getOwnerId());
            ps.setInt(7, product.getId());

            ps.executeUpdate();

        } catch (SQLException ex) {
            throw new DAOException("Impossible to update the product", ex);
        }
    }

    /**
     * Delete the alredy existing {@code Product} passed as parameter from the
     * storage system.
     *
     * @param primaryKey the primaryKey of the {@code product} to delete.
     * @throws DAOException if an error occurred during the delting action.
     */
    @Override
    public void delete(Integer primaryKey) throws DAOException {
        if (primaryKey == null) {
            throw new DAOException("primaryKey is not valid", new NullPointerException("primaryKey is null"));
        }
        try (PreparedStatement stm = CON.prepareStatement("DELETE FROM products WHERE id = ?")) {
            stm.setInt(1, primaryKey);
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to delete the product", ex);
        }
    }

    /**
     * Returns the number of {@link Product product} stored on the persistence
     * system of the application.
     *
     * @return the number of records present into the storage system.
     * @throws DAOException if an error occurred during the information
     * retrieving.
     */
    @Override
    public Long getCount() throws DAOException {
        try (Statement stmt = CON.createStatement()) {
            ResultSet counter = stmt.executeQuery("SELECT COUNT(*) FROM products");
            if (counter.next()) {
                return counter.getLong(1);
            }

        } catch (SQLException ex) {
            throw new DAOException("Impossible to count products", ex);
        }

        return 0L;
    }

    /**
     * Returns the {@link Product product} with the primary key equals to the
     * one passed as parameter.
     *
     * @param primaryKey the {@code id} of the {@code product} to get.
     * @return the {@code product} with the id equals to the one passed as
     * parameter.
     * @throws DAOException if an error occurred during the information
     * retrieving.
     */
    @Override
    public Product getByPrimaryKey(Integer primaryKey) throws DAOException {
        if (primaryKey == null) {
            throw new DAOException("primaryKey is not valid", new NullPointerException("primaryKey is null"));
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM products WHERE id = ?")) {
            stm.setInt(1, primaryKey);
            ResultSet rs = stm.executeQuery();

            rs.next();
            return setAllProductFields(rs);

        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the product for the passed primary key", ex);
        }
    }

    /**
     * Returns the list of all the valid {@link Product product} stored by the
     * storage system.
     *
     * @return the list of all the valid {@code product}.
     * @throws DAOException if an error occurred during the information
     * retrieving.
     */
    @Override
    public List<Product> getAll() throws DAOException {
        try (Statement stm = CON.createStatement()) {

            List<Product> products = new ArrayList<>();
            ResultSet rs = stm.executeQuery("SELECT * FROM products ORDER BY name");

            while (rs.next()) {
                products.add(setAllProductFields(rs));
            }

            return products;

        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the list of products", ex);
        }
    }

    @Override
    public List<Product> getByShoppingListCategory(Integer shoppingListCategoryId, Integer userId) throws DAOException {
        if (shoppingListCategoryId == null || userId == null) {
            throw new DAOException("shoppingListCategoryId and userId are mandatory fields", new NullPointerException("shoppingListCategoryId or userId is null"));
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM products, users_products, PC_LC"
                + "WHERE products.product_category = PC_LC.product_category"
                + "AND PC_LC.list_category = ?"
                + "AND (product.owner IS NULL"
                + "OR (product.id = users_products.product"
                + "AND users_product.user = ?))")) {

            List<Product> products = new ArrayList<>();

            stm.setInt(1, shoppingListCategoryId);
            stm.setInt(2, userId);
            ResultSet rs = stm.executeQuery();

            while (rs.next()) {
                products.add(setAllProductFields(rs));
            }

            return products;

        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the list of products for the passed shoppingListCategoryId and userId", ex);
        }
    }

    @Override
    public List<Product> searchByName(String query, Integer shoppingListCategoryId, Integer userId) throws DAOException {
        if (shoppingListCategoryId == null || userId == null) {
            throw new DAOException("shoppingListCategoryId and userId are mandatory fields", new NullPointerException("shoppingListCategoryId or userId is null"));
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM products, users_products, PC_LC"
                + "WHERE products.product_category = PC_LC.product_category"
                + "AND PC_LC.list_category = ?"
                + "AND (product.owner IS NULL"
                + "OR (product.id = users_products.product"
                + "AND users_product.user = ?))"
                + "AND product.name LIKE ?")) {

            List<Product> products = new ArrayList<>();

            stm.setInt(1, shoppingListCategoryId);
            stm.setInt(2, userId);
            stm.setString(3, "%" + query + "%");
            ResultSet rs = stm.executeQuery();

            while (rs.next()) {
                products.add(setAllProductFields(rs));
            }

            return products;

        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the list of products for the passed query, shoppingListCategoryId and userId", ex);
        }
    }

    @Override
    public void addLinkWithUser(Integer productId, Integer userId) throws DAOException {
        if ((productId == null) || (userId == null)) {
            throw new DAOException("productId and userId are mandatory fields", new NullPointerException("productId or userId are null"));
        }
        try (PreparedStatement ps = CON.prepareStatement("INSERT INTO users_products (user, product) VALUES (?, ?)")) {

            ps.setInt(1, userId);
            ps.setInt(2, productId);

            ps.executeUpdate();

        } catch (SQLException ex) {
            if (ex.getSQLState().equals("23505")) {
                throw new DAOException("Impossible to link the passed product with the passed user", new UniqueConstraintException("This link already exist in the system"));
            }
            throw new DAOException("Impossible to link the passed product with the passed user", ex);
        }
    }

    @Override
    public void removeLinkWithUser(Integer productId, Integer userId) throws DAOException {
        if ((productId == null) || (userId == null)) {
            throw new DAOException("productId and userId are mandatory fields", new NullPointerException("productId or userId are null"));
        }
        try (PreparedStatement stm = CON.prepareStatement("DELETE FROM users_products WHERE (user = ? AND product = ?)")) {
            stm.setInt(1, userId);
            stm.setInt(1, productId);
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to delete the link between the passed product and the passed user", ex);
        }
    }

    /**
     * Convinience method for setting all the fileds of a {@code product} after
     * retriving it from the storage system.
     *
     * @param rs the {@link ResultSet} of the query that retrives the
     * {@code product}
     * @return the new {@code product}
     * @throws SQLException if an error occurred during the information
     * retriving
     */
    private Product setAllProductFields(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setId(rs.getInt("id"));
        product.setName(rs.getString("name"));
        product.setNotes(rs.getString("notes"));
        product.setLogoPath(rs.getString("logo"));
        product.setPhotoPath(rs.getString("photo"));
        product.setProductCategoryId(rs.getInt("product_category"));
        product.setOwnerId(rs.getInt("owner"));

        return product;
    }

}
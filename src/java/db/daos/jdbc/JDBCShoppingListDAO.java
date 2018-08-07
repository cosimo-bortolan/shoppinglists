package db.daos.jdbc;

import db.daos.ShoppingListDAO;
import db.entities.ShoppingList;
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
 * The JDBC implementation of the {@link ShoppingListDAO} interface.
 */
public class JDBCShoppingListDAO extends JDBCDAO<ShoppingList, Integer> implements ShoppingListDAO {

    /**
     * The default constructor of the class.
     *
     * @param con the connection to the persistence system.
     */
    public JDBCShoppingListDAO(Connection con) {
        super(con);
    }

    /**
     * Persists the new {@code ShoppingList} passed as parameter to the storage
     * system.
     *
     * @param shoppingList the new {@code shoppingList} to persist.
     * @return the id of the new persisted record.
     * @throws DAOException if an error occurred during the persist action.
     */
    @Override
    public Integer insert(ShoppingList shoppingList) throws DAOException {
        if (shoppingList == null) {
            throw new DAOException("shoppingList is not valid", new NullPointerException("shoppingList is null"));
        }
        try (PreparedStatement ps = CON.prepareStatement("INSERT INTO lists (name, description, logo, list_category, owner) VALUES (?,?,?,?,?)", Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, shoppingList.getName());
            ps.setString(2, shoppingList.getDescription());
            ps.setString(3, shoppingList.getLogoPath());
            ps.setInt(4, shoppingList.getListCategoryId());
            ps.setInt(5, shoppingList.getOwnerId());

            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) {
                shoppingList.setId(rs.getInt(1));
            }

            return shoppingList.getId();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to insert the new shoppingList", ex);
        }
    }

    /**
     * Persists the alredy existing {@code ShoppingList} passed as parameter to
     * the storage system.
     *
     * @param shoppingList the {@code shoppingList} to persist.
     * @throws DAOException if an error occurred during the persist action.
     */
    @Override
    public void update(ShoppingList shoppingList) throws DAOException {
        if (shoppingList == null) {
            throw new DAOException("shoppingList is not valid", new NullPointerException("shoppingList is null"));
        }

        Integer shoppingListId = shoppingList.getId();
        if (shoppingListId == null) {
            throw new DAOException("shoppingList is not valid", new NullPointerException("shoppingList id is null"));
        }

        try (PreparedStatement ps = CON.prepareStatement("UPDATE lists SET name = ?, description = ?, logo = ?, listCategory = ?, owner = ? WHERE id = ?")) {

            ps.setString(1, shoppingList.getName());
            ps.setString(2, shoppingList.getDescription());
            ps.setString(3, shoppingList.getLogoPath());
            ps.setInt(4, shoppingList.getListCategoryId());
            ps.setInt(5, shoppingList.getOwnerId());
            ps.setInt(6, shoppingListId);

            ps.executeUpdate();

        } catch (SQLException ex) {
            throw new DAOException("Impossible to update the shoppingList", ex);
        }
    }

    /**
     * Delete the alredy existing {@code ShoppingList} passed as parameter from
     * the storage system.
     *
     * @param primaryKey the primaryKey of the {@code shoppingList} to delete.
     * @throws DAOException if an error occurred during the delting action.
     */
    @Override
    public void delete(Integer primaryKey) throws DAOException {
        if (primaryKey == null) {
            throw new DAOException("primaryKey is not valid", new NullPointerException("primaryKey is null"));
        }
        try (PreparedStatement stm = CON.prepareStatement("DELETE FROM lists WHERE id = ?")) {
            stm.setInt(1, primaryKey);
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to delete the shoppingList", ex);
        }
    }

    /**
     * Returns the number of {@link ShoppingList shoppingList} stored on the
     * persistence system of the application.
     *
     * @return the number of records present into the storage system.
     * @throws DAOException if an error occurred during the information
     * retrieving.
     */
    @Override
    public Long getCount() throws DAOException {
        try (Statement stmt = CON.createStatement()) {
            ResultSet counter = stmt.executeQuery("SELECT COUNT(*) FROM lists");
            if (counter.next()) {
                return counter.getLong(1);
            }

        } catch (SQLException ex) {
            throw new DAOException("Impossible to count shoppingLists", ex);
        }

        return 0L;
    }

    /**
     * Returns the {@link ShoppingList shoppingList} with the primary key equals
     * to the one passed as parameter.
     *
     * @param primaryKey the {@code id} of the {@code shoppingList} to get.
     * @return the {@code shoppingList} with the id equals to the one passed as
     * parameter.
     * @throws DAOException if an error occurred during the information
     * retrieving.
     */
    @Override
    public ShoppingList getByPrimaryKey(Integer primaryKey) throws DAOException {
        if (primaryKey == null) {
            throw new DAOException("primaryKey is not valid", new NullPointerException("primaryKey is null"));
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM lists WHERE id = ?")) {
            stm.setInt(1, primaryKey);
            ResultSet rs = stm.executeQuery();

            rs.next();
            return setAllShoppingListFields(rs);

        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the shoppingList for the passed primary key", ex);
        }
    }

    /**
     * Returns the list of all the valid {@link ShoppingList shoppingList}
     * stored by the storage system.
     *
     * @return the list of all the valid {@code shoppingList}.
     * @throws DAOException if an error occurred during the information
     * retrieving.
     */
    @Override
    public List<ShoppingList> getAll() throws DAOException {
        try (Statement stm = CON.createStatement()) {

            List<ShoppingList> shoppingLists = new ArrayList<>();
            ResultSet rs = stm.executeQuery("SELECT * FROM lists ORDER BY name");

            while (rs.next()) {
                shoppingLists.add(setAllShoppingListFields(rs));
            }

            return shoppingLists;

        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the list of shoppingLists", ex);
        }
    }

    @Override
    public List<ShoppingList> getByUserId(Integer userId) throws DAOException {
        if (userId == null) {
            throw new DAOException("userId is a mandatory field", new NullPointerException("userId is null"));
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM lists, users_lists WHERE (id = list AND user = ?) ORDER BY name")) {

            List<ShoppingList> shoppingLists = new ArrayList<>();

            stm.setInt(1, userId);
            ResultSet rs = stm.executeQuery();

            while (rs.next()) {
                shoppingLists.add(setAllShoppingListFields(rs));
            }

            return shoppingLists;

        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the list of shoppingLists for the passed userId", ex);
        }
    }

    @Override
    public void addLinkWithUser(Integer shoppingListId, Integer userId, int permissions, boolean notifications) throws DAOException {
        if ((shoppingListId == null) || (userId == null)) {
            throw new DAOException("shoppingListId and userId are mandatory fields", new NullPointerException("shoppingListId or userId are null"));
        }
        try (PreparedStatement ps = CON.prepareStatement("INSERT INTO users_lists (user, list, permissions, notifications) VALUES (?, ?, ?, ?)")) {

            ps.setInt(1, userId);
            ps.setInt(2, shoppingListId);
            ps.setInt(3, permissions);
            ps.setBoolean(4, notifications);

            ps.executeUpdate();

        } catch (SQLException ex) {
            if (ex.getSQLState().equals("23505")) {
                throw new DAOException("Impossible to link the passed shoppingList with the passed user", new UniqueConstraintException("This link already exist in the system"));
            }
            throw new DAOException("Impossible to link the passed shoppingList with the passed user", ex);
        }
    }

    @Override
    public void removeLinkWithUser(Integer shoppingListId, Integer userId) throws DAOException {
        if ((shoppingListId == null) || (userId == null)) {
            throw new DAOException("shoppingListId and userId are mandatory fields", new NullPointerException("shoppingListId or userId are null"));
        }
        try (PreparedStatement stm = CON.prepareStatement("DELETE FROM users_lists WHERE (user = ? AND list = ?)")) {
            stm.setInt(1, userId);
            stm.setInt(1, shoppingListId);
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to delete the link between the passed shoppingList and the passed user", ex);
        }
    }

    @Override
    public void updateLinkWithUser(Integer shoppingListId, Integer userId, int permissions, boolean notifications) throws DAOException {
        if ((shoppingListId == null) || (userId == null)) {
            throw new DAOException("shoppingListId and userId are mandatory fields", new NullPointerException("shoppingListId or userId are null"));
        }
        try (PreparedStatement ps = CON.prepareStatement("UPDATE users_lists SET permissions = ?, notifications = ? WHERE user = ? AND list = ?")) {

            ps.setInt(1, permissions);
            ps.setBoolean(2, notifications);
            ps.setInt(3, userId);
            ps.setInt(4, shoppingListId);

            ps.executeUpdate();

        } catch (SQLException ex) {
            throw new DAOException("Impossible to update the link between the passed shoppingList and the passed user", ex);
        }
    }

    @Override
    public void addProduct(Integer shoppingListId, Integer productId, int quantity, boolean necessary) throws DAOException {
        if ((shoppingListId == null) || (productId == null)) {
            throw new DAOException("shoppingListId and productId are mandatory fields", new NullPointerException("shoppingListId or productId are null"));
        }
        try (PreparedStatement ps = CON.prepareStatement("INSERT INTO lists_products (list, productId, quantity, necessary) VALUES (?, ?, ?, ?)")) {

            ps.setInt(1, shoppingListId);
            ps.setInt(2, productId);
            ps.setInt(3, quantity);
            ps.setBoolean(4, necessary);

            ps.executeUpdate();

        } catch (SQLException ex) {
            if (ex.getSQLState().equals("23505")) {
                throw new DAOException("Impossible to link the passed shoppingList with the passed product", new UniqueConstraintException("This link already exist in the system"));
            }
            throw new DAOException("Impossible to link the passed shoppingList with the passed product", ex);
        }
    }

    @Override
    public void removeProduct(Integer shoppingListId, Integer productId) throws DAOException {
        if ((shoppingListId == null) || (productId == null)) {
            throw new DAOException("shoppingListId and productId are mandatory fields", new NullPointerException("shoppingListId or productId are null"));
        }
        try (PreparedStatement stm = CON.prepareStatement("DELETE FROM lists_products WHERE (list = ? AND product = ?)")) {
            stm.setInt(1, shoppingListId);
            stm.setInt(1, productId);
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to delete the link between the passed shoppingList and the passed product", ex);
        }
    }

    @Override
    public void updateProduct(Integer shoppingListId, Integer productId, int quantity, boolean necessary) throws DAOException {
        if ((shoppingListId == null) || (productId == null)) {
            throw new DAOException("shoppingListId and productId are mandatory fields", new NullPointerException("shoppingListId or productId are null"));
        }
        try (PreparedStatement ps = CON.prepareStatement("UPDATE lists_products SET quantity = ?, necessary = ? WHERE list = ? AND product = ?")) {

            ps.setInt(1, quantity);
            ps.setBoolean(2, necessary);
            ps.setInt(3, shoppingListId);
            ps.setInt(4, productId);

            ps.executeUpdate();

        } catch (SQLException ex) {
            throw new DAOException("Impossible to update the link between the passed shoppingList and the passed product", ex);
        }
    }

    /**
     * Convinience method for setting all the fileds of a {@code shoppingList}
     * after retriving it from the storage system.
     *
     * @param rs the {@link ResultSet} of the query that retrives the
     * {@code shoppingList}
     * @return the new {@code shoppingList}
     * @throws SQLException if an error occurred during the information
     * retriving
     */
    private ShoppingList setAllShoppingListFields(ResultSet rs) throws SQLException {
        ShoppingList shoppingList = new ShoppingList();
        shoppingList.setId(rs.getInt("id"));
        shoppingList.setName(rs.getString("name"));
        shoppingList.setDescription(rs.getString("description"));
        shoppingList.setLogoPath(rs.getString("logo"));
        shoppingList.setListCategoryId(rs.getInt("list_category"));
        shoppingList.setOwnerId(rs.getInt("owner"));

        return shoppingList;
    }

}
import java.sql.*;

public class Assignment2 {
    
    // A connection to the database  
    Connection connection;
    // Statement to run queries
    Statement sql;
    // Prepared Statement
    PreparedStatement ps;
    // Resultset for the query
    ResultSet rs;
  
    //CONSTRUCTOR
    Assignment2(){
    }
  
    //Using the input parameters, establish a connection to be used for this session. Returns true if connection is sucessful
    public boolean connectDB(String URL, String username, String password){
        // Try loading the drivers
        try{
            Class.forName(("org.postgresql.Driver"));
        }catch (ClassNotFoundException e){
            return false
        }
        // Try connecting to the database
        try{
            connection = DriverManager.getConnection(URL, uername, password);
        }catch (Exception e){
            return false;
        }
        // Return true if we created the connection
        return true;
    }
  
    //Closes the connection. Returns true if closure was sucessful
    public boolean disconnectDB(){
        // Try to close the connection
        try{
            connection.close();
        }catch(Exception e){
            return false;
        }
        // Return true if successful
        return true;
    }
    
    public boolean insertPlayer(int pid, String pname, int globalRank, int cid) {
        // Try to insert
        try{
            // Create query
            ps = connection.prepareStatement("INSERT INTO player VALUES(?, ?, ?, ?)");
            // Fill in the values with passed in values
            ps.setInt(1, pid);
            ps.setString(2, pname);
            ps.setInt(3, globalRank);
            ps.setInt(4, cid);
            // Execute the insert
            ps.executeUpdate()
        }catch(Exception e){
            return false;
        }
        // Return true if no errors are thrown
        return true;
    }
  
    public int getChampions(int pid) {
        // Create the query
        sql = "SELECT COUNT(pid) FROM champion WHERE pid = ?";
        ps = connection.prepareStatement(sql);
        // Insert the pid that user wants
        ps.setInt(1, pid);
        // Execute the query
        rs = ps.executeQuery();
        // Return the number of championships the player has won
        while (rs.next()) {
            return (rs.getInt("count"));
        }

        return 0;
    }
   
    public String getCourtInfo(int courtid){
        // Var to hold the return
        String courtinfo = "";
        try{
            // Create the query
            sql = "SELECT courtid, courtname, capacity, tname " +
                    "FROM court, tournament " +
                    "WHERE court.tid = tournament.tid " +
                    "AND courtid = ?";
            ps = connection.prepareStatement(sql);
            // Insert the court id
            ps.setInt(1, courtid);
            rs = ps.executeQuery();
            // Get the results
            while (rs.next()){
                courtinfo = rs.getInt("courtid") + ":" + rs.getString("courtname") + ":"
                        + rs.getInt("capacity") + ":" + rs.getString("tname");
            }
            // Return result info
            return courtinfo;
        }catch (Exception e){
            return courtinfo;
        }
    }

    public boolean chgRecord(int pid, int year, int wins, int losses){
        try{
            // Create the query
            ps = connection.prepareStatement("UPDATE record SET wins = ?, losses = ? WHERE pid = ? and year = ?");
            // Insert all the values that we need
            ps.setInt(1, pid);
            ps.setInt(2, year);
            ps.setInt(3, wins);
            ps.setInt(4, losses);
            // Execute the update
            ps.executeUpdate();
            return true;
        }catch (Exception e){
            return false;
        }
    }

    public boolean deleteMatcBetween(int p1id, int p2id){
        try{
            // Create the query
            ps = connection.prepareStatement("DELETE FROM event WHERE winid = ? and lossid = ?");
            // Insert values
            ps.setInt(1, p1id);
            ps.setInt(2, p2id);
            // Execute the update
            ps.executeUpdate();
            return true;
        }catch(Exception e){
            return false;
        }
    }
  
    public String listPlayerRanking(){
        try{
            // Var to hold the return
            String result= "";
            // Create the query
            sql = "SELECT pname, globalrank FROM player ORDER BY globalrank";
            ps = connection.prepareStatement(sql);
            // Execute the query
            rs = ps.executeQuery();
            // Create the return string
            while(rs.next()){
                result += rs.getString("pname") + ":" + rs.getInt("globalrank") + "\n";
            }
            // Return the result
            return result;
        }catch (Exception e){
            return result;
        }
    }
  
    public int findTriCircle(){
        // Create the query
        sql = "SELECT COUNT(*) FROM " +
                "(SELECT DISTINCT e1.winid, e1.lossid, e2.winid, e2.lossid " +
                "FROM event e1, event e2 WHERE e1.lossid = e2.winid and e2.lossid = e1.winid)" +
                " AS results";
        ps = connection.prepareStatement(sql);
        // Execute the query
        rs = ps.executeQuery();
        while (rs.next()) {
            return((rs.getInt("count")/2));
        }
    }
    
    public boolean updateDB(){
        try{
            // Create the table
            sql = "CREATE TABLE IF NOT EXISTS championPlayers (pid INTEGER, pname VARCHAR, nchampions INTEGER)";
            ps = connection.prepareStatement(sql);
            // Execute the query
            rs = ps.executeQuery();

            // Get the data
            sql = "SELECT player.pid, pname, COUNT(player.pid) " +
                    "FROM champion, player WHERE champion.pid = player.pid " +
                    "GROUP BY player.pid, pname ORDER BY player.pid";
            ps = connection.prepareStatement(sql);
            // Execute the query
            rs = ps.executeQuery();

            // Run a loop and populate the table
            while (rs.next()){
                // Create the query
                ps = connection.prepareStatement("INSERT INTO championPlayers VALUES (?, ?, ?)");
                // Insert values
                ps.setInt(1, rs.getInt("pid"));
                ps.setString(2, rs.getString("pname"));
                ps.setInt(3, rs.getInt("count"));
                // Execute the update
                ps.executeUpdate();
            }
            return true;
        }catch (Exception e){
            return false;
        }
    }


}
<?php



// Database connection details
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "uwbdatabase";

// Create connection to the database
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Check the request method

 if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    // Handle GET request to fetch the latest coordinates
    $sql = "SELECT coordinateX, coordinateY FROM trackingdata WHERE timestamp >= (SELECT MAX(timestamp) AS latest_timestamp FROM trackingdata) - INTERVAL 2 MINUTE ORDER BY id DESC;";
    $result = $conn->query($sql);

    // Check if any results were returned
    if ($result->num_rows > 0) {
        // Fetch the latest coordinates
        $rows = $result->fetch_all();
        // echo $result->num_rows;
        
        // exit();

        header("Content-type: application/json");
        echo json_encode($rows);
        // echo json_encode(['x' => $row['coordinateX'], 'y' => $row['coordinateY']]);
    } else {
        // Return default coordinates if no data is found
        echo json_encode(['x' => 0, 'y' => 0]);
    }
}



// Close the database connection
$conn->close();

?>




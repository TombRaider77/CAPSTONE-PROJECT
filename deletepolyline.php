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

 if ($_SERVER['REQUEST_METHOD'] == 'DELETE') {
    // Handle GET request to fetch the latest coordinates
    $sql = "DELETE FROM trackingdata WHERE timestamp < NOW() - INTERVAL 5 MINUTE";
    $result = $conn->query($sql);

    if ($conn->query($sql) === TRUE) {
        echo json_encode(["message" => "Old entries deleted successfully."]);
    } else {
        echo json_encode(["error" => "Error deleting entries: " . $conn->error]);
    }
} else {
    echo json_encode(["error" => "Invalid request method."]);
}

// Close the database connection
$conn->close();






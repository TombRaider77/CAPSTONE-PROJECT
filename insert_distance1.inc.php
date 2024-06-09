<?php
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
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Handle POST request to insert data
    if (isset($_POST["distance1"]) && isset($_POST["distance2"]) && isset($_POST["distance3"]) && isset($_POST["coordinateX"]) && isset($_POST["coordinateY"])) {
        // Retrieve the POST data
        $distance1 = $_POST["distance1"];
        $distance2 = $_POST["distance2"];
        $distance3 = $_POST["distance3"];
        $coordinateX = $_POST["coordinateX"];
        $coordinateY = $_POST["coordinateY"];

        // Prepare the SQL statement to insert data into the database
        $stmt = $conn->prepare("INSERT INTO Trackingdata (distance1, distance2, distance3, coordinateX, coordinateY) VALUES (?, ?, ?, ?, ?)");
        $stmt->bind_param("ddddd", $distance1, $distance2, $distance3, $coordinateX, $coordinateY);

        // Execute the prepared statement
        if ($stmt->execute()) {
            echo "New record created successfully";
        } else {
            echo "Error: " . $stmt->error;
        }

        // Close the statement
        $stmt->close();
    }
} elseif ($_SERVER['REQUEST_METHOD'] == 'GET') {
    // Handle GET request to fetch the latest data
    $sql = "SELECT coordinateX, coordinateY, distance1, distance2, distance3 FROM Trackingdata ORDER BY timestamp DESC LIMIT 1";
    $result = $conn->query($sql);

    // Check if any results were returned
    if ($result->num_rows > 0) {
        // Fetch the latest data
        $row = $result->fetch_assoc();
        header("Content-type: application/json");
        echo json_encode([
            'x' => $row['coordinateX'],
            'y' => $row['coordinateY'],
            'distance1' => $row['distance1'],
            'distance2' => $row['distance2'],
            'distance3' => $row['distance3']
        ]);
    } else {
        // Return default values if no data is found
        echo json_encode(['x' => 0, 'y' => 0, 'distance1' => 0, 'distance2' => 0, 'distance3' => 0]);
    }
}

// Close the database connection
$conn->close();
?>

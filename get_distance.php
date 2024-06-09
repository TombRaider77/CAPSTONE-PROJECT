<?php
header('Content-Type: application/json');

$servername = "localhost";
$username = "root"; // Your DB username
$password = "";     // Your DB password
$dbname = "uwbdatabase";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Query to get the latest distance data
$result = $conn->query("SELECT Distance, created_at FROM distancedata ORDER BY created_at DESC LIMIT 1");

// Fetch the data
$data = $result->fetch_assoc();

// Echo data as JSON
echo json_encode($data);

$conn->close();


<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "myDB";

// Create connection
$conn = mysqli_connect($servername, $username, $password, $dbname);

// Check connection
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}
{
echo "Connected successfully";

$name2 = $_POST['name1'];
$email2 = $_POST['description'];

$sql = "INSERT INTO cm_manage_roles (name, description)
VALUES ('".$_POST["name1"]."', '".$_POST["description1"]."')";

if (mysqli_query($conn, $sql)) {
    echo "New record created successfully";
} else {
    echo "Error: " . $sql . "<br>" . mysqli_error($conn);
}

}
?>
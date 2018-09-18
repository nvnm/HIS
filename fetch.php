<?php
 define('HOST','localhost');
 define('USERNAME', 'root');
 define('PASSWORD','');
 define('DB','myDB');
 
 $con = mysqli_connect(HOST,USERNAME,PASSWORD,DB);
 
 
 
 $sql = "select updated_at, name, description from CM_Manage_Roles";
 
 $res = mysqli_query($con,$sql);
 
 $result = array();
 
 while($row = mysqli_fetch_array($res)){
 array_push($result, array('updated_at'=>$row[0], 'name'=>$row[1], 'description'=>$row[2]));
 }
 
 echo json_encode(array('result'=>$result));
 
 mysqli_close($con);
?>
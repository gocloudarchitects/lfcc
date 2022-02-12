<style>
body {font-family: monospace;}
div {display: inline-block; min-width: 4em;}
</style>
<?php
$mysqli = new mysqli("db","root","root","lamp");

if ($mysqli -> connect_errno) {
  echo "Failed to connect to MySQL: " . $mysqli -> connect_error;
  exit();
}

$sql = "SELECT id,message FROM data";
if ($result = $mysqli -> query($sql)) {
  while ($row = $result -> fetch_row()) {
	  printf ("<div>[%s]</div>%s<br/>", $row[0], $row[1]);
  }
  $result -> free_result();
}
$mysqli -> close();
?>
</body>

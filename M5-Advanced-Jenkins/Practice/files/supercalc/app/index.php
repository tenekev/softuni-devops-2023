<html>
  <head>
    <meta charset="UTF-8"/>
    <title>Super Calculator</title>
  </head>
  <body>
    <h3>Super Calculator</h3>
    <form action="index.php" method="post">
      <label for="opa">Operand A</label><br />
      <input id="opa" name="opa" type="text" /><br />
      <label for="opr">Operator</label><br />
      <select id="opr" name="opr">
        <option value="add">+</option>
        <option value="sub">-</option>
      </select><br />
      <label for="opb">Operand B</label><br />
      <input id="opb" name="opb" type="text" /><br /><br />
      <input id="submit" type="submit" value="Calculate" />
    </form>
<?php
if (!empty($_POST))
{
    $opa = $_POST['opa'];
    $opb = $_POST['opb'];
    $opr = $_POST['opr'];

    if ($opr == 'add') { print "$opa + $opb = "; print intval($opa)+intval($opb); }
    if ($opr == 'sub') { print "$opa - $opb = "; print intval($opa)+intval($opb); }
}
?>
  </body>
</html>
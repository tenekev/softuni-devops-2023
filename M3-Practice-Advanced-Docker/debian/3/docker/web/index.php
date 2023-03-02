<html>
  <head>
    <meta charset="UTF-8"/>
    <title>Данни за Кръвната захар на Българите</title>

    <style>
      body {
          background: url(background.jpg);
          font-family: sans-serif;
      }
      p {
          max-width: 700px;
          text-align: left;
      }
      small {
        background: #ffff;
      }
      .styled-table {
          border-collapse: collapse;
          margin: 25px 0;
          font-size: 0.9em;
          min-width: 400px;
          box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
          border-radius: .5rem;
          overflow: hidden;
      }
      .styled-table thead tr {
          background-color: #4f52ff;
          color: #ffffff;
          text-align: left;
      }
      .styled-table th,
      .styled-table td {
          padding: 12px 20px;
      }
      .styled-table tbody tr {
          border-bottom: 1px solid #dddddd;
      }

      .styled-table tbody tr:nth-of-type(even) {
          background-color: #f3f3f3;
      }
      .styled-table tbody tr:nth-of-type(odd) {
          background-color: #ffffff;
      }

      .styled-table tbody tr:last-of-type {
          border-bottom: 2px solid #4f52ff;
      }
      .styled-table tbody tr td:nth-of-type(3) {
          text-align: center;
      }
      .styled-table tbody tr td:nth-of-type(6) {
          font-weight: 600;
          text-align: center;
          font-size: 1.1rem;
      }
      .info {
        background: #ffffff;
        padding: 10px 20px;
        max-width: 700px;
        border-radius: .5rem;
        border: 2px solid #7e96f2;
      }
    </style>

  </head>
  <body>
    <div align="center">
      
      <?php 
        print "<small>Processed by <b>".gethostname()."</b> on ".date('Y-m-d-H-i-s')."</small><br /><br /><br />";
      ?>

      <img src="cover.png" />
      <div class="info">
        <h1>Каква е кръвната ми захар?</h1>
        <p>Студентските асоциации в МУ Пловдив периодично провеждат кампании, свързани с профилактика на здравето. Една такава кампания е Измерване на кръвната захар. Събраната информация е много полезна за хора, които развиват научна дейност в университета. </p>
        <p>Информацията в таблицата е реална и анонимизирана - имената са различни. Бях я подготвил за дипломна работа и тъй като е стандартизирана, реших че мога да я използвам в това демо.</p>
      </div>
      <table class="styled-table">
        <thead>
          <tr><th>Име</th><th>Фамилия</th><th>Възраст</th><th>Пол</th><th>Населено място</th><th>Кръвна захар</th></tr>
        </thead>
        <tbody>

<?php
   require_once ('config.php');

   #print "{$host}, {$database}, {$user}, {$password}";

   try {
      $connection = new PDO("mysql:host={$host};dbname={$database};charset=utf8", $user, $password);
      $query = $connection->query("SELECT first_name, last_name, age, gender, location, blood_sugar FROM diabetes_results ORDER BY blood_sugar DESC");
      $people = $query->fetchAll();

      if (empty($people)) {
         echo "<tr><td>Няма данни.</td></tr>\n";
      } else {
         foreach ($people as $person) {
            print "<tr><td>{$person['first_name']}</td><td>{$person['last_name']}</td><td>{$person['age']}</td><td>{$person['gender']}</td><td>{$person['location']}</td><td>{$person['blood_sugar']}</td></tr>\n";
         }
      }
   }
   catch (PDOException $e) {
      print "<tr><td><div align='center'>\n";
      print "Няма връзка към базата. Опитайте отново. <a href=\"#\" onclick=\"document.getElementById('error').style = 'display: block;';\">Детайли</a><br/>\n";
      print "<span id='error' style='display: none;'><small><i>".$e->getMessage()." <a href=\"#\" onclick=\"document.getElementById('error').style = 'display: none;';\">Скрий</a></i></small></span>\n";
      print "</div></td></tr>\n";
   }
?>

        </tbody>
      </table>

    </div>
  </body>
</html>

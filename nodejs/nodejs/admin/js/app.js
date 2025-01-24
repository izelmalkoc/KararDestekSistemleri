const express = require('express');
const app = express();
const port = 3000; 

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
const mysql = require('mysql');

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'kullanici_adiniz',
  password: 'sifreniz',
  database: 'veritabani_adi'
});

connection.connect((err) => {
  if (err) {
    console.error('MySQL connection error: ', err);
  } else {
    console.log('Connected to MySQL');
  }
}); 
app.get('/products', (req, res) => {
    const query = 'SELECT * FROM urunler'; 
    connection.query(query, (err, results) => {
      if (err) {
        console.error('Error executing query: ', err);
        res.status(500).send('Internal Server Error');
      } else {
        res.json(results);
      }
    });
  });
  

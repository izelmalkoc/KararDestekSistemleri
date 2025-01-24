const http = require('http');
const express = require('express');
const mysql = require('mysql');
const dbConfig = require('./dbConfig');
const path = require('path');
const bodyParser = require('body-parser'); // Import body-parser

const app = express();
app.use(express.static(path.join(__dirname, 'admin')));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Define your route
app.get('/', (req, res) => {
  const connection = mysql.createConnection(dbConfig);

  connection.query('SELECT * FROM urunler', (error, results, fields) => {
    if (error) throw error;
    res.send('<h1>Admin Panel</h1><ul>' + results.map(urun => `<li>${urun.urun_ad}</li>`).join('') + '</ul>');
    connection.end();
  });
});

app.get('/admin/login', (req, res) => {
  res.sendFile(path.join(__dirname, 'admin', 'login.html'));
});


app.get('/admin/register', (req, res) => {
  res.sendFile(path.join(__dirname, 'admin', 'register.html'));
});


app.get('/admin', (req, res) => {
  res.sendFile(path.join(__dirname, 'admin', 'index.html'));
});


app.get('/admin/kitaplar', (req, res) => {
  res.sendFile(path.join(__dirname, 'admin', 'books.html'));
});

app.get('/admin/analizler', (req, res) => {
  res.sendFile(path.join(__dirname, 'admin', 'analyzes.html'));
});

app.get('/admin/musteriler', (req, res) => {
  res.sendFile(path.join(__dirname, 'admin', 'customer.html'));
});

app.get('/admin/siparis', (req, res) => {
  res.sendFile(path.join(__dirname, 'admin', 'order.html'));
});

app.get('/admin/siparisler', (req, res) => {
  res.sendFile(path.join(__dirname, 'admin', 'orders.html'));
});

app.get('/admin/fetch-sales-by-year-and-season', (req, res) => {
  const connection = mysql.createConnection(dbConfig);

  const query = `
        SELECT s.yil, sz.sezon_ad, COUNT(s.satis_id) AS toplam_satis
        FROM satislar s
        JOIN siparisler sz ON s.sezon_id = sz.sezon_id
        GROUP BY s.yil, sz.sezon_ad
        ORDER BY s.yil DESC, sz.sezon_ad ASC
    `;

  connection.query(query, (error, results, fields) => {
    connection.end();

    if (error) {
      return res.status(500).json({ error: 'Internal Server Error' });
    }

    // Send the data as JSON
    res.json(results);
  });
});

app.get('/admin/kitap-ekle', (req, res) => {
  res.sendFile(path.join(__dirname, 'admin', 'create-book.html'));
});

// Admin sayfası route'u
app.get('/admin/fetch', (req, res) => {
  const connection = mysql.createConnection(dbConfig);

  // Toplam kitap sayısı, yazar sayısı ve müşteri sayısı getir
  const query = `
    SELECT
      (SELECT COUNT(kitap_id) FROM kitaplar) AS kitapSayisi,
      (SELECT COUNT(yazar_id) FROM yazarlar) AS yazarSayisi,
      (SELECT COUNT(musteri_id) FROM musteriler) AS musteriSayisi
  `;

  connection.query(query, (error, results, fields) => {
    connection.end();

    if (error) {
      return res.status(500).json({ error: 'Internal Server Error' });
    }

    // Send the data as JSON
    res.json(results[0]); // Assuming you want to send the counts as a single JSON object
  });
});

app.get('/admin/fetch-analyzes', (req, res) => {
  const connection = mysql.createConnection(dbConfig);

  const query = `
    SELECT
      (SELECT COUNT(kitap_id) FROM kitaplar) AS kitapSayisi,
      (SELECT COUNT(yazar_id) FROM yazarlar) AS yazarSayisi,
      (SELECT COUNT(musteri_id) FROM musteriler) AS musteriSayisi,
      (SELECT COUNT(kategori_id) FROM kitap_kategori) AS kategoriSayisi,
      (SELECT SUM(adet) FROM siparis) AS satisToplami,
      kitaplar.kitap_id,
      kitaplar.kitap_adi,
      kitap_kategori.kategori_ad,
      SUM(siparis.adet) AS toplam_satis_adet
    FROM kitaplar
    LEFT JOIN siparis ON kitaplar.kitap_id = siparis.kitap_id
    LEFT JOIN kitap_kategori ON kitap_kategori.kategori_id = kitaplar.kategori_id
    GROUP BY kitaplar.kitap_id
  `;

  connection.query(query, (error, results, fields) => {
    connection.end();

    if (error) {
      return res.status(500).json({ error: 'Internal Server Error' });
    }

    // Dizi içinde dizi olarak düzenleme
    const satisAnalizi = results.map(result => ({
      kitap_id: result.kitap_id,
      kitap_adi: result.kitap_adi,
      kategori_ad: result.kategori_ad,
      toplam_satis_adet: result.toplam_satis_adet
    }));

    // Diğer verileri de ekleyebilirsiniz
    const responseData = {
      kitapSayisi: results[0].kitapSayisi,
      yazarSayisi: results[0].yazarSayisi,
      musteriSayisi: results[0].musteriSayisi,
      kategoriSayisi: results[0].kategoriSayisi,
      satisToplami: results[0].satisToplami,
      satisAnalizi: satisAnalizi
    };

    // Send the data as JSON
    res.json(responseData);
  });
});

app.get('/admin/fetch-order', (req, res) => {
  const connection = mysql.createConnection(dbConfig);

  const query = `
    SELECT
      m.magaza_id,
      m.magaza_ad,
      GROUP_CONCAT(u.urun_id) AS urun_ids,
      GROUP_CONCAT(u.urun_ad) AS urun_ads,
      GROUP_CONCAT(s.satis_adedi) AS satis_adetleri,
      SUM(s.satis_adedi) AS toplam_satis
    FROM
      satislar s
      INNER JOIN magazalar m ON s.magaza_id = m.magaza_id
      INNER JOIN urunler u ON s.urun_id = u.urun_id
    GROUP BY
      m.magaza_id,
      m.magaza_ad
    ORDER BY
      m.magaza_id;
  `;

  connection.query(query, (error, results, fields) => {
    connection.end();

    if (error) {
      return res.status(500).json({ error: 'Internal Server Error' });
    }

    res.json(results);
  });
});
app.get('/admin/fetch-products-with-sales-by-store-grouped', (req, res) => {
  const connection = mysql.createConnection(dbConfig);

  const query = `
    SELECT
      YEAR(s.tarih) AS yil,
      s.kitap_id,
      COUNT(*) AS satis_sayisi,
      k.kitap_adi
    FROM siparis s
    JOIN kitaplar k ON s.kitap_id = k.kitap_id
    GROUP BY yil, s.kitap_id
    ORDER BY yil DESC, satis_sayisi DESC;
  `;

  connection.query(query, (error, results, fields) => {
    connection.end();

    if (error) {
      return res.status(500).json({ error: 'Internal Server Error' });
    }

    // Gruplama işlemi
    const groupedData = results.reduce((acc, item) => {
      const year = item.yil;

      if (!acc[year]) {
        acc[year] = [];
      }

      acc[year].push({
        kitap_id: item.kitap_id,
        kitap_adi: item.kitap_adi,
        satis_sayisi: item.satis_sayisi,
      });

      return acc;
    }, {});

    res.json(groupedData);
  });
});

app.get('/admin/fetch-customer-with-sales-by-store-grouped', (req, res) => {
  const connection = mysql.createConnection(dbConfig);

  const query = `
    SELECT
      YEAR(s.tarih) AS yil,
      s.musteri_id,
      COUNT(*) AS siparis_sayisi,
      m.ad,
      m.soyad
    FROM siparis s
    JOIN musteriler m ON s.musteri_id = m.musteri_id
    GROUP BY yil, s.musteri_id
    ORDER BY yil DESC, siparis_sayisi DESC;
  `;

  connection.query(query, (error, results, fields) => {
    connection.end();

    if (error) {
      return res.status(500).json({ error: 'Internal Server Error' });
    }

    // Gruplama işlemi
    const groupedData = results.reduce((acc, item) => {
      const year = item.yil;

      if (!acc[year]) {
        acc[year] = [];
      }

      acc[year].push({
        musteri_id: item.musteri_id,
        musteri_adi: item.ad,
        musteri_soyadi: item.soyad,
        siparis_sayisi: item.siparis_sayisi,
      });

      return acc;
    }, {});

    res.json(groupedData);
  });
});





app.get('/admin/fetch-orders', (req, res) => {
  const connection = mysql.createConnection(dbConfig);

  const query = `
  SELECT u.*, k.kitap_adi, m.ad , m.soyad
  FROM siparis u
  JOIN kitaplar k ON u.kitap_id = k.kitap_id
  JOIN musteriler m ON u.musteri_id = m.musteri_id
    `;

  connection.query(query, (error, results, fields) => {
    if (error) {
      connection.end();
      return res.status(500).json({ error: 'Internal Server Error' });
    }

    // Send the data as JSON
    res.json(results);

    connection.end();
  });
});

app.get('/admin/fetch-books', (req, res) => {
  const connection = mysql.createConnection(dbConfig);

  const query = `
    SELECT u.*, k.kategori_ad, y.ad ,y.soyad
    FROM kitaplar u
    JOIN kitap_kategori k ON u.kategori_id = k.kategori_id
    JOIN yazarlar y ON u.yazar_id = y.yazar_id
    ORDER BY u.kitap_id DESC

  `;

  connection.query(query, (error, results, fields) => {
    connection.end();

    if (error) {
      return res.status(500).json({ error: 'Internal Server Error' });
    }

    // Send the data as JSON
    res.json(results);
  });
});

const bcrypt = require('bcrypt');
const saltRounds = 10;

app.post('/register-post', async (req, res) => {
  const connection = mysql.createConnection(dbConfig);
  const { admin_adsoyad, admin_mail, admin_password } = req.body;

  console.log(req.body);

  try {
    // Hash the password
    const hashedPassword = await bcrypt.hash(admin_password, saltRounds);

    // Insert user into the 'admin' table using prepared statement
    const query = 'INSERT INTO kullanicilar (admin_adsoyad, admin_mail, admin_password) VALUES (?, ?, ?)';
    connection.query(query, [admin_adsoyad, admin_mail, hashedPassword], (error, results, fields) => {
      if (error) {
        console.error('Error during registration:', error);
        return res.status(500).json({ error: 'Internal Server Error' });
      }
      res.json({ message: 'Registration successful' });
    });
  } catch (error) {
    console.error('Error during password hashing:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  } finally {
    // Close the database connection
    connection.end();
  }
});

// app.js
app.post('/login-post', async (req, res) => {
  const { admin_mail, admin_password } = req.body;

  // Kullanıcıyı kontrol et
  const query = 'SELECT * FROM admin WHERE admin_mail = ?';
  connection.query(query, [admin_mail], async (error, results, fields) => {
    if (error) {
      return res.status(500).json({ error: 'Internal Server Error' });
    }

    if (results.length === 0) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const hashedPassword = results[0].admin_password;

    // Şifre karşılaştırması
    const match = await bcrypt.compare(admin_password, hashedPassword);

    if (match) {
      res.json({ message: 'Login successful' });
    } else {
      res.status(401).json({ message: 'Invalid credentials' });
    }
  });
});

app.post('/submit_book_form', (req, res) => {
  const kitap_adi = req.body.ad;
  const kategori_id = req.body.kategoriID;
  const yayinevi = req.body.yayinevi;
  const yazarAdi = req.body.yazarAdi;
  const yazarSoyadi = req.body.yazarSoyadi;
  const fiyat = req.body.fiyat;

  const connection = mysql.createConnection(dbConfig);

  // Check if the author exists
  const yazarSorgu = `
    SELECT yazar_id FROM yazarlar WHERE ad = ? AND soyad = ? LIMIT 1
  `;

  connection.query(yazarSorgu, [yazarAdi, yazarSoyadi], (error, results, fields) => {
    if (error) {
      console.error(error);
      connection.end();
      return res.status(500).json({ error: 'Internal Server Error' });
    }

    if (results.length === 0) {
      connection.end();
      return res.status(400).json({ error: 'Yazar bulunamadı.' });
    }

    const yazarId = results[0].yazar_id;

    // Get the total number of books
    const totalKitapSorgu = `
      SELECT COUNT(*) AS totalKitap FROM kitaplar
    `;

    connection.query(totalKitapSorgu, (error, results, fields) => {
      if (error) {
        console.error(error);
        connection.end();
        return res.status(500).json({ error: 'Internal Server Error' });
      }

      const totalKitap = results[0].totalKitap;
      const kitapId = totalKitap + 1; // Increment by one more than the total

      // Insert book into the database
      const kitapEklemeSorgu = `
        INSERT INTO kitaplar (kitap_id, kitap_adi, kategori_id, yayinevi, yazar_id, fiyat) 
        VALUES (?, ?, ?, ?, ?, ?)
      `;

      connection.query(kitapEklemeSorgu, [kitapId, kitap_adi, kategori_id, yayinevi, yazarId, fiyat], (error, results, fields) => {
        connection.end();

        if (error) {
          console.error(error);
          return res.status(500).json({ error: 'Internal Server Error' });
        }

        res.send(`Form gönderildi: Kitap ID=${kitapId}, Kitap Adı=${kitap_adi}, Kategori ID=${kategori_id}, Yayınevi=${yayinevi}, Yazar Adı=${yazarAdi}, Yazar Soyadı=${yazarSoyadi}, Fiyat=${fiyat}`);
      });
    });
  });
});


const server = http.createServer(app);

server.listen(3001, () => {
  console.log('Uygulama çalıştırıldı...');
});

-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Anamakine: 127.0.0.1
-- Üretim Zamanı: 29 Ara 2023, 11:17:00
-- Sunucu sürümü: 10.4.28-MariaDB
-- PHP Sürümü: 8.1.17

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Veritabanı: `nodejs`
--

DELIMITER $$
--
-- Yordamlar
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `güncelKitapSayisi` ()   SELECT COUNT(kitap.kitap_id) kitapSayisi FROM kitap$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `güncelYazarSayisi` ()   SELECT COUNT(yazar.yazar_id) yazarSayisi FROM yazar$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `kategoriIdyeGoreSatis` (IN `hedef_kategori_id` INT(10))   SELECT kitap_kategori.kategori_ad,kitap.kitap_adi,musteri.ad AS MusteriAdi,siparis.adet,siparis.tarih
FROM siparis
INNER JOIN kitap ON siparis.kitap_id=kitap.kitap_id
INNER JOIN musteri ON siparis.musteri_id=musteri.musteri_id
INNER JOIN kitap_kategori ON kitap.kategori_id=kitap_kategori.kategori_id
WHERE kitap_kategori.kategori_id=hedef_kategori_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `kategoriyeAdınaGoreSatislar` ()   SELECT kitap.kitap_adi, SUM(siparis.siparis_id) as siparisSayisi, kitap_kategori.kategori_ad
FROM kitap
JOIN siparis ON kitap.kitap_id = siparis.kitap_id
JOIN musteri ON musteri.musteri_id = siparis.musteri_id
JOIN kitap_kategori ON kitap_kategori.kategori_id = kitap.kategori_id
GROUP BY kitap.kitap_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `kitapEkle` ()   SELECT kitap.kitap_adi ,COUNT(kitap.kitap_id)as sayi
FROM kitap
GROUP BY kitap.kitap_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `musteriyeGoreSiparisDetay` (IN `ad` VARCHAR(100), IN `soyad` VARCHAR(100))   SELECT musteri.musteri_id,musteri.ad,musteri.soyad,kitap.kitap_adi,
siparis.adet,siparis.tarih
FROM siparis
INNER JOIN musteri ON siparis.musteri_id=musteri.musteri_id
INNER JOIN kitap ON siparis.kitap_id=kitap.kitap_id
WHERE musteri.ad = ad AND musteri.soyad=soyad$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `tariheGoreKitapSatisToplami` (IN `baslangic_tarihi` DATE, IN `bitis_tarihi` DATE)   SELECT kitap.kitap_adi,SUM(siparis.adet) AS ToplamSatis
FROM siparis
INNER JOIN kitap ON siparis.kitap_id=kitap.kitap_id
WHERE siparis.tarih BETWEEN baslangic_tarihi AND bitis_tarihi
GROUP BY kitap.kitap_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `toplamMagazaSatis` ()   SELECT SUM(siparis.adet) AS toplam_satis FROM siparis$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `urunBazındaToplamSatis` ()   SELECT kitaplar.kitap_id,kitaplar.kitap_adi,kitap_kategori.kategori_ad,
SUM(siparis.adet) AS toplam_satis_adet
FROM kitaplar
LEFT JOIN siparis ON kitaplar.kitap_id=siparis.kitap_id
LEFT JOIN kitap_kategori ON kitap_kategori.kategori_id=kitaplar.kategori_id
GROUP BY kitaplar.kitap_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `yılaGoreSatis` (IN `hedef_yil` INT(10))   SELECT YEAR(siparis.tarih) AS Yil, kitap.kitap_adi,musteri.ad AS MusteriAdi,siparis.adet,siparis.tarih
FROM siparis
INNER JOIN kitap ON siparis.kitap_id=kitap.kitap_id
INNER JOIN musteri ON siparis.musteri_id=musteri.musteri_id
WHERE YEAR(siparis.tarih)=hedef_yil$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `admin`
--

CREATE TABLE `admin` (
  `admin_sifre` int(11) NOT NULL,
  `admin_mail` text NOT NULL,
  `admin_adSoyad` varchar(50) NOT NULL,
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

--
-- Tablo döküm verisi `admin`
--

INSERT INTO `admin` (`admin_sifre`, `admin_mail`, `admin_adSoyad`, `id`) VALUES
(1234, 'izelmalkoc@hotmail.com', 'İzel Malkoç', 1),
(12345, 'kitapvagonu@example.com', 'Kitap Vagonu', 2);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `kitaplar`
--

CREATE TABLE `kitaplar` (
  `kitap_adi` varchar(200) NOT NULL,
  `yazar_id` int(10) NOT NULL,
  `kategori_id` int(10) NOT NULL,
  `kitap_id` int(10) NOT NULL,
  `fiyat` int(5) NOT NULL,
  `yayinevi` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

--
-- Tablo döküm verisi `kitaplar`
--

INSERT INTO `kitaplar` (`kitap_adi`, `yazar_id`, `kategori_id`, `kitap_id`, `fiyat`, `yayinevi`) VALUES
('İnsan Neyle Yaşar?', 3, 1, 1, 18, 'İş Bankası'),
('Bir İdam Mahkumunun Son Günü', 6, 1, 2, 19, 'İş Bankası'),
('Martin Eden', 9, 1, 3, 54, 'İş Bankası'),
('Beyaz Zambaklar Ülkesinde', 10, 1, 4, 19, 'İş Bankası'),
('Altıncı Koğuş', 15, 1, 5, 14, 'İş Bankası'),
('Yeraltından Notlar', 17, 1, 6, 22, 'İş Bankası'),
('Suç ve Ceza', 17, 1, 7, 77, 'İş Bankası'),
('Mutlu Bir Yaşam Üzerine', 20, 1, 8, 19, 'İş Bankası'),
('Genç Werther\'in Acıları', 39, 1, 9, 19, 'İş Bankası'),
('Kızıl Veba', 9, 1, 10, 15, 'İş Bankası'),
('Kürk Mantolu Modanna', 7, 2, 11, 13, 'Yapı Kredi'),
('Beni Neden Sevmedin Anne?', 8, 2, 12, 84, 'Destek Yayınları'),
('Sarı Sıcak', 11, 2, 13, 108, 'Yapı Kredi'),
('Bronz 2 Seti', 14, 2, 14, 130, 'Ren Kitap'),
('İçimizdeki Şeytan', 7, 2, 15, 21, 'Yapı Kredi'),
('Aşk Hikayesi', 23, 2, 16, 87, 'Kapı Yayınları'),
('Gökçen 1 Unutulan Çiçekler', 24, 2, 17, 134, 'Ephesus Yayınları'),
('Kayıp Ağaçlar Adası', 28, 2, 18, 136, 'Doğan Kitap'),
('Ben Amir', 30, 2, 19, 80, 'Alfa Yayıncılık'),
('Kuyucaklı Yusuf', 7, 2, 20, 17, 'Yapı Kredi'),
('995 Km', 33, 2, 21, 104, 'Metis Yayınları'),
('Serenad', 34, 2, 22, 103, 'İnkılap Kitabevi'),
('Gece Yarısı Kütüphanesi', 2, 2, 23, 90, 'Domingo Yayınevi'),
('Yaşamak', 5, 2, 24, 71, 'Jaguar Kitap'),
('Olağanüstü Bir Gece', 12, 2, 25, 15, 'İş Bankası'),
('Şeker Portakalı', 13, 2, 26, 85, 'Can Yayınları'),
('Martı', 18, 2, 27, 70, 'Epsilon Yayınları'),
('Veronika Ölmek İstiyor', 19, 2, 28, 88, 'Can Yayınları'),
('Simyacı', 19, 2, 29, 85, 'Can Yayınları'),
('İntihar Dükkanı', 21, 2, 30, 62, 'Sel Yayıncılık'),
('Satranç', 12, 2, 31, 13, 'İş Bankası'),
('Hayvan Çiftliği', 22, 2, 32, 34, 'Can Yayınları'),
('1984', 22, 2, 33, 54, 'Can Yayınları'),
('Dönüşüm', 26, 2, 34, 16, 'İş Bankası'),
('Beni Asla Bırakma', 27, 2, 35, 84, 'Yapı Kredi'),
('Dansa Davet', 21, 2, 36, 52, 'Sel Yayıncılık'),
('Ay Işığı Sokağı', 12, 2, 37, 15, 'İş Bankası'),
('Otomatik Portakal', 29, 2, 38, 28, 'İş Bankası'),
('Beyaz Gemi', 31, 2, 39, 45, 'Ötüken Neşriyat'),
('Sol Ayağım', 32, 2, 40, 77, 'Nora'),
('Antika Titanik', 1, 3, 41, 58, 'April Yayıncılık'),
('Yılan Avı', 16, 3, 42, 135, 'Koridor Yayıncılık'),
('Acı Kahve', 25, 3, 43, 46, 'Altın Kitaplar'),
('Doğu Ekspresi\'nde Cinayet', 25, 3, 44, 79, 'Altın Kitaplar'),
('Dördüncü Kanat', 4, 4, 45, 274, 'Olimpos Yayınları'),
('Harry Potter ve Felsefe Taşı', 35, 4, 46, 84, 'Yapı Kredi'),
('Varislerin Oyunu', 36, 4, 47, 113, 'İndigo Kitap'),
('Yüzüklerin Efendisi', 37, 4, 48, 77, 'Teras Kitap'),
('Freddy\'nin Pizza Dükkanında Beş Gece', 38, 4, 49, 294, 'Olimpos Çocuk'),
('Nobis optio minim a', 1, 1, 51, 123, 'In voluptatibus est '),
('Laborum Explicabo ', 1, 2, 52, 23, 'Nostrum minim iusto ');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `kitap_kategori`
--

CREATE TABLE `kitap_kategori` (
  `kategori_id` int(10) NOT NULL,
  `kategori_ad` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

--
-- Tablo döküm verisi `kitap_kategori`
--

INSERT INTO `kitap_kategori` (`kategori_id`, `kategori_ad`) VALUES
(1, 'Dünya Klasikleri'),
(2, 'Türk Roman'),
(3, 'Polisiye'),
(4, 'Fantastik');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `musteriler`
--

CREATE TABLE `musteriler` (
  `musteri_id` int(10) NOT NULL,
  `ad` varchar(100) NOT NULL,
  `soyad` varchar(100) NOT NULL,
  `e_mail` varchar(100) NOT NULL,
  `dogum_tarihi` date NOT NULL,
  `guncelleme_tarihi` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

--
-- Tablo döküm verisi `musteriler`
--

INSERT INTO `musteriler` (`musteri_id`, `ad`, `soyad`, `e_mail`, `dogum_tarihi`, `guncelleme_tarihi`) VALUES
(1, 'Ahmet', 'Yılmaz', 'ahmet.yilmaz@example.com', '1990-05-15', '2023-12-10 20:30:05'),
(2, 'Ayşe', 'Kaya', 'ayse.kaya@example.com', '1985-08-22', '2023-12-10 20:30:05'),
(3, 'Mehmet', 'Demir', 'mehmet.demir@example.com', '1992-03-10', '2023-12-10 20:30:05'),
(4, 'Fatma', 'Arslan', 'fatma.arslan@example.com', '1988-11-05', '2023-12-10 20:30:05'),
(5, 'Gizem', 'Yıldız', 'gizem.yildiz@example.com', '1990-08-11', '2023-12-10 20:30:05'),
(6, 'Ali', 'Demir', 'ali.demir@example.com', '1988-12-25', '2023-12-10 20:30:05'),
(7, 'Zeynep', 'Kaya', 'zeynep.kaya@example.com', '1992-06-30', '2023-12-10 20:30:05'),
(8, 'Ahmet', 'Erdoğan', 'ahmet.erdogan@example.com', '1985-02-14', '2023-12-10 20:30:05'),
(9, 'Elif', 'Güneş', 'elif.gunes@example.com', '1993-09-17', '2023-12-10 20:30:05'),
(10, 'Merve', 'Yılmaz', 'merve.yilmaz@example.com', '1982-04-03', '2023-12-10 20:30:05'),
(11, 'Mustafa', 'Şahin', 'mustafa.sahin@example.com', '1998-11-26', '2023-12-10 20:30:05'),
(12, 'Ayşe', 'Türk', 'ayse.turk@example.com', '1987-07-09', '2023-12-10 20:30:05'),
(13, 'Cem', 'Koç', 'cem.koc@example.com', '1994-01-22', '2023-12-10 20:30:05'),
(14, 'Emine', 'Sarı', 'emine.sari@example.com', '1980-05-07', '2023-12-10 20:30:05'),
(15, 'Can', 'Tuncer', 'can.tuncer@example.com', '1986-10-20', '2023-12-10 20:30:05'),
(16, 'Ece', 'Yıldırım', 'ece.yildirim@example.com', '1991-05-05', '2023-12-10 20:30:05'),
(17, 'Gökhan', 'Akyüz', 'gokhan.akyuz@example.com', '1997-12-18', '2023-12-10 20:30:05'),
(18, 'Derya', 'Yılmaz', 'derya.yilmaz@example.com', '1983-06-02', '2023-12-10 20:30:05'),
(19, 'Zehra', 'Erdem', 'zehra.erdem@example.com', '1996-01-15', '2023-12-10 20:30:05'),
(20, 'Şevval', 'Aktaş', 'sevval.aktas@example.com', '1989-07-28', '2023-12-10 20:30:05'),
(21, 'Oktay', 'Koç', 'oktay.koc@example.com', '1992-02-10', '2023-12-10 20:30:05'),
(22, 'Zara', 'Güneş', 'zara.gunes@example.com', '1984-09-23', '2023-12-10 20:30:05'),
(23, 'Murat', 'Türk', 'murat.turk@example.com', '1995-04-08', '2023-12-10 20:30:05'),
(24, 'Selin', 'Erdoğan', 'selin.erdogan@example.com', '1981-08-21', '2023-12-10 20:30:05'),
(25, 'Yasin', 'Sari', 'yasin.sari@example.com', '1987-12-04', '2023-12-10 20:30:05'),
(26, 'Deniz', 'Yıldırım', 'deniz.yildirim@example.com', '1993-04-17', '2023-12-10 20:30:05'),
(27, 'Selin', 'Güneş', 'selin.gunes@example.com', '1989-09-30', '2023-12-10 20:30:05'),
(28, 'Umut', 'Koç', 'umut.koc@example.com', '1994-02-13', '2023-12-10 20:30:05'),
(29, 'Nur', 'Akyüz', 'nur.akyuz@example.com', '1985-06-26', '2023-12-10 20:30:05'),
(30, 'Emir', 'Yılmaz', 'emir.yilmaz@example.com', '1998-01-09', '2023-12-10 20:30:05'),
(31, 'Mehmet', 'Aydın', 'mehmet.aydin@example.com', '1995-03-18', '2023-12-10 20:30:05'),
(32, 'Ahmet', 'Yıldız', 'ahmet.yildiz@example.com', '1990-08-11', '2023-12-10 20:30:05'),
(33, 'Gizem', 'Aktaş', 'gizem.aktas@example.com', '1988-12-25', '2023-12-10 20:30:05'),
(34, 'Mert', 'Kaya', 'mert.kaya@example.com', '1992-06-30', '2023-12-10 20:30:05'),
(35, 'Ezgi', 'Erdoğan', 'ezgi.erdogan@example.com', '1985-02-14', '2023-12-10 20:30:05'),
(36, 'Onur', 'Güneş', 'onur.gunes@example.com', '1993-09-17', '2023-12-10 20:30:05'),
(37, 'Deniz', 'Yılmaz', 'deniz.yilmaz@example.com', '1982-04-03', '2023-12-10 20:30:05'),
(38, 'Merve', 'Şahin', 'merve.sahin@example.com', '1998-11-26', '2023-12-10 20:30:05'),
(39, 'Ahmet', 'Türk', 'ahmet.turk@example.com', '1987-07-09', '2023-12-10 20:30:05'),
(40, 'Cemre', 'Koç', 'cemre.koc@example.com', '1994-01-22', '2023-12-10 20:30:05'),
(41, 'Yusuf', 'Sari', 'yusuf.sari@example.com', '1980-05-07', '2023-12-10 20:30:05'),
(42, 'Elif', 'Tuncer', 'elif.tuncer@example.com', '1986-10-20', '2023-12-10 20:30:05'),
(43, 'Berkay', 'Yıldırım', 'berkay.yildirim@example.com', '1991-05-05', '2023-12-10 20:30:05'),
(44, 'Ece', 'Akyüz', 'ece.akyuz@example.com', '1997-12-18', '2023-12-10 20:30:05'),
(45, 'Murat', 'Erdoğan', 'murat.erdogan@example.com', '1983-06-02', '2023-12-10 20:30:05'),
(46, 'Zeynep', 'Erdem', 'zeynep.erdem@example.com', '1996-01-15', '2023-12-10 20:30:05'),
(47, 'Yasin', 'Aktaş', 'yasin.aktas@example.com', '1989-07-28', '2023-12-10 20:30:05'),
(48, 'Şevval', 'Koç', 'sevval.koc@example.com', '1992-02-10', '2023-12-10 20:30:05'),
(49, 'Selin', 'Güneş', 'selin.gunes@example.com', '1984-09-23', '2023-12-10 20:30:05'),
(50, 'Oktay', 'Türk', 'oktay.turk@example.com', '1995-04-08', '2023-12-10 20:30:05');

--
-- Tetikleyiciler `musteriler`
--
DELIMITER $$
CREATE TRIGGER `adIlkHarfBuyukIkıncıKucuk` BEFORE INSERT ON `musteriler` FOR EACH ROW SET new.ad = CONCAT(UPPER(SUBSTRING(new.ad, 1, 1)), LOWER(SUBSTRING(new.ad, 2))),
    new.soyad = CONCAT(UPPER(SUBSTRING(new.soyad, 1, 1)), LOWER(SUBSTRING(new.soyad, 2)))
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `kayitGuncelleme` BEFORE UPDATE ON `musteriler` FOR EACH ROW SET NEW.guncelleme_tarihi = NOW()
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `soyadBuyuk` BEFORE INSERT ON `musteriler` FOR EACH ROW SET new.soyad = UPPER(new.soyad)
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `siparis`
--

CREATE TABLE `siparis` (
  `siparis_id` int(10) NOT NULL,
  `kitap_id` int(10) NOT NULL,
  `musteri_id` int(10) NOT NULL,
  `adet` int(100) NOT NULL,
  `tarih` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

--
-- Tablo döküm verisi `siparis`
--

INSERT INTO `siparis` (`siparis_id`, `kitap_id`, `musteri_id`, `adet`, `tarih`) VALUES
(1, 1, 1, 2, '2023-12-08'),
(2, 3, 2, 1, '2023-11-07'),
(3, 6, 3, 3, '2023-12-12'),
(4, 10, 4, 2, '2023-12-11'),
(5, 15, 5, 1, '2023-12-04'),
(6, 21, 6, 4, '2023-12-09'),
(7, 28, 7, 2, '2023-12-10'),
(8, 36, 8, 1, '2023-12-01'),
(9, 45, 9, 3, '2023-11-30'),
(10, 1, 1, 2, '2023-12-08'),
(11, 18, 21, 2, '2023-11-18'),
(12, 25, 22, 1, '2023-11-17'),
(13, 32, 23, 4, '2023-11-16'),
(14, 14, 13, 1, '2023-11-26'),
(15, 19, 14, 3, '2023-11-25'),
(16, 24, 15, 2, '2023-11-24'),
(17, 31, 16, 1, '2023-11-23'),
(18, 39, 17, 4, '2023-11-22'),
(19, 47, 18, 2, '2023-11-21'),
(20, 3, 19, 1, '2023-11-20'),
(21, 12, 20, 3, '2023-11-19'),
(22, 2, 11, 1, '2023-11-28'),
(23, 9, 12, 2, '2023-11-27'),
(24, 6, 3, 3, '2023-12-06'),
(25, 10, 4, 2, '2023-12-05'),
(26, 15, 5, 1, '2023-12-04'),
(27, 21, 6, 4, '2023-12-03'),
(28, 28, 7, 2, '2023-12-02'),
(29, 36, 8, 1, '2023-12-02'),
(30, 45, 9, 3, '2023-11-30'),
(32, 1, 1, 2, '2023-12-08'),
(33, 3, 2, 1, '2023-12-07'),
(34, 4, 24, 2, '2023-11-05'),
(35, 11, 25, 1, '2023-11-04'),
(36, 16, 26, 3, '2023-11-03'),
(37, 22, 27, 2, '2023-11-02'),
(38, 29, 28, 1, '2023-11-01'),
(39, 37, 29, 4, '2023-10-31'),
(40, 45, 30, 2, '2023-10-30'),
(41, 2, 31, 1, '2023-10-29'),
(42, 9, 32, 3, '2023-10-28'),
(43, 14, 33, 2, '2023-10-27'),
(44, 19, 34, 1, '2023-10-26'),
(45, 24, 35, 3, '2023-10-25'),
(46, 31, 36, 2, '2023-10-24'),
(47, 39, 37, 4, '2023-10-23'),
(48, 47, 38, 2, '2023-10-22'),
(49, 3, 39, 1, '2023-10-21'),
(50, 12, 40, 3, '2023-10-20'),
(51, 16, 41, 2, '2023-10-16'),
(52, 16, 41, 2, '2023-11-28'),
(54, 16, 41, 2, '2023-10-16'),
(55, 22, 42, 3, '2023-05-31'),
(56, 29, 43, 3, '2023-11-28'),
(57, 37, 44, 2, '2023-11-18'),
(58, 45, 45, 1, '2023-11-08'),
(59, 2, 46, 4, '2023-10-29'),
(60, 9, 47, 2, '2023-09-07'),
(61, 14, 48, 1, '2023-08-28'),
(62, 19, 49, 12, '2023-07-26'),
(63, 24, 50, 1, '2023-06-18'),
(64, 16, 39, 12, '2023-09-20'),
(65, 16, 39, 12, '2023-06-01'),
(66, 24, 50, 10, '2023-06-02'),
(67, 19, 49, 12, '2023-06-03'),
(68, 14, 48, 13, '2023-06-04'),
(69, 9, 47, 20, '2023-06-05'),
(70, 2, 46, 4, '2023-06-06'),
(71, 45, 45, 1, '2023-06-07'),
(72, 37, 44, 2, '2023-06-08'),
(73, 29, 43, 3, '2023-06-09'),
(77, 22, 42, 3, '2023-06-10'),
(78, 16, 41, 2, '2023-06-11'),
(79, 16, 41, 2, '2023-06-12'),
(80, 16, 41, 2, '2023-06-13'),
(81, 12, 40, 3, '2023-06-14'),
(82, 3, 39, 1, '2023-06-15'),
(83, 47, 38, 2, '2023-06-16'),
(84, 39, 37, 4, '2023-06-17'),
(85, 31, 36, 2, '2023-06-18'),
(86, 24, 35, 3, '2023-06-19'),
(87, 19, 34, 1, '2023-06-20'),
(88, 14, 33, 2, '2023-06-21'),
(89, 9, 32, 3, '2023-06-22'),
(90, 2, 31, 1, '2023-06-23'),
(91, 45, 30, 2, '2023-06-24'),
(92, 37, 29, 4, '2023-06-25'),
(93, 7, 15, 3, '2023-06-26'),
(94, 5, 18, 2, '2023-06-27'),
(95, 10, 21, 4, '2023-06-28'),
(96, 2, 24, 1, '2023-06-29'),
(97, 8, 27, 2, '2023-06-30'),
(98, 1, 30, 3, '2023-07-01'),
(99, 6, 33, 1, '2023-07-02'),
(100, 9, 36, 4, '2023-07-03'),
(101, 4, 39, 2, '2023-07-04'),
(102, 3, 12, 5, '2023-06-25'),
(103, 41, 15, 12, '2023-07-20'),
(104, 17, 48, 1, '2023-07-07'),
(105, 20, 50, 4, '2023-07-08'),
(106, 23, 49, 2, '2023-07-09'),
(107, 26, 47, 3, '2023-07-10'),
(108, 29, 30, 1, '2023-07-11'),
(109, 32, 43, 2, '2023-07-12'),
(110, 35, 46, 3, '2023-07-13'),
(111, 38, 49, 4, '2023-07-14'),
(112, 41, 42, 1, '2023-07-15'),
(113, 44, 45, 2, '2023-07-16'),
(114, 47, 48, 3, '2023-07-17'),
(115, 40, 41, 2, '2023-07-18'),
(116, 43, 44, 1, '2023-07-19'),
(117, 46, 47, 4, '2023-07-20'),
(118, 49, 20, 3, '2023-07-21'),
(119, 42, 23, 2, '2023-07-22'),
(120, 45, 26, 1, '2023-07-23'),
(121, 48, 29, 4, '2023-07-24'),
(122, 41, 22, 3, '2023-07-25'),
(123, 34, 25, 2, '2023-07-26'),
(124, 37, 28, 1, '2023-07-27'),
(125, 30, 21, 3, '2023-07-28'),
(126, 33, 24, 4, '2023-07-29'),
(127, 36, 27, 2, '2023-07-30'),
(128, 39, 20, 1, '2023-07-31'),
(129, 32, 33, 3, '2023-08-01'),
(130, 35, 36, 2, '2023-08-02'),
(131, 38, 39, 4, '2023-08-03'),
(132, 1, 32, 3, '2023-08-04'),
(133, 4, 35, 1, '2023-08-05'),
(134, 7, 38, 2, '2023-08-06'),
(135, 10, 41, 3, '2023-08-07'),
(136, 3, 44, 1, '2023-08-08'),
(137, 6, 47, 4, '2023-08-09'),
(138, 9, 50, 2, '2023-08-10'),
(139, 2, 43, 1, '2023-08-11'),
(140, 5, 46, 3, '2023-08-12'),
(141, 8, 19, 2, '2023-08-13'),
(142, 11, 12, 4, '2023-08-14'),
(143, 14, 15, 3, '2023-08-15'),
(144, 17, 18, 2, '2023-08-16'),
(145, 10, 11, 1, '2023-08-17'),
(146, 13, 14, 4, '2023-08-18'),
(147, 16, 17, 2, '2023-08-19'),
(148, 19, 10, 3, '2023-08-20'),
(149, 12, 13, 1, '2023-08-21'),
(150, 15, 16, 2, '2023-08-22'),
(151, 18, 19, 3, '2023-08-23'),
(152, 11, 12, 4, '2023-08-24'),
(153, 14, 15, 2, '2023-08-25'),
(154, 17, 18, 1, '2023-08-26'),
(155, 10, 21, 3, '2023-08-27'),
(156, 13, 4, 2, '2023-08-28'),
(157, 16, 7, 1, '2023-08-29'),
(158, 19, 10, 4, '2023-08-30'),
(159, 12, 13, 3, '2023-08-31'),
(160, 15, 6, 2, '2023-09-01'),
(161, 18, 9, 1, '2023-09-02'),
(162, 11, 2, 3, '2023-09-03'),
(163, 24, 5, 2, '2023-09-04'),
(164, 27, 8, 4, '2023-09-05'),
(165, 20, 1, 3, '2023-09-06'),
(166, 23, 4, 2, '2023-09-07'),
(167, 26, 7, 1, '2023-09-08'),
(168, 29, 40, 3, '2023-09-09'),
(169, 22, 43, 2, '2023-09-10'),
(170, 25, 46, 1, '2023-09-11'),
(171, 28, 49, 4, '2023-09-12'),
(172, 21, 2, 2, '2023-09-13'),
(173, 24, 5, 3, '2023-09-14'),
(174, 27, 28, 1, '2023-09-15'),
(175, 20, 21, 4, '2023-09-16'),
(176, 23, 24, 3, '2023-09-17'),
(177, 26, 27, 2, '2023-09-18'),
(178, 29, 20, 1, '2023-09-19'),
(179, 22, 23, 3, '2023-09-20'),
(180, 25, 26, 2, '2023-09-21'),
(181, 48, 29, 4, '2023-09-22'),
(182, 21, 22, 2, '2023-09-23'),
(183, 24, 25, 1, '2023-09-24'),
(184, 37, 28, 3, '2023-09-25'),
(185, 30, 21, 2, '2023-09-26'),
(186, 33, 24, 1, '2023-09-27'),
(187, 36, 7, 4, '2023-09-28'),
(188, 39, 30, 2, '2023-09-29'),
(189, 32, 33, 3, '2023-09-30'),
(190, 35, 36, 1, '2023-10-01'),
(191, 38, 39, 2, '2023-10-02'),
(192, 31, 32, 4, '2023-10-03'),
(193, 34, 35, 3, '2023-10-04'),
(194, 37, 38, 2, '2023-10-05'),
(195, 40, 31, 1, '2023-10-06'),
(196, 43, 34, 3, '2023-10-07'),
(197, 46, 37, 2, '2023-10-08'),
(198, 49, 30, 1, '2023-10-09'),
(199, 42, 3, 4, '2023-10-10'),
(200, 5, 36, 2, '2023-10-11'),
(201, 8, 39, 3, '2023-10-12'),
(202, 1, 32, 1, '2023-10-13'),
(203, 34, 45, 2, '2023-10-14'),
(204, 7, 38, 4, '2023-10-15'),
(205, 30, 31, 2, '2023-10-16'),
(206, 33, 34, 3, '2023-10-17'),
(207, 36, 37, 1, '2023-10-18'),
(208, 39, 30, 2, '2023-10-19'),
(209, 32, 33, 3, '2023-10-20'),
(210, 35, 36, 4, '2023-10-21'),
(211, 38, 9, 1, '2023-10-22'),
(212, 41, 2, 2, '2023-10-23'),
(213, 44, 35, 3, '2023-10-24'),
(214, 47, 8, 2, '2023-10-25'),
(215, 30, 1, 1, '2023-10-26'),
(216, 33, 4, 4, '2023-10-27'),
(217, 6, 7, 2, '2023-10-28'),
(218, 9, 30, 3, '2023-10-29'),
(219, 32, 33, 1, '2023-10-30'),
(220, 35, 6, 2, '2023-10-31'),
(221, 38, 39, 3, '2023-11-01'),
(222, 31, 2, 4, '2023-11-02'),
(223, 34, 45, 1, '2023-11-03'),
(224, 37, 48, 2, '2023-11-04'),
(225, 30, 41, 3, '2023-11-05'),
(226, 33, 44, 2, '2023-11-06'),
(227, 38, 47, 1, '2023-11-07'),
(228, 38, 40, 4, '2023-11-08'),
(229, 39, 43, 2, '2023-11-09'),
(230, 39, 46, 3, '2023-11-10'),
(231, 38, 49, 1, '2023-11-11'),
(232, 41, 32, 2, '2023-11-12'),
(233, 44, 45, 4, '2023-11-13'),
(234, 47, 48, 3, '2023-11-14'),
(235, 40, 1, 2, '2023-11-15'),
(236, 13, 4, 1, '2023-11-16'),
(237, 16, 47, 4, '2023-11-17'),
(238, 19, 40, 2, '2023-11-18'),
(239, 22, 3, 3, '2023-11-19'),
(240, 25, 46, 1, '2023-11-20'),
(241, 28, 49, 2, '2023-11-21'),
(242, 41, 42, 3, '2023-11-22'),
(243, 44, 5, 4, '2023-11-23'),
(244, 47, 28, 1, '2023-11-24'),
(245, 40, 21, 2, '2023-11-25'),
(246, 43, 24, 3, '2023-11-26'),
(247, 46, 17, 2, '2023-11-27'),
(248, 49, 10, 1, '2023-11-28'),
(249, 2, 13, 4, '2023-11-29');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `yazarlar`
--

CREATE TABLE `yazarlar` (
  `ad` varchar(50) NOT NULL,
  `soyad` varchar(50) NOT NULL,
  `yazar_id` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

--
-- Tablo döküm verisi `yazarlar`
--

INSERT INTO `yazarlar` (`ad`, `soyad`, `yazar_id`) VALUES
('Murat', 'Menteş', 1),
('Matt', 'Haig', 2),
('Lev Nikolayeviç', 'Tolstoy', 3),
('Rebecca', 'Yarros', 4),
('Yu', 'Hua', 5),
('Victor', 'Hugo', 6),
('Sabahattin', 'Ali', 7),
('Esra', 'Ezmeci', 8),
('Jack', 'London', 9),
('Grigory', 'Petrov', 10),
('Yaşar', 'Kemal', 11),
('Stefan', 'Zweig', 12),
('Jose Moruo', 'Vasconcelos', 13),
('Özge', 'Naz', 14),
('Anton Pavloviç', 'Çehov', 15),
('John', 'Verdon', 16),
('Fyodor Mihayloviç', 'Dostoyevski', 17),
('Richard', 'Bach', 18),
('Paulo', 'Coelho', 19),
('Seneca', 'Seneca', 20),
('Jean', 'Teule', 21),
('George', 'Orwell', 22),
('İskender', 'Pala', 23),
('Loresima', 'Loresima', 24),
('Agatha', 'Christie', 25),
('Franz', 'Kafka', 26),
('Kazuo', 'Ishiguro', 27),
('Elif', 'Şafak', 28),
('Anthony', 'Burgess', 29),
('Sinan', 'Akyüz', 30),
('Cengiz', 'Aytmatov', 31),
('Christy', 'Brown', 32),
('Murathan', 'Mungan', 33),
('Zülfi', 'Livaneli', 34),
('J. K.', 'Rowling', 35),
('Adora', 'Yağmur', 36),
('Ilan', 'Ferry', 37),
('Diana', 'Camero', 38),
('Johann Wolfgang', 'Goethe', 39);

--
-- Dökümü yapılmış tablolar için indeksler
--

--
-- Tablo için indeksler `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id`);

--
-- Tablo için indeksler `kitaplar`
--
ALTER TABLE `kitaplar`
  ADD PRIMARY KEY (`kitap_id`),
  ADD KEY `fk_kitap_kategori` (`kategori_id`),
  ADD KEY `yazar_id` (`yazar_id`);

--
-- Tablo için indeksler `kitap_kategori`
--
ALTER TABLE `kitap_kategori`
  ADD PRIMARY KEY (`kategori_id`);

--
-- Tablo için indeksler `musteriler`
--
ALTER TABLE `musteriler`
  ADD PRIMARY KEY (`musteri_id`);

--
-- Tablo için indeksler `siparis`
--
ALTER TABLE `siparis`
  ADD PRIMARY KEY (`siparis_id`),
  ADD KEY `musteri_id` (`musteri_id`),
  ADD KEY `kitap_id` (`kitap_id`);

--
-- Tablo için indeksler `yazarlar`
--
ALTER TABLE `yazarlar`
  ADD PRIMARY KEY (`yazar_id`);

--
-- Dökümü yapılmış tablolar için kısıtlamalar
--

--
-- Tablo kısıtlamaları `kitaplar`
--
ALTER TABLE `kitaplar`
  ADD CONSTRAINT `fk_kitap_kategori` FOREIGN KEY (`kategori_id`) REFERENCES `kitap_kategori` (`kategori_id`),
  ADD CONSTRAINT `kitaplar_ibfk_1` FOREIGN KEY (`kategori_id`) REFERENCES `kitap_kategori` (`kategori_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `kitaplar_ibfk_2` FOREIGN KEY (`yazar_id`) REFERENCES `yazarlar` (`yazar_id`);

--
-- Tablo kısıtlamaları `siparis`
--
ALTER TABLE `siparis`
  ADD CONSTRAINT `siparis_ibfk_1` FOREIGN KEY (`musteri_id`) REFERENCES `musteriler` (`musteri_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `siparis_ibfk_2` FOREIGN KEY (`kitap_id`) REFERENCES `kitaplar` (`kitap_id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

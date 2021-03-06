

-- Kalıtım Örneği

CREATE DATABASE "AlisVerisUygulamasi"
ENCODING='UTF-8'
LC_COLLATE='tr_TR.UTF-8'
LC_CTYPE='tr_TR.UTF-8'
OWNER postgres
TEMPLATE=template0;

CREATE SCHEMA "Personel";

CREATE TABLE "Personel"."Personel" ( 
	"personelNo" serial,
	"adi" Character Varying( 40 ) NOT NULL,
	"soyadi" Character Varying( 40 ) NOT NULL,
	"personelTipi" Character( 1 ) NOT NULL,
	CONSTRAINT "personelPK" PRIMARY KEY ( "personelNo" ) );
	
CREATE TABLE "Personel"."Danisman" ( 
	"personelNo" INT,
	"sirket" Character Varying( 40 ) NOT NULL,
	CONSTRAINT "danismanPK" PRIMARY KEY ( "personelNo" ) );
	

CREATE TABLE "Personel"."SatisTemsilcisi" ( 
	"personelNo" INT,
	"bolge" Character Varying( 40 ) NOT NULL,
	CONSTRAINT "satisTemsilcisiPK" PRIMARY KEY ( "personelNo" ) );
	

ALTER TABLE "Personel"."Danisman"
	ADD CONSTRAINT "DanismanPersonel" FOREIGN KEY ("personelNo")
	REFERENCES "Personel"."Personel" ("personelNo")
	ON DELETE CASCADE
	ON UPDATE CASCADE;


ALTER TABLE "Personel"."SatisTemsilcisi"
	ADD CONSTRAINT "SatisTemsilcisiPersonel" FOREIGN KEY ("personelNo")
	REFERENCES "Personel"."Personel" ("personelNo")
	ON DELETE CASCADE
	ON UPDATE CASCADE;


SELECT * FROM "Personel"."Personel"
INNER JOIN "Personel"."SatisTemsilcisi"
ON "Personel"."Personel"."personelNo" = "Personel"."SatisTemsilcisi"."personelNo"


SELECT "adi", "soyadi" FROM "Personel"."Personel"
WHERE "personelTipi"='S';


------------------------------


-- Görünüm / View Örneği


CREATE OR REPLACE VIEW "public"."SiparisMusteriSatisTemsilcisi" AS
SELECT "orders"."OrderID",
    "orders"."OrderDate",
    "customers"."CompanyName",
    "customers"."ContactName",
    "employees"."FirstName",
    "employees"."LastName"
FROM "orders"
INNER JOIN "employees" ON "orders"."EmployeeID" = "employees"."EmployeeID"
INNER JOIN "customers" ON "orders"."CustomerID" = "customers"."CustomerID";


SELECT * FROM "SiparisMusteriSatisTemsilcisi"
------------------------------


-- Özyineli Birleştirme / Tekli İlişki Örneği


ALTER TABLE "employees"
	ADD CONSTRAINT "lnk_employees_employees" FOREIGN KEY ("ReportsTo")
	REFERENCES "employees" ("EmployeeID")
	ON DELETE CASCADE
	ON UPDATE CASCADE;


SELECT "Calisan"."FirstName" AS "Calisan Ilk Isim",
	    "Calisan"."LastName" AS "Calisan Soy Isim",
	    "Yonetici"."FirstName" AS "Yonetici Ilk Isim",
	    "Yonetici"."LastName" AS "Yonetici Soy Isim"
FROM "employees" AS "Calisan"
INNER JOIN "employees" AS "Yonetici" ON "Yonetici"."EmployeeID" = "Calisan"."ReportsTo";



SELECT "Calisan"."FirstName" AS "Calisan Ilk Isim",
	    "Calisan"."LastName" AS "Calisan Soy Isim",
	    "Yonetici"."FirstName" AS "Yonetici Ilk Isim",
	    "Yonetici"."LastName" AS "Yonetici Soy Isim"
FROM "employees" AS "Calisan"
LEFT OUTER JOIN "employees" AS "Yonetici" ON "Yonetici"."EmployeeID" = "Calisan"."ReportsTo";


------------------------------


-- Alt Sorgu Örnekleri


-- Örnek


SELECT AVG("UnitPrice") FROM "products";


SELECT "ProductID", "UnitPrice" FROM "products"
WHERE "UnitPrice" < (SELECT AVG("UnitPrice") FROM "products");


-- Örnek


SELECT "ProductID" FROM "products" WHERE "ProductName" = 'Bilgisayar Y Z';


SELECT DISTINCT "public"."customers"."CustomerID",
    "public"."customers"."CompanyName",
    "public"."customers"."ContactName"
FROM "orders"
INNER JOIN "customers" ON "orders"."CustomerID" = "customers"."CustomerID"
INNER JOIN "order_details" ON "order_details"."OrderID" = "orders"."OrderID"
WHERE "order_details"."ProductID" =
    (SELECT "ProductID" FROM "products" WHERE "ProductName" = 'Bilgisayar Y Z')
ORDER BY "public"."customers"."CustomerID";


-- Örnek

SELECT "SupplierID" FROM "products" WHERE "UnitPrice" > 18

SELECT * FROM "suppliers"
WHERE "SupplierID" IN
    (SELECT "SupplierID" FROM "products" WHERE "UnitPrice" > 18);


-- Örnek

SELECT "ProductID" FROM "products" WHERE "ProductName" LIKE 'A%';

SELECT DISTINCT "public"."customers"."CustomerID",
    "public"."customers"."CompanyName",
    "public"."customers"."ContactName"
FROM "orders"
INNER JOIN "customers" ON "orders"."CustomerID" = "customers"."CustomerID"
INNER JOIN "order_details" ON "order_details"."OrderID" = "orders"."OrderID"
WHERE "order_details"."ProductID" IN
    (SELECT "ProductID" FROM "products" WHERE "ProductName" LIKE 'A%');


-- Örnek


SELECT * FROM  "products"
WHERE "UnitPrice" = ANY
(
    SELECT "UnitPrice"
    FROM "suppliers"
    LEFT OUTER JOIN "products"
    ON "suppliers"."SupplierID" = "products"."SupplierID"
    WHERE "suppliers"."CompanyName" = 'Tokyo Traders'
);


SELECT * FROM  "products"
WHERE "UnitPrice" IN
(
    SELECT "UnitPrice"
    FROM "suppliers"
    LEFT OUTER JOIN "products"
    ON "suppliers"."SupplierID" = "products"."SupplierID"
    WHERE "suppliers"."CompanyName" = 'Tokyo Traders'
);


SELECT * FROM  "products"
WHERE "UnitPrice" < ANY
(
    SELECT "UnitPrice"
    FROM "suppliers"
    LEFT OUTER JOIN "products"
    ON "suppliers"."SupplierID" = "products"."SupplierID"
    WHERE "suppliers"."CompanyName" = 'Tokyo Traders'
);


SELECT * FROM  "products"
WHERE "UnitPrice" < ALL
(
    SELECT "UnitPrice"
    FROM "suppliers"
    LEFT OUTER JOIN "products"
    ON "suppliers"."SupplierID" = "products"."SupplierID"
    WHERE "suppliers"."CompanyName" = 'Tokyo Traders'
);


-- Örnek

SELECT AVG("UnitsInStock") FROM "products";

SELECT "SupplierID", SUM("UnitsInStock") AS "Stoktaki Toplam Ürün Sayısı"
FROM  "products"
GROUP BY "SupplierID"
HAVING SUM("UnitsInStock") < (SELECT AVG("UnitsInStock") FROM "products");


-- Örnek


SELECT MAX("Quantity") FROM "order_details";


SELECT "ProductID", SUM("Quantity")
FROM "order_details"
GROUP BY "ProductID"
HAVING SUM("Quantity") > (SELECT MAX("Quantity") FROM "order_details");


-- Örnek


SELECT
    "ProductName",
    "UnitsInStock",
    (SELECT MAX("UnitsInStock") FROM "products") AS "En Büyük Değer"
FROM "products";


SELECT
    "SupplierID",
    COUNT("UnitsInStock") AS "Toplam",
    SQRT(SUM(("UnitsInStock" - (SELECT AVG("UnitsInStock") FROM "products")) ^ 2) / COUNT("UnitsInStock"))  AS "Standart Sapma"
FROM "products"
GROUP BY "SupplierID"


-- Örnek


SELECT "ProductName", "UnitPrice" FROM "products" AS "urunler1"
WHERE "urunler1"."UnitPrice" >
(
SELECT AVG("UnitPrice") FROM "products" AS "urunler2"
WHERE "urunler1"."SupplierID" = "urunler2"."SupplierID"
);


SELECT "CustomerID", "CompanyName", "ContactName"
FROM "customers"
WHERE EXISTS
    (SELECT * FROM "orders" WHERE "customers"."CustomerID" = "orders"."CustomerID");


-- Örnek


SELECT "CustomerID" FROM "customers"
UNION
SELECT "CustomerID" FROM "orders"
ORDER BY "CustomerID";


SELECT "CustomerID" FROM "customers"
UNION ALL
SELECT "CustomerID" FROM "orders"
ORDER BY "CustomerID";


SELECT "CompanyName", "Country" FROM "customers"
UNION ALL
SELECT "CompanyName", "Country" FROM "suppliers"
ORDER BY 2;


SELECT "CompanyName", "Country" FROM "customers"
EXCEPT
SELECT "CompanyName", "Country" FROM "suppliers"
ORDER BY 2;

------İşlem (Transaction)-----

-- İşlem (transaction) veri tabanı yönetim sistemlerinin önemli özelliklerinden birisi.
-- ACID ile belirtilen ozellikleri destekler

--ACID:  
--Atomicity: İşlem(transaction) kapsamındaki alt işlemlerin tamamı bir bütün olarak ele alınır. Ya alt işlemlerin tamamı 
--başarılı olarak çalıştırılır, ya da herhangi birinde hata varsa tamamı iptal edilir ve veritabanı eski kararlı haline 
--döndürülür. 
--Consistency: Herhangi bir kısıt ihlal edilirse roll back işlemiyle veritabanı eski kararlı haline döndürülür.
--Isolation: İşlemler birbirlerini (ortak kaynak kullanımı durumunda) etkilemezler. Kullanılan ortak kaynak işlem tarafından, 
--işlem tamamlanana kadar, kilitlenir.
--Durability: Sistem tarafından bir hata meydana gelmesi durumunda tamamlanmış olan işlem sistem çalışmaya başladıktan sonra 
--mutlaka tamamlanır.

----------------------------------------------------
BEGIN; --İşleme (Transaction) başla.

INSERT INTO "order_details" ("OrderID", "ProductID", "UnitPrice", "Quantity", "Discount")
VALUES (10248, 11, 20, 2, 0);

-- Yukarıdaki sorguda hata mevcutsa ilerlenilmez.
-- Aşağıdaki sorguda hata mevcutsa bu noktadan geri sarılır (rollback).
-- Yani yukarıdaki sorguda yapılan işlemler geri alınır.

Update "products" 
SET "UnitsInStock" = "UnitsInStock" - 2
WHERE "ProductID" = 11;

-- Her iki sorguda hatasız bir şekilde icra edilirse her ikisini de işlet ve veri tabanının durumunu güncelle.

COMMIT; --İşlemi (transaction) tamamla.

----------------------------------------------------
BEGIN;
UPDATE Hesap SET bakiye = bakiye - 100.00
    WHERE adi = 'Ahmet';

--SAVEPOINT my_savepoint;

UPDATE Hesap SET bakiye = bakiye + 100.00
    WHERE adi = 'Mehmet';

-- parayı Mehmete değil Ayşeye gönder
--ROLLBACK TO my_savepoint;
--UPDATE Hesap SET bakiye = bakiye + 100.00
    --WHERE adi = 'Ayşe';
COMMIT;





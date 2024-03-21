DROP TABLE IF EXISTS brands; 
DROP TABLE IF EXISTS categories; 
DROP TABLE IF EXISTS customers; 
DROP TABLE IF EXISTS order_items; 
DROP TABLE IF EXISTS orders; 
DROP TABLE IF EXISTS products; 
DROP TABLE IF EXISTS staffs CASCADE;
DROP TABLE IF EXISTS stocks;
DROP TABLE IF EXISTS stores;


CREATE TABLE "stores" (
  "store_id" integer PRIMARY KEY,
  "store_name" varchar(80),
  "phone" char(14),
  "email" text,
  "street" text,
  "city" varchar(80),
  "state" char(2),
  "zip_code" integer
);

CREATE TABLE "staffs" (
  "staff_id" integer PRIMARY KEY,
  "first_name" varchar(80),
  "last_name" varchar(80),
  "email" text,
  "phone" char(14),
  "active" integer,
  "store_id" integer,
  "manager_id" integer NULL 
);

CREATE TABLE "brands" (
  "brand_id" integer PRIMARY KEY,
  "brand_name" varchar(80)
);

CREATE TABLE "categories" (
  "category_id" integer PRIMARY KEY,
  "category_name" varchar(80)
);

CREATE TABLE "customers" (
  "customer_id" INTEGER PRIMARY KEY,
  "firstname" varchar(80),
  "lastname" varchar(80),
  "phone" char(14),
  "email" text,
  "street" text,
  "city" varchar(80),
  "state" char(2),
  "zip_code" integer
);

CREATE TABLE "order_items" (
  "order_id" integer,
  "item_id" integer,
  "product_id" integer,
  "quantity" integer,
  "list_price" float,
  "discount" float
);

CREATE TABLE "orders" (
  "order_id" integer PRIMARY KEY,
  "customer_id" integer,
  "order_status" integer,
  "order_date" date,
  "required_date" date,
  "shipped_date" date NULL,
  "store_id" integer,
  "staff_id" integer
);

CREATE TABLE "products" (
  "product_id" integer PRIMARY KEY,
  "product_name" text,
  "brand_id" integer,
  "category_id" integer,
  "model_year" integer,
  "list_price" float
);

CREATE TABLE "stocks" (
  "store_id" integer,
  "product_id" integer,
  "quantity" integer
);

ALTER TABLE "staffs" ADD FOREIGN KEY ("staff_id") REFERENCES "staffs" ("manager_id");

ALTER TABLE "staffs" ADD FOREIGN KEY ("store_id") REFERENCES "stores" ("store_id");

ALTER TABLE "order_items" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id");

ALTER TABLE "orders" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id");

ALTER TABLE "orders" ADD FOREIGN KEY ("store_id") REFERENCES "stores" ("store_id");

ALTER TABLE "orders" ADD FOREIGN KEY ("staff_id") REFERENCES "staffs" ("staff_id");

ALTER TABLE "products" ADD FOREIGN KEY ("brand_id") REFERENCES "brands" ("brand_id");

ALTER TABLE "products" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("category_id");

ALTER TABLE "stocks" ADD FOREIGN KEY ("store_id") REFERENCES "stores" ("store_id");

ALTER TABLE "stocks" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id");

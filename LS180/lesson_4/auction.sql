DROP TABLE IF EXISTS public.bidders;
DROP TABLE IF EXISTS public.items;
DROP TABLE IF EXISTS public.bids;

CREATE TABLE bidders (
  id serial PRIMARY KEY,
  name text NOT NULL
);

CREATE TABLE items (
  id serial PRIMARY KEY,
  name text NOT NULL,
  initial_price numeric(6, 2) NOT NULL CHECK (initial_price BETWEEN 0.01 AND 1000.00),
  sales_price numeric(6, 2) CHECK (sales_price BETWEEN 0.01 AND 1000.00)
);

CREATE TABLE bids (
  id serial PRIMARY KEY,
  bidder_id integer NOT NULL REFERENCES bidders(id) ON DELETE CASCADE,
  item_id integer NOT NULL REFERENCES items(id) ON DELETE CASCADE,
  amount numeric(6, 2) NOT NULL CHECK (amount BETWEEN 0.01 AND 1000.00)
);

CREATE INDEX ON bids(bidder_id, item_id);

SELECT name AS "Bids on Items" 
FROM items 
  WHERE items.id IN (SELECT DISTINCT bids.item_id FROM bids);

SELECT name AS "Not Bid On"
FROM items 
  WHERE items.id NOT IN (SELECT DISTINCT bids.item_id from bids);

SELECT bidders.name 
FROM bidders 
WHERE EXISTS (SELECT 1 FROM bids WHERE bids.bidder_id = bidders.id);


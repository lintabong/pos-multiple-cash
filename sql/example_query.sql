INSERT INTO transactions (transaction_type, source_type, amount, wallet_id, target_wallet_id, description) 
VALUES ('TRANSFER', 'TRANSFER', 100000, 1, 2, '');

INSERT INTO transactions ( transaction_type, source_type, business_name, user_id, description, amount, wallet_id, category_id, transaction_date)
VALUES ('EXPENSE', 'PERSONAL', NULL, 3, 'Netflix', 54000, 4, 6, '2024-10-05 14:30:00'
);

INSERT INTO transactions ( 
    transaction_type, source_type, business_name, user_id, description, amount, wallet_id, category_id, transaction_date
)
VALUES (
    'EXPENSE', 'PERSONAL', NULL, 3, 'sekolah irrish tk', 1700000, 4, 5, '2024-07-01 18:28:00'
);

INSERT INTO transactions ( 
    transaction_type, source_type, business_name, user_id, description, amount, wallet_id, category_id, transaction_date
)
VALUES (
    'EXPENSE', 'PERSONAL', NULL, 3, 'bintang', 800000, 4, 4, '2024-07-01 19:39:00'
);

UPDATE transactions SET isActive = 0 WHERE transaction_id = 4;

INSERT INTO `items`(`product_name`, `stock_keeping_unit`, `purchase_price`, `selling_price`, `stock`, `user_id`) 
VALUES ('Male pin header 40 pin pitch 2.54mm','sku-01',480,1000,15,3);

INSERT INTO `items`(`product_name`, `stock_keeping_unit`, `purchase_price`, `selling_price`, `stock`, `user_id`) 
VALUES ('Terminal block blok (T=block) biru 2p 2 kaki','sku-01',480,800,10,3);

INSERT INTO `items`(`product_name`, `stock_keeping_unit`, `purchase_price`, `selling_price`, `stock`, `user_id`) 
VALUES ('Male pin header 40 pin pitch 2.54mm','sku-01',850,1200,10,3);

INSERT INTO `items`(`product_name`, `stock_keeping_unit`, `purchase_price`, `selling_price`, `stock`, `user_id`) 
VALUES ('Modul Charger TP4056 4.2v 1A USB type C Power Bank 18650','sku-01',1300,2200,8,3);

INSERT INTO `items`(`product_name`, `stock_keeping_unit`, `purchase_price`, `selling_price`, `stock`, `user_id`) 
VALUES ('Set Obeng 24 in 1 magnetic premium baut kecil screwdriver kit tools','sku-05',7700,17000,3,3);
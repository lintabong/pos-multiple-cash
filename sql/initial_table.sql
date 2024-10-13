CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL
);

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    isActive BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

CREATE TABLE user_detail (
    user_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(20),
    age INT,
    gender ENUM('Male', 'Female'),
    village VARCHAR(100),
    subdistrict VARCHAR(100),
    regency VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE wallets (
    wallet_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    wallet_name VARCHAR(50) NOT NULL,
    balance DECIMAL(10, 2) DEFAULT 0,
    isActive BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    transaction_type ENUM('INCOME', 'EXPENSE') NOT NULL,
    isActive BOOLEAN DEFAULT TRUE
);

CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_type ENUM('INCOME', 'EXPENSE', 'TRANSFER') NOT NULL,
    source_type ENUM('PERSONAL', 'BUSINESS', 'TRANSFER') NOT NULL,
    business_name VARCHAR(100),
    user_id INT NOT NULL,
    description VARCHAR(255),
    amount DECIMAL(10, 2) NOT NULL,
    wallet_id INT,
    target_wallet_id INT,
    category_id INT,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    isActive BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (wallet_id) REFERENCES wallets(wallet_id),
    FOREIGN KEY (target_wallet_id) REFERENCES wallets(wallet_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    INDEX idx_transaction_date (transaction_date)  -- Menambahkan index pada kolom transaction_date
);

CREATE TABLE items (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    stock_keeping_unit VARCHAR(100) NOT NULL,
    purchase_price DECIMAL(10, 2) NOT NULL,
    selling_price DECIMAL(10, 2) NOT NULL,
    stock INT DEFAULT 0,
    user_id INT NOT NULL,
    business_name VARCHAR(100),
    category_id INT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
);

CREATE TABLE sale_items (
    sale_item_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    FOREIGN KEY (product_id) REFERENCES items(product_id)
);

DELIMITER $$

CREATE TRIGGER update_wallet_balance_after_transfer
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    IF NEW.transaction_type = 'TRANSFER' THEN
        -- Mengurangi saldo dompet sumber
        UPDATE wallets 
        SET balance = balance - NEW.amount 
        WHERE wallet_id = NEW.wallet_id;

        -- Menambahkan saldo ke dompet tujuan
        UPDATE wallets 
        SET balance = balance + NEW.amount 
        WHERE wallet_id = NEW.target_wallet_id;
    END IF;
END $$

CREATE TRIGGER update_wallet_balance_after_expense
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    IF NEW.transaction_type = 'EXPENSE' THEN
        -- Mengurangi saldo dari dompet sumber
        UPDATE wallets 
        SET balance = balance - NEW.amount
        WHERE wallet_id = NEW.wallet_id;
    END IF;
END $$

CREATE TRIGGER update_wallet_balance_after_income
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    IF NEW.transaction_type = 'INCOME' THEN
        -- Menambahkan saldo ke dompet sumber
        UPDATE wallets 
        SET balance = balance + NEW.amount
        WHERE wallet_id = NEW.wallet_id;
    END IF;
END $$;

CREATE TRIGGER update_wallet_balance_after_transaction_update
AFTER UPDATE ON transactions
FOR EACH ROW
BEGIN
    -- Jika nominal transaksi diperbarui
    IF OLD.transaction_type = 'INCOME' THEN
        -- Kurangi saldo berdasarkan nilai lama
        UPDATE wallets 
        SET balance = balance - OLD.amount
        WHERE wallet_id = OLD.wallet_id;

        -- Tambahkan saldo berdasarkan nilai baru
        UPDATE wallets 
        SET balance = balance + NEW.amount
        WHERE wallet_id = NEW.wallet_id;
    
    ELSEIF OLD.transaction_type = 'EXPENSE' THEN
        -- Tambahkan saldo berdasarkan nilai lama
        UPDATE wallets 
        SET balance = balance + OLD.amount
        WHERE wallet_id = OLD.wallet_id;

        -- Kurangi saldo berdasarkan nilai baru
        UPDATE wallets 
        SET balance = balance - NEW.amount
        WHERE wallet_id = NEW.wallet_id;
    
    ELSEIF OLD.transaction_type = 'TRANSFER' THEN
        -- Kurangi saldo dompet sumber dengan nilai lama
        UPDATE wallets 
        SET balance = balance + OLD.amount
        WHERE wallet_id = OLD.wallet_id;

        -- Tambahkan saldo ke dompet tujuan dengan nilai lama
        UPDATE wallets 
        SET balance = balance - OLD.amount
        WHERE wallet_id = OLD.target_wallet_id;

        -- Tambahkan saldo dompet sumber dengan nilai baru
        UPDATE wallets 
        SET balance = balance - NEW.amount
        WHERE wallet_id = NEW.wallet_id;

        -- Kurangi saldo dari dompet tujuan dengan nilai baru
        UPDATE wallets 
        SET balance = balance + NEW.amount
        WHERE wallet_id = NEW.target_wallet_id;
    END IF;
END $$;

CREATE TRIGGER update_wallet_balance_after_wallet_id_change
AFTER UPDATE ON transactions
FOR EACH ROW
BEGIN
    -- Cek jika wallet_id diperbarui
    IF OLD.wallet_id != NEW.wallet_id THEN
        -- Tambahkan saldo ke dompet lama
        UPDATE wallets 
        SET balance = balance + OLD.amount
        WHERE wallet_id = OLD.wallet_id;

        -- Kurangi saldo dari dompet baru
        UPDATE wallets 
        SET balance = balance - NEW.amount
        WHERE wallet_id = NEW.wallet_id;
    END IF;
END $$;


CREATE TRIGGER after_user_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO user_detail (user_id) VALUES (NEW.user_id);
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER update_item_stock_after_sale
AFTER INSERT ON sale_items
FOR EACH ROW
BEGIN
    DECLARE trans_type ENUM('INCOME', 'EXPENSE');  -- Variabel untuk menyimpan tipe transaksi

    -- Ambil transaction_type dari transaksi terkait
    SELECT transaction_type INTO trans_type
    FROM transactions
    WHERE transaction_id = NEW.transaction_id;

    -- Jika transaksi adalah penjualan (INCOME), kurangi stok
    IF trans_type = 'INCOME' THEN
        UPDATE items 
        SET stock = stock - NEW.quantity 
        WHERE product_id = NEW.product_id;
    
    -- Jika transaksi adalah pembelian (EXPENSE), tambah stok
    ELSEIF trans_type = 'EXPENSE' THEN
        UPDATE items 
        SET stock = stock + NEW.quantity 
        WHERE product_id = NEW.product_id;
    END IF;
END $$

DELIMITER ;

INSERT INTO `roles`(`role_name`) VALUES ('superadmin');
INSERT INTO `roles`(`role_name`) VALUES ('admin');
INSERT INTO `roles`(`role_name`) VALUES ('owner');
INSERT INTO `roles`(`role_name`) VALUES ('employee');

INSERT INTO users (username, email, password, role_id, isActive) VALUES ('superadmin', 'superadmin@gmail.com', '121', 1, TRUE);
INSERT INTO users (username, email, password, role_id, isActive) VALUES ('admin', 'admin@gmail.com', '121', 2, TRUE);
INSERT INTO users (username, email, password, role_id, isActive) VALUES ('lintang', 'lintang@gmail.com', '121', 3, TRUE);

INSERT INTO `wallets`(`user_id`, `wallet_name`, `balance`) VALUES (3, 'Cash', 0);
INSERT INTO `wallets`(`user_id`, `wallet_name`, `balance`) VALUES (3, 'Bank Mandiri', 0);
INSERT INTO `wallets`(`user_id`, `wallet_name`, `balance`) VALUES (3, 'BSI', 0);
INSERT INTO `wallets`(`user_id`, `wallet_name`, `balance`) VALUES (3, 'Gopay', 0);
INSERT INTO `wallets`(`user_id`, `wallet_name`, `balance`) VALUES (3, 'Dana', 0);
INSERT INTO `wallets`(`user_id`, `wallet_name`, `balance`) VALUES (3, 'BRI', 0);

INSERT INTO `categories`(`category_name`, `transaction_type`) VALUES ('Komponen','EXPENSE');
INSERT INTO `categories`(`category_name`, `transaction_type`) VALUES ('Proyek','EXPENSE');
INSERT INTO `categories`(`category_name`, `transaction_type`) VALUES ('Acrylic','EXPENSE');
INSERT INTO `categories`(`category_name`, `transaction_type`) VALUES ('Bayar hutang','EXPENSE');
INSERT INTO `categories`(`category_name`, `transaction_type`) VALUES ('Pendidikan','EXPENSE');
INSERT INTO `categories`(`category_name`, `transaction_type`) VALUES ('Langganan','EXPENSE');
INSERT INTO `categories`(`category_name`, `transaction_type`) VALUES ('Gaji','INCOME');
INSERT INTO `categories`(`category_name`, `transaction_type`) VALUES ('Sampingan','INCOME');
INSERT INTO `categories`(`category_name`, `transaction_type`) VALUES ('Elektronik','EXPENSE');
INSERT INTO `categories`(`category_name`, `transaction_type`) VALUES ('Makan Jajan','EXPENSE');
INSERT INTO `categories`(`category_name`, `transaction_type`) VALUES ('Internet','EXPENSE');
INSERT INTO `categories`(`category_name`, `transaction_type`) VALUES ('Zakat','EXPENSE');
INSERT INTO `categories`(`category_name`, `transaction_type`) VALUES ('Kesehatan','EXPENSE');
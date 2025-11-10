DROP DATABASE IF EXISTS sqlutions;
CREATE DATABASE sqlutions;
USE sqlutions;

-- ================== 1. TABLE CREATION ==================
CREATE TABLE medicine (
    medicine_id   INT PRIMARY KEY AUTO_INCREMENT,
    medicine_name VARCHAR(50),
    brand         VARCHAR(50),
    cost          INT,
    dose          INT,
    expiry_date   DATE
);

CREATE TABLE customer (
    customer_id     INT PRIMARY KEY AUTO_INCREMENT,
    customer_name   VARCHAR(50),
    date_of_birth   DATE,
    gender          CHAR(1),
    phone           VARCHAR(10),
    address_street  VARCHAR(105),
    address_city    VARCHAR(50),
    address_state   VARCHAR(50)
);

CREATE TABLE pharmacist (
    pharmacist_id   INT PRIMARY KEY AUTO_INCREMENT,
    name            VARCHAR(50),
    email           VARCHAR(100),
    phone           VARCHAR(10),
    qualification   VARCHAR(50)
);

CREATE TABLE stock (
    stock_id          INT PRIMARY KEY AUTO_INCREMENT,
    medicine_id       INT,
    quantity_available INT,
    last_updated      DATE,
    FOREIGN KEY (medicine_id) REFERENCES medicine(medicine_id)
);

CREATE TABLE prescription (
    prescription_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id     INT,
    doctor_name     VARCHAR(50),
    issue_date      DATE,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

CREATE TABLE prescribed_medicine (
    prescription_id INT,
    medicine_id     INT,
    dosage          VARCHAR(50),
    duration        INT,
    instructions    TEXT,
    PRIMARY KEY (prescription_id, medicine_id),
    FOREIGN KEY (prescription_id) REFERENCES prescription(prescription_id),
    FOREIGN KEY (medicine_id)     REFERENCES medicine(medicine_id)
);

CREATE TABLE bill (
    bill_id       INT PRIMARY KEY AUTO_INCREMENT,
    customer_id   INT,
    pharmacist_id INT,
    bill_date     DATE,
    total_amount  DECIMAL(10,2),
    FOREIGN KEY (customer_id)   REFERENCES customer(customer_id),
    FOREIGN KEY (pharmacist_id) REFERENCES pharmacist(pharmacist_id)
);

CREATE TABLE bill_items (
    bill_id     INT,
    medicine_id INT,
    quantity    INT,
    subtotal    DECIMAL(10,2),
    PRIMARY KEY (bill_id, medicine_id),
    FOREIGN KEY (bill_id)     REFERENCES bill(bill_id),
    FOREIGN KEY (medicine_id) REFERENCES medicine(medicine_id)
);

-- ================== 2. INSERT DATA ==================

-- 2.1 Medicines
INSERT INTO medicine (medicine_name, brand, cost, dose, expiry_date) VALUES
('Paracetamol',      'Cipla',       20, 500, '2026-06-01'),
('Amoxicillin',      'Sun Pharma',  50, 250, '2025-12-31'),
('Cetirizine',       'Zydus',       15,  10, '2026-03-10'),
('Ibuprofen',        'Cipla',       40, 400, '2026-12-01'),
('Azithromycin',     'Sun Pharma',  60, 250, '2026-08-15'),
('Metformin',        'Zydus',       30, 500, '2027-01-10'),
('Aspirin',          'Dr. Reddy',   25, 100, '2026-11-30'),
('Dolo',             'Torrent',     20, 650, '2027-05-05'),
('Pantoprazole',     'Cipla',       35,  40, '2026-09-12'),
('Rabeprazole',      'Sun Pharma',  50,  20, '2026-07-01'),
('Losartan',         'Zydus',       45,  50, '2027-03-01'),
('Atorvastatin',     'Dr. Reddy',   55,  10, '2027-06-15'),
('Levocetirizine',   'Torrent',     15,   5, '2027-02-20'),
('Omeprazole',       'Cipla',       40,  20, '2026-10-01'),
('Domperidone',      'Sun Pharma',  25,  10, '2026-09-09'),
('Ranitidine',       'Zydus',       20, 150, '2027-04-01'),
('Amiodarone',       'Dr. Reddy',   70, 200, '2026-12-12'),
('Fluconazole',      'Torrent',     60, 150, '2027-01-01'),
('Loratadine',       'Cipla',       35,  10, '2026-11-20'),
('Naproxen',         'Sun Pharma',  65, 250, '2026-10-15');

-- 2.2 Customers
INSERT INTO customer (customer_name, date_of_birth, gender, phone, address_street, address_city, address_state) VALUES
('Amit Sharma',    '1990-02-15', 'M', '9876543210', '123 Main St',      'Delhi',        'Delhi'),
('Priya Mehta',    '1985-07-20', 'F', '9123456789', '456 South Ave',    'Mumbai',       'Maharashtra'),
('Rahul Kumar',    '1992-11-30', 'M', '9988776655', '789 Park Rd',      'Bangalore',    'Karnataka'),
('Anjali Singh',   '1995-04-10', 'F', '9876543211', '101 Lake View',    'Kolkata',      'West Bengal'),
('Vikram Patel',   '1988-09-05', 'M', '9112233445', '234 MG Road',      'Chennai',      'Tamil Nadu'),
('Sneha Gupta',    '2000-01-25', 'F', '9334455667', '567 High St',      'Hyderabad',    'Telangana'),
('Rohan Joshi',    '1993-06-18', 'M', '9445566778', '890 River Side',   'Pune',         'Maharashtra'),
('Kavita Reddy',   '1982-03-12', 'F', '9556677889', '321 Green Valley', 'Ahmedabad',    'Gujarat'),
('Suresh Nair',    '1979-08-22', 'M', '9667788990', '654 Temple St',    'Jaipur',       'Rajasthan'),
('Divya Verma',    '1998-12-01', 'F', '9778899001', '987 Hilltop Dr',   'Lucknow',      'Uttar Pradesh'),
('Arjun Das',      '1991-05-14', 'M', '9889900112', '111 Ocean Dr',     'Kochi',        'Kerala'),
('Pooja Agarwal',  '1996-10-28', 'F', '9990011223', '222 Sunset Blvd',  'Chandigarh',   'Punjab'),
('Manish Tiwari',  '1986-04-03', 'M', '9001122334', '333 Central Plaza','Bhopal',       'Madhya Pradesh'),
('Nikita Shah',    '1994-07-09', 'F', '9112233446', '444 North Gate',   'Indore',       'Madhya Pradesh'),
('Sandeep Yadav',  '1980-02-20', 'M', '9223344557', '555 East Lane',    'Patna',        'Bihar'),
('Meera Iyer',     '1999-09-17', 'F', '9334455668', '666 West End',     'Guwahati',     'Assam'),
('Harish Kumar',   '1983-11-23', 'M', '9445566779', '777 Galaxy Apt',   'Visakhapatnam','Andhra Pradesh'),
('Sunita Rao',     '1997-01-08', 'F', '9556677880', '888 Star Colony',  'Nagpur',       'Maharashtra'),
('Deepak Mishra',  '1989-06-30', 'M', '9667788991', '999 Moonbeam Rd',  'Surat',        'Gujarat');

-- 2.3 Pharmacists
INSERT INTO pharmacist (name, email, phone, qualification) VALUES
('Rita Mehra',      'rita@pharmacy.com',      '9998887776', 'B.Pharm'),
('Rohit Jain',      'rohit@pharmacy.com',     '8887776665', 'D.Pharm'),
('Anjali Sharma',   'anjali@pharmacy.com',    '9876543212', 'M.Pharm'),
('Sameer Gupta',    'sameer@pharmacy.com',    '9123456789', 'B.Pharm'),
('Kavita Singh',    'kavita@pharmacy.com',    '9988776655', 'D.Pharm'),
('Vikram Kumar',    'vikram@pharmacy.com',    '9876543211', 'B.Pharm'),
('Sneha Patel',     'sneha@pharmacy.com',     '9112233445', 'M.Pharm'),
('Alok Verma',      'alok@pharmacy.com',      '9334455667', 'D.Pharm'),
('Priya Desai',     'pdesai@pharmacy.com',    '9445566778', 'B.Pharm'),
('Sunil Reddy',     'sunil@pharmacy.com',     '9556677889', 'B.Pharm'),
('Meena Iyer',      'meena@pharmacy.com',     '9667788990', 'Pharm.D'),
('Rajesh Nair',     'rajesh@pharmacy.com',    '9778899001', 'D.Pharm'),
('Divya Joshi',     'divya@pharmacy.com',     '9889900112', 'B.Pharm'),
('Amit Chauhan',    'amit@pharmacy.com',      '9990011223', 'M.Pharm'),
('Neha Agarwal',    'neha@pharmacy.com',      '9001122334', 'B.Pharm'),
('Tarun Mehta',     'tarun@pharmacy.com',     '9112233446', 'D.Pharm'),
('Sonali Shah',     'sonali@pharmacy.com',    '9223344557', 'B.Pharm'),
('Manoj Kumar',     'manoj@pharmacy.com',     '9334455668', 'Pharm.D'),
('Geeta Yadav',     'geeta@pharmacy.com',     '9445566779', 'M.Pharm'),
('Prakash Rao',     'prakash@pharmacy.com',   '9556677880', 'B.Pharm');

-- 2.4 Stock
INSERT INTO stock (medicine_id, quantity_available, last_updated) VALUES
(1,100,'2025-11-05'),(2,50,'2025-11-05'),(3,75,'2025-11-05'),(4,120,'2025-11-05'),
(5,80,'2025-11-05'),(6,200,'2025-11-05'),(7,60,'2025-11-05'),(8,90,'2025-11-05'),
(9,150,'2025-11-05'),(10,40,'2025-11-05'),(11,110,'2025-11-05'),(12,70,'2025-11-05'),
(13,130,'2025-11-05'),(14,25,'2025-11-05'),(15,180,'2025-11-05'),(16,95,'2025-11-05'),
(17,55,'2025-11-05'),(18,85,'2025-11-05'),(19,140,'2025-11-05'),(20,65,'2025-11-05');

-- 2.5 Prescriptions
INSERT INTO prescription (customer_id, doctor_name, issue_date) VALUES
(1,'Dr. Neha Kapoor','2025-09-20'),(2,'Dr. Rajiv Menon','2025-09-25'),
(3,'Dr. Suresh Gupta','2025-09-15'),(4,'Dr. Anjali Desai','2025-09-28'),
(5,'Dr. Vikram Singh','2025-10-01'),(6,'Dr. Priya Sharma','2025-09-22'),
(7,'Dr. Mohan Kumar','2025-09-18'),(8,'Dr. Sunita Patil','2025-09-30'),
(9,'Dr. Arjun Reddy','2025-09-21'),(10,'Dr. Kavita Rao','2025-09-26'),
(11,'Dr. Rajesh Khanna','2025-09-19'),(12,'Dr. Meena Joshi','2025-09-29'),
(13,'Dr. Sameer Khan','2025-09-23'),(14,'Dr. Geeta Nair','2025-09-27'),
(15,'Dr. Harish Verma','2025-09-16'),(16,'Dr. Deepa Iyer','2025-09-24'),
(17,'Dr. Alok Mishra','2025-09-17'),(18,'Dr. Rina Mehta','2025-09-20'),
(19,'Dr. Sandeep Shah','2025-09-28');

-- 2.6 Prescribed Medicines
INSERT INTO prescribed_medicine (prescription_id, medicine_id, dosage, duration, instructions) VALUES
(1,1,'1 tablet twice a day',5,'After meals'),
(1,2,'1 capsule daily',7,'Morning only'),
(2,3,'1 tablet at night',3,'Before bed'),
(2,5,'1 tablet as needed',10,'For pain relief, max 3 per day'),
(3,7,'1 tablet twice a day',30,'Before meals'),
(4,6,'1 tablet daily',5,'Finish the course'),
(5,9,'1 tablet daily',14,'In the morning'),
(6,4,'1 capsule before breakfast',30,NULL),
(7,18,'Apply gel twice a day',7,'External use only'),
(8,10,'2 puffs as needed',90,'For shortness of breath'),
(9,8,'1 tablet at bedtime',30,NULL),
(10,12,'1 tablet in the evening',28,'For allergies'),
(11,19,'1 tablet every 12 hours',7,'With plenty of water'),
(12,13,'1 tablet 30 mins before food',14,NULL),
(13,15,'1 tablet twice a day',10,'After meals'),
(14,1,'2 tablets every 6 hours',3,'For fever'),
(14,5,'1 tablet as needed for pain',3,'Max 3 per day'),
(15,20,'1 tablet in the morning',15,NULL),
(16,11,'1 tablet daily',30,'With breakfast'),
(17,16,'1 capsule three times a day',10,'After meals');

-- ================== 3. BILLS (parent first) ==================
INSERT INTO bill (customer_id, pharmacist_id, bill_date, total_amount) VALUES
(1,1,'2025-09-28',90.00),(2,2,'2025-09-29',65.00),(3,3,'2025-09-15',375.00),
(4,4,'2025-09-28',60.00),(5,5,'2025-10-01',280.00),(6,6,'2025-09-23',320.00),
(7,7,'2025-09-18',60.00),(8,8,'2025-09-30',100.00),(9,9,'2025-09-22',120.00),
(10,10,'2025-09-26',165.00),(11,11,'2025-09-20',140.00),(12,12,'2025-09-30',180.00),
(13,13,'2025-09-24',200.00),(14,14,'2025-09-27',220.00),(15,15,'2025-09-17',455.00),
(16,16,'2025-09-25',450.00),(17,17,'2025-09-19',160.00);

-- ================== 4. BILL ITEMS (child) ==================
INSERT INTO bill_items (bill_id, medicine_id, quantity, subtotal) VALUES
(1,1,2,40.00),(1,2,1,50.00),
(2,3,3,45.00),(2,1,1,20.00),
(3,7,15,375.00),
(4,6,2,60.00),
(5,9,8,280.00),
(6,4,8,320.00),
(7,18,1,60.00),
(8,10,2,100.00),
(9,8,6,120.00),
(10,12,3,165.00),
(11,19,4,140.00),
(12,13,12,180.00),
(13,15,8,200.00),
(14,1,2,40.00),(14,5,3,180.00),
(15,20,7,455.00),
(16,11,10,450.00),
(17,16,8,160.00);

-- ================== 5. VERIFICATION ==================
SHOW TABLES;
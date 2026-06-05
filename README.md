# SQLutions - Pharmacy Management System

A web-based Pharmacy Management System built with Flask and MySQL. It allows users to manage customers, create bills with live medicine search, and track sales efficiently.
Made with Python, Flask and MySQL

---

## Features

- Customer Management with age validation (18+)
- Live medicine search with autocomplete while creating bills
- Dynamic bill creation with multiple items
- Automatic total calculation
- View all bills and detailed bill information
- Responsive web interface
- Secure database operations

---

## Tech Stack

- Backend: Flask (Python)
- Database: MySQL
- Frontend: HTML, Bootstrap 5, JavaScript
- Database Connector: mysql-connector-python

---

## Project Structure

```bash
sqlutions-flask/
├── app.py                    # Main Flask Application
├── config.py                 # Database Configuration
├── .env                      # Environment Variables (Git ignored)
├── requirements.txt          # Python dependencies
├── templates/                # HTML Templates
│   ├── base.html             # Base layout template
│   ├── index.html            # Homepage
│   ├── customers.html        # Customer management page
│   ├── bills.html            # All bills listing page
│   ├── bill_details.html     # Individual bill details page
│   └── add_bill.html         # Create new bill page
└── static/                   # Static files
    └── style.css             # Custom CSS styles
```

---

## Installation and Setup

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/sqlutions-flask.git
cd sqlutions-flask
```
### 2. Install Dependencies
```bash
pip install -r requirements.txt
```
### 3. Database Setup
Run the SQL script to create the database and tables:
```SQL
SOURCE sqlutions_final.sql;
```
### 4. Configure Database
Create a .env file in the root directory:
```env
MYSQL_HOST=localhost
MYSQL_USER=root
MYSQL_PASSWORD=your_password
MYSQL_DB=sqlutions
MYSQL_PORT=3306
```
### 5. Run the Application
```bash
python app.py
```
Open your browser and navigate to:
http://127.0.0.1:5000

---
## Usage

- Home: Dashboard with navigation
- Customers: Add and view customers
- Bills: View all previous bills
- New Bill: Create new bill with live medicine search
- Type medicine name to get suggestions
- Add multiple medicines
- Submit to generate bill
---
## Database Features

- Triggers for age validation
- Proper foreign key relationships
- Complex joins and aggregate queries
- Stored procedures and functions for reporting
---
## Future Enhancements

- User authentication system
- PDF bill generation
- Stock management module
- Advanced analytics dashboard
- Search and filter improvements
---
### License
- This project is developed for academic purposes (DBMS Mini Project).
---

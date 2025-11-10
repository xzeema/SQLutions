# app.py
from flask import Flask, render_template, request, redirect, url_for, flash
import mysql.connector
from mysql.connector import Error
from config import Config
import datetime

app = Flask(__name__)
app.secret_key = 'supersecretkey'

def get_db_connection():
    try:
        conn = mysql.connector.connect(
            host=Config.MYSQL_HOST,
            user=Config.MYSQL_USER,
            password=Config.MYSQL_PASSWORD,
            database=Config.MYSQL_DB,
            port=Config.MYSQL_PORT
        )
        return conn
    except Error as e:
        print(f"DB Error: {e}")
        return None

# Home
@app.route('/')
def index():
    # NEW: A proper dashboard/index page
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    # Get some quick stats
    cursor.execute("SELECT COUNT(*) AS count FROM customer")
    customer_count = cursor.fetchone()['count']
    
    cursor.execute("SELECT COUNT(*) AS count FROM medicine")
    medicine_count = cursor.fetchone()['count']
    
    cursor.execute("SELECT COUNT(*) AS count FROM bill WHERE bill_date = CURDATE()")
    today_bills = cursor.fetchone()['count']
    
    cursor.execute("SELECT SUM(quantity_available) AS total_stock FROM stock")
    total_stock = cursor.fetchone()['total_stock']
    
    cursor.close()
    conn.close()
    
    return render_template('index.html', 
                           customer_count=customer_count,
                           medicine_count=medicine_count,
                           today_bills=today_bills,
                           total_stock=total_stock)

# View Customers + Add
@app.route('/customers', methods=['GET', 'POST'])
def customers():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    if request.method == 'POST':
        name = request.form['name']
        dob = request.form['dob']
        gender = request.form['gender']
        phone = request.form['phone']
        street = request.form['street']
        city = request.form['city']
        state = request.form['state']

        try:
            # UPDATED: This INSERT will now be checked by your trigger
            cursor.execute("""
                INSERT INTO customer 
                (customer_name, date_of_birth, gender, phone, address_street, address_city, address_state)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (name, dob, gender, phone, street, city, state))
            conn.commit()
            flash("Customer added successfully!", "success")
            
        except Error as e:
            # UPDATED: Specific error handling for your age-check trigger
            if e.sqlstate == '45000':
                # This catches the custom error message from your trigger
                flash(f"Registration Error: Customer must be at least 18 years old.", "danger")
            else:
                flash(f"Error: {e}", "danger")
        finally:
            cursor.close()
            conn.close()
        return redirect(url_for('customers'))

    # GET: Show list
    cursor.execute("SELECT * FROM customer ORDER BY customer_id DESC LIMIT 20")
    customers = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('customers.html', customers=customers)

# NEW: View Medicines + Add
@app.route('/medicines', methods=['GET', 'POST'])
def medicines():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    if request.method == 'POST':
        try:
            name = request.form['name']
            brand = request.form['brand']
            cost = request.form['cost']
            dose = request.form['dose']
            expiry = request.form['expiry_date']

            cursor.execute("""
                INSERT INTO medicine (medicine_name, brand, cost, dose, expiry_date)
                VALUES (%s, %s, %s, %s, %s)
            """, (name, brand, cost, dose, expiry))
            
            # Also add a default stock entry
            med_id = cursor.lastrowid
            cursor.execute("""
                INSERT INTO stock (medicine_id, quantity_available, last_updated)
                VALUES (%s, 0, CURDATE())
            """, (med_id,))
            
            conn.commit()
            flash("Medicine added and initial stock set to 0.", "success")
        except Error as e:
            conn.rollback()
            flash(f"Error: {e}", "danger")
        finally:
            cursor.close()
            conn.close()
        return redirect(url_for('medicines'))

    # GET: Show list
    cursor.execute("SELECT * FROM medicine ORDER BY medicine_name")
    medicines = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('medicines.html', medicines=medicines)

# NEW: View Pharmacists + Add
@app.route('/pharmacists', methods=['GET', 'POST'])
def pharmacists():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    if request.method == 'POST':
        try:
            name = request.form['name']
            email = request.form['email']
            phone = request.form['phone']
            qualification = request.form['qualification']

            cursor.execute("""
                INSERT INTO pharmacist (name, email, phone, qualification)
                VALUES (%s, %s, %s, %s)
            """, (name, email, phone, qualification))
            conn.commit()
            flash("Pharmacist added successfully!", "success")
        except Error as e:
            conn.rollback()
            flash(f"Error: {e}", "danger")
        finally:
            cursor.close()
            conn.close()
        return redirect(url_for('pharmacists'))

    # GET: Show list
    cursor.execute("SELECT * FROM pharmacist ORDER BY name")
    pharmacists = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('pharmacists.html', pharmacists=pharmacists)

# NEW: View Stock
@app.route('/stock')
def stock():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT m.medicine_name, m.brand, m.cost, s.stock_id, s.quantity_available, s.last_updated
        FROM stock s
        JOIN medicine m ON s.medicine_id = m.medicine_id
        ORDER BY m.medicine_name
    """)
    stock_levels = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('stock.html', stock_levels=stock_levels)

# View Bills
@app.route('/bills')
def bills():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT b.bill_id, b.bill_date, b.total_amount, 
               c.customer_name, p.name AS pharmacist_name
        FROM bill b
        JOIN customer c ON b.customer_id = c.customer_id
        JOIN pharmacist p ON b.pharmacist_id = p.pharmacist_id
        ORDER BY b.bill_date DESC
    """)
    bills = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('bills.html', bills=bills)

# Bill Details + Items
@app.route('/bill/<int:bill_id>')
def bill_details(bill_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    # Bill header
    cursor.execute("""
        SELECT b.*, c.customer_name, p.name AS pharmacist_name
        FROM bill b
        JOIN customer c ON b.customer_id = c.customer_id
        JOIN pharmacist p ON b.pharmacist_id = p.pharmacist_id
        WHERE b.bill_id = %s
    """, (bill_id,))
    bill = cursor.fetchone()

    # Bill items
    cursor.execute("""
        SELECT bi.*, m.medicine_name, m.brand
        FROM bill_items bi
        JOIN medicine m ON bi.medicine_id = m.medicine_id
        WHERE bi.bill_id = %s
    """, (bill_id,))
    items = cursor.fetchall()

    # UPDATED: Call your SQL function to get a calculated total for verification
    cursor.execute("SELECT fn_calculate_bill_total(%s) AS calculated_total", (bill_id,))
    calculated_total = cursor.fetchone()['calculated_total']

    cursor.close()
    conn.close()
    return render_template('bill_details.html', bill=bill, items=items, calculated_total=calculated_total)

# Add New Bill (Simple form)
@app.route('/add_bill', methods=['GET', 'POST'])
def add_bill():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    if request.method == 'POST':
        customer_id = request.form['customer_id']
        pharmacist_id = request.form['pharmacist_id']
        items = request.form.getlist('medicine_id')
        quantities = request.form.getlist('quantity')
        
        # UPDATED: Major logic update for transactional integrity and stock control
        try:
            bill_items_to_insert = []
            total = 0

            # 1. First pass: Check stock and calculate totals
            for med_id, qty in zip(items, quantities):
                qty = int(qty)
                if qty <= 0: continue
                
                # Check stock quantity
                cursor.execute("""
                    SELECT m.cost, s.quantity_available 
                    FROM medicine m
                    JOIN stock s ON m.medicine_id = s.medicine_id
                    WHERE m.medicine_id = %s
                """, (med_id,))
                med_data = cursor.fetchone()
                
                if not med_data:
                    raise Exception(f"Medicine ID {med_id} not found.")
                
                if med_data['quantity_available'] < qty:
                    raise Exception(f"Insufficient stock for medicine ID {med_id}. Available: {med_data['quantity_available']}, Requested: {qty}")

                # Calculate subtotal and add to list
                cost = med_data['cost']
                subtotal = cost * qty
                total += subtotal
                bill_items_to_insert.append((med_id, qty, subtotal))

            # 2. If all stock checks passed, insert the bill
            cursor.execute("""
                INSERT INTO bill (customer_id, pharmacist_id, bill_date, total_amount)
                VALUES (%s, %s, CURDATE(), %s)
            """, (customer_id, pharmacist_id, total))
            bill_id = cursor.lastrowid

            # 3. Insert bill items and update stock for each
            for med_id, qty, subtotal in bill_items_to_insert:
                # Insert bill item
                cursor.execute("""
                    INSERT INTO bill_items (bill_id, medicine_id, quantity, subtotal)
                    VALUES (%s, %s, %s, %s)
                """, (bill_id, med_id, qty, subtotal))
                
                # Update stock
                cursor.execute("""
                    UPDATE stock 
                    SET quantity_available = quantity_available - %s, last_updated = CURDATE()
                    WHERE medicine_id = %s
                """, (qty, med_id))

            # 4. Commit all changes at once
            conn.commit()
            flash("Bill created successfully and stock updated!", "success")
            return redirect(url_for('bill_details', bill_id=bill_id))

        except Exception as e:
            conn.rollback()
            flash(f"Error: {e}", "danger")

    # GET: Show form
    cursor.execute("SELECT customer_id, customer_name FROM customer ORDER BY customer_name")
    customers = cursor.fetchall()
    cursor.execute("SELECT pharmacist_id, name FROM pharmacist ORDER BY name")
    pharmacists = cursor.fetchall()
    
    # UPDATED: Only show medicines that are in stock
    cursor.execute("""
        SELECT m.medicine_id, m.medicine_name, m.cost 
        FROM medicine m
        JOIN stock s ON m.medicine_id = s.medicine_id
        WHERE s.quantity_available > 0
        ORDER BY m.medicine_name
    """)
    medicines = cursor.fetchall()

    cursor.close()
    conn.close()
    return render_template('add_bill.html', customers=customers, pharmacists=pharmacists, medicines=medicines)

if __name__ == '__main__':
    app.run(debug=True, port=5000)
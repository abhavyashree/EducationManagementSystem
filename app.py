from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from mysql.connector import pooling

app = Flask(__name__)
CORS(app)

db_config = {
    "host": "localhost",
    "user": "root",
    "password": "Bhavya@16",
    "database": "education_management_system"
}

connection_pool = pooling.MySQLConnectionPool(
    pool_name="ems_pool",
    pool_size=5,
    **db_config
)

def get_db():
    return connection_pool.get_connection()


# 🏠 HOME
@app.route('/')
def home():
    return "Backend is running!"


# 📝 REGISTER
@app.route('/register', methods=['POST'])
def register():
    data = request.json
    name = data['name']
    email = data['email']
    password = data['password']
    userType = data['userType']

    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    try:
        if userType == "student":
            cursor.execute("SELECT * FROM Students WHERE email = %s", (email,))
            existing = cursor.fetchone()
            if existing:
                return jsonify({"status": "fail", "message": "This email is already registered as a student."})
            cursor.execute(
                "INSERT INTO Students (name, email, password) VALUES (%s, %s, %s)",
                (name, email, password)
            )
        else:
            cursor.execute("SELECT * FROM Faculty WHERE email = %s", (email,))
            existing = cursor.fetchone()
            if existing:
                return jsonify({"status": "fail", "message": "This email is already registered as faculty."})
            cursor.execute(
                "INSERT INTO Faculty (name, email, password) VALUES (%s, %s, %s)",
                (name, email, password)
            )

        conn.commit()
        return jsonify({"status": "success", "message": "Account created successfully!"})

    except Exception as e:
        conn.rollback()
        return jsonify({"status": "fail", "message": str(e)})
    finally:
        cursor.close()
        conn.close()


# 🔐 LOGIN
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data['email']
    password = data['password']
    userType = data['userType']

    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    try:
        if userType == "student":
            cursor.execute(
                "SELECT * FROM Students WHERE email=%s AND password=%s",
                (email, password)
            )
        else:
            cursor.execute(
                "SELECT * FROM Faculty WHERE email=%s AND password=%s",
                (email, password)
            )

        user = cursor.fetchone()

        if user:
            user_id = user['student_id'] if userType == "student" else user['faculty_id']
            return jsonify({"status": "success", "userType": userType, "user_id": user_id})
        else:
            return jsonify({"status": "fail"})
    finally:
        cursor.close()
        conn.close()


# 📚 GET ALL COURSES
@app.route('/courses', methods=['GET'])
def get_courses():
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM Courses")
        return jsonify(cursor.fetchall())
    finally:
        cursor.close()
        conn.close()


# ➕ ADD COURSE
@app.route('/add_course', methods=['POST'])
def add_course():
    data = request.json
    conn = get_db()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO Courses (course_name, department, credits, faculty_id)
            VALUES (%s, %s, %s, %s)
        """, (data['course_name'], "CSE", 3, data['faculty_id']))

        conn.commit()
        return jsonify({"message": "Course added successfully"})

    except Exception as e:
        conn.rollback()
        return jsonify({"message": str(e)})
    finally:
        cursor.close()
        conn.close()


# 📚 GET COURSES BY FACULTY (new)
@app.route('/faculty_courses/<int:faculty_id>', methods=['GET'])
def get_faculty_courses(faculty_id):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("""
            SELECT course_id, course_name, department, credits
            FROM Courses
            WHERE faculty_id = %s
        """, (faculty_id,))
        return jsonify(cursor.fetchall())
    except Exception as e:
        return jsonify({"error": str(e)})
    finally:
        cursor.close()
        conn.close()


# 📋 GET ASSIGNMENTS BY FACULTY (new)
@app.route('/faculty_assignments/<int:faculty_id>', methods=['GET'])
def get_faculty_assignments(faculty_id):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("""
            SELECT a.title, a.due_date, a.total_marks, c.course_name
            FROM Assignments a
            JOIN Courses c ON a.course_id = c.course_id
            WHERE c.faculty_id = %s
        """, (faculty_id,))
        return jsonify(cursor.fetchall())
    except Exception as e:
        return jsonify({"error": str(e)})
    finally:
        cursor.close()
        conn.close()


# 📊 GET GRADES GIVEN BY FACULTY (new)
@app.route('/faculty_grades/<int:faculty_id>', methods=['GET'])
def get_faculty_grades(faculty_id):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("""
            SELECT s.name AS student_name, c.course_name, g.grade
            FROM Grades g
            JOIN Students s ON g.student_id = s.student_id
            JOIN Courses c ON g.course_id = c.course_id
            WHERE c.faculty_id = %s
        """, (faculty_id,))
        return jsonify(cursor.fetchall())
    except Exception as e:
        return jsonify({"error": str(e)})
    finally:
        cursor.close()
        conn.close()


# 🎓 ENROLL STUDENT
@app.route('/enroll', methods=['POST'])
def enroll():
    data = request.json
    conn = get_db()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO Enrollments (student_id, course_id, semester, status)
            VALUES (%s, %s, 'Sem1', 'Active')
        """, (data['student_id'], data['course_id']))

        conn.commit()
        return jsonify({"message": "Enrolled successfully"})

    except Exception as e:
        conn.rollback()
        return jsonify({"message": str(e)})
    finally:
        cursor.close()
        conn.close()


# 📖 GET ENROLLMENTS
@app.route('/enrollments/<int:student_id>', methods=['GET'])
def get_enrollments(student_id):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT c.course_id, c.course_name
            FROM Enrollments e
            JOIN Courses c ON e.course_id = c.course_id
            WHERE e.student_id = %s
        """, (student_id,))
        return jsonify(cursor.fetchall())

    except Exception as e:
        return jsonify({"error": str(e)})
    finally:
        cursor.close()
        conn.close()


# 📝 ADD ASSIGNMENT
@app.route('/add_assignment', methods=['POST'])
def add_assignment():
    data = request.json
    conn = get_db()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO Assignments (course_id, title, due_date, total_marks)
            VALUES (%s, %s, %s, 100)
        """, (data['course_id'], data['title'], data['due_date']))

        conn.commit()
        return jsonify({"message": "Assignment added"})

    except Exception as e:
        conn.rollback()
        return jsonify({"message": str(e)})
    finally:
        cursor.close()
        conn.close()


# 📚 GET ASSIGNMENTS FOR STUDENT
@app.route('/assignments/<int:student_id>', methods=['GET'])
def get_assignments(student_id):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT a.title, a.due_date, a.total_marks
            FROM Assignments a
            JOIN Enrollments e ON a.course_id = e.course_id
            WHERE e.student_id = %s
        """, (student_id,))
        return jsonify(cursor.fetchall())

    except Exception as e:
        return jsonify({"error": str(e)})
    finally:
        cursor.close()
        conn.close()


# 🎯 ADD GRADE
@app.route('/add_grade', methods=['POST'])
def add_grade():
    data = request.json
    conn = get_db()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO Grades (student_id, course_id, grade)
            VALUES (%s, %s, %s)
        """, (data['student_id'], data['course_id'], data['grade']))

        conn.commit()
        return jsonify({"message": "Grade added"})

    except Exception as e:
        conn.rollback()
        return jsonify({"message": str(e)})
    finally:
        cursor.close()
        conn.close()


# 📊 GET GRADES FOR STUDENT
@app.route('/grades/<int:student_id>', methods=['GET'])
def get_grades(student_id):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT c.course_name, g.grade
            FROM Grades g
            JOIN Courses c ON g.course_id = c.course_id
            WHERE g.student_id = %s
        """, (student_id,))
        return jsonify(cursor.fetchall())

    except Exception as e:
        return jsonify({"error": str(e)})
    finally:
        cursor.close()
        conn.close()


# ▶️ RUN
if __name__ == "__main__":
    app.run(debug=True)
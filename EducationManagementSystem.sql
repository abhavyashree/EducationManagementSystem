create database education_management_system;
use education_management_system;
CREATE TABLE Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL
);
CREATE TABLE Faculty (
    faculty_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL
);
CREATE TABLE Courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    credits INT,
    faculty_id INT,
    FOREIGN KEY (faculty_id) REFERENCES Faculty(faculty_id)
);
CREATE TABLE Enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    semester VARCHAR(20),
    status VARCHAR(20),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
)
CREATE TABLE Assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT,
    title VARCHAR(200),
    due_date DATE,
    total_marks INT DEFAULT 100,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);
CREATE TABLE Grades (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    grade VARCHAR(5),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);
INSERT INTO Students (name, email, password) VALUES ('Test Student', 'student@test.com', '1234');
INSERT INTO Faculty (name, email, password) VALUES ('Test Faculty', 'faculty@test.com', '1234');
SHOW TABLES;
select * from courses;
select * from students;
CREATE TABLE Assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT,
    title VARCHAR(200),
    due_date DATE,
    total_marks INT DEFAULT 100,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);
SELECT course_id, course_name FROM Courses;
select * from assignments;
select * from courses;
select * from enrollments;
select * from grades;
select * from students;
SELECT * FROM faculty;
INSERT INTO  Enrollments (
    enrollment_id ,
    student_id ,
    course_id ,
    semester ,
    status ) VALUES(10,6,4,"Sem4","Active");
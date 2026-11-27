DROP TABLE IF EXISTS MarksGrades;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Branches;
DROP TABLE IF EXISTS Teachers;
DROP TABLE IF EXISTS Subjects;

-- 1. Independent table: no FKs needed
CREATE TABLE Branches (
    BranchID    INT PRIMARY KEY,
    BranchName  VARCHAR(15) NOT NULL UNIQUE
);

-- 2. References Branches(BranchName)
CREATE TABLE Students (
    StudentID      INT PRIMARY KEY,
    StudentName    VARCHAR(15) NOT NULL,
    StudentBranch  VARCHAR(15),
    CONSTRAINT UQ_Student_Branch
        UNIQUE (StudentID, StudentBranch),
    CONSTRAINT FK_Student_Branch
        FOREIGN KEY (StudentBranch)
        REFERENCES Branches(BranchName)
);

-- 3. Independent table: no FKs needed
CREATE TABLE Subjects (
    SubjectID    VARCHAR(5) PRIMARY KEY,
    SubjectName  VARCHAR(10),
    Semester     INT
);

-- 4. References Subjects(SubjectID)
CREATE TABLE Teachers (
    Teacher_id    VARCHAR(10) PRIMARY KEY,
    Teacher_Name  VARCHAR(20),
    SubjectID     VARCHAR(5),
    CONSTRAINT FK_Teacher_Subject
        FOREIGN KEY (SubjectID)
        REFERENCES Subjects(SubjectID)
);

-- 5. References Students AND Subjects
CREATE TABLE MarksGrades (
    StudentID      INT,
    StudentBranch  VARCHAR(15),
    SubjectID      VARCHAR(5),
    MARKS          FLOAT,
    GRADE          FLOAT,
    PRIMARY KEY (StudentID, SubjectID),
    CONSTRAINT FK_Marks_Student
        FOREIGN KEY (StudentID, StudentBranch)
        REFERENCES Students(StudentID, StudentBranch),
    CONSTRAINT FK_Marks_Subject
        FOREIGN KEY (SubjectID)
        REFERENCES Subjects(SubjectID)
);

--- Schema customers

DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Salaries ;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Department;

-- 1. Independent table: no FKs needed
CREATE TABLE Department (
    DepartmentId    INT PRIMARY KEY,
    DepartmentName  VARCHAR(15)
);

-- 2. References Department(DepartmentId)
CREATE TABLE Employees (
    EmployeeId    VARCHAR(10) PRIMARY KEY,
    EmployeeName  VARCHAR(15),
    EmployeeAge   INT,
    DepartmentId  INT,
    CONSTRAINT FK_Employee_Department
        FOREIGN KEY (DepartmentId)
        REFERENCES Department(DepartmentId)
);

-- 3. Independent table: no FKs needed
CREATE TABLE Customers (
    CustomerId       VARCHAR(15) PRIMARY KEY,
    Customer_Name    VARCHAR(20),
    CustomerAddress  VARCHAR(5)
);

-- 4. References Customers(CustomerId)
CREATE TABLE Orders (
    OrderId       VARCHAR(10) PRIMARY KEY,
    CustomerId    VARCHAR(15),
    OrderValue    FLOAT,
    OrderDate     DATE,
    OrderStatus   VARCHAR(10),
    CONSTRAINT FK_Order_Customer
        FOREIGN KEY (CustomerId)
        REFERENCES Customers(CustomerId)
);

-- 5. References Employees(EmployeeId)
CREATE TABLE Salaries (
    EmployeeId          VARCHAR(10) PRIMARY KEY,
    EmployeeJoiningDate DATE,
    Employee_Salary     FLOAT,
    CONSTRAINT FK_Salary_Employee
        FOREIGN KEY (EmployeeId)
        REFERENCES Employees(EmployeeId)
);

===================================================

--Indexes:


DROP INDEX IF EXISTS idx_student_name ;

CREATE INDEX idx_student_name
ON Students (StudentName);

DROP INDEX IF EXISTS idx_branch_name ;

CREATE UNIQUE INDEX idx_branch_name
ON Branches (BranchName);

DROP INDEX IF EXISTS idx_marks_lookup ;

CREATE INDEX idx_marks_lookup
ON MarksGrades (StudentID, SubjectID);


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DROP INDEX IF EXISTS idx_employee_name ;

CREATE INDEX idx_employee_name
ON Employees (EmployeeName);

DROP INDEX IF EXISTS idx_dept_name ;

CREATE UNIQUE INDEX idx_dept_name
ON Department (DepartmentName);

DROP INDEX IF EXISTS idx_order_lookup ;

CREATE INDEX idx_order_lookup
ON Orders (CustomerId, OrderDate);



===================================================

--Views

DROP VIEW IF EXISTS StudentBranchView;


CREATE VIEW StudentBranchView AS
SELECT StudentName, StudentBranch
FROM Students;

DROP VIEW IF EXISTS TopScorers;

CREATE VIEW TopScorers AS
SELECT StudentID, MARKS
FROM MarksGrades
WHERE MARKS > 90;

DROP VIEW IF EXISTS StuSubTeacher;

CREATE VIEW StuSubTeacher AS
SELECT s.StudentName, su.SubjectName, t.Teacher_Name
FROM MarksGrades m
JOIN Students s ON m.StudentID=s.StudentID
JOIN Subjects su ON m.SubjectID=su.SubjectID
JOIN Teachers t ON su.SubjectID=t.SubjectID;



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DROP VIEW IF EXISTS EmployeeDeptView;

CREATE VIEW EmployeeDeptView AS
SELECT EmployeeName, DepartmentId
FROM Employees;

DROP VIEW IF EXISTS HighEarners;

CREATE VIEW HighEarners AS
SELECT EmployeeId, Employee_Salary
FROM Salaries
WHERE Employee_Salary > 90000;


DROP VIEW IF EXISTS EmpDeptSalary;

CREATE VIEW EmpDeptSalary AS
SELECT e.EmployeeName, d.DepartmentName, s.Employee_Salary
FROM Employees e
JOIN Department d ON e.DepartmentId=d.DepartmentId
JOIN Salaries s ON e.EmployeeId=s.EmployeeId;


=======================================

Only if the editor supports stored procedures


-- Stored Procedures

DROP PROCEDURE IF EXISTS GetStudentMarks;

CREATE PROCEDURE GetStudentMarks(
  IN sid INT)
BEGIN
  SELECT * FROM MarksGrades
  WHERE StudentID = sid;
END;

DROP PROCEDURE IF EXISTS AddStudent;

CREATE PROCEDURE AddStudent(
  IN sName VARCHAR(15),
  IN sBranch VARCHAR(15))
BEGIN
  INSERT INTO Students
    VALUES (NULL, sName, sBranch);
END;

DROP PROCEDURE IF EXISTS AvgMarks;

CREATE PROCEDURE AvgMarks(
  IN subj VARCHAR(5), OUT avgMarks FLOAT)
BEGIN
  SELECT AVG(MARKS) INTO avgMarks
  FROM MarksGrades WHERE SubjectID=subj;
END;

CALL GetStudentMarks(101);

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE PROCEDURE GetSalary(
  IN eid VARCHAR(10))
BEGIN
  SELECT * FROM Salaries
  WHERE EmployeeId = eid;
END;

CREATE PROCEDURE AddCustomer(
  IN cName VARCHAR(20),
  IN cAddr VARCHAR(5))
BEGIN
  INSERT INTO Customers
    VALUES (NULL, cName, cAddr);
END;

CREATE PROCEDURE AvgDeptSalary(
  IN dept INT, OUT avgSal FLOAT)
BEGIN
  SELECT AVG(Employee_Salary)
  INTO avgSal FROM Salaries;
END;

CALL GetSalary('EMP-1042');

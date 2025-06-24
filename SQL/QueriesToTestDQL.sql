-- Queries to Test (DQL) 

--Require students to write SQL queries for: 
--1. List all patients who visited a certain doctor. 
SELECT * FROM DoctorsSchema.Doctors;
SELECT * FROM PatientsSchema.Patients;
SELECT * FROM DoctorsSchema.Appointments;

SELECT P.* 
FROM PatientsSchema.Patients P LEFT OUTER JOIN DoctorsSchema.Appointments A ON P.PatientID = A.PatientID
INNER JOIN DoctorsSchema.Doctors D ON D.DoctorID = A.DoctorID
WHERE D.DoctorName = 'Dr. John Smith';

--2. Count of appointments per department. 
SELECT * FROM DoctorsSchema.Doctors;
SELECT * FROM DoctorsSchema.Appointments;
SELECT * FROM SystemSchema.Departments;

SELECT DEP.DepartmentName AS 'Department Name', COUNT(A.DoctorID) AS 'Number Of Appointments'
FROM DoctorsSchema.Doctors DO INNER JOIN DoctorsSchema.Appointments A ON DO.DoctorID = A.DoctorID
RIGHT OUTER JOIN SystemSchema.Departments DEP ON DEP.DepartmentID = DO.DoctorID
GROUP BY DEP.DepartmentName;

--3. Retrieve doctors who have more than 5 appointments in a month. 
SELECT * FROM DoctorsSchema.Doctors;
SELECT * FROM DoctorsSchema.Appointments;

SELECT D.DoctorName AS 'Doctor Name', COUNT(A.DoctorID) AS 'Number Of Appointments'
FROM DoctorsSchema.Doctors D INNER JOIN DoctorsSchema.Appointments A ON D.DoctorID = A.DoctorID
WHERE MONTH(A.AppointmentDate) IN (7, 8, 9)
GROUP BY D.DoctorName
HAVING COUNT(A.DoctorID) > 5;

--4. Use JOINs across 3–4 tables. 
--select all doctors with all appointment details and patients details
SELECT * FROM DoctorsSchema.Doctors;
SELECT * FROM DoctorsSchema.Appointments;
SELECT * FROM PatientsSchema.Patients;

SELECT D.DoctorID AS 'Doctor ID', D.DoctorName AS 'Doctor Name', P.PatientName AS 'PatientName', A.AppointmentDate AS 'Appointment Date'
FROM DoctorsSchema.Doctors D INNER JOIN DoctorsSchema.Appointments A ON D.DoctorID = A.DoctorID
INNER JOIN PatientsSchema.Patients P ON P.PatientID = A.PatientID
GROUP BY D.DoctorID, D.DoctorName, P.PatientName, A.AppointmentDate;

--5. Use GROUP BY, HAVING, and aggregate functions. 
-- select all doctors in each departmenet where doctor count more than 1.
SELECT * FROM DoctorsSchema.Doctors;

SELECT D.DepartmentID AS 'Department ID', COUNT(D.DoctorName) AS 'Number Of Doctor'
FROM DoctorsSchema.Doctors D
GROUP BY D.DepartmentID
HAVING COUNT(D.DoctorName) > 1;

--6. Use SUBQUERIES and EXISTS. 
--select all doctors who treat more than 5 patients
SELECT * FROM DoctorsSchema.Doctors;
SELECT * FROM DoctorsSchema.Appointments;

SELECT D.DoctorID as 'Doctor ID', D.DoctorName AS 'Doctor Name' 
FROM DoctorsSchema.Doctors D INNER JOIN DoctorsSchema.Appointments A ON D.DoctorID = A.DoctorID
WHERE EXISTS (
SELECT D.DoctorID  
FROM DoctorsSchema.Doctors D
)
GROUP BY  D.DoctorID, D.DoctorName
HAVING COUNT(A.PatientID) > 5;



# Required Database Objects 

|Table          |Description                                    |
|---------------|-----------------------------------------------|
|Patients       |name, DOB, gender, contact info                |
|Doctors        |specialization, contact info                   |
|Departments    |cardiology, dermatology, etc.                  |
|Appointments   |Links patients with doctors and a time         |
|Admissions     |For in-patient stays: room number, date in/out | 
|Rooms          |Room number, type (ICU, general), availability |
|MedicalRecords |Diagnosis, treatment plans, date, notes        |
|Billing        |Total cost, patient ID, services, date         |
|Staff          |Nurses, admin: role, shift, assigned dept      |
|Users          |Login credentials: username, password, role    |

## 1. ERD 
![ERD](./Images/_HospitalManagementSystemERD.png)

## 2. Mapping
![Mapping](./Images/_HospitalManagementSystemMapping.png)

## 3. Normalization
![Normalization](./Images/_HospitalManagementSystemNormalization.png)

# Database Design Requirements 

## 1. DDL (CREATION OF THE TABLE)

```sql
-- Create Hospital Management System database
CREATE DATABASE HospitalManagementSystem;

USE HospitalManagementSystem;

-- Create Staffs table
CREATE TABLE Staffs (
    StaffID INT PRIMARY KEY IDENTITY(1,1),
    StaffRole VARCHAR(100) NOT NULL CHECK (StaffRole IN 
    ('Doctor', 'Receptionist', 'Nurse', 'Pharmacist', 'Technician', 'Surgeon', 'Admin'))
);

--Adding constraint for StaffRole to check if the value entered is vailde or not

-- Create Users table
CREATE TABLE Users (
    --UserID INT PRIMARY KEY IDENTITY(1,1),
	UserID INT IDENTITY(1,1),
    StaffID INT FOREIGN KEY REFERENCES Staffs(StaffID) ON DELETE CASCADE ON UPDATE CASCADE,
    UserName VARCHAR(50) NOT NULL,
    Password VARCHAR(50) NOT NULL,
	PRIMARY KEY(UserID, StaffID)
);

--PRIMARY KEY is a Composite kay 

-- Create Departments table
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName VARCHAR(100) NOT NULL CHECK (DepartmentName IN 
    ('Cardiology', 'Neurology', 'Pediatrics', 'Orthopedics', 'General Surgery', 'Radiology', 'Dermatology'))
);

--Adding constraint for DepartmentName to check if the value entered is vailde or not

-- Create Doctors table
CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    StaffID INT NOT NULL,
    DepartmentID INT FOREIGN KEY REFERENCES Departments(DepartmentID) ON DELETE SET NULL ON UPDATE NO ACTION,
    DoctorName VARCHAR(50) NOT NULL,
    DOB DATE NOT NULL,
    Gender VARCHAR(10) NOT NULL CHECK (Gender IN ('Male', 'Female')),
    Specialization VARCHAR(255) NOT NULL DEFAULT 'General Practitioner',
    PhoneNo VARCHAR(8) NOT NULL CHECK(LEN(RTRIM(PhoneNo)) = 8),
    Address VARCHAR(255),
    Email VARCHAR(255),

    -- Composite Foreign Key
    CONSTRAINT FK_Doctors_Users FOREIGN KEY (UserID, StaffID)
        REFERENCES Users(UserID, StaffID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

--becosue the FK is a Composite PK first I prepare a column to take their value (UserID, StaffID) sparet and then 
-- I add a constraint FK (FK_Doctors_Users) which will brainge the Composite PK together and divided the into 
--(UserID, StaffID) columns

--Adding constraint for Gender, Specialization and PhoneNo to check if the value entered is vailde or not

-- Create Patients table
CREATE TABLE Patients (
    PatientID INT PRIMARY KEY IDENTITY(1,1),
    PatientName VARCHAR(50) NOT NULL,
    DOB DATE NOT NULL,
    Gender VARCHAR(20) NOT NULL,
    PhoneNo VARCHAR(8) CHECK(LEN(RTRIM(PhoneNo)) = 8),
    Address VARCHAR(255),
    Email VARCHAR(255)
);

--Adding constraint for PhoneNo to check if the value entered is vailde or not

-- Create Appointments table
CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT FOREIGN KEY REFERENCES Patients(PatientID)ON DELETE CASCADE ON UPDATE CASCADE,
    DoctorID INT FOREIGN KEY REFERENCES Doctors(DoctorID)ON DELETE NO ACTION ON UPDATE NO ACTION,
    AppointmentTime TIME NOT NULL,
    AppointmentDate DATE NOT NULL
);

-- Create Rooms table
CREATE TABLE Rooms (
    RoomNumber INT PRIMARY KEY,
    Type VARCHAR(50),
    Availability VARCHAR(10) DEFAULT 'TRUE'
);

--Adding constraint for Availability to check if the value entered is vailde or not

-- Create Receptionist table
CREATE TABLE Receptionist (
    ReceptionistID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    StaffID INT NOT NULL,
    ReceptionistName VARCHAR(50), 

	-- Composite Foreign Key
    CONSTRAINT FK_Receptionist_Users FOREIGN KEY (UserID, StaffID)
        REFERENCES Users(UserID, StaffID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Create Admissions table
CREATE TABLE Admissions (
    AdmissionID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT FOREIGN KEY REFERENCES Patients(PatientID) ON DELETE CASCADE ON UPDATE CASCADE,
    RoomNumber INT FOREIGN KEY REFERENCES Rooms(RoomNumber) ON DELETE SET NULL ON UPDATE NO ACTION,
    ReceptionistID INT FOREIGN KEY REFERENCES Receptionist(ReceptionistID) ON DELETE SET NULL ON UPDATE NO ACTION,
    DateIn DATE NOT NULL,
    DateOut DATE
);

-- Create MedicalRecords table
CREATE TABLE MedicalRecords (
    MedicalRecordsID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT FOREIGN KEY REFERENCES Patients(PatientID) ON DELETE CASCADE ON UPDATE CASCADE,
    DoctorID INT FOREIGN KEY REFERENCES Doctors(DoctorID) ON DELETE NO ACTION ON UPDATE NO ACTION,
    Notes VARCHAR(255) DEFAULT 'No note add',
    Date DATE NOT NULL
);

--Adding constraint for Notes to check if the value entered is vailde or not

-- Create MedicalDiagnoses table
CREATE TABLE MedicalDiagnoses (
    DiagnosisID INT PRIMARY KEY IDENTITY(1,1),
    MedicalRecordsID INT FOREIGN KEY REFERENCES MedicalRecords(MedicalRecordsID) ON DELETE CASCADE ON UPDATE CASCADE,
    Diagnosis VARCHAR(255) DEFAULT 'No diagnosis add'
);

--Adding constraint for Diagnosis to check if the value entered is vailde or not

-- Create MedicalTreatments table
CREATE TABLE MedicalTreatments (
    TreatmentID INT PRIMARY KEY IDENTITY(1,1),
    MedicalRecordsID INT FOREIGN KEY REFERENCES MedicalRecords(MedicalRecordsID) ON DELETE CASCADE ON UPDATE CASCADE,
    TreatmentPlans VARCHAR(255) DEFAULT 'No treatment plans add'
);

--Adding constraint for TreatmentPlans to check if the value entered is vailde or not

-- Create Billing table
CREATE TABLE Billing (
    BillingID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT FOREIGN KEY REFERENCES Patients(PatientID) ON DELETE CASCADE ON UPDATE CASCADE,
    MedicalRecordsID INT FOREIGN KEY REFERENCES MedicalRecords(MedicalRecordsID)ON DELETE NO ACTION ON UPDATE NO ACTION,
    Date DATE NOT NULL
);

-- Create BillingServices table
CREATE TABLE BillingServices (
    ServicesID INT PRIMARY KEY IDENTITY(1,1),
    BillingID INT FOREIGN KEY REFERENCES Billing(BillingID) ON DELETE CASCADE ON UPDATE CASCADE,
    ServicesName VARCHAR(255) NOT NULL,
    ServicesCost decimal NOT NULL CHECK (ServicesCost > 0)
);

--Adding constraint for ServicesCost to check if the value entered is vailde or not
```

## 2. DML (INSERTION OF THE DATA)

**. Insert into Staffs**
```sql
INSERT INTO Staffs (StaffRole) VALUES 
('Doctor'), ('Receptionist'), ('Nurse'), ('Pharmacist'), ('Technician'), ('Surgeon'), ('Admin');

SELECT * FROM Staffs;
```
![Staffs Table](./Images/_StaffsTable.png)

**. Insert into Users**
```sql
-- Insert into Users
INSERT INTO Users (StaffID, UserName, Password) VALUES 
(1, 'docjohn', 'pass123'),
(2, 'reception1', 'pass234'),
(3, 'nurse_amy', 'pass345'),
(4, 'pharm_bob', 'pass456'),
(5, 'tech_mike', 'pass567'),
(6, 'surge_linda', 'pass678'),
(7, 'admin_kate', 'pass789');

SELECT * FROM Users;
```
![Users Table](./Images/_UsersTable.png)

**. Insert into Departments**
```sql
-- Insert into Departments
INSERT INTO Departments (DepartmentName) VALUES 
('Cardiology'), ('Neurology'), ('Pediatrics'), ('Orthopedics'), ('General Surgery'), ('Radiology'), ('Dermatology');

SELECT * FROM Departments;
```
![Departments Table](./Images/_DepartmentsTable.png)

**. Insert into Doctors**
```sql
-- Insert into Doctors
INSERT INTO Doctors (UserID, StaffID, DepartmentID, DoctorName, DOB, Gender, Specialization, PhoneNo, Address, Email) VALUES 
(1, 1, 1, 'Dr. John Smith', '1980-04-12', 'Male', 'Cardiologist', '99887766', '123 Heart St.', 'john@hospital.com'),
(1, 1, 2, 'Dr. Alice Brown', '1975-07-19', 'Female', 'Neurologist', '99887761', '456 Brain Ave.', 'alice@hospital.com'),
(1, 1, 3, 'Dr. Emma White', '1988-09-21', 'Female', 'Pediatrician', '99887762', '789 Kid Ln.', 'emma@hospital.com'),
(1, 1, 4, 'Dr. Noah Black', '1982-12-01', 'Male', 'Orthopedic', '99887763', '321 Bone Blvd.', 'noah@hospital.com'),
(1, 1, 5, 'Dr. Liam Green', '1979-11-17', 'Male', 'Surgeon', '99887764', '654 Cut St.', 'liam@hospital.com'),
(1, 1, 6, 'Dr. Olivia Grey', '1983-06-25', 'Female', 'Radiologist', '99887765', '987 Scan Ave.', 'olivia@hospital.com'),
(1, 1, 7, 'Dr. Mason Blue', '1990-02-28', 'Male', 'Dermatologist', '99887760', '123 Skin Rd.', 'mason@hospital.com');

SELECT * FROM Doctors;
```
![Doctors Table](./Images/_DoctorsTable.png)

**. Insert into Patients**
```sql
-- Insert into Patients
INSERT INTO Patients (PatientName, DOB, Gender, PhoneNo, Address, Email) VALUES 
('James Taylor', '1992-08-15', 'Male', '90909090', '12 Street A', 'james@mail.com'),
('Sophie Turner', '1985-03-22', 'Female', '80808080', '34 Street B', 'sophie@mail.com'),
('William Scott', '1978-06-10', 'Male', '70707070', '56 Street C', 'william@mail.com'),
('Lily Adams', '1990-11-02', 'Female', '60606060', '78 Street D', 'lily@mail.com'),
('Michael Lee', '1982-01-30', 'Male', '50505050', '90 Street E', 'michael@mail.com'),
('Grace Hill', '1995-09-17', 'Female', '40404040', '21 Street F', 'grace@mail.com'),
('Daniel Young', '2000-12-20', 'Male', '30303030', '43 Street G', 'daniel@mail.com');

SELECT * FROM Patients;
```
![Patients Table](./Images/_PatientsTable.png)

**. Insert into Appointments**
```sql
-- Insert into Appointments
INSERT INTO Appointments (PatientID, DoctorID, AppointmentTime, AppointmentDate) VALUES 
(1, 1, '09:00', '2025-07-01'),
(2, 2, '10:00', '2025-07-02'),
(3, 3, '11:00', '2025-07-03'),
(4, 4, '12:00', '2025-07-04'),
(5, 5, '13:00', '2025-07-05'),
(6, 6, '14:00', '2025-07-06'),
(7, 7, '15:00', '2025-07-07');

SELECT * FROM Appointments;
```
![Appointments Table](./Images/_AppointmentsTable.png)

**. Insert into Rooms**
```sql
-- Insert into Rooms
INSERT INTO Rooms (RoomNumber, Type, Availability) VALUES 
(101, 'ICU', 'TRUE'),
(102, 'General', 'FALSE'),
(103, 'Pediatrics', 'TRUE'),
(104, 'Maternity', 'TRUE'),
(105, 'Surgery', 'FALSE'),
(106, 'Radiology', 'TRUE'),
(107, 'Dermatology', 'TRUE');

SELECT * FROM Rooms;
```
![Rooms Table](./Images/_RoomsTable.png)

**. Insert into Receptionist**
```sql
-- Insert into Receptionist
INSERT INTO Receptionist (UserID, StaffID, ReceptionistName) VALUES 
(2, 2, 'Sarah'),
(2, 2, 'Anna'),
(2, 2, 'Zara'),
(2, 2, 'Nina'),
(2, 2, 'Emma'),
(2, 2, 'Lana'),
(2, 2, 'Rina');

SELECT * FROM Receptionist;
```
![Receptionist Table](./Images/_ReceptionistTable.png)

**. Insert into Admissions**
```sql
-- Insert into Admissions
INSERT INTO Admissions (PatientID, RoomNumber, ReceptionistID, DateIn, DateOut) VALUES 
(1, 101, 1, '2025-06-01', '2025-06-05'),
(2, 102, 2, '2025-06-02', '2025-06-06'),
(3, 103, 3, '2025-06-03', '2025-06-07'),
(4, 104, 4, '2025-06-04', '2025-06-08'),
(5, 105, 5, '2025-06-05', '2025-06-09'),
(6, 106, 6, '2025-06-06', '2025-06-10'),
(7, 107, 7, '2025-06-07', '2025-06-11');

SELECT * FROM Admissions;
```
![Admissions Table](./Images/_AdmissionsTable.png)

**. Insert into MedicalRecords**
```sql
-- Insert into MedicalRecords
INSERT INTO MedicalRecords (PatientID, DoctorID, Notes, Date) VALUES 
(1, 1, 'Initial checkup', '2025-06-01'),
(2, 2, 'Headache observed', '2025-06-02'),
(3, 3, 'Fever noted', '2025-06-03'),
(4, 4, 'Fracture diagnosis', '2025-06-04'),
(5, 5, 'Surgery recommended', '2025-06-05'),
(6, 6, 'Scan done', '2025-06-06'),
(7, 7, 'Skin rash treated', '2025-06-07');

SELECT * FROM MedicalRecords;
```
![MedicalRecords Table](./Images/_MedicalRecordsTable.png)

**. Insert into MedicalDiagnoses**
```sql
-- Insert into MedicalDiagnoses
INSERT INTO MedicalDiagnoses (MedicalRecordsID, Diagnosis) VALUES 
(1, 'Hypertension'),
(2, 'Migraine'),
(3, 'Flu'),
(4, 'Broken arm'),
(5, 'Appendicitis'),
(6, 'Lung infection'),
(7, 'Eczema');

SELECT * FROM MedicalDiagnoses;
```
![MedicalDiagnoses Table](./Images/_MedicalDiagnosesTable.png)

**. Insert into MedicalTreatments**
```sql
-- Insert into MedicalTreatments
INSERT INTO MedicalTreatments (MedicalRecordsID, TreatmentPlans) VALUES 
(1, 'Blood pressure meds'),
(2, 'Painkillers'),
(3, 'Rest and fluids'),
(4, 'Cast'),
(5, 'Surgery scheduled'),
(6, 'Antibiotics'),
(7, 'Ointments');

SELECT * FROM MedicalTreatments;
```
![MedicalTreatments Table](./Images/_MedicalTreatmentsTable.png)

**. Insert into Billing**
```sql
-- Insert into Billing
INSERT INTO Billing (PatientID, MedicalRecordsID, Date) VALUES 
(1, 1, '2025-06-01'),
(2, 2, '2025-06-02'),
(3, 3, '2025-06-03'),
(4, 4, '2025-06-04'),
(5, 5, '2025-06-05'),
(6, 6, '2025-06-06'),
(7, 7, '2025-06-07');

SELECT * FROM Billing;
```
![Billing Table](./Images/_BillingTable.png)

**. Insert into BillingServices**
```sql
-- Insert into BillingServices
INSERT INTO BillingServices (BillingID, ServicesName, ServicesCost) VALUES 
(1, 'Checkup', 20.44),
(2, 'MRI', 120),
(3, 'Consultation', 50),
(4, 'X-Ray', 70),
(5, 'Surgery', 500.04),
(6, 'CT Scan', 150),
(7, 'Skin Treatment', 80.489);

SELECT * FROM BillingServices;
```
![BillingServices Table](./Images/_BillingServicesTable.png)

## 3.  Relational Schema

```sql
--SystemSchema
CREATE SCHEMA SystemSchema;

ALTER SCHEMA SystemSchema TRANSFER Staffs;  
ALTER SCHEMA SystemSchema TRANSFER Users;
ALTER SCHEMA SystemSchema TRANSFER Departments;

--DoctorsSchema
CREATE SCHEMA DoctorsSchema;

ALTER SCHEMA DoctorsSchema TRANSFER Doctors;  
ALTER SCHEMA DoctorsSchema TRANSFER Appointments;
ALTER SCHEMA DoctorsSchema TRANSFER MedicalRecords;
ALTER SCHEMA DoctorsSchema TRANSFER MedicalDiagnoses;
ALTER SCHEMA DoctorsSchema TRANSFER MedicalTreatments;

--PatientsSchema
CREATE SCHEMA PatientsSchema;

ALTER SCHEMA PatientsSchema TRANSFER Patients;  
ALTER SCHEMA PatientsSchema TRANSFER Billing;
ALTER SCHEMA PatientsSchema TRANSFER BillingServices;

--ReceptionistSchema
CREATE SCHEMA ReceptionistSchema;

ALTER SCHEMA ReceptionistSchema TRANSFER Receptionist;  
ALTER SCHEMA ReceptionistSchema TRANSFER Rooms;
ALTER SCHEMA ReceptionistSchema TRANSFER Admissions;
```

# Queries to Test (DQL) 

Require students to write SQL queries for: 

## 1. List all patients who visited a certain doctor. 
```sql
SELECT * FROM DoctorsSchema.Doctors;
SELECT * FROM PatientsSchema.Patients;
SELECT * FROM DoctorsSchema.Appointments;

SELECT P.* 
FROM PatientsSchema.Patients P LEFT OUTER JOIN DoctorsSchema.Appointments A ON P.PatientID = A.PatientID
INNER JOIN DoctorsSchema.Doctors D ON D.DoctorID = A.DoctorID
WHERE D.DoctorName = 'Dr. John Smith';
```
![Patients Visited Doctor](./Images/_PatientsVisitedDoctor.png)

## 2. Count of appointments per department. 
```sql
SELECT * FROM DoctorsSchema.Doctors;
SELECT * FROM DoctorsSchema.Appointments;
SELECT * FROM SystemSchema.Departments;

SELECT DEP.DepartmentName AS 'Department Name', COUNT(A.DoctorID) AS 'Number Of Appointments'
FROM DoctorsSchema.Doctors DO INNER JOIN DoctorsSchema.Appointments A ON DO.DoctorID = A.DoctorID
RIGHT OUTER JOIN SystemSchema.Departments DEP ON DEP.DepartmentID = DO.DoctorID
GROUP BY DEP.DepartmentName;
```
![Appointments Per Department](./Images/_AppointmentsPerDepartment.png)

## 3. Retrieve doctors who have more than 5 appointments in a month. 
```sql
SELECT * FROM DoctorsSchema.Doctors;
SELECT * FROM DoctorsSchema.Appointments;

SELECT D.DoctorName AS 'Doctor Name', COUNT(A.DoctorID) AS 'Number Of Appointments'
FROM DoctorsSchema.Doctors D INNER JOIN DoctorsSchema.Appointments A ON D.DoctorID = A.DoctorID
WHERE MONTH(A.AppointmentDate) IN (7, 8, 9)
GROUP BY D.DoctorName
HAVING COUNT(A.DoctorID) > 5;
```
![Doctors With More Than 5 Appointments](./Images/_DoctorsWithMoreThan5Appointments.png)

## 4. Use JOINs across 3–4 tables. 
```sql
--select all doctors with all appointment details and patients details
SELECT * FROM DoctorsSchema.Doctors;
SELECT * FROM DoctorsSchema.Appointments;
SELECT * FROM PatientsSchema.Patients;

SELECT D.DoctorID AS 'Doctor ID', D.DoctorName AS 'Doctor Name', P.PatientName AS 'PatientName', A.AppointmentDate AS 'Appointment Date'
FROM DoctorsSchema.Doctors D INNER JOIN DoctorsSchema.Appointments A ON D.DoctorID = A.DoctorID
INNER JOIN PatientsSchema.Patients P ON P.PatientID = A.PatientID
GROUP BY D.DoctorID, D.DoctorName, P.PatientName, A.AppointmentDate;
```
![Join Across Tables](./Images/_JoinAcrossTables.png)

## 5. Use GROUP BY, HAVING, and aggregate functions. 
```sql
-- select all doctors in each departmenet where doctor count more than 1.
SELECT * FROM DoctorsSchema.Doctors;

SELECT D.DepartmentID AS 'Department ID', COUNT(D.DoctorName) AS 'Number Of Doctor'
FROM DoctorsSchema.Doctors D
GROUP BY D.DepartmentID
HAVING COUNT(D.DoctorName) > 1;
```
![Group By and Having](./Images/_GroupByAndHaving.png)

## 6. Use SUBQUERIES and EXISTS. 
```sql
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
```
![Subqueries and Exists](./Images/_SubqueriesAndExists.png)

# Functions & Stored Procedures 

## 1. Scalar function to calculate patient age from DOB. 
```sql
CREATE FUNCTION dbo.CalculateAge (@DOB DATE)
RETURNS INT
AS
BEGIN
    DECLARE @Age INT;
    SET @Age = DATEDIFF(YEAR, @DOB, GETDATE());

    -- Adjust if birthday hasn't occurred this year yet
    IF (MONTH(@DOB) > MONTH(GETDATE())) OR 
       (MONTH(@DOB) = MONTH(GETDATE()) AND DAY(@DOB) > DAY(GETDATE()))
       SET @Age = @Age - 1;

    RETURN @Age;
END;

--to call dbo.CalculateAge (@DOB DATE)
SELECT PatientName, dbo.CalculateAge(DOB) AS Age FROM PatientsSchema.Patients;
```
![Calculate Age Function](./Images/_CalculateAgeFunction.png)

## 2. Stored procedure to admit a patient (insert to Admissions, update Room availability). 
```sql
CREATE PROCEDURE AdmitPatient
    @PatientID INT,
    @RoomNumber INT,
    @ReceptionistID INT,
    @DateIn DATE,
    @DateOut DATE = NULL
AS
BEGIN
    BEGIN TRANSACTION;

    -- Insert new admission record
    INSERT INTO ReceptionistSchema.Admissions (PatientID, RoomNumber, ReceptionistID, DateIn, DateOut)
    VALUES (@PatientID, @RoomNumber, @ReceptionistID, @DateIn, @DateOut);

    -- Update room availability to FALSE (occupied)
    UPDATE ReceptionistSchema.Rooms
    SET Availability = 'FALSE'
    WHERE RoomNumber = @RoomNumber;

    COMMIT TRANSACTION;
END;

--to call PROCEDURE AdmitPatient 
EXEC AdmitPatient @PatientID = 1, @RoomNumber = 103, @ReceptionistID = 2, @DateIn = '2025-07-01';


--DROP PROCEDURE AdmitPatient;
```

## 3. Procedure to generate invoice (insert into Billing based on treatments). 
```sql
CREATE PROCEDURE GenerateInvoice
    @PatientID INT,
    @MedicalRecordsID INT,
    @BillingDate DATE
AS
BEGIN
    BEGIN TRANSACTION;

    -- insert new billing record to PatientsSchema.Billing
    INSERT INTO PatientsSchema.Billing (PatientID, MedicalRecordsID, Date)
    VALUES (@PatientID, @MedicalRecordsID, @BillingDate);

    DECLARE @BillingID INT = SCOPE_IDENTITY();
	--SCOPE_IDENTITY(); is a system function in SQL Server that returns the last identity value generated in the current scope

    -- insert services based on treatments to PatientsSchema.BillingServices
    INSERT INTO PatientsSchema.BillingServices (BillingID, ServicesName, ServicesCost)
    SELECT 
        @BillingID,
        TreatmentPlans, --ServicesName = TreatmentPlans
        -- to get TreatmentPlans from DoctorsSchema.MedicalTreatments using join
        CASE 
		-- if ServicesName = '' then ServicesCost = ''
            WHEN TreatmentPlans = 'Surgery scheduled' THEN 500.00
            WHEN TreatmentPlans = 'Antibiotics' THEN 150.00
            WHEN TreatmentPlans = 'Blood pressure meds' THEN 80.00
            WHEN TreatmentPlans = 'Painkillers' THEN 50.00
            WHEN TreatmentPlans = 'Rest and fluids' THEN 30.00
            WHEN TreatmentPlans = 'Cast' THEN 120.00
            WHEN TreatmentPlans = 'Ointments' THEN 60.00
            ELSE 100.00 -- default cost
        END
    FROM DoctorsSchema.MedicalTreatments
    WHERE MedicalRecordsID = @MedicalRecordsID;

    COMMIT TRANSACTION;
END;

--to call PROCEDURE GenerateInvoice
EXEC GenerateInvoice @PatientID = 3, @MedicalRecordsID = 3, @BillingDate = '2025-07-01';
```

## 4. Procedure to assign doctor to department and shift. 
```sql
--becouse I do not have shift column in my table I need to add it first 
--4.1. Alter table to add shift
ALTER TABLE DoctorsSchema.Doctors
ADD Shift VARCHAR(20) DEFAULT 'Morning';

--4.2. Create procedure to update department and shift
CREATE PROCEDURE AssignDoctorToDepartmentAndShift
    @DoctorID INT,
    @DepartmentID INT,
    @Shift VARCHAR(20)
AS
BEGIN
    UPDATE DoctorsSchema.Doctors
    SET DepartmentID = @DepartmentID,
        Shift = @Shift
    WHERE DoctorID = @DoctorID;
END;

--to call PROCEDURE AssignDoctorToDepartmentAndShift
EXEC AssignDoctorToDepartmentAndShift @DoctorID = 1, @DepartmentID = 3, @Shift = 'Evening';

SELECT * FROM DoctorsSchema.Doctors;

--DROP PROCEDURE AssignDoctorToDepartmentAndShift;
```
![![Assign Doctor To Department And Shift](./Images/_AssignDoctorToDepartmentAndShift.png)](./Images/_AssignDoctorToDepartmentAndShift.png)

# Triggers 

## 1. After insert on Appointments → auto log in MedicalRecords. 
```sql
CREATE TRIGGER trg_AfterInsert_Appointment
ON DoctorsSchema.Appointments
AFTER INSERT
--Start of the trigger body
AS
BEGIN
    -- Insert automatically into MedicalRecords for each new appointment
    INSERT INTO DoctorsSchema.MedicalRecords (PatientID, DoctorID, Notes, Date)
    SELECT 
        PatientID, 
        DoctorID, 
        'Auto-created from appointment', 
        CAST(GETDATE() AS DATE)
    FROM inserted;
END;

--to test TRIGGER trg_AfterInsert_Appointment
INSERT INTO DoctorsSchema.Appointments (PatientID, DoctorID, AppointmentTime, AppointmentDate) VALUES 
(1, 1, '09:00', '2025-08-01');

SELECT * FROM DoctorsSchema.Appointments WHERE AppointmentDate = '2025-08-01';
SELECT * FROM DoctorsSchema.MedicalRecords;

--DROP TRIGGER trg_AfterInsert_Appointment;
```
![After Insert Trigger](./Images/_AfterInsertTrigger.png)

## 2. Before delete on Patients → prevent deletion if pending bills exist. 
```sql
--in sql server we have something call INSTEAD OF DELETE trigger which used to intercept and conditionally prevent deletion.
CREATE TRIGGER trg_BeforeDelete_Patient
ON PatientsSchema.Patients
INSTEAD OF DELETE --This type of trigger intercepts the delete operation and decides whether to allow it or block it
--Start of the trigger body
AS
BEGIN
    IF EXISTS (
        SELECT 1 -- A dummy value. We use SELECT 1 because we don’t need actual data, just to know if something exists
        FROM PatientsSchema.Billing B
        WHERE B.PatientID IN (SELECT PatientID FROM deleted) -- deleted is a special table holding the rows targeted for deletion.
    )
    BEGIN
        -- stop deletion if bills exist
        --RAISERROR -> Displays an error message and stops the process.
        RAISERROR ('Cannot delete patient with pending bills.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        -- If no bills, allow deletion
        DELETE FROM PatientsSchema.Patients
        WHERE PatientID IN (SELECT PatientID FROM deleted);
    END
END;

--to test TRIGGER trg_BeforeDelete_Patient
--get patients having billing records
SELECT B.BillingID, B.PatientID, P.PatientName
FROM PatientsSchema.Billing B
JOIN PatientsSchema.Patients P ON B.PatientID = P.PatientID;

--try to delete patients with PatientID 1
DELETE FROM PatientsSchema.Patients
WHERE PatientID = 1;
```
![Before Delete Trigger](./Images/_BeforeDeleteTrigger.png)

## 3. After update on Rooms → ensure no two patients occupy same room. 
```sql
CREATE TRIGGER trg_AfterUpdateRooms3
ON ReceptionistSchema.Admissions
AFTER UPDATE
--Start of the trigger body
AS
BEGIN
    IF EXISTS (
        SELECT RoomNumber
        FROM ReceptionistSchema.Rooms
		WHERE Availability = 'TRUE'
        GROUP BY RoomNumber
        --HAVING COUNT(*) > 1
    )
    BEGIN
        -- If room has more than one patient, block the update
        RAISERROR ('Room conflict detected: Multiple patients assigned to the same room.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

--DROP TRIGGER trg_AfterUpdateRooms;


--to test TRIGGER trg_AfterUpdate_Rooms
--1. get all room with the number of Patients assign to it 
SELECT RoomNumber, COUNT(*) AS PatientCount
FROM ReceptionistSchema.Admissions
GROUP BY RoomNumber;

--2. try to update (enter new Patients ... becouse the not change but Patients will) a new Patients in a room which a assigned Patients
-- Example: Assign patient 3 to Room 101 which already has patient 1.
UPDATE ReceptionistSchema.Admissions
SET RoomNumber = 101
WHERE PatientID = 3;

SELECT * FROM ReceptionistSchema.Rooms;
SELECT * FROM ReceptionistSchema.Admissions;
```
![After Update Trigger](./Images/_AfterUpdateTrigger.png)

# Security (DCL) 

## 1. Create at least two user roles: DoctorUser, AdminUser. 
```sql
-- to create role for DoctorUser and AdminUser
CREATE ROLE DoctorUser;
CREATE ROLE AdminUser;
```

## 2. GRANT SELECT for DoctorUser on Patients and Appointments only. 
```sql
-- Grant SELECT on Patients and Appointments
GRANT SELECT ON PatientsSchema.Patients TO DoctorUser;
GRANT SELECT ON DoctorsSchema.Appointments TO DoctorUser;
```

## 3. GRANT INSERT, UPDATE for AdminUser on all tables. 
```sql
-- SystemSchema
GRANT INSERT, UPDATE ON SystemSchema.Staffs TO AdminUser;
GRANT INSERT, UPDATE ON SystemSchema.Users TO AdminUser;
GRANT INSERT, UPDATE ON SystemSchema.Departments TO AdminUser;

-- DoctorsSchema
GRANT INSERT, UPDATE ON DoctorsSchema.Doctors TO AdminUser;
GRANT INSERT, UPDATE ON DoctorsSchema.Appointments TO AdminUser;
GRANT INSERT, UPDATE ON DoctorsSchema.MedicalRecords TO AdminUser;
GRANT INSERT, UPDATE ON DoctorsSchema.MedicalDiagnoses TO AdminUser;
GRANT INSERT, UPDATE ON DoctorsSchema.MedicalTreatments TO AdminUser;

-- PatientsSchema
GRANT INSERT, UPDATE ON PatientsSchema.Patients TO AdminUser;
GRANT INSERT, UPDATE ON PatientsSchema.Billing TO AdminUser;
GRANT INSERT, UPDATE ON PatientsSchema.BillingServices TO AdminUser;

-- ReceptionistSchema
GRANT INSERT, UPDATE ON ReceptionistSchema.Receptionist TO AdminUser;
GRANT INSERT, UPDATE ON ReceptionistSchema.Rooms TO AdminUser;
GRANT INSERT, UPDATE ON ReceptionistSchema.Admissions TO AdminUser;
```

## 4.REVOKE DELETE for Doctors. 
```sql
--I do not give Doctors permission to delete so first I have to give it to him then do REVOKE
GRANT DELETE ON DoctorsSchema.Appointments TO DoctorUser;

REVOKE DELETE ON DoctorsSchema.Appointments FROM DoctorUser;
```
**To check if the permission is revoked**

![Step 1](./Images/REVOKE_DELETE_step1.png)
![Step 2](./Images/REVOKE_DELETE_step2.png)

# Transactions (TCL) 
```sql
--• Simulate a transaction: admit a patient → insert record, update room, create billing → commit. 
--• Add rollback logic in case of failure. 

BEGIN TRY
    BEGIN TRANSACTION;

    --insert admission
    INSERT INTO ReceptionistSchema.Admissions (PatientID, RoomNumber, ReceptionistID, DateIn)
    VALUES (1, 3, 1, GETDATE());

    --update room availability to 'FALSE' (occupied)
    UPDATE ReceptionistSchema.Rooms
    SET Availability = 'FALSE'
    WHERE RoomNumber = 3;

    --insert billing record
    INSERT INTO PatientsSchema.Billing (PatientID, MedicalRecordsID, Date)
    VALUES (1, 1, GETDATE());  -- Assuming MedicalRecordsID = 1 (for simulation)

    --commit the transaction if all succeed
    COMMIT TRANSACTION;

    PRINT 'Transaction completed successfully.';

END TRY
BEGIN CATCH
    -- rollback in case of any error
    ROLLBACK TRANSACTION;--it show where it is stoped

    PRINT 'Transaction failed. Rolling back...';
    PRINT ERROR_MESSAGE();
END CATCH
```
![Transaction Example](./Images/_TransactionExample.png)

















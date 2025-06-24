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
![Staffs Table](./Images/_StaffsTable.PNG)

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
![Users Table](./Images/_UsersTable.PNG)

**. Insert into Departments**
```sql
-- Insert into Departments
INSERT INTO Departments (DepartmentName) VALUES 
('Cardiology'), ('Neurology'), ('Pediatrics'), ('Orthopedics'), ('General Surgery'), ('Radiology'), ('Dermatology');

SELECT * FROM Departments;
```
![Departments Table](./Images/_DepartmentsTable.PNG)

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
![Doctors Table](./Images/_DoctorsTable.PNG)

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
![Patients Table](./Images/_PatientsTable.PNG)

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
![Appointments Table](./Images/_AppointmentsTable.PNG)

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
![Rooms Table](./Images/_RoomsTable.PNG)

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
![Receptionist Table](./Images/_ReceptionistTable.PNG)

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
![Admissions Table](./Images/_AdmissionsTable.PNG)

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
![MedicalRecords Table](./Images/_MedicalRecordsTable.PNG)

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
![MedicalDiagnoses Table](./Images/_MedicalDiagnosesTable.PNG)

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
![MedicalTreatments Table](./Images/_MedicalTreatmentsTable.PNG)

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
![Billing Table](./Images/_BillingTable.PNG)

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
![BillingServices Table](./Images/_BillingServicesTable.PNG)














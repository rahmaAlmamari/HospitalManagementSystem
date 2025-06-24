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



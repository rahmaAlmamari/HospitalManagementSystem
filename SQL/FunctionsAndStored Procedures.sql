--Functions & Stored Procedures 

--Require: 
--1. Scalar function to calculate patient age from DOB. 
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

--------------------------------------------------------------------------------------------------------------------
--2. Stored procedure to admit a patient (insert to Admissions, update Room availability). 
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
--------------------------------------------------------------------------------------------------------------
--3. Procedure to generate invoice (insert into Billing based on treatments). 
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

-------------------------------------------------------------------------------------------

--4. Procedure to assign doctor to department and shift. 
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


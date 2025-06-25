--Triggers 
--Implement: 

--1. After insert on Appointments → auto log in MedicalRecords. 
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

---------------------------------------------------------------------------------

--2. Before delete on Patients → prevent deletion if pending bills exist. 
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

--------------------------------------------------------------------------------------

--3. After update on Rooms → ensure no two patients occupy same room. 
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



--Transactions (TCL) 
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

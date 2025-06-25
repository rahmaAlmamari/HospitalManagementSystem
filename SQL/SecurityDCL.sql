-- Security (DCL) 
--1. Create at least two user roles: DoctorUser, AdminUser. 
-- to create role for DoctorUser and AdminUser
CREATE ROLE DoctorUser;
CREATE ROLE AdminUser;

--2. GRANT SELECT for DoctorUser on Patients and Appointments only. 
-- Grant SELECT on Patients and Appointments
GRANT SELECT ON PatientsSchema.Patients TO DoctorUser;
GRANT SELECT ON DoctorsSchema.Appointments TO DoctorUser;

--3. GRANT INSERT, UPDATE for AdminUser on all tables. 
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

--4. REVOKE DELETE for Doctors.
--I do not give Doctors permission to delete so first I have to give it to him then do REVOKE
GRANT DELETE ON DoctorsSchema.Appointments TO DoctorUser;

REVOKE DELETE ON DoctorsSchema.Appointments FROM DoctorUser;

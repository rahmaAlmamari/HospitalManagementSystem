--Views 

--1. vw_DoctorSchedule: Upcoming appointments per doctor. 
CREATE VIEW vw_DoctorSchedule AS
SELECT 
    D.DoctorID,
    D.DoctorName,
    A.AppointmentDate,
    A.AppointmentTime,
    P.PatientName
FROM DoctorsSchema.Doctors D
JOIN DoctorsSchema.Appointments A ON D.DoctorID = A.DoctorID
JOIN PatientsSchema.Patients P ON A.PatientID = P.PatientID
WHERE A.AppointmentDate >= CAST(GETDATE() AS DATE); --to show only upcoming appointments

--to call VIEW vw_DoctorSchedule
SELECT * FROM vw_DoctorSchedule;

--2. vw_PatientSummary: Patient info with their latest visit. 
CREATE VIEW vw_PatientSummary AS
SELECT 
    P.PatientID,
    P.PatientName,
    P.Gender,
    P.PhoneNo,
    P.Email,
    MAX(M.Date) AS LatestVisitDate,--in my db Patient can have many MedicalRecords so I used MAX(M.Date) to get the recent one
    D.DoctorName AS LastDoctorSeen
FROM PatientsSchema.Patients P
LEFT JOIN DoctorsSchema.MedicalRecords M ON P.PatientID = M.PatientID
LEFT JOIN DoctorsSchema.Doctors D ON M.DoctorID = D.DoctorID
GROUP BY P.PatientID, P.PatientName, P.Gender, P.PhoneNo, P.Email, D.DoctorName;

--to call VIEW vw_PatientSummary
SELECT * FROM vw_PatientSummary;

--3. vw_DepartmentStats: Number of doctors and patients per department. 
CREATE VIEW vw_DepartmentStats AS
SELECT 
    Dept.DepartmentID,
    Dept.DepartmentName,
    COUNT(DISTINCT D.DoctorID) AS NumberOfDoctors, --I used 'DISTINCT' to count unique id of Doctor 
    COUNT(DISTINCT A.PatientID) AS NumberOfPatients --I used 'DISTINCT' to count unique id of Patient 
FROM SystemSchema.Departments Dept
LEFT JOIN DoctorsSchema.Doctors D ON Dept.DepartmentID = D.DepartmentID
LEFT JOIN DoctorsSchema.Appointments A ON D.DoctorID = A.DoctorID
GROUP BY Dept.DepartmentID, Dept.DepartmentName;

--to call VIEW vw_DepartmentStats
SELECT * FROM vw_DepartmentStats;
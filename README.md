# Required Database Objects - Tables (ERD)

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
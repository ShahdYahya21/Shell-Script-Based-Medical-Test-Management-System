# Medical Test Management System (Bash Script)

The **Medical Test Management System** is a Bash script that allows users to manage patient test records, validate inputs, and perform various operations such as adding, searching, updating, and deleting test records.

## Features

- **Input Validation**: Ensures correctness of patient IDs, test names, dates, statuses, and results.
- **Test Management**: Add, search, update, and delete medical test records.
- **Abnormal Test Detection**: Identifies test results that are outside normal ranges.
- **Statistical Analysis**: Computes average test values.
- **Interactive Menu**: Provides a user-friendly menu for system navigation.

---

## 1. Validation Functions

These functions ensure data correctness before processing.

### `validate_patient_id()`
- Checks if the patient ID is a **7-digit integer**.
- Uses `grep` with regex `[0-9]\{7\}` to match exactly **7 digits**.
- If invalid, prints `"Invalid ID"` and returns **1 (error)**.

### `check_test_existence()`
- Checks if a medical test exists in `medicalTest.txt`.
- Extracts test names and searches for the given test.
- If the test does not exist, prints `"The test does not exist"`.

### `validate_date()`
- Ensures the **date format** is `YYYY-MM`.
- Uses `grep -E '^[0-9]{4}-(0[1-9]|1[0-2])$'` to validate format and month range (`01-12`).
- If invalid, prints `"The Date is invalid"`.

### `validate_status()`
- Checks if the test status is **"pending"**, **"completed"**, or **"reviewed"**.
- Uses `grep -iE '^(pending|completed|reviewed)$'` for case-insensitive validation.
- If invalid, prints `"Invalid status"`.

### `validate_result()`
- Ensures the test result is a **number** (integer or float).
- Uses `grep '[0-9]\.[0-9]'` for floats or `grep '[0-9]'` for integers.
- If invalid, prints `"Invalid result"`.

---

## 2. Core Functionalities

### `Add_new_test()`
Prompts the user for:
- **Patient ID**
- **Test Name**
- **Test Date**
- **Test Status**
- **Test Result**

#### Validation:
- Each input is validated using respective functions.
- The test result is appended with its **unit** based on the test type:
  - `hgb` → `g/dL`
  - `bgt`, `ldl` → `mg/dL`
  - `systole`, `diastole` → `mm Hg`

- Saves the test data in **`medicalRecord.txt`**.

### `search_for_upNormal_tests()`
- Prompts the user for a **medical test name**.
- Extracts **normal range values** (`lowValue` & `highValue`) from `medicalTest.txt`.
- Compares each test result from `medicalRecord.txt`:
  - If the result is **greater than highValue** or **less than lowValue**, it prints the test as **abnormal**.

### `calc_avg()`
- Computes the **average test result** for each test.
- Extracts all test names from `medicalTest.txt`.
- Retrieves results from `medicalRecord.txt`, sums them up, and calculates the **average value**.

### `update_test()`
- Prompts the user for:
  - **Patient ID**
  - **Test Name**
  - **New Result**
- Ensures the patient has taken the specified test.
- Uses `sed` to replace the **old result** with the **new result** in `medicalRecord.txt`.

### `delete_test_result()`
- Asks for a **Patient ID**.
- Ensures the **patient exists**.
- Lists all tests for that patient and asks for a **line number**.
- Uses `sed` to delete the selected test from `medicalRecord.txt`.

---


## 3. Menu System

The script first prompts the user to enter a **file name** (`medicalRecord.txt`).  
If the file **does not exist**, the user is asked to **re-enter or exit**.

### **Main Menu**
```
please enter the name of the file , if you want exit enter -1
medicalRecord.txt

****Welcome to Medical Test Management System***

MAIN MENU
=====================================================
[1] Add a new medical test record
[2] Search for a test by patient ID
[3] Search for up normal tests
[4] Retrieve average test value
[5] Update test result
[6] Delete test result
[0] Exit from the program
=====================================================
Enter the choice:
```

---

## Example Use Cases

### Adding a Test Record
```
Enter patient ID:
1300512
Enter test name:
Diastole
Enter the test Date:
2024-07
Enter the test status:
Completed
Enter the test result:
25
```

### Searching for Tests by Patient ID
```
Please enter the patient ID:
1300512

All patient test for this 1300512 is:
1300512: Hgb, 2024-04, 32, g/dL, Completed
1300512: BGT, 2024-05, 120, mg/dL, Reviewed
1300512: LDL, 2022-07, 12, mg/dL, Pending
1300512: Diastole, 2024-07, 25, mm Hg, Completed
```

### Searching for Abnormal Tests
```
Enter a medical test:
BGT
The up normal tests:
1300512: BGT, 2022-05, 120, mg/dL, Pending
1300512: BGT, 2022-07, 120, mg/dL, Pending
```

### Retrieving Average Test Value
```
Retrieving average test value for BGT...
Average value for BGT: 110 mg/dL
```

### Updating a Test Result
```
Enter the patient ID:
1300515
Enter test name:
Systole
Enter the new result:
100
```

### Deleting a Test Result
```
Enter the ID to delete:
1300515
1: 1300515: Systole, 2024-07, 100, mm Hg, Completed
Enter the line number to delete from 'medicalRecord.txt':
1
The test with ID 1300515 has been deleted from medicalRecord.txt.
```

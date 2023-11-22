/*Add a Result_sal column to the Employees table. Create a new table Audit_sal(Date_Time, User, Employee_id, Salary_old, Salary_new, Com_old, com_new, Result_sal_old, result_sal_new). Create a Compound trigger that, when adding new records or changing values in the Salary and Commission_Pct columns, will automatically calculate the Result_sal value using the formula Salary + Salary*Commission_Pct and record changes in salary and commission percentage for each employee in the Audit_sal table, indicating the time of change and accounting the record that made the changes.
  Check the result of the trigger by simultaneously changing values with one UPDATE command and adding several rows with the INSERT..SELECT command.*/
/* Create a copy of the employees table */
CREATE TABLE EMPL5_14 AS(
SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME,EMAIL,PHONE_NUMBER,
HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID FROM EMPLOYEES
);
\
/* Delete data from the table */
delete from empl5_14;
\
/* Add a column to the table */
ALTER TABLE EMPL5_14 ADD RESULT_SAL NUMBER(8,2);
COMMIT;
\
/* Create a table for salary change audit report */
CREATE TABLE AUDIT_SAL (DATE_TIME DATE, USER_NAME VARCHAR2(30) NOT NULL,
    EMPLOYEE_ID NUMBER(6) NOT NULL, SALARY_OLD NUMBER(8,2),
    SALARY_NEW NUMBER(8,2), COM_OLD NUMBER(2,2), COM_NEW NUMBER(2,2),
    RESULT_SAL_OLD NUMBER(8,2), RESULT_SAL_NEW NUMBER(8,2));
\
/* Create a trigger */
CREATE OR REPLACE TRIGGER EMP_AUDIT_RES5_14 FOR
INSERT OR UPDATE OF SALARY, COMMISSION_PCT ON EMPL5_14
COMPOUND TRIGGER

/* Before each row is modified, fill the new column */
BEFORE EACH ROW IS
BEGIN
    :NEW.RESULT_SAL := :NEW.SALARY+:NEW.SALARY*:NEW.COMMISSION_PCT;
END BEFORE EACH ROW;

/* After each row is modified, insert data into the audit report */
AFTER EACH ROW IS
/* Define a variable of the audit report table type for convenience */
    AUDITREC AUDIT_SAL%ROWTYPE;
BEGIN
    AUDITREC.DATE_TIME := SYSDATE;
    AUDITREC.USER_NAME := USER;
    AUDITREC.EMPLOYEE_ID := :NEW.EMPLOYEE_ID;
    AUDITREC.SALARY_OLD := :OLD.SALARY;
    AUDITREC.SALARY_NEW := :NEW.SALARY;
    AUDITREC.COM_OLD := :OLD.COMMISSION_PCT;
    AUDITREC.COM_NEW := :NEW.COMMISSION_PCT;
    AUDITREC.RESULT_SAL_OLD := :OLD.RESULT_SAL;
    AUDITREC.RESULT_SAL_NEW := :NEW.RESULT_SAL; 
    INSERT INTO AUDIT_SAL VALUES AUDITREC;
END AFTER EACH ROW;
END EMP_AUDIT_RES5_14;
\
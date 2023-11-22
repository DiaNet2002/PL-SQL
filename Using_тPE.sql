
/*CREATE PROGRAM TO DISPLAY THE NAME AND NUMBER OF THE DEPARTMENT LOCATED IN SOUTHLAKE CITY (USING DEPARTMENTS AND LOCATIONS TABLE). USE THE %TYPE DIRECTIVE IN YOUR SOLUTION.*/

DECLARE
    dep_no departments.department_id%TYPE;
    dep_name departments.department_name%TYPE;
BEGIN
    -- Select the department_id and department_name into variables dep_no and dep_name respectively
    -- from the departments table where department_id is the minimum value
    -- among the departments that are joined with locations table on location_id
    -- and the city is 'Southlake'
    SELECT department_id, department_name 
    INTO dep_no, dep_name 
    FROM departments
    WHERE department_id= (SELECT MIN(department_id)
                          FROM departments d JOIN locations l ON (d.location_id = l.location_id)
                          WHERE l.city='Southlake');
    -- Display the department number and name
    DBMS_OUTPUT.PUT_LINE('Department in Southlake has number ' || dep_no || ' and name ' || dep_name);
END;
/

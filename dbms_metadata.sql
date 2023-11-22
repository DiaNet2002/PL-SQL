/*Creating triggers Create a package to save in a file DDL commands for creating individual schema objects (tables, views, packages, triggers, procedures, functions), groups of objects of the same type or all objects). File name, group of objects, name of a specific object – parameters.*/
CREATE OR REPLACE PACKAGE ddl_export AS
    PROCEDURE export_ddl(
        p_object_type IN VARCHAR2, 
        p_object_name in VARCHAR2, 
        p_file_name  in VARCHAR2
    );
 PROCEDURE export_ddl_group(
        p_object_type in VARCHAR2, 
        p_file_name in VARCHAR2
    );
   PROCEDURE export_ddl_all(
        p_file_name in VARCHAR2
    );/**/
END ddl_export;
/
CREATE OR REPLACE PACKAGE BODY ddl_export AS
    PROCEDURE export_ddl(
        p_object_type VARCHAR2, 
        p_object_name VARCHAR2, 
        p_file_name VARCHAR2
    ) AS
/*Convert to uppercase for input parameters*/
    p_type VARCHAR2(30) :=Upper(p_object_type);
     p_name VARCHAR2(30) :=Upper(p_object_name);
        l_file UTL_FILE.FILE_TYPE; 
    BEGIN
        l_file := UTL_FILE.FOPEN('STUD_PLSQL', p_file_name, 'W');
        UTL_FILE.PUT_LINE(l_file, DBMS_METADATA.GET_DDL(p_type, p_name));
        UTL_FILE.FCLOSE(l_file);
         EXCEPTION
/*Print error for incorrect arguments or if they do not exist*/
    WHEN OTHERS THEN
      dbms_output.put_line('An error occurred: '  SQLERRM);
    END;

   PROCEDURE export_ddl_group(p_object_type IN VARCHAR2, p_file_name IN VARCHAR2)
  AS
    v_file UTL_FILE.FILE_TYPE;
/*Cursor to select objects of the specified group type*/
    cursor v_cursor is
    select object_name, object_type
    from user_objects
    where object_type=upper(p_object_type);

  BEGIN

    v_file := utl_file.fopen('STUD_PLSQL', p_file_name, 'W');
/*Loop through and write the data of all elements in the group*/
    for rec in v_cursor loop
    utl_file.put(v_file, DBMS_METADATA.GET_DDL(rec.object_type, rec.object_name));
    end loop;
    utl_file.fclose(v_file);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('An error occurred: '  SQLERRM);
  END;

  PROCEDURE export_ddl_all( p_file_name IN VARCHAR2)
  AS
    v_file UTL_FILE.FILE_TYPE;
/*Cursor to select all objects except package bodies and LOBs*/
    cursor v_cursor is
    select object_name, object_type
    from user_objects
    WHERE object_type!='PACKAGE BODY'
    AND object_type!='LOB' ;

  BEGIN
    v_file := utl_file.fopen('STUD_PLSQL', p_file_name, 'W');
    for rec in v_cursor loop
    utl_file.put(v_file, DBMS_METADATA.GET_DDL(rec.object_type, rec.object_name));
    end loop;
    utl_file.fclose(v_file);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('An error occurred: ' || SQLERRM);
  END;
END ddl_export;
/
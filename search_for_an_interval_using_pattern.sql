/*The file records dates and data on product prices on these dates. You want to create a batch procedure that allows you to determine time intervals during which product prices changed according to a specified pattern. The following values can be used in the template: I – increasing interval, D – decreasing price interval, C – constant price interval. The number of intervals in the pattern and the order in which they appear is determined by the user when performing the procedure.
Examples of templates:
I, C, D, I, D
D, I, D, I
I, D, I
Procedure parameters: Analysis interval start date, Analysis interval end date, Product name, Template.
As a result of the procedure, all intervals in which the price of the product changed in accordance with the template should be obtained.
Information about the start date of each interval corresponding to the template, the end date of each interval corresponding to the template, and the duration of the intervals should be displayed on the screen and in the file.
The package must contain procedures for viewing data from the source data file and the results file.
Exception handling is required.*/
DECLARE
  v_file_handle UTL_FILE.FILE_TYPE;
BEGIN
  -- Open the file for writing
  v_file_handle := UTL_FILE.FOPEN('STUD_PLSQL', 'dia_net_dop4_product.txt', 'W');
  -- Write information to a file
  UTL_FILE.PUT_LINE(v_file_handle, 'dia_net_dop4_product.txt');
  UTL_FILE.PUT_LINE(v_file_handle, 'Хлеб#01.03.21#35');
    UTL_FILE.PUT_LINE(v_file_handle, 'Хлеб#02.03.21#37');
    UTL_FILE.PUT_LINE(v_file_handle, 'Хлеб#03.03.21#37');
    UTL_FILE.PUT_LINE(v_file_handle, 'Хлеб#04.03.21#33');
    UTL_FILE.PUT_LINE(v_file_handle, 'Хлеб#05.03.21#37');
    UTL_FILE.PUT_LINE(v_file_handle, 'Хлеб#06.03.21#32');
    UTL_FILE.PUT_LINE(v_file_handle, 'Хлеб#07.03.21#31');
    UTL_FILE.PUT_LINE(v_file_handle, 'Молоко#01.03.21#48');
    UTL_FILE.PUT_LINE(v_file_handle, 'Молоко#02.03.21#45');
    UTL_FILE.PUT_LINE(v_file_handle, 'Молоко#03.03.21#43');
    UTL_FILE.PUT_LINE(v_file_handle, 'Молоко#04.03.21#49');
    UTL_FILE.PUT_LINE(v_file_handle, 'Молоко#05.03.21#50');
    UTL_FILE.PUT_LINE(v_file_handle, 'Молоко#06.03.21#43');
    UTL_FILE.PUT_LINE(v_file_handle, 'Молоко#07.03.21#46');
    UTL_FILE.PUT_LINE(v_file_handle, 'Яблоки#01.03.21#100');
    UTL_FILE.PUT_LINE(v_file_handle, 'Яблоки#02.03.21#100');
    UTL_FILE.PUT_LINE(v_file_handle, 'Яблоки#03.03.21#105');
    UTL_FILE.PUT_LINE(v_file_handle, 'Яблоки#04.03.21#107');
    UTL_FILE.PUT_LINE(v_file_handle, 'Яблоки#05.03.21#104');
    UTL_FILE.PUT_LINE(v_file_handle, 'Яблоки#06.03.21#110');
    UTL_FILE.PUT_LINE(v_file_handle, 'Яблоки#07.03.21#107');
    UTL_FILE.PUT_LINE(v_file_handle, 'Яблоки#08.03.21#110');
    UTL_FILE.PUT_LINE(v_file_handle, 'Яблоки#09.03.21#107');
    UTL_FILE.PUT_LINE(v_file_handle, 'Мясо#01.03.21#400');
    UTL_FILE.PUT_LINE(v_file_handle, 'Мясо#02.03.21#400');
    UTL_FILE.PUT_LINE(v_file_handle, 'Мясо#03.03.21#410');
    UTL_FILE.PUT_LINE(v_file_handle, 'Мясо#04.03.21#407');
    UTL_FILE.PUT_LINE(v_file_handle, 'Мясо#05.03.21#420');
    UTL_FILE.PUT_LINE(v_file_handle, 'Мясо#06.03.21#409');
    UTL_FILE.PUT_LINE(v_file_handle, 'Мясо#07.03.21#430');
    UTL_FILE.PUT_LINE(v_file_handle, '');
  -- Close the file
  UTL_FILE.FCLOSE(v_file_handle);
END;
\
/*Package specification code:*/
CREATE OR REPLACE PACKAGE price_analysis_pkg IS
TYPE record_type IS RECORD (
        product VARCHAR2(100),
        date_p DATE,
        price NUMBER(6)
      );
      /*collection type*/
      TYPE collection_type IS TABLE OF record_type INDEX BY PLS_INTEGER;
      /*declare the collection*/
     data_collection collection_type;
    PROCEDURE find_price_intervals(start_date IN DATE, end_date IN DATE, product_name IN VARCHAR2, patt IN VARCHAR2);
	PROCEDURE price_analitics (start_date IN DATE, end_date IN DATE, p_name IN VARCHAR2);
PROCEDURE print_file(ind IN VARCHAR) ;
END price_analysis_pkg;
\
/*Package body code:*/
CREATE OR REPLACE PACKAGE BODY price_analysis_pkg IS
   PROCEDURE price_analitics (start_date IN DATE, end_date IN DATE, p_name IN VARCHAR2)
IS
 /*line to read file*/
  file_line VARCHAR2(500);
    /*-- variables for writing data from a file line*/
  product_name VARCHAR2(100);
  date_value DATE;
  price_value NUMBER;
  file_handler UTL_FILE.FILE_TYPE;
  coll collection_type;
  c NUMBER;
BEGIN
/*Read data from the file and add it to the collection*/
    /* -- open the file for reading*/
    file_handler := UTL_FILE.FOPEN('STUD_PLSQL', 'dia_net_dop4_product.txt', 'R');
    UTL_FILE.GET_LINE(file_handler, file_line);
     /* -- read the file line by line*/
    LOOP
      UTL_FILE.GET_LINE(file_handler, file_line);
       /*-- check that the string is not empty*/
      EXIT WHEN file_line IS NULL ;
      c:=data_collection.COUNT + 1;
      /* -- split the line by '#'*/
      product_name := SUBSTR(file_line, 1, INSTR(file_line, '#') - 1);
      
      date_value := TO_DATE(SUBSTR(file_line, INSTR(file_line, '#') + 1, INSTR(file_line, '#', 1, 2) - INSTR(file_line, '#') - 1), 'DD.MM.YYYY');
      price_value := TO_NUMBER(SUBSTR(file_line, INSTR(file_line, '#', 1, 2) + 1));

      /* -- add an entry to the collection*/
    data_collection(c).product := product_name;
     data_collection(c).date_p :=date_value;
     data_collection(c).price :=price_value;

    END LOOP;
    /* -- close the file*/
    UTL_FILE.FCLOSE(file_handler);
/*Select records from the collection by intervals and product*/
   SELECT * BULK COLLECT INTO coll
  FROM TABLE(data_collection)
  where product=p_name AND date_p >= start_date
            AND date_p <= end_date
  ORDER BY product,date_p; 
 data_collection.DELETE;
  FOR i IN 1..coll.COUNT LOOP
    data_collection(i) := coll(i);
  END LOOP;
  END;
  /*Procedure for printing a file with source data or result (depending on the parameter)*/
  PROCEDURE print_file (ind IN VARCHAR)
  is
v_file_handle UTL_FILE.FILE_TYPE;
v_file_line VARCHAR2(4000);
no_file EXCEPTION;
BEGIN
    /*-- Open the file for reading*/
  if(ind='rez') then 
  v_file_handle := UTL_FILE.FOPEN('STUD_PLSQL', 'dia_net_dop4_rezult.txt', 'R');
  else if(ind='product') then 
  v_file_handle := UTL_FILE.FOPEN('STUD_PLSQL', 'dia_net_dop4_product.txt', 'R');
  else RAISE no_file;
  end if;
  end if;
   /* -- Read data from the file line by line*/
  LOOP
    BEGIN
      UTL_FILE.GET_LINE(v_file_handle, v_file_line);
      DBMS_OUTPUT.PUT_LINE(v_file_line);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        EXIT;
    END;
  END LOOP;

  /* -- Close the file*/
  UTL_FILE.FCLOSE(v_file_handle);
/*Exception handling: if there is no file with the result yet, or the wrong parameter is specified*/
  EXCEPTION
      WHEN no_file THEN
  DBMS_OUTPUT.PUT_LINE('Такого параметра нет!!! Используйте rez для просмотра результата или product для списка продуктов');
  when UTL_FILE.invalid_operation then 
   DBMS_OUTPUT.PUT_LINE('Файла с результатом пока нет');
  end;
/*Procedure for finding intervals using a template*/
      PROCEDURE find_price_intervals(start_date IN DATE, end_date IN DATE, product_name IN VARCHAR2, patt IN VARCHAR2) IS
        v_file_handle UTL_FILE.FILE_TYPE;
/*Record for storing template data*/
        TYPE rez_type IS RECORD (
        p VARCHAR2(1),
        s_d DATE,
        e_d DATE
      );
    /* -- collection type*/
      TYPE rezalt_type IS TABLE OF rez_type INDEX BY PLS_INTEGER;
    str varchar2(100);
    rez varchar2(200);
    TYPE mas_type IS TABLE OF rez_type INDEX BY PLS_INTEGER;
     mas mas_type;
      mas2 mas_type;
     k number(3) :=mas.count;
      v number(3) :=mas2.count;
      no_data_file exception;
      no_pattern exception;
      pat varchar2(100):=patt;
    BEGIN
/*Call the procedure to fetch data*/
     price_analitics (start_date, end_date, product_name);
    if(data_collection.count=0) then raise no_data_file;end if;
/*Remove repeated characters in a row in the template*/
    pat:=REGEXP_replace(pat,'I+','I');
    pat:=REGEXP_replace(pat,'C+','C');
    pat:=REGEXP_replace(pat,'D+','D');
/*Set the sample to a template that it fits*/
        for i in 2..data_collection.count
        loop
        k:=mas.count+1;
            if(data_collection(i-1).price>data_collection(i).price) then 
            mas(k).p:='D'; mas(k).s_d:=data_collection(i-1).date_p;
            mas(k).e_d:=data_collection(i).date_p;
            elsif (data_collection(i-1).price<data_collection(i).price) then 
            mas(k).p:='I'; mas(k).s_d:=data_collection(i-1).date_p;
            mas(k).e_d:=data_collection(i).date_p;
            elsif (data_collection(i-1).price=data_collection(i).price) then 
            mas(k).p:='C'; mas(k).s_d:=data_collection(i-1).date_p;
            mas(k).e_d:=data_collection(i).date_p;
            end if;
            
        end loop;
       /*If the intervals in the sample pattern are repeated by type, they are combined*/
        k:=mas.count;
        mas2(1):=mas(1);
        for i in 2..k
        loop
            v:=mas2.count+1;
            if(mas2(v-1).p=mas(i).p) then
            mas2(v-1).e_d:=mas(i).e_d;
            else mas2(v):=mas(i);
            end if;
        end loop;
        /*Convert the selection pattern into a string*/
        for i in 1..mas2.count
        loop 
        str:=str||to_char(mas2(i).p);
        end loop;
        k:=1;
/*Check for at least one pattern match*/
        if (instr(str,pat,k)=0) then RAISE no_pattern;end if;
        v_file_handle := UTL_FILE.FOPEN('STUD_PLSQL', 'dia_net_dop4_rezult.txt', 'W');
        UTL_FILE.PUT_LINE(v_file_handle, 'dia_net_dop4_rezult.txt');
        /*Find all matching patterns and create a file from them and display them on the screen*/
        loop
        v:=instr(str,pat,k);
        rez:='Start date: '||mas2(v).s_d||', '||'End date: '||mas2(v+length(pat)-1).e_d||', Duration:  '||(mas2(v+length(pat)-1).e_d-mas2(v).s_d);
        DBMS_OUTPUT.PUT_LINE(rez);
        UTL_FILE.PUT_LINE(v_file_handle, rez);
        k:=v+1;
        exit when instr(str,pat,k)=0;
        end loop;
        UTL_FILE.FCLOSE(v_file_handle);
        mas.DELETE;
        mas2.delete;
        data_collection.delete;
        /*Error handling: for the absence of requested data, for non-matching patterns */
        exception when no_data_file
        then v_file_handle := UTL_FILE.FOPEN('STUD_PLSQL', 'dia_net_dop4_rezult.txt', 'W');
        UTL_FILE.PUT_LINE(v_file_handle, 'dia_net_dop4_rezult.txt');
        rez:='Такого продукта в данные даты нет. Для просмотра данных используйте функцию print_file с параметром product';
         DBMS_OUTPUT.PUT_LINE(rez);
          UTL_FILE.PUT_LINE(v_file_handle, rez);
          UTL_FILE.FCLOSE(v_file_handle);
          when no_pattern then 
          v_file_handle := UTL_FILE.FOPEN('STUD_PLSQL', 'dia_net_dop4_rezult.txt', 'W');
        UTL_FILE.PUT_LINE(v_file_handle, 'dia_net_dop4_rezult.txt');
        rez:='По данному шаблону ничего не найдено';
         DBMS_OUTPUT.PUT_LINE(rez);
          UTL_FILE.PUT_LINE(v_file_handle, rez);
          UTL_FILE.FCLOSE(v_file_handle);
    END;
END price_analysis_pkg;

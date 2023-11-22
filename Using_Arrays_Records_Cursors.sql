/*The table contains information about successful and unsuccessful attempts to connect to the database (User, Time, Successful/Failure). You need to get a list of users who have made N unsuccessful connection attempts in a row and the time of the last unsuccessful connection. After N consecutive unsuccessful connection attempts, the countdown of attempts begins again. The value N is specified as a parameter.
If there are no records in the table that satisfy the specified value N, the following message should be displayed:
No user has made <number> consecutive unsuccessful connection attempts.*/

/*Create table for testing*/
DROP TABLE conect;
CREATE TABLE conect
(name VARCHAR2(30)  NOT NULL, 
time_log TIMESTAMP NOT NULL,
result	VARCHAR2(10) NOT NULL);

INSERT INTO conect 
VALUES('A',TO_DATE('20-11-11 17:58:00','DD.MM.YY HH24:MI:SS'), 'Неудачно');
INSERT INTO conect
VALUES('B',TO_DATE('20-11-11 18:00:05','DD.MM.YY HH24:MI:SS'), 'Удачно');
INSERT INTO conect 
VALUES('C',TO_DATE('20-11-11 18:10:03','DD.MM.YY HH24:MI:SS'), 'Неудачно');
INSERT INTO conect
VALUES('A',TO_DATE('20-11-11 18:12:20','DD.MM.YY HH24:MI:SS'), 'Неудачно');
INSERT INTO conect
VALUES('B',TO_DATE('20-11-11 18:18:00','DD.MM.YY HH24:MI:SS'), 'Неудачно');
INSERT INTO conect 
VALUES('B',TO_DATE('20-11-11 18:20:01','DD.MM.YY HH24:MI:SS'), 'Удачно');
INSERT INTO conect
VALUES('C',TO_DATE('20-11-11 18:25:42','DD.MM.YY HH24:MI:SS'), 'Неудачно');
INSERT INTO conect 
VALUES('A',TO_DATE('20-11-11 18:30:12','DD.MM.YY HH24:MI:SS'), 'Неудачно');
INSERT INTO conect
VALUES('A',TO_DATE('20-11-11 18:32:24','DD.MM.YY HH24:MI:SS'), 'Неудачно');
INSERT INTO conect 
VALUES('A',TO_DATE('20-11-11 18:35:00','DD.MM.YY HH24:MI:SS'), 'Удачно');
INSERT INTO conect
VALUES('B',TO_DATE('20-11-11 18:41:30','DD.MM.YY HH24:MI:SS'), 'Удачно');
INSERT INTO conect
VALUES('C',TO_DATE('20-11-11 18:42:08','DD.MM.YY HH24:MI:SS'), 'Неудачно');
INSERT INTO conect
VALUES('C',TO_DATE('20-11-11 18:48:00','DD.MM.YY HH24:MI:SS'), 'Удачно');
INSERT INTO conect
VALUES('A',TO_DATE('20-11-11 18:52:00','DD.MM.YY HH24:MI:SS'), 'Неудачно');
INSERT INTO conect
VALUES('A',TO_DATE('20-11-11 18:53:13','DD.MM.YY HH24:MI:SS'), 'Неудачно');
INSERT INTO conect 
VALUES('B',TO_DATE('20-11-11 18:54:30','DD.MM.YY HH24:MI:SS'), 'Неудачно');
INSERT INTO conect 
VALUES('A',TO_DATE('20-11-11 18:55:19','DD.MM.YY HH24:MI:SS'), 'Неудачно');
INSERT INTO conect 
VALUES('A',TO_DATE('20-11-11 18:55:58','DD.MM.YY HH24:MI:SS'), 'Удачно');



DEFINE NUM=&N;
/*Ask for the number of repetitions*/
DECLARE 
    CURSOR con_cursor IS
        SELECT ROWNUM AS count, name, time_log, result
        FROM conect
        ORDER BY 2,3;
    /*Create a cursor with the sorted table and row numbering*/
    TYPE rec_con IS RECORD 
        ( last_n conect.name%TYPE, time conect.time_log%TYPE);
        /*Create record to store name and time*/
    TYPE m_con IS TABLE OF
        rec_con
    INDEX BY PLS_INTEGER;
    /*Create array to store required rows*/
    massiv m_con;
    v_ename VARCHAR(30) :=' '; 
    /*variable to store the used name*/
    n NUMBER:=0;
    i PLS_INTEGER;
    e_no_data_cur EXCEPTION;
    e_small_n EXCEPTION;
BEGIN
    IF(&NUM<2) THEN 
        RAISE e_small_n; END IF; 
        /*check the value of n*/
    FOR con IN con_cursor
        LOOP
            IF(con_cursor%NOTFOUND) THEN 
                RAISE e_no_data_cur; END IF; 
                /*check for connection data availability*/
            IF(v_ename !=con.name) THEN  
                v_ename:=con.name; n:=0;
            END IF; 
            /*check the name to compare data only for one person*/
            IF(con.result='Неудачно') THEN 
                n:=n+1; 
                /*count unsuccessful connections*/
                IF(n=&NUM) THEN
                    massiv(con.count).last_n:=con.name;
                    massiv(con.count).time:=con.time_log;
                END IF;
                /*store data when the required number of repetitions is reached*/
            ELSE n:=0; 
            /*reset the counter if there was a successful connection*/
            END IF;
       END LOOP;
    i := massiv.FIRST;
    IF(i IS NULL) 
        THEN DBMS_OUTPUT.PUT_LINE('No user made '&NUM' consecutive unsuccessful connection attempts.'); 
        /*if the array is empty, output that there is no suitable data*/
    ELSE 
        DBMS_OUTPUT.PUT_LINE('User Time of the '&NUM'th consecutive unsuccessful attempt');
        WHILE i IS NOT NULL LOOP
            DBMS_Output.PUT_LINE
                ('       'massiv(i).last_n '       '||TO_CHAR( massiv(i).time,'DD.MM.YY HH24:MI:SS'));
            i := massiv.NEXT(i);  
        END LOOP;
  END IF; 
  /*output data from the array*/
EXCEPTION
    WHEN e_no_data_cur THEN
        DBMS_OUTPUT.PUT_LINE('No connection data available');
/*Display error when there is no data*/
    WHEN e_small_n THEN
        DBMS_OUTPUT.PUT_LINE('Enter a number of unsuccessful attempts greater than 2');  
/*Display error when n is small*/
END;

Translate the comments to English:

DEFINE NUM=&N;
/*Ask for the number of repetitions*/
DECLARE 
    CURSOR con_cursor IS
        SELECT ROWNUM AS count, name, time_log, result
        FROM conect
        ORDER BY 2,3;
    /*Create a cursor with the sorted table and row numbering*/
    TYPE rec_con IS RECORD 
        ( last_n conect.name%TYPE, time conect.time_log%TYPE);
        /*Create record to store name and time*/
    TYPE m_con IS TABLE OF
        rec_con
    INDEX BY PLS_INTEGER;
    /*Create array to store required rows*/
    massiv m_con;
    v_ename VARCHAR(30) :=' '; 
    /*variable to store the used name*/
    n NUMBER:=0;
    i PLS_INTEGER;
    e_no_data_cur EXCEPTION;
    e_small_n EXCEPTION;
BEGIN
    IF(&NUM<2) THEN 
        RAISE e_small_n; END IF; 
        /*check the value of n*/
    FOR con IN con_cursor
        LOOP
            IF(con_cursor%NOTFOUND) THEN 
                RAISE e_no_data_cur; END IF; 
                /*check for connection data availability*/
            IF(v_ename !=con.name) THEN  
                v_ename:=con.name; n:=0;
            END IF; 
            /*check the name to compare data only for one person*/
            IF(con.result='Неудачно') THEN 
                n:=n+1; 
                /*count unsuccessful connections*/
                IF(n=&NUM) THEN
                    massiv(con.count).last_n:=con.name;
                    massiv(con.count).time:=con.time_log;
                END IF;
                /*store data when the required number of repetitions is reached*/
            ELSE n:=0; 
            /*reset the counter if there was a successful connection*/
            END IF;
       END LOOP;
    i := massiv.FIRST;
    IF(i IS NULL) 
        THEN DBMS_OUTPUT.PUT_LINE('No user made '&NUM' consecutive unsuccessful connection attempts.'); 
        /*if the array is empty, output that there is no suitable data*/
    ELSE 
        DBMS_OUTPUT.PUT_LINE('User Time of the '&NUM'th consecutive unsuccessful attempt');
        WHILE i IS NOT NULL LOOP
            DBMS_Output.PUT_LINE
                ('       'massiv(i).last_n '       '||TO_CHAR( massiv(i).time,'DD.MM.YY HH24:MI:SS'));
            i := massiv.NEXT(i);  
        END LOOP;
  END IF; 
  /*output data from the array*/
EXCEPTION
    WHEN e_no_data_cur THEN
        DBMS_OUTPUT.PUT_LINE('No connection data available');
/*Display error when there is no data*/
    WHEN e_small_n THEN
        DBMS_OUTPUT.PUT_LINE('Enter a number of unsuccessful attempts greater than 2');  
/*Display error when n is small*/
END;
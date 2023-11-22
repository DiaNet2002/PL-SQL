/*Create a package for converting an algebraic expression into Polish notation, reverse Polish notation, and vice versa. The package should also provide translation of expressions from Polish notation to reverse Polish notation and vice versa.
Example:
Original expression (1 + 22)*4 + a
Representation in reverse Polish notation 1 22 + 4 ? a +
*/
/*Package declaration*/
create or replace PACKAGE dop3_pkg AS
    FUNCTION f_get_opz (
        p_str IN VARCHAR2
    ) RETURN VARCHAR2;

  FUNCTION f_ret_opz (
        p_str IN VARCHAR2
    ) RETURN VARCHAR2;
      FUNCTION get_check (
        p_str IN VARCHAR2
    ) RETURN boolean;

    FUNCTION return_check (
        p_str IN VARCHAR2
    ) RETURN boolean;
END dop3_pkg;

/*Package body*/
create or replace package BODY dop3_pkg 
AS
  FUNCTION f_get_opz (
        p_str IN VARCHAR2
    ) RETURN VARCHAR2
    As
/*Record for operation priorities*/
    TYPE my_rec_pr IS RECORD (
        s    VARCHAR2(6),
        pr   NUMBER(1)
    );
/*Storing characters operation*/
    TYPE op_table IS
        TABLE OF my_rec_pr INDEX BY PLS_INTEGER;
    rec      my_rec_pr;
    o        op_table;
    i        NUMBER := 1;
    k        NUMBER := 1;
    j        NUMBER := 0;
    l        NUMBER ;
    s2       VARCHAR2(3);
    stroka   VARCHAR2(400);
    str varchar2(400) :=p_str;
    e_no_good EXCEPTION;
BEGIN
/*Remove spaces, replace the unary minus with an underscore and add parentheses at the beginning and end*/
    str := replace(str, ' ');
    str := regexp_replace(str, '^-', '_');
    str := regexp_replace(str, '\(-', '(_');
    str:='('||str||')';
    l := length(str);

/*Call the check function, if it returns false, then throw an exception*/
    if(not get_check(str)) then raise e_no_good; 
    end if;
    WHILE ( i < l ) LOOP
        j := j + 1;

/*Check for the first occurrence of a number or sign*/
/*If this is a number, then enter it in a line*/
        IF ( regexp_instr(str, '\w*[.,]?\w+[$]?', i) < regexp_instr(str, '[()\*\+-\\]', i) OR regexp_instr(str, '[()\*\+-\\]', i)= 0 ) THEN
            stroka := stroka || '  ' || regexp_substr(str, '\w*[.,]?\w+[$]?', i);
/*We count the position of the beginning of the search for further*/
            i := regexp_instr(str, '\w*[.,]?\w+[$]?', i) + length(regexp_substr(str, '\w*[.,]?\w+[$]?', i));
        ELSE
            s2 := regexp_substr(str, '[()\*\+-\\]', i);
            i := regexp_instr(str, '[()\*\+-\\]', i) + length(regexp_substr(str, '[()\*\+-\\]', i));

/*Assign priorities to operations*/
            IF ( s2 = '(' OR s2 = ')' ) THEN
                o(k).pr := 3;
                o(k).s := s2;
                k := k + 1;
            ELSE
                IF ( s2 = '/' OR s2 = '*' ) THEN
                    o(k).pr := 1;
                    o(k).s := s2;
                    k := k + 1;
                ELSIF ( s2 = '+' OR s2 = '-' ) THEN
                    o(k).pr := 2;
                    o(k).s := s2;
                    k := k + 1;
                END IF;

/*If an operation with a higher priority is encountered, then we enter all the previous ones in a line*/                IF ( k > 2 AND o(k - 2).pr <= o(k - 1).pr ) THEN
                    stroka := stroka || '  '|| o(k - 2).s;
                    o(k - 2).pr := o(k - 1).pr;
                    o(k - 2).s := o(k - 1).s;
                    o.DELETE(k - 1);
                    k := k - 1;
                END IF;
            END IF;
/*When we encounter a closing bracket, before we encounter an opening bracket, we enter the operations in the line*/            IF ( k >= 2 AND o(k - 1).s = ')' ) THEN
                o.DELETE(k - 1);
                k := k - 2;
                WHILE ( o(k).s != '(' ) LOOP
                    stroka := stroka || '  '|| o(k).s;
                    o.DELETE(k);
                    k := k - 1;
                    EXIT WHEN o(k).s = '(';
                END LOOP;
                o.DELETE(k);
            END IF;
        END IF;
    END LOOP;

/*Enter the last character in the line*/
    IF ( i >= l ) THEN
        k := o.last;
        IF ( k >= 2 ) THEN
            LOOP
                  stroka := stroka || '  ' || o(k).s;
                o.DELETE(k);
                k := o.last;
                EXIT WHEN o(k).s='(';
            END LOOP;
            o.DELETE(k);
        END IF;
    END IF;
    return stroka;

/*Exception handling*/
  exception 
    when e_no_good then 
    return ' Не корректно введены данные';
    raise;
    
END f_get_opz;

  FUNCTION f_ret_opz (
        p_str IN VARCHAR2
    ) RETURN VARCHAR2

As
/*Array for components*/
    TYPE op_table IS
        TABLE OF VARCHAR2(160) INDEX BY PLS_INTEGER;

    o        op_table;
    i        NUMBER := 1;
    k        NUMBER ;
    j        NUMBER := 1;
    s2       VARCHAR2(3);
    pr       NUMBER(1) := 0;
    pr2      NUMBER(1) := 0;
    stroka   VARCHAR2(400);
    str VARCHAR2(400):=p_str; 
    l        NUMBER := length(str);
     e_no_good EXCEPTION;
BEGIN

/*Call a function to check the validity of the input string*/
  if(not return_check(str)) then raise e_no_good; 
    end if;
    k := 1;
    WHILE ( i > 0 ) LOOP

/*Find the first component*/
        i := instr(str, ' ', j + 1);

/*If we put this number in an array*/
        IF ( regexp_like(substr(str, j, i - j), '\w*[.,]?\w+[$]?') ) THEN
            o(k) := substr(str, j, i - j);
            k := k + 1;
        ELSE

/*If the sign is entered into a variable*/
            IF ( substr(str, j, i - j) IS NULL ) THEN
                s2 := replace(substr(str, j), ' ');
            ELSE
                s2 := replace(substr(str, j, i - j), ' ');
            END IF;

/*Prioritize operations*/
            IF ( s2 = '/' OR s2 = '*' ) THEN
                pr2 := 1;
            ELSIF ( s2 = '+' OR s2 = '-' ) THEN
                pr2 := 2;
            END IF;

/*Compare priorities and form a string*/
            IF ( k > 2 ) THEN
                IF ( pr2 < pr ) THEN
                    o(k - 2) := '('  || o(k - 2) || ') '|| ' '|| s2 || ' '  || '(' || o(k - 1) || ') ';
                ELSE
                    o(k - 2) := o(k - 2)  || ' '  || s2 || ' ' || o(k - 1);
                END IF;
                k := k - 1;
            END IF;
            pr := pr2;
        END IF;
        str := substr(str, j + i);
    END LOOP;
    return o(k - 1);

/*Handling invalid line exception*/
       exception 
    when e_no_good then 
    return ' Не корректно введены данные';
END f_ret_opz; 

 FUNCTION get_check (
        p_str IN VARCHAR2
    ) RETURN boolean
as
 str   VARCHAR2(400) := p_str;
/*Array of components*/
    TYPE op_table IS
        TABLE OF VARCHAR2(10) INDEX BY PLS_INTEGER;
/*Stack of closing brackets*/
    TYPE skob IS
        TABLE OF VARCHAR2(10) INDEX BY PLS_INTEGER;
    o     op_table;
    f     skob;
    i     NUMBER := 1;
    k     NUMBER := 1;
    j     NUMBER := 1;
    l     NUMBER := length(str);
BEGIN
    WHILE ( i <= l ) LOOP

/*Check for characters*/
    IF ( regexp_count(str, '[\*\+-\\]') = 0 ) THEN
          return false;
        END IF;

/*Checking that there are one more numbers than characters*/
        IF ( NOT regexp_count(str, '\w*[.,]?\w+[$]?') - 1 = regexp_count(str, '[\*\+-\\]') - regexp_count(str, '\w*[.,]\w+[$]?') )
        THEN
            return false;
        END IF;
/*Check for a number or sign*/
        IF ( regexp_count(str, '\w*[.,]?\w+[$]?', i) > 0 AND regexp_instr(str, '\w*[.,]?\w+[$]?', i) < regexp_instr(str, '[()\*\+-\\]'
        , i) OR regexp_instr(str, '[()\*\+-\\]', i) < 0 ) THEN
            o(k) := regexp_substr(str, '\w*[.,]?\w+[$]?', i);

/*Check for two numbers in a row*/
            IF ( k > 1 AND regexp_like(o(k - 1), '\w*[.,]?\w+[$]?') ) THEN
               return false;
            END IF;

            i := regexp_instr(str, '\w*[.,]?\w+[$]?', i) + length(regexp_substr(str, '\w*[.,]?\w+[$]?', i));

        ELSE
            o(k) := regexp_substr(str, '[()\*\+-\\]', i);
/*If there is an opening parenthesis, then push the closing one onto the stack*/            
IF ( o(k) = '(' ) THEN
                f(j) := ')';
                j := j + 1;
                o.DELETE(k);
                k := k - 1;

/*If the closing parenthesis and the parenthesis stack is not empty*/
            ELSIF ( k > 0 AND o(k) = ')' AND f.last IS NOT NULL ) THEN
                o.DELETE(k);
                k := k - 1;
                f.DELETE(j - 1);
                j := j - 1;
/*If the stack of brackets is empty*/
            ELSIF ( k > 0 AND o(k) = ')' AND f.last IS NULL ) THEN
                return false;
                o.DELETE(k);
                k := k - 1;
/*check for input of other characters*/
            ELSIF ( k > 3 AND regexp_like(o(k - 1), '[()\*\+-\\]') AND o(k - 1) != '(' AND NOT regexp_like(o(k - 1), '\w*[.,]?\w+[$]?'
            ) ) THEN
               return false;
            END IF;

            i := regexp_instr(str, '[()\*\+-\\]', i) + length(regexp_substr(str, '[()\*\+-\\]', i));

        END IF;

        k := k + 1;
    END LOOP;

/*If the stack is not empty at the end*/
    IF ( f.count > 0 ) THEN
        return false;
    END IF;
    return true;
END get_check;


FUNCTION return_check (
        p_str IN VARCHAR2
    ) RETURN boolean as
 str   VARCHAR2(400) := p_str;
    l     NUMBER ;

BEGIN

/*Remove extra spaces*/
    str:=regexp_replace(str,'[  ]+',' ');
     l     := length(str);

/*Checking for the ratio of numbers and characters*/
    if(not regexp_count(str, '\w*[.,]?\w+[$]?')-1= regexp_count(str, '[\*\+-\\]')  -regexp_count(str, '\w*[.,]\w+[$]?'))then return false;
   end if;

/*Checks for the required number of spaces*/
     if(not regexp_count(str, '\w*[.,]?\w+[$]?')+ regexp_count(str, '[\*\+-\\]')  -regexp_count(str, '\w*[.,]\w+[$]?')-1<= regexp_count(str,  '[ ]+') )then return false;
    end if;
/*Check for the first component*/
    if(not regexp_instr(str, '\w*[.,]?\w+[$]?') < regexp_instr(str, '[()\*\+-\\]'))then return false;
    end if;

/*Check for the last component*/
    if(not regexp_instr(str, '\w*[.,]?\w+[$]?',l-2) < regexp_instr(str, '[()\*\+-\\]',l-2))then return false;
    end if;
return true;
END;
    end dop3_pkg;

-- Forward declaration 
CREATE TYPE dept_t;
/

-- Create emp_t 
CREATE TYPE emp_t AS OBJECT (
    empno      CHAR(6),
    firstname  VARCHAR2(12),
    lastname   VARCHAR2(15),
    workdept   REF dept_t,
    sex        CHAR(1),
    birthdate  DATE,
    salary     NUMBER(8,2)
);
/

-- Now complete dept_t 
CREATE TYPE dept_t AS OBJECT (
    deptno     CHAR(3),
    deptname   VARCHAR2(36),
    mgrno      REF emp_t,
    admrdept   REF dept_t
);
/


-- Create tables without SCOPE first
CREATE TABLE OREMP OF emp_t (
  empno PRIMARY KEY
) OBJECT IDENTIFIER IS PRIMARY KEY;
/

CREATE TABLE ORDEPT OF dept_t (
  deptno PRIMARY KEY
) OBJECT IDENTIFIER IS PRIMARY KEY;
/

-- Add SCOPE constraints after both tables exist
ALTER TABLE OREMP ADD SCOPE FOR (workdept) IS ORDEPT;
/
ALTER TABLE ORDEPT ADD SCOPE FOR (mgrno) IS OREMP;
/
ALTER TABLE ORDEPT ADD SCOPE FOR (admrdept) IS ORDEPT;
/


INSERT INTO OREMP VALUES (emp_t('000010','CHRISTINE','HAAS',NULL,'F',TO_DATE('14/AUG/53','DD/MON/RR'),72750));
INSERT INTO OREMP VALUES (emp_t('000020','MICHAEL','THOMPSON',NULL,'M',TO_DATE('02/FEB/68','DD/MON/RR'),61250));
INSERT INTO OREMP VALUES (emp_t('000030','SALLY','KWAN',NULL,'F',TO_DATE('11/MAY/71','DD/MON/RR'),58250));
INSERT INTO OREMP VALUES (emp_t('000060','IRVING','STERN',NULL,'M',TO_DATE('07/JUL/65','DD/MON/RR'),55555));
INSERT INTO OREMP VALUES (emp_t('000070','EVA','PULASKI',NULL,'F',TO_DATE('26/MAY/73','DD/MON/RR'),56170));
INSERT INTO OREMP VALUES (emp_t('000050','JOHN','GEYER',NULL,'M',TO_DATE('15/SEP/55','DD/MON/RR'),60175));
INSERT INTO OREMP VALUES (emp_t('000090','EILEEN','HENDERSON',NULL,'F',TO_DATE('15/MAY/61','DD/MON/RR'),49750));
INSERT INTO OREMP VALUES (emp_t('000100','THEODORE','SPENSER',NULL,'M',TO_DATE('18/DEC/76','DD/MON/RR'),46150));


INSERT INTO ORDEPT VALUES (dept_t('A00','SPIFFY COMPUTER SERVICE DIV.',NULL,NULL));
INSERT INTO ORDEPT VALUES (dept_t('B01','PLANNING',NULL,NULL));
INSERT INTO ORDEPT VALUES (dept_t('C01','INFORMATION CENTRE',NULL,NULL));
INSERT INTO ORDEPT VALUES (dept_t('D01','DEVELOPMENT CENTRE',NULL,NULL));


--Update workdept in OREMP 

UPDATE OREMP e
SET e.workdept = (SELECT REF(d) FROM ORDEPT d WHERE d.deptno='A00')
WHERE e.empno='000010';

UPDATE OREMP e
SET e.workdept = (SELECT REF(d) FROM ORDEPT d WHERE d.deptno='B01')
WHERE e.empno IN ('000020','000090','000100');

UPDATE OREMP e
SET e.workdept = (SELECT REF(d) FROM ORDEPT d WHERE d.deptno='C01')
WHERE e.empno IN ('000030','000050');

UPDATE OREMP e
SET e.workdept = (SELECT REF(d) FROM ORDEPT d WHERE d.deptno='D01')
WHERE e.empno IN ('000060','000070');



UPDATE ORDEPT d
SET d.mgrno = (SELECT REF(e) FROM OREMP e WHERE e.empno='000010')
WHERE d.deptno='A00';

UPDATE ORDEPT d
SET d.mgrno = (SELECT REF(e) FROM OREMP e WHERE e.empno='000020')
WHERE d.deptno='B01';

UPDATE ORDEPT d
SET d.mgrno = (SELECT REF(e) FROM OREMP e WHERE e.empno='000030')
WHERE d.deptno='C01';

UPDATE ORDEPT d
SET d.mgrno = (SELECT REF(e) FROM OREMP e WHERE e.empno='000060')
WHERE d.deptno='D01';



-- Update ORDEPT with admrdept REF values
UPDATE ORDEPT d
SET d.admrdept = (SELECT REF(ad) FROM ORDEPT ad WHERE ad.deptno='A00')
WHERE d.deptno IN ('A00','B01','C01');

UPDATE ORDEPT d
SET d.admrdept = (SELECT REF(ad) FROM ORDEPT ad WHERE ad.deptno='C01')
WHERE d.deptno='D01';


--2 (a)
SELECT d.deptname, DEREF(d.mgrno).lastname AS manager_lastname
FROM ORDEPT d;
/

--2 (b)
SELECT e.empno, e.lastname, DEREF(e.workdept).deptname AS dept_name
FROM OREMP e;
/

--2 (c)
SELECT d.deptno, d.deptname, DEREF(d.admrdept).deptname AS admin_dept_name
FROM ORDEPT d;
/

--2 (d)    
SELECT d.deptno, d.deptname,
       DEREF(d.admrdept).deptname AS admin_dept_name,
       DEREF(DEREF(d.admrdept).mgrno).lastname AS admin_mgr_lastname
FROM ORDEPT d;
/

--2 (e) 
SELECT e.empno, e.firstname, e.lastname, e.salary,
       DEREF(DEREF(e.workdept).mgrno).lastname AS mgr_lastname,
       DEREF(DEREF(e.workdept).mgrno).salary AS mgr_salary
FROM OREMP e;
/
--2 (f)
SELECT DEREF(e.workdept).deptno AS deptno,
       DEREF(e.workdept).deptname AS deptname,
       e.sex,
       AVG(e.salary) AS avg_salary
FROM OREMP e
GROUP BY DEREF(e.workdept).deptno, DEREF(e.workdept).deptname, e.sex
ORDER BY deptno, sex;
/




--4 
DROP TABLE OREMP CASCADE CONSTRAINTS
/

DROP TABLE ORDEPT CASCADE CONSTRAINTS
/


DROP TYPE emp_t FORCE
/

DROP TYPE dept_t FORCE
/
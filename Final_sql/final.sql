-- ============================================================
-- Final Project — [Nassyr_Ainaz] — [University Domain]
-- Database: [university] / Schema: [university]
-- ============================================================

CREATE SCHEMA IF NOT EXISTS university;
SET search_path TO university;

DROP TABLE IF EXISTS drop_out, grade, assigned_classes, course, attendance, clubs, staff, students CASCADE;
DROP TYPE IF EXISTS expell_status CASCADE;

CREATE TABLE IF NOT EXISTS students (
    student_id   SERIAL PRIMARY KEY,
    full_name    VARCHAR(150) NOT NULL,
    gender       VARCHAR(10)  NOT NULL CHECK (gender IN ('M','F','Other')),
    address      VARCHAR(150) NOT NULL,	
    birth_date   DATE,
    phone_number CHAR(8)
);

CREATE TABLE IF NOT EXISTS staff (
    staff_id     SERIAL PRIMARY KEY,
    full_name    VARCHAR(150) NOT NULL,
    gender       VARCHAR(10)  NOT NULL CHECK (gender IN ('M','F','Other')),
    address      VARCHAR(150) NOT NULL,	
    email        VARCHAR(50)  NOT NULL UNIQUE,
    phone_number CHAR(8),
    birth_date   DATE,
    job          VARCHAR(50)  NOT NULL 
);

CREATE TABLE IF NOT EXISTS clubs (
    club_id      SERIAL PRIMARY KEY,
    name         VARCHAR(50)  NOT NULL
);

CREATE TABLE IF NOT EXISTS student_clubs (
    student_id INT NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    club_id    INT NOT NULL REFERENCES clubs(club_id) ON DELETE CASCADE,
    join_date  DATE DEFAULT CURRENT_DATE,
    PRIMARY KEY (student_id, club_id)  
);


CREATE TYPE expell_status AS ENUM ('stay', 'expell');

CREATE TABLE IF NOT EXISTS attendance (
    attendance_id SERIAL PRIMARY KEY,
    log_time      TIMESTAMP NOT NULL,
    status        VARCHAR(10) DEFAULT 'present' CHECK (status IN ('present', 'missing')),
    student_id    INT NOT NULL REFERENCES students(student_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS course (
    course_id    SERIAL PRIMARY KEY,
    name         VARCHAR(50) NOT NULL,
    student_id   INT NOT NULL REFERENCES students(student_id) ON DELETE RESTRICT,
    staff_id     INT NOT NULL REFERENCES staff(staff_id) ON DELETE RESTRICT,
    "group"      VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS assigned_classes (
    class_id     SERIAL PRIMARY KEY,
    student_id   INT NOT NULL REFERENCES students(student_id) ON DELETE RESTRICT,
    staff_id     INT NOT NULL REFERENCES staff(staff_id) ON DELETE RESTRICT,
    class_name   CHAR(3) NOT NULL,
    course_id    INT NOT NULL REFERENCES course(course_id) ON DELETE RESTRICT,
    class_date   DATE
);

CREATE TABLE IF NOT EXISTS grade (
    grade_id     SERIAL PRIMARY KEY,
    grade        VARCHAR(2),
    student_id   INT NOT NULL REFERENCES students(student_id) ON DELETE RESTRICT,
    staff_id     INT NOT NULL REFERENCES staff(staff_id) ON DELETE RESTRICT,
    "group"      VARCHAR(50) NOT NULL,
    course_id    INT NOT NULL REFERENCES course(course_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS drop_out (
    drop_out_id  SERIAL PRIMARY KEY,
    student_id   INT NOT NULL REFERENCES students(student_id) ON DELETE RESTRICT,
    "group"      VARCHAR(50),
    status       expell_status DEFAULT 'stay'
);

ALTER TABLE students ALTER COLUMN phone_number TYPE VARCHAR(20);
ALTER TABLE students ALTER COLUMN gender SET DEFAULT 'Other';

ALTER TABLE staff ALTER COLUMN phone_number TYPE VARCHAR(20);
ALTER TABLE staff ALTER COLUMN gender SET DEFAULT 'Other';

SELECT table_name 
FROM information_schema.tables
WHERE table_schema = 'university'
ORDER BY table_name;

TRUNCATE TABLE students, staff, clubs, attendance, course, assigned_classes, grade, drop_out
RESTART IDENTITY CASCADE;

INSERT INTO students (full_name, gender, address, birth_date, phone_number) VALUES
    ('Amina Asan', 'F', 'Nursaya 65', DATE '2008-06-05', '7788035847'),
    ('Azat Hamitov', 'M', 'Avangard 45', DATE '2007-09-16', '7788035847'),
    ('Ainaz Nassyr', 'F', 'Nutsaya 75', DATE '2008-02-29', '7084800443');

INSERT INTO staff (full_name, gender, address, email, phone_number, birth_date, job) VALUES
    ('Dias', 'M', 'Avangard 22', 'dias@gmail.com', '7785584751', DATE '1996-11-25', 'teacher'),
    ('Anurbek', 'M', 'Avangard 89', 'anuarbek@gmail.com', '7785584548', DATE '2003-02-15', 'teacher'),
    ('Azamat', 'M', 'Avangard 105', 'azamat@gmail.com', '7725584751', DATE '1996-02-05', 'teacher');

INSERT INTO clubs (name) VALUES
    ('Music'), ('Arts'), ('Football'), ('Science'), ('Dance');


INSERT INTO student_clubs (student_id, club_id) VALUES
    (3, 1),
    (3, 3), 
    (1, 3), 
    (2, 5);


INSERT INTO attendance (log_time, status, student_id) VALUES
     ('2026-05-25 13:30:00', 'present', 1),
     ('2026-05-25 08:30:00', 'present', 3),
     ('2026-05-25 10:00:00', 'missing', 2);

INSERT INTO course (name, student_id, staff_id, "group") VALUES
     ('Engineering complex machines', 1, 2, 'MECH-02-23'),
     ('Identify substance', 3, 2, 'CHEM-01-22'),
     ('Fixing sequence', 3, 1, 'MECH-03-22');

INSERT INTO assigned_classes (student_id, staff_id, class_name, course_id, class_date) VALUES
     (1, 1, '101', 2, DATE '2026-05-25'),
     (2, 3, '303', 1, DATE '2026-05-28'),
     (3, 2, '215', 3, DATE '2026-05-23');

INSERT INTO grade (grade, student_id, staff_id, "group", course_id) VALUES
     ('75', 1, 2, 'Software-03-23', 3),
     ('63', 3, 2, 'Software-03-23', 1),
     ('80', 2, 1, 'Software-03-23', 2);

INSERT INTO drop_out (student_id, "group", status) VALUES
     (1, 'Software-03-23', 'stay'),
     (2, 'Software-03-23', 'stay'),
     (3, 'Software-03-23', 'expell');


SELECT 'students' AS t, COUNT(*) FROM students
UNION ALL SELECT 'staff',    COUNT(*) FROM staff
UNION ALL SELECT 'clubs',      COUNT(*) FROM clubs
UNION ALL SELECT 'attendance', COUNT(*) from attendance
UNION ALL SELECT 'course',      COUNT(*) FROM course
UNION ALL SELECT 'assigned_classes',      COUNT(*) FROM assigned_classes
UNION ALL SELECT 'grade',      COUNT(*) FROM grade
UNION ALL SELECT 'drop_out',      COUNT(*) FROM drop_out
;

BEGIN;
    DELETE FROM drop_out
    WHERE status = 'expell'
    RETURNING student_id, "group", status;
ROLLBACK;

REASSIGN OWNED BY uni_readonly, uni_writer TO CURRENT_USER;
DROP OWNED BY uni_readonly, uni_writer;
DROP ROLE IF EXISTS uni_readonly, uni_writer;


CREATE ROLE uni_readonly;
CREATE ROLE uni_writer;


GRANT USAGE ON SCHEMA university TO uni_readonly, uni_writer;


GRANT SELECT ON ALL TABLES IN SCHEMA university TO uni_readonly;


GRANT INSERT, UPDATE ON university.staff TO uni_writer;

REVOKE UPDATE ON university.staff FROM uni_writer;
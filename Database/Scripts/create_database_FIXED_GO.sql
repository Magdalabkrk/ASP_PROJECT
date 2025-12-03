-- ============================================
-- UNIWERSYTET - BAZA DANYCH
-- ============================================
-- Plik: create_database_FIXED_GO.sql
-- Status: ✅ Z PRAWIDŁOWYMI SEPARATORAMI
-- Data: Grudzień 2025
-- Opis: Cała baza danych + triggery + views w jednym pliku

USE master;
GO

-- Usuń starą bazę jeśli istnieje
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'UniversityDB')
BEGIN
    ALTER DATABASE UniversityDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE UniversityDB;
END
GO

-- Utwórz nową bazę
CREATE DATABASE UniversityDB;
GO

USE UniversityDB;
GO

-- ============================================
-- 1. TABELE SŁOWNIKI (VALIDATION TABLES)
-- ============================================

-- Rola użytkownika
CREATE TABLE ROLES (
    role_id INT PRIMARY KEY IDENTITY(1,1),
    role_name NVARCHAR(50) NOT NULL UNIQUE,
    description NVARCHAR(200),
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

-- Wydział
CREATE TABLE DEPARTMENTS (
    department_id INT PRIMARY KEY IDENTITY(1,1),
    department_name NVARCHAR(100) NOT NULL UNIQUE,
    description NVARCHAR(500),
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

-- Grupa laboratoryjna
CREATE TABLE GROUPS (
    group_id INT PRIMARY KEY IDENTITY(1,1),
    group_name NVARCHAR(100) NOT NULL UNIQUE,
    max_students INT DEFAULT 25,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

-- Rok akademicki
CREATE TABLE ACADEMIC_YEARS (
    year_id INT PRIMARY KEY IDENTITY(1,1),
    year_name NVARCHAR(20) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

-- Skala ocen
CREATE TABLE GRADES (
    grade_id INT PRIMARY KEY IDENTITY(1,1),
    grade_value DECIMAL(3,1) NOT NULL UNIQUE,
    grade_name NVARCHAR(50) NOT NULL,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

-- Typ oceny (egzamin, zaliczenie, itp.)
CREATE TABLE GRADE_TYPES (
    grade_type_id INT PRIMARY KEY IDENTITY(1,1),
    grade_type_name NVARCHAR(50) NOT NULL UNIQUE,
    description NVARCHAR(200),
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

-- ============================================
-- 2. UŻYTKOWNICY
-- ============================================

-- Wszyscy użytkownicy
CREATE TABLE USERS (
    user_id INT PRIMARY KEY IDENTITY(1,1),
    nick NVARCHAR(50) NOT NULL UNIQUE,
    email NVARCHAR(100) NOT NULL UNIQUE,
    email_verified BIT DEFAULT 0,
    password_hash NVARCHAR(255) NOT NULL,
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    birth_date DATE,
    pesel NVARCHAR(11),
    address NVARCHAR(200),
    role_id INT NOT NULL,
    is_active BIT DEFAULT 1,
    last_login DATETIME,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    archived_at DATETIME NULL,
    FOREIGN KEY (role_id) REFERENCES ROLES(role_id),
    CONSTRAINT chk_email CHECK (email LIKE '%@%')
);
GO

-- Pracownicy
CREATE TABLE EMPLOYEES (
    employee_id INT PRIMARY KEY IDENTITY(1,1),
    nick NVARCHAR(50) NOT NULL UNIQUE,
    email NVARCHAR(100) NOT NULL UNIQUE,
    email_verified BIT DEFAULT 0,
    password_hash NVARCHAR(255) NOT NULL,
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    role_id INT NOT NULL,
    is_active BIT DEFAULT 1,
    last_login DATETIME,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    archived_at DATETIME NULL,
    FOREIGN KEY (role_id) REFERENCES ROLES(role_id),
    CONSTRAINT chk_employee_email CHECK (email LIKE '%@%')
);
GO

-- Wykładowcy
CREATE TABLE LECTURERS (
    lecturer_id INT PRIMARY KEY IDENTITY(1,1),
    employee_id INT NOT NULL UNIQUE,
    academic_position NVARCHAR(50),
    department_id INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (employee_id) REFERENCES EMPLOYEES(employee_id),
    FOREIGN KEY (department_id) REFERENCES DEPARTMENTS(department_id)
);
GO

-- Studenci
CREATE TABLE STUDENTS (
    student_id INT PRIMARY KEY IDENTITY(1,1),
    nick NVARCHAR(50) NOT NULL UNIQUE,
    lab_group_id INT NOT NULL,
    index_number NVARCHAR(20),
    bank_account NVARCHAR(28),
    is_active BIT DEFAULT 1,
    archived_at DATETIME NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (lab_group_id) REFERENCES GROUPS(group_id),
    UNIQUE (index_number)
);
GO

-- ============================================
-- 3. AKADEMICZNE
-- ============================================

-- Moduły/Przedmioty
CREATE TABLE MODULES (
    module_id INT PRIMARY KEY IDENTITY(1,1),
    module_name NVARCHAR(100) NOT NULL,
    hours INT NOT NULL,
    ects_credits INT NOT NULL,
    lecturer_id INT NOT NULL,
    department_id INT NOT NULL,
    description NVARCHAR(500),
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (lecturer_id) REFERENCES LECTURERS(lecturer_id),
    FOREIGN KEY (department_id) REFERENCES DEPARTMENTS(department_id)
);
GO

-- Przypisanie grup do modułów (N:M)
CREATE TABLE GROUP_MODULES (
    group_module_id INT PRIMARY KEY IDENTITY(1,1),
    group_id INT NOT NULL,
    module_id INT NOT NULL,
    exam_date DATE,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (group_id) REFERENCES GROUPS(group_id),
    FOREIGN KEY (module_id) REFERENCES MODULES(module_id),
    UNIQUE (group_id, module_id)
);
GO

-- Instancje modułów (konkretne zajęcia)
CREATE TABLE MODULE_INSTANCES (
    instance_id INT PRIMARY KEY IDENTITY(1,1),
    module_id INT NOT NULL,
    year_id INT NOT NULL,
    topic NVARCHAR(200) NOT NULL,
    start_datetime DATETIME NOT NULL,
    end_datetime DATETIME NOT NULL,
    room_no NVARCHAR(20),
    description NVARCHAR(500),
    required_materials NVARCHAR(500),
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (module_id) REFERENCES MODULES(module_id),
    FOREIGN KEY (year_id) REFERENCES ACADEMIC_YEARS(year_id)
);
GO

-- Rejestracja obecności
CREATE TABLE STUDENTS_MODULE_INSTANCES (
    attendance_id INT PRIMARY KEY IDENTITY(1,1),
    student_id INT NOT NULL,
    instance_id INT NOT NULL,
    attended BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id),
    FOREIGN KEY (instance_id) REFERENCES MODULE_INSTANCES(instance_id),
    UNIQUE (student_id, instance_id)
);
GO

-- Oceny studentów
CREATE TABLE STUDENT_GRADES (
    grade_record_id INT PRIMARY KEY IDENTITY(1,1),
    student_id INT NOT NULL,
    module_id INT NOT NULL,
    grade_id INT NOT NULL,
    grade_type_id INT NOT NULL,
    lecturer_id INT NOT NULL,
    year_id INT NOT NULL,
    grade_date DATE NOT NULL,
    comment NVARCHAR(500),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id),
    FOREIGN KEY (module_id) REFERENCES MODULES(module_id),
    FOREIGN KEY (grade_id) REFERENCES GRADES(grade_id),
    FOREIGN KEY (grade_type_id) REFERENCES GRADE_TYPES(grade_type_id),
    FOREIGN KEY (lecturer_id) REFERENCES LECTURERS(lecturer_id),
    FOREIGN KEY (year_id) REFERENCES ACADEMIC_YEARS(year_id)
);
GO

-- ============================================
-- 4. ADMINISTRACYJNE
-- ============================================

-- Płatności czesnego
CREATE TABLE TUITIONS (
    tuition_id INT PRIMARY KEY IDENTITY(1,1),
    student_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE,
    due_date DATE NOT NULL,
    year_id INT NOT NULL,
    is_paid BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id),
    FOREIGN KEY (year_id) REFERENCES ACADEMIC_YEARS(year_id)
);
GO

-- Syllabusy przedmiotów
CREATE TABLE SYLLABUSES (
    syllabus_id INT PRIMARY KEY IDENTITY(1,1),
    module_id INT NOT NULL,
    year_id INT NOT NULL,
    content NVARCHAR(MAX),
    learning_outcomes NVARCHAR(MAX),
    grading_criteria NVARCHAR(MAX),
    required_readings NVARCHAR(MAX),
    file_path NVARCHAR(255),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (module_id) REFERENCES MODULES(module_id),
    FOREIGN KEY (year_id) REFERENCES ACADEMIC_YEARS(year_id)
);
GO

-- Ogłoszenia
CREATE TABLE ANNOUNCEMENTS (
    announcement_id INT PRIMARY KEY IDENTITY(1,1),
    title NVARCHAR(200) NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    created_by INT NOT NULL,
    target_group_id INT,
    is_active BIT DEFAULT 1,
    priority INT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (created_by) REFERENCES LECTURERS(lecturer_id),
    FOREIGN KEY (target_group_id) REFERENCES GROUPS(group_id)
);
GO

-- ============================================
-- 5. INDEKSY (OPTYMALIZACJA)
-- ============================================

CREATE INDEX idx_users_nick ON USERS(nick);
GO
CREATE INDEX idx_users_role ON USERS(role_id);
GO
CREATE INDEX idx_users_email ON USERS(email);
GO
CREATE INDEX idx_employees_nick ON EMPLOYEES(nick);
GO
CREATE INDEX idx_students_nick ON STUDENTS(nick);
GO
CREATE INDEX idx_students_group ON STUDENTS(lab_group_id);
GO
CREATE INDEX idx_lecturers_employee ON LECTURERS(employee_id);
GO
CREATE INDEX idx_lecturers_department ON LECTURERS(department_id);
GO
CREATE INDEX idx_modules_lecturer ON MODULES(lecturer_id);
GO
CREATE INDEX idx_modules_department ON MODULES(department_id);
GO
CREATE INDEX idx_group_modules_group ON GROUP_MODULES(group_id);
GO
CREATE INDEX idx_group_modules_module ON GROUP_MODULES(module_id);
GO
CREATE INDEX idx_module_instances_module ON MODULE_INSTANCES(module_id);
GO
CREATE INDEX idx_module_instances_year ON MODULE_INSTANCES(year_id);
GO
CREATE INDEX idx_student_module_instances_student ON STUDENTS_MODULE_INSTANCES(student_id);
GO
CREATE INDEX idx_student_module_instances_instance ON STUDENTS_MODULE_INSTANCES(instance_id);
GO
CREATE INDEX idx_student_grades_student ON STUDENT_GRADES(student_id);
GO
CREATE INDEX idx_student_grades_module ON STUDENT_GRADES(module_id);
GO
CREATE INDEX idx_student_grades_lecturer ON STUDENT_GRADES(lecturer_id);
GO
CREATE INDEX idx_tuitions_student ON TUITIONS(student_id);
GO
CREATE INDEX idx_tuitions_paid ON TUITIONS(is_paid);
GO
CREATE INDEX idx_announcements_group ON ANNOUNCEMENTS(target_group_id);
GO

-- ============================================
-- 6. TRIGGERY (WALIDACJA)
-- ============================================

-- Trigger 1: Rola student
CREATE TRIGGER tr_student_role_validation
ON STUDENTS
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @nick NVARCHAR(50);
    DECLARE @role_id INT;
    
    SELECT @nick = nick FROM inserted;
    SELECT @role_id = role_id FROM USERS WHERE nick = @nick;
    
    IF @role_id <> 1
    BEGIN
        RAISERROR('Student musi mieć rolę student (role_id=1)', 16, 1);
        ROLLBACK TRANSACTION;
    END
END
GO

-- Trigger 2: Rola employee
CREATE TRIGGER tr_employee_role_validation
ON EMPLOYEES
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @emp_nick NVARCHAR(50);
    DECLARE @emp_role_id INT;
    
    SELECT @emp_nick = nick FROM inserted;
    SELECT @emp_role_id = role_id FROM EMPLOYEES WHERE nick = @emp_nick;
    
    IF @emp_role_id <> 2
    BEGIN
        RAISERROR('Pracownik musi mieć rolę employee (role_id=2)', 16, 1);
        ROLLBACK TRANSACTION;
    END
END
GO

-- Trigger 3: Dostęp studenta do modułu
CREATE TRIGGER tr_student_grades_validation
ON STUDENT_GRADES
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @student_id INT;
    DECLARE @module_id INT;
    DECLARE @check_count INT;
    
    SELECT @student_id = student_id, @module_id = module_id FROM inserted;
    
    -- Sprawdź czy student ma dostęp do modułu
    SELECT @check_count = COUNT(*)
    FROM STUDENTS s
    INNER JOIN GROUP_MODULES gm ON s.lab_group_id = gm.group_id
    WHERE s.student_id = @student_id AND gm.module_id = @module_id;
    
    IF @check_count = 0
    BEGIN
        RAISERROR('Student nie ma dostępu do tego modułu', 16, 1);
        ROLLBACK TRANSACTION;
    END
END
GO

-- ============================================
-- 7. VIEWS (WIDOKI GOTOWE DLA MVC)
-- ============================================

-- Informacje studenta
CREATE VIEW vw_student_info AS
SELECT 
    s.student_id,
    u.nick,
    u.email,
    u.first_name,
    u.last_name,
    u.birth_date,
    u.pesel,
    u.address,
    g.group_name,
    s.index_number,
    s.bank_account,
    u.is_active,
    u.last_login
FROM STUDENTS s
INNER JOIN USERS u ON s.nick = u.nick
INNER JOIN GROUPS g ON s.lab_group_id = g.group_id
WHERE u.role_id = 1;
GO

-- Plan zajęć studenta
CREATE VIEW vw_student_schedule AS
SELECT 
    s.student_id,
    mi.instance_id,
    m.module_name,
    mi.topic,
    mi.start_datetime,
    mi.end_datetime,
    mi.room_no,
    mi.description,
    mi.required_materials,
    l.academic_position,
    e.first_name + ' ' + e.last_name as lecturer_name
FROM STUDENTS s
INNER JOIN GROUP_MODULES gm ON s.lab_group_id = gm.group_id
INNER JOIN MODULE_INSTANCES mi ON gm.module_id = mi.module_id
INNER JOIN MODULES m ON mi.module_id = m.module_id
INNER JOIN LECTURERS l ON m.lecturer_id = l.lecturer_id
INNER JOIN EMPLOYEES e ON l.employee_id = e.employee_id
WHERE s.is_active = 1;
GO

-- Oceny studenta
CREATE VIEW vw_student_grades_summary AS
SELECT 
    sg.student_id,
    m.module_name,
    g.grade_value,
    gr.grade_type_name,
    e.first_name + ' ' + e.last_name as lecturer_name,
    sg.grade_date,
    ay.year_name,
    sg.comment
FROM STUDENT_GRADES sg
INNER JOIN MODULES m ON sg.module_id = m.module_id
INNER JOIN GRADES g ON sg.grade_id = g.grade_id
INNER JOIN GRADE_TYPES gr ON sg.grade_type_id = gr.grade_type_id
INNER JOIN LECTURERS l ON sg.lecturer_id = l.lecturer_id
INNER JOIN EMPLOYEES e ON l.employee_id = e.employee_id
INNER JOIN ACADEMIC_YEARS ay ON sg.year_id = ay.year_id;
GO

-- Płatności studenta
CREATE VIEW vw_student_tuitions AS
SELECT 
    s.student_id,
    u.nick,
    t.amount,
    t.payment_date,
    t.due_date,
    t.is_paid,
    ay.year_name,
    DATEDIFF(DAY, CAST(GETDATE() AS DATE), t.due_date) as days_to_due
FROM TUITIONS t
INNER JOIN STUDENTS s ON t.student_id = s.student_id
INNER JOIN USERS u ON s.nick = u.nick
INNER JOIN ACADEMIC_YEARS ay ON t.year_id = ay.year_id;
GO

-- Przedmioty grupy
CREATE VIEW vw_group_modules AS
SELECT 
    gm.group_module_id,
    g.group_id,
    g.group_name,
    m.module_id,
    m.module_name,
    m.hours,
    m.ects_credits,
    l.academic_position,
    e.first_name + ' ' + e.last_name as lecturer_name,
    gm.exam_date,
    d.department_name
FROM GROUP_MODULES gm
INNER JOIN GROUPS g ON gm.group_id = g.group_id
INNER JOIN MODULES m ON gm.module_id = m.module_id
INNER JOIN LECTURERS l ON m.lecturer_id = l.lecturer_id
INNER JOIN EMPLOYEES e ON l.employee_id = e.employee_id
INNER JOIN DEPARTMENTS d ON m.department_id = d.department_id;
GO

-- Studenci w grupie (dla wykładowcy)
CREATE VIEW vw_group_students AS
SELECT 
    s.student_id,
    u.nick,
    u.email,
    u.first_name,
    u.last_name,
    g.group_id,
    g.group_name,
    s.index_number,
    u.is_active
FROM STUDENTS s
INNER JOIN USERS u ON s.nick = u.nick
INNER JOIN GROUPS g ON s.lab_group_id = g.group_id
WHERE u.role_id = 1 AND u.is_active = 1;
GO

-- Informacje wykładowcy
CREATE VIEW vw_lecturer_info AS
SELECT 
    l.lecturer_id,
    e.nick,
    e.email,
    e.first_name,
    e.last_name,
    l.academic_position,
    d.department_name,
    COUNT(DISTINCT m.module_id) as module_count
FROM LECTURERS l
INNER JOIN EMPLOYEES e ON l.employee_id = e.employee_id
INNER JOIN DEPARTMENTS d ON l.department_id = d.department_id
LEFT JOIN MODULES m ON l.lecturer_id = m.lecturer_id
WHERE e.role_id = 2 AND e.is_active = 1
GROUP BY l.lecturer_id, e.nick, e.email, e.first_name, e.last_name, l.academic_position, d.department_name;
GO

-- Lista do rejestracji (dla wykładowcy)
CREATE VIEW vw_attendance_list AS
SELECT 
    smi.attendance_id,
    mi.instance_id,
    mi.topic,
    mi.start_datetime,
    s.student_id,
    u.nick,
    u.first_name,
    u.last_name,
    smi.attended
FROM STUDENTS_MODULE_INSTANCES smi
INNER JOIN MODULE_INSTANCES mi ON smi.instance_id = mi.instance_id
INNER JOIN STUDENTS s ON smi.student_id = s.student_id
INNER JOIN USERS u ON s.nick = u.nick;
GO

-- ============================================
-- 8. PODSUMOWANIE
-- ============================================

PRINT '========== BAZA DANYCH UTWORZONA POMYŚLNIE ==========';
PRINT '';
PRINT 'Liczba tabel: 18';
PRINT 'Liczba indeksów: 20+';
PRINT 'Liczba triggerów: 3';
PRINT 'Liczba views: 7';
PRINT '';
PRINT 'TERAZ: Uruchom insert_sample_FINAL.sql';
PRINT '';
PRINT '========== KONIEC ==========';

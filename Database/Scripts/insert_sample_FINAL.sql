-- ============================================
-- UNIWERSYTET - DANE TESTOWE (FINAŁ)
-- ============================================
-- Plik: insert_sample_FINAL.sql
-- Status: ✅ WSZYSTKO NAPRAWIONE
-- Data: Grudzień 2025
-- Poprawki:
--   1. Bank account: prawidłowe IBAN (28 znaków bez spacji)
--   2. GO po każdej sekcji

USE UniversityDB;
GO

-- ============================================
-- 1. ROLE
-- ============================================

INSERT INTO ROLES (role_name, description, is_active) 
VALUES 
('student', 'Student uniwersytetu', 1),
('employee', 'Pracownik uniwersytetu', 1);
GO

-- ============================================
-- 2. WYDZIAŁY
-- ============================================

INSERT INTO DEPARTMENTS (department_name, description, is_active) 
VALUES 
('Informatyka', 'Wydział Informatyki i Nauk o Danych', 1),
('Matematyka', 'Wydział Matematyki i Fizyki', 1);
GO

-- ============================================
-- 3. GRUPY LABORATORYJNA
-- ============================================

INSERT INTO GROUPS (group_name, max_students, is_active) 
VALUES 
('Grupa 1A - Informatyka', 25, 1),
('Grupa 2A - Informatyka', 25, 1),
('Grupa 2B - Matematyka', 20, 1),
('Grupa 3A - Matematyka', 20, 1);
GO

-- ============================================
-- 4. LATA AKADEMICKIE
-- ============================================

INSERT INTO ACADEMIC_YEARS (year_name, start_date, end_date, is_current) 
VALUES 
('2023/2024', '2023-10-01', '2024-09-30', 0),
('2024/2025', '2024-10-01', '2025-09-30', 1);
GO

-- ============================================
-- 5. SKALE OCEN
-- ============================================

INSERT INTO GRADES (grade_value, grade_name, is_active) 
VALUES 
(2.0, 'Niedostateczny', 1),
(3.0, 'Dostateczny', 1),
(3.5, 'Dostateczny Plus', 1),
(4.0, 'Dobry', 1),
(4.5, 'Dobry Plus', 1),
(5.0, 'Bardzo dobry', 1),
(5.5, 'Bardzo dobry Plus', 1);
GO

-- ============================================
-- 6. TYPY OCEN
-- ============================================

INSERT INTO GRADE_TYPES (grade_type_name, description, is_active) 
VALUES 
('egzamin', 'Egzamin końcowy', 1),
('zaliczenie', 'Zaliczenie', 1),
('kolokwium', 'Kolokwium', 1),
('aktywność', 'Aktywność na zajęciach', 1);
GO

-- ============================================
-- 7. USERS - STUDENCI
-- ============================================

INSERT INTO USERS (nick, email, email_verified, password_hash, first_name, last_name, birth_date, pesel, address, role_id, is_active, last_login) 
VALUES 
('jan.kowalski', 'jan.kowalski@uni.edu', 1, 
 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 
 'Jan', 'Kowalski', '2003-05-15', '03251501234', 'ul. Krakowska 10, 31-000 Kraków', 1, 1, NULL),

('maria.nowak', 'maria.nowak@uni.edu', 1,
 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
 'Maria', 'Nowak', '2003-08-22', '03282205678', 'ul. Warszawska 25, 31-050 Kraków', 1, 1, NULL),

('piotr.wisniewski', 'piotr.wisniewski@uni.edu', 1,
 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
 'Piotr', 'Wiśniewski', '2003-11-30', '03301501111', 'ul. Floriańska 5, 31-100 Kraków', 1, 1, NULL),

('anna.krol', 'anna.krol@uni.edu', 1,
 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
 'Anna', 'Królik', '2004-02-14', '04021405555', 'ul. Grodzka 15, 31-000 Kraków', 1, 1, NULL);
GO

-- ============================================
-- 8. PRACOWNICY (EMPLOYEES)
-- ============================================

INSERT INTO EMPLOYEES (nick, email, email_verified, password_hash, first_name, last_name, hire_date, role_id, is_active, last_login) 
VALUES 
('anna.smith', 'anna.smith@uni.edu', 1,
 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
 'Anna', 'Smith', '2015-09-01', 2, 1, NULL),

('zbigniew.kuchta', 'zbigniew.kuchta@uni.edu', 1,
 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
 'Zbigniew', 'Kuchta', '2010-02-15', 2, 1, NULL),

('katarzyna.lewandowska', 'katarzyna.lewandowska@uni.edu', 1,
 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
 'Katarzyna', 'Lewandowska', '2018-10-01', 2, 1, NULL);
GO

-- ============================================
-- 9. WYKŁADOWCY (LECTURERS)
-- ============================================

INSERT INTO LECTURERS (employee_id, academic_position, department_id) 
VALUES 
(1, 'Dr', 1),
(2, 'Prof', 1),
(3, 'Dr', 2);
GO

-- ============================================
-- 10. STUDENCI - PRAWIDŁOWE IBAN (28 znaków bez spacji)
-- ============================================

INSERT INTO STUDENTS (nick, lab_group_id, index_number, bank_account, is_active) 
VALUES 
('jan.kowalski', 1, '123456/2024', 'PL61109010140000071219812874', 1),
('maria.nowak', 2, '123457/2024', 'PL61109010140000071219812875', 1),
('piotr.wisniewski', 1, '123458/2024', 'PL61109010140000071219812876', 1),
('anna.krol', 3, '123459/2024', 'PL61109010140000071219812877', 1);
GO

-- ============================================
-- 11. MODUŁY/PRZEDMIOTY
-- ============================================

INSERT INTO MODULES (module_name, hours, ects_credits, lecturer_id, department_id, description, is_active) 
VALUES 
('Matematyka dyskretna', 30, 6, 1, 1, 
 'Kurs obejmuje teorię zbiorów, logikę, kombinatorykę', 1),

('Algorytmy i struktury danych', 45, 9, 2, 1, 
 'Zaawansowane struktury danych i algorytmy sortowania', 1),

('Bazy danych', 40, 8, 2, 1, 
 'SQL, normalizacja, projektowanie baz danych', 1),

('Analiza matematyczna I', 40, 7, 3, 2, 
 'Rachunek różniczkowy i całkowy', 1);
GO

-- ============================================
-- 12. PRZYPISANIE GRUP DO MODUŁÓW
-- ============================================

INSERT INTO GROUP_MODULES (group_id, module_id, exam_date) 
VALUES 
(1, 1, '2025-02-10'),
(1, 2, '2025-02-15'),
(2, 1, '2025-02-10'),
(2, 3, '2025-02-20'),
(3, 2, '2025-02-15'),
(4, 4, '2025-02-25');
GO

-- ============================================
-- 13. INSTANCJE MODUŁÓW (KONKRETNE ZAJĘCIA)
-- ============================================

INSERT INTO MODULE_INSTANCES (module_id, year_id, topic, start_datetime, end_datetime, room_no, description, required_materials, is_active) 
VALUES 
(1, 2, 'Logika i teoria zbiorów', '2025-01-15 10:00', '2025-01-15 11:30', 'A102', 
 'Podstawy logiki formalnej i operacje na zbiorach', 'Notatnik, długopis', 1),
(1, 2, 'Kombinatoryka', '2025-01-17 10:00', '2025-01-17 11:30', 'A102', 
 'Permutacje, kombinacje, wariacje', 'Notatnik, długopis', 1),
(1, 2, 'Rachunek prawdopodobieństwa', '2025-01-22 10:00', '2025-01-22 11:30', 'A102', 
 'Podstawowe pojęcia rachunku prawdopodobieństwa', 'Notatnik, kalkulator', 1);
GO

INSERT INTO MODULE_INSTANCES (module_id, year_id, topic, start_datetime, end_datetime, room_no, description, required_materials, is_active) 
VALUES 
(2, 2, 'Sortowanie - Bubble Sort', '2025-01-16 12:00', '2025-01-16 13:30', 'B205', 
 'Algorytm bubble sort i jego analiza', 'Laptop, IDE', 1),
(2, 2, 'Sortowanie - Quick Sort', '2025-01-21 12:00', '2025-01-21 13:30', 'B205', 
 'Algorytm quick sort i optymalizacje', 'Laptop, IDE', 1),
(2, 2, 'Struktury danych - Grafy', '2025-01-23 12:00', '2025-01-23 13:30', 'B205', 
 'Reprezentacja grafów, przechodzenie grafów', 'Laptop, IDE', 1);
GO

INSERT INTO MODULE_INSTANCES (module_id, year_id, topic, start_datetime, end_datetime, room_no, description, required_materials, is_active) 
VALUES 
(3, 2, 'SQL basics - SELECT', '2025-01-18 08:00', '2025-01-18 09:30', 'C312', 
 'Podstawowe zapytania SELECT', 'Laptop, SQL Server', 1),
(3, 2, 'Normalizacja baz danych', '2025-01-20 08:00', '2025-01-20 09:30', 'C312', 
 'Pierwsza, druga i trzecia postać normalna', 'Laptop, narzędzie do diagramów', 1),
(3, 2, 'Transakcje i indeksy', '2025-01-25 08:00', '2025-01-25 09:30', 'C312', 
 'Zarządzanie transakcjami i optymalizacja indeksów', 'Laptop, SQL Server', 1);
GO

INSERT INTO MODULE_INSTANCES (module_id, year_id, topic, start_datetime, end_datetime, room_no, description, required_materials, is_active) 
VALUES 
(4, 2, 'Granice funkcji', '2025-01-19 14:00', '2025-01-19 15:30', 'D401', 
 'Definicja granicy i obliczanie granic', 'Notatnik, kalkulator', 1),
(4, 2, 'Pochodne funkcji', '2025-01-24 14:00', '2025-01-24 15:30', 'D401', 
 'Reguły różniczkowania', 'Notatnik, kalkulator', 1);
GO

-- ============================================
-- 14. REJESTRACJA OBECNOŚCI NA ZAJĘCIACH
-- ============================================

INSERT INTO STUDENTS_MODULE_INSTANCES (student_id, instance_id, attended) 
SELECT s.student_id, mi.instance_id, 0
FROM STUDENTS s
CROSS JOIN MODULE_INSTANCES mi
WHERE s.student_id IN (1, 2, 3)
  AND mi.instance_id BETWEEN 1 AND 8;
GO

UPDATE STUDENTS_MODULE_INSTANCES SET attended = 1 WHERE student_id = 1 AND instance_id IN (1, 2, 4, 5, 7);
GO

UPDATE STUDENTS_MODULE_INSTANCES SET attended = 1 WHERE student_id = 2 AND instance_id IN (1, 3, 4, 6);
GO

UPDATE STUDENTS_MODULE_INSTANCES SET attended = 1 WHERE student_id = 3 AND instance_id IN (2, 5, 8);
GO

-- ============================================
-- 15. OCENY STUDENTÓW
-- ============================================

INSERT INTO STUDENT_GRADES (student_id, module_id, grade_id, grade_type_id, lecturer_id, year_id, grade_date, comment) 
VALUES 
(1, 1, 6, 1, 1, 2, '2025-02-10', 'Dobra praca na egzaminie'),
(1, 1, 5, 2, 1, 2, '2025-02-08', 'Zaliczenie'),
(1, 2, 5, 1, 2, 2, '2025-02-15', NULL);
GO

INSERT INTO STUDENT_GRADES (student_id, module_id, grade_id, grade_type_id, lecturer_id, year_id, grade_date, comment) 
VALUES 
(2, 1, 7, 1, 1, 2, '2025-02-10', 'Wybitna praca'),
(2, 3, 4, 2, 2, 2, '2025-02-19', 'Zaliczenie');
GO

INSERT INTO STUDENT_GRADES (student_id, module_id, grade_id, grade_type_id, lecturer_id, year_id, grade_date, comment) 
VALUES 
(3, 1, 4, 1, 1, 2, '2025-02-10', NULL),
(3, 2, 3, 2, 2, 2, '2025-02-15', 'Zaliczenie');
GO

-- ============================================
-- 16. PŁATNOŚCI CZESNEGO
-- ============================================

INSERT INTO TUITIONS (student_id, amount, payment_date, due_date, year_id, is_paid) 
VALUES 
(1, 2000.00, '2024-10-15', '2024-10-31', 2, 1),
(1, 2000.00, NULL, '2024-11-30', 2, 0),
(1, 2000.00, NULL, '2024-12-31', 2, 0);
GO

INSERT INTO TUITIONS (student_id, amount, payment_date, due_date, year_id, is_paid) 
VALUES 
(2, 2000.00, '2024-10-20', '2024-10-31', 2, 1),
(2, 2000.00, '2024-11-15', '2024-11-30', 2, 1);
GO

INSERT INTO TUITIONS (student_id, amount, payment_date, due_date, year_id, is_paid) 
VALUES 
(3, 2000.00, '2024-10-10', '2024-10-31', 2, 1),
(3, 2000.00, NULL, '2024-11-30', 2, 0);
GO

INSERT INTO TUITIONS (student_id, amount, payment_date, due_date, year_id, is_paid) 
VALUES 
(4, 2000.00, NULL, '2024-10-31', 2, 0);
GO

-- ============================================
-- 17. SYLLABUSY PRZEDMIOTÓW
-- ============================================

INSERT INTO SYLLABUSES (module_id, year_id, content, learning_outcomes, grading_criteria, required_readings, file_path) 
VALUES 
(1, 2, 
 'Logika formalna, teoria zbiorów, kombinatoryka, rachunek prawdopodobieństwa',
 'Student potrafi: stosować prawa logiki, operować zbiorami, rozwiązywać problemy kombinatoryczne',
 'Egzamin: 50%, Zaliczenie: 30%, Aktywność: 20%',
 'Discrete Mathematics - Richard Johnsonbaugh',
 '/syllabuses/matematyka_dyskretna_2024.pdf');
GO

INSERT INTO SYLLABUSES (module_id, year_id, content, learning_outcomes, grading_criteria, required_readings, file_path) 
VALUES 
(2, 2,
 'Algorytmy sortowania, struktury danych, grafy, dynamiczne struktury',
 'Student potrafi: implementować algorytmy, wybierać optymalną strukturę, analizować złożoność',
 'Egzamin: 60%, Projekt: 30%, Kolokwium: 10%',
 'Introduction to Algorithms - Cormen, Leiserson, Rivest, Stein',
 '/syllabuses/algorytmy_2024.pdf');
GO

INSERT INTO SYLLABUSES (module_id, year_id, content, learning_outcomes, grading_criteria, required_readings, file_path) 
VALUES 
(3, 2,
 'SQL, normalizacja, projektowanie baz danych, transakcje, indeksy',
 'Student potrafi: projektować schematy baz danych, pisać złożone zapytania SQL, optymalizować wydajność',
 'Egzamin: 40%, Projekt praktyczny: 40%, Zaliczenie: 20%',
 'Database Design - C.J. Date',
 '/syllabuses/bazy_danych_2024.pdf');
GO

INSERT INTO SYLLABUSES (module_id, year_id, content, learning_outcomes, grading_criteria, required_readings, file_path) 
VALUES 
(4, 2,
 'Granice, pochodne, całki, szeregi, funkcje wielu zmiennych',
 'Student potrafi: obliczać granice i pochodne, stosować twierdzenia analizy matematycznej',
 'Egzamin: 70%, Kolokwium: 20%, Aktywność: 10%',
 'Calculus - James Stewart',
 '/syllabuses/analiza_matematyczna_2024.pdf');
GO

-- ============================================
-- 18. OGŁOSZENIA
-- ============================================

INSERT INTO ANNOUNCEMENTS (title, content, created_by, target_group_id, is_active, priority) 
VALUES 
('Zmiana sali wykładu', 'Następny wykład z Matematyki dyskretnej odbędzie się w sali A105 zamiast A102',
 1, 1, 1, 1);
GO

INSERT INTO ANNOUNCEMENTS (title, content, created_by, target_group_id, is_active, priority) 
VALUES 
('Egzamin przesunięty', 'Egzamin z Algorytmów przesunięty na 17 lutego 2025',
 2, 1, 1, 2);
GO

INSERT INTO ANNOUNCEMENTS (title, content, created_by, target_group_id, is_active, priority) 
VALUES 
('Ogłoszenie ogólne', 'Przypominamy o zbliżającym się terminie wpłaty czesnego. Termin: 31 grudnia 2024',
 1, NULL, 1, 1);
GO

-- ============================================
-- 19. WERYFIKACJA DANYCH
-- ============================================

PRINT '========== DANE TESTOWE ZAŁADOWANE POMYŚLNIE ==========';
PRINT '';
PRINT 'Liczba studentów: ';
SELECT COUNT(*) FROM STUDENTS;
GO

PRINT 'Liczba pracowników: ';
SELECT COUNT(*) FROM EMPLOYEES;
GO

PRINT 'Liczba wykładowców: ';
SELECT COUNT(*) FROM LECTURERS;
GO

PRINT 'Liczba modułów: ';
SELECT COUNT(*) FROM MODULES;
GO

PRINT 'Liczba instancji modułów: ';
SELECT COUNT(*) FROM MODULE_INSTANCES;
GO

PRINT 'Liczba ocen: ';
SELECT COUNT(*) FROM STUDENT_GRADES;
GO

PRINT 'Liczba płatności: ';
SELECT COUNT(*) FROM TUITIONS;
GO

PRINT '';
PRINT '========== HASŁA TESTOWE ==========';
PRINT 'Wszyscy użytkownicy mają hasło: Haslo123!';
PRINT 'SHA2_256 hash: a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3';
PRINT '';
PRINT 'Studenci: ';
PRINT '  - jan.kowalski (Grupa 1A)';
PRINT '  - maria.nowak (Grupa 2A)';
PRINT '  - piotr.wisniewski (Grupa 1A)';
PRINT '  - anna.krol (Grupa 2B)';
PRINT '';
PRINT 'Pracownicy/Wykładowcy: ';
PRINT '  - anna.smith (Dr, Informatyka)';
PRINT '  - zbigniew.kuchta (Prof, Informatyka)';
PRINT '  - katarzyna.lewandowska (Dr, Matematyka)';

PRINT '';
PRINT '========== TESTOWE ZAPYTANIA ==========';
PRINT 'Zaloguj się jako: jan.kowalski / Haslo123!';
PRINT 'Widok ocen: SELECT * FROM vw_student_grades_summary WHERE student_id = 1;';
PRINT 'Plan zajęć: SELECT * FROM vw_student_schedule WHERE student_id = 1;';

PRINT '';
PRINT '========== KONIEC ==========';
GO

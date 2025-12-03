-- ============================================
-- UNIWERSYTET - VIEWS (DO DODANIA)
-- ============================================
-- Dodaj te widoki do create_database_FIXED_GO.sql
-- (w sekcji 7. VIEWS - WIDOKI)

-- ============================================
-- VIEW 1: Oceny studenta (szczegółowo)
-- ============================================

CREATE VIEW vw_student_grades_summary AS
SELECT 
    s.student_id,
    s.index_number,
    u.first_name + ' ' + u.last_name AS student_name,
    m.module_name,
    g.grade_name,
    g.grade_value,
    gt.grade_type_name,
    sg.grade_date,
    sg.comment,
    ay.year_name
FROM STUDENT_GRADES sg
INNER JOIN STUDENTS s ON sg.student_id = s.student_id
INNER JOIN USERS u ON s.nick = u.nick
INNER JOIN MODULES m ON sg.module_id = m.module_id
INNER JOIN GRADES g ON sg.grade_id = g.grade_id
INNER JOIN GRADE_TYPES gt ON sg.grade_type_id = gt.grade_type_id
INNER JOIN ACADEMIC_YEARS ay ON sg.year_id = ay.year_id
WHERE sg.student_id IS NOT NULL;
GO

-- ============================================
-- VIEW 2: Plan zajęć studenta
-- ============================================

CREATE VIEW vw_student_schedule AS
SELECT 
    s.student_id,
    s.index_number,
    u.first_name + ' ' + u.last_name AS student_name,
    m.module_name,
    mi.topic AS zajecia_temat,
    mi.start_datetime AS data_start,
    mi.end_datetime AS data_koniec,
    mi.room_no AS sala,
    mi.description AS opis,
    mi.required_materials AS materiały,
    CASE WHEN smi.attended = 1 THEN 'Obecny' ELSE 'Nieobecny' END AS obecność
FROM STUDENTS s
INNER JOIN USERS u ON s.nick = u.nick
INNER JOIN STUDENTS_MODULE_INSTANCES smi ON s.student_id = smi.student_id
INNER JOIN MODULE_INSTANCES mi ON smi.instance_id = mi.instance_id
INNER JOIN MODULES m ON mi.module_id = m.module_id
WHERE s.student_id IS NOT NULL;
GO

-- ============================================
-- VIEW 3: Podsumowanie ocen studenta
-- ============================================

CREATE VIEW vw_student_grades_avg AS
SELECT 
    s.student_id,
    s.index_number,
    u.first_name + ' ' + u.last_name AS student_name,
    m.module_name,
    COUNT(sg.grade_id) AS liczba_ocen,
    AVG(g.grade_value) AS srednia_ocen,
    MAX(g.grade_value) AS najwyzsza_ocena,
    MIN(g.grade_value) AS najnizsza_ocena
FROM STUDENTS s
INNER JOIN USERS u ON s.nick = u.nick
LEFT JOIN STUDENT_GRADES sg ON s.student_id = sg.student_id
LEFT JOIN MODULES m ON sg.module_id = m.module_id
LEFT JOIN GRADES g ON sg.grade_id = g.grade_id
GROUP BY s.student_id, s.index_number, u.first_name, u.last_name, m.module_name;
GO

-- ============================================
-- VIEW 4: Frekwencja studenta
-- ============================================

CREATE VIEW vw_student_attendance AS
SELECT 
    s.student_id,
    s.index_number,
    u.first_name + ' ' + u.last_name AS student_name,
    m.module_name,
    COUNT(smi.instance_id) AS total_zajecia,
    SUM(CASE WHEN smi.attended = 1 THEN 1 ELSE 0 END) AS obecny,
    SUM(CASE WHEN smi.attended = 0 THEN 1 ELSE 0 END) AS nieobecny,
    ROUND(
        CAST(SUM(CASE WHEN smi.attended = 1 THEN 1 ELSE 0 END) AS FLOAT) / 
        COUNT(smi.instance_id) * 100, 
        2
    ) AS procent_frekwencji
FROM STUDENTS s
INNER JOIN USERS u ON s.nick = u.nick
INNER JOIN STUDENTS_MODULE_INSTANCES smi ON s.student_id = smi.student_id
INNER JOIN MODULE_INSTANCES mi ON smi.instance_id = mi.instance_id
INNER JOIN MODULES m ON mi.module_id = m.module_id
GROUP BY s.student_id, s.index_number, u.first_name, u.last_name, m.module_name;
GO

-- ============================================
-- VIEW 5: Status płatności czesnego
-- ============================================

CREATE VIEW vw_student_tuition_status AS
SELECT 
    s.student_id,
    s.index_number,
    u.first_name + ' ' + u.last_name AS student_name,
    t.amount,
    t.due_date,
    t.payment_date,
    CASE 
        WHEN t.is_paid = 1 THEN 'Opłacone'
        WHEN GETDATE() > t.due_date THEN 'Zaległa'
        ELSE 'Czekające'
    END AS status_platnosci,
    ay.year_name
FROM STUDENTS s
INNER JOIN USERS u ON s.nick = u.nick
INNER JOIN TUITIONS t ON s.student_id = t.student_id
INNER JOIN ACADEMIC_YEARS ay ON t.year_id = ay.year_id;
GO

-- ============================================
-- TEST QUERIES
-- ============================================

PRINT '';
PRINT '========== TESTY VIEWS ==========';
PRINT '';
PRINT 'Test 1: Oceny studenta';
SELECT * FROM vw_student_grades_summary WHERE student_id = 1;
GO

PRINT '';
PRINT 'Test 2: Plan zajęć studenta';
SELECT * FROM vw_student_schedule WHERE student_id = 1;
GO

PRINT '';
PRINT 'Test 3: Średnie ocen';
SELECT * FROM vw_student_grades_avg WHERE student_id = 1;
GO

PRINT '';
PRINT 'Test 4: Frekwencja';
SELECT * FROM vw_student_attendance WHERE student_id = 1;
GO

PRINT '';
PRINT 'Test 5: Status czesnego';
SELECT * FROM vw_student_tuition_status WHERE student_id = 1;
GO

PRINT '';
PRINT '========== WSZYSTKIE VIEWS DZIAŁAJĄ! ==========';
GO

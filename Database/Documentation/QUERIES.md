# 🔍 QUERIES.md - Przydatne Zapytania SQL

## 📋 Spis treści

1. [Zapytania SELECT](#zapytania-select)
2. [JOINy dla raportów](#joiny-dla-raportów)
3. [Agregacje i statystyki](#agregacje-i-statystyki)
4. [Zaawansowane zapytania](#zaawansowane-zapytania)
5. [Optymalizacja](#optymalizacja)

---

## 📊 Zapytania SELECT

### 1. Pokaż wszystkich studentów

```sql
SELECT 
    s.student_id,
    s.index_number,
    u.first_name,
    u.last_name,
    u.email,
    g.group_name,
    s.bank_account,
    s.is_active
FROM STUDENTS s
INNER JOIN USERS u ON s.nick = u.nick
INNER JOIN GROUPS g ON s.lab_group_id = g.group_id
WHERE s.is_active = 1
ORDER BY u.last_name, u.first_name;
```

**Wynik:** Lista wszystkich aktywnych studentów z ich grupami

---

### 2. Pokaż wszystkich pracowników

```sql
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email,
    r.role_name,
    e.hire_date,
    e.is_active
FROM EMPLOYEES e
INNER JOIN ROLES r ON e.role_id = r.role_id
WHERE e.is_active = 1
ORDER BY e.last_name;
```

---

### 3. Pokaż wszystkich wykładowców

```sql
SELECT 
    l.lecturer_id,
    e.first_name,
    e.last_name,
    l.academic_position,
    d.department_name,
    COUNT(m.module_id) AS liczba_przedmiotow
FROM LECTURERS l
INNER JOIN EMPLOYEES e ON l.employee_id = e.employee_id
INNER JOIN DEPARTMENTS d ON l.department_id = d.department_id
LEFT JOIN MODULES m ON l.lecturer_id = m.lecturer_id AND m.is_active = 1
WHERE e.is_active = 1
GROUP BY l.lecturer_id, e.first_name, e.last_name, l.academic_position, d.department_name
ORDER BY e.last_name;
```

---

### 4. Pokaż przedmioty z wykładowcami

```sql
SELECT 
    m.module_id,
    m.module_name,
    m.hours,
    m.ects_credits,
    e.first_name + ' ' + e.last_name AS lecturer_name,
    d.department_name,
    m.is_active
FROM MODULES m
INNER JOIN LECTURERS l ON m.lecturer_id = l.lecturer_id
INNER JOIN EMPLOYEES e ON l.employee_id = e.employee_id
INNER JOIN DEPARTMENTS d ON m.department_id = d.department_id
WHERE m.is_active = 1
ORDER BY d.department_name, m.module_name;
```

---

### 5. Pokaż plan zajęć na dzisiaj

```sql
SELECT 
    mi.instance_id,
    m.module_name,
    mi.topic,
    mi.start_datetime,
    mi.end_datetime,
    mi.room_no,
    CONCAT(e.first_name, ' ', e.last_name) AS lecturer_name
FROM MODULE_INSTANCES mi
INNER JOIN MODULES m ON mi.module_id = m.module_id
INNER JOIN LECTURERS l ON m.lecturer_id = l.lecturer_id
INNER JOIN EMPLOYEES e ON l.employee_id = e.employee_id
WHERE CAST(mi.start_datetime AS DATE) = CAST(GETDATE() AS DATE)
AND mi.is_active = 1
ORDER BY mi.start_datetime;
```

---

### 6. Pokaż grupy i liczę studentów

```sql
SELECT 
    g.group_id,
    g.group_name,
    g.max_students,
    COUNT(s.student_id) AS aktualnie_studentow,
    (g.max_students - COUNT(s.student_id)) AS dostepnych_miejsc
FROM GROUPS g
LEFT JOIN STUDENTS s ON g.group_id = s.lab_group_id AND s.is_active = 1
WHERE g.is_active = 1
GROUP BY g.group_id, g.group_name, g.max_students
ORDER BY g.group_name;
```

---

## 🔗 JOINy dla raportów

### 1. Raport: Oceny studenta z łączeniem tabel

```sql
SELECT 
    s.index_number,
    u.first_name + ' ' + u.last_name AS student_name,
    m.module_name,
    g.grade_name,
    g.grade_value,
    gt.grade_type_name,
    sg.grade_date,
    sg.comment,
    e.first_name + ' ' + e.last_name AS lecturer_name
FROM STUDENT_GRADES sg
INNER JOIN STUDENTS s ON sg.student_id = s.student_id
INNER JOIN USERS u ON s.nick = u.nick
INNER JOIN MODULES m ON sg.module_id = m.module_id
INNER JOIN GRADES g ON sg.grade_id = g.grade_id
INNER JOIN GRADE_TYPES gt ON sg.grade_type_id = gt.grade_type_id
INNER JOIN LECTURERS l ON sg.lecturer_id = l.lecturer_id
INNER JOIN EMPLOYEES e ON l.employee_id = e.employee_id
WHERE s.student_id = 1  -- Zmień na ID studenta
ORDER BY sg.grade_date DESC;
```

---

### 2. Raport: Frekwencja studenta

```sql
SELECT 
    u.first_name + ' ' + u.last_name AS student_name,
    m.module_name,
    COUNT(smi.attendance_id) AS total_zajecia,
    SUM(CASE WHEN smi.attended = 1 THEN 1 ELSE 0 END) AS presente,
    SUM(CASE WHEN smi.attended = 0 THEN 1 ELSE 0 END) AS nieobecny,
    ROUND(
        CAST(SUM(CASE WHEN smi.attended = 1 THEN 1 ELSE 0 END) AS FLOAT) / 
        COUNT(smi.attendance_id) * 100, 
        2
    ) AS procent_frekwencji
FROM STUDENTS_MODULE_INSTANCES smi
INNER JOIN STUDENTS s ON smi.student_id = s.student_id
INNER JOIN USERS u ON s.nick = u.nick
INNER JOIN MODULE_INSTANCES mi ON smi.instance_id = mi.instance_id
INNER JOIN MODULES m ON mi.module_id = m.module_id
WHERE s.student_id = 1  -- Zmień na ID studenta
GROUP BY u.first_name, u.last_name, m.module_name
ORDER BY m.module_name;
```

---

### 3. Raport: Status płatności czesnego

```sql
SELECT 
    u.first_name + ' ' + u.last_name AS student_name,
    s.index_number,
    ay.year_name,
    t.amount,
    t.due_date,
    t.payment_date,
    CASE 
        WHEN t.is_paid = 1 THEN 'Opłacone'
        WHEN GETDATE() > t.due_date THEN 'Zaległa'
        ELSE 'Czekające'
    END AS status_platnosci,
    DATEDIFF(DAY, t.due_date, GETDATE()) AS dni_zwloki
FROM TUITIONS t
INNER JOIN STUDENTS s ON t.student_id = s.student_id
INNER JOIN USERS u ON s.nick = u.nick
INNER JOIN ACADEMIC_YEARS ay ON t.year_id = ay.year_id
WHERE ay.is_current = 1
ORDER BY 
    CASE 
        WHEN t.is_paid = 1 THEN 3
        WHEN GETDATE() > t.due_date THEN 1
        ELSE 2
    END,
    u.last_name;
```

---

### 4. Raport: Plan zajęć grupy

```sql
SELECT 
    g.group_name,
    m.module_name,
    mi.topic,
    CONVERT(VARCHAR(10), mi.start_datetime, 23) AS data,
    CONVERT(VARCHAR(5), mi.start_datetime, 108) AS od_godziny,
    CONVERT(VARCHAR(5), mi.end_datetime, 108) AS do_godziny,
    mi.room_no AS sala,
    CONCAT(e.first_name, ' ', e.last_name) AS prowadzacy
FROM GROUP_MODULES gm
INNER JOIN GROUPS g ON gm.group_id = g.group_id
INNER JOIN MODULES m ON gm.module_id = m.module_id
INNER JOIN MODULE_INSTANCES mi ON m.module_id = mi.module_id
INNER JOIN LECTURERS l ON m.lecturer_id = l.lecturer_id
INNER JOIN EMPLOYEES e ON l.employee_id = e.employee_id
WHERE g.group_id = 1  -- Zmień na ID grupy
AND CAST(mi.start_datetime AS DATE) >= GETDATE()
ORDER BY mi.start_datetime;
```

---

### 5. Raport: Sylabusy przedmiotów

```sql
SELECT 
    d.department_name,
    m.module_name,
    m.hours,
    m.ects_credits,
    CONCAT(e.first_name, ' ', e.last_name) AS lecturer_name,
    ay.year_name,
    sy.content,
    sy.learning_outcomes,
    sy.grading_criteria,
    sy.file_path
FROM SYLLABUSES sy
INNER JOIN MODULES m ON sy.module_id = m.module_id
INNER JOIN LECTURERS l ON m.lecturer_id = l.lecturer_id
INNER JOIN EMPLOYEES e ON l.employee_id = e.employee_id
INNER JOIN DEPARTMENTS d ON m.department_id = d.department_id
INNER JOIN ACADEMIC_YEARS ay ON sy.year_id = ay.year_id
WHERE ay.is_current = 1
ORDER BY d.department_name, m.module_name;
```

---

## 📈 Agregacje i statystyki

### 1. Średnie oceny na przedmioty

```sql
SELECT 
    m.module_name,
    COUNT(sg.grade_record_id) AS liczba_ocen,
    ROUND(AVG(g.grade_value), 2) AS srednia_ocena,
    MAX(g.grade_value) AS najwyzsza_ocena,
    MIN(g.grade_value) AS najnizsza_ocena
FROM STUDENT_GRADES sg
INNER JOIN MODULES m ON sg.module_id = m.module_id
INNER JOIN GRADES g ON sg.grade_id = g.grade_id
GROUP BY m.module_id, m.module_name
ORDER BY srednia_ocena DESC;
```

---

### 2. Statystyka: Oceny po typach

```sql
SELECT 
    gt.grade_type_name,
    COUNT(sg.grade_record_id) AS liczba_ocen,
    ROUND(AVG(g.grade_value), 2) AS srednia,
    g.grade_name,
    COUNT(*) AS ilosc
FROM STUDENT_GRADES sg
INNER JOIN GRADE_TYPES gt ON sg.grade_type_id = gt.grade_type_id
INNER JOIN GRADES g ON sg.grade_id = g.grade_id
GROUP BY gt.grade_type_id, gt.grade_type_name, g.grade_value, g.grade_name
ORDER BY gt.grade_type_name, g.grade_value;
```

---

### 3. Zaległy czesne - studenci

```sql
SELECT 
    u.first_name + ' ' + u.last_name AS student_name,
    s.index_number,
    SUM(CASE WHEN t.is_paid = 0 AND GETDATE() > t.due_date THEN t.amount ELSE 0 END) AS zalegla_kwota,
    COUNT(CASE WHEN t.is_paid = 0 AND GETDATE() > t.due_date THEN 1 END) AS liczba_zalegych,
    MAX(DATEDIFF(DAY, t.due_date, GETDATE())) AS dni_zwloki_max
FROM STUDENTS s
INNER JOIN USERS u ON s.nick = u.nick
LEFT JOIN TUITIONS t ON s.student_id = t.student_id
WHERE s.is_active = 1
GROUP BY s.student_id, u.first_name, u.last_name, s.index_number
HAVING SUM(CASE WHEN t.is_paid = 0 AND GETDATE() > t.due_date THEN t.amount ELSE 0 END) > 0
ORDER BY zalegla_kwota DESC;
```

---

### 4. Frekwencja: najlepsza i najgorsza

```sql
SELECT TOP 10
    u.first_name + ' ' + u.last_name AS student_name,
    ROUND(
        CAST(SUM(CASE WHEN smi.attended = 1 THEN 1 ELSE 0 END) AS FLOAT) / 
        COUNT(*) * 100, 
        2
    ) AS procent_frekwencji
FROM STUDENTS_MODULE_INSTANCES smi
INNER JOIN STUDENTS s ON smi.student_id = s.student_id
INNER JOIN USERS u ON s.nick = u.nick
GROUP BY s.student_id, u.first_name, u.last_name
ORDER BY procent_frekwencji DESC;
```

---

## 🔮 Zaawansowane zapytania

### 1. Studenci bez ocen (zagrożeni)

```sql
SELECT DISTINCT
    s.student_id,
    u.first_name + ' ' + u.last_name AS student_name,
    g.group_name
FROM STUDENTS s
INNER JOIN USERS u ON s.nick = u.nick
INNER JOIN GROUPS g ON s.lab_group_id = g.group_id
LEFT JOIN STUDENT_GRADES sg ON s.student_id = sg.student_id
WHERE sg.grade_record_id IS NULL
AND s.is_active = 1
ORDER BY u.last_name;
```

---

### 2. Przedmioty bez studentów

```sql
SELECT 
    m.module_id,
    m.module_name,
    COUNT(gm.group_id) AS liczba_grup
FROM MODULES m
LEFT JOIN GROUP_MODULES gm ON m.module_id = gm.module_id
WHERE m.is_active = 1
GROUP BY m.module_id, m.module_name
HAVING COUNT(gm.group_id) = 0;
```

---

### 3. Wykładowcy z wiele przedmiotami

```sql
SELECT 
    l.lecturer_id,
    e.first_name + ' ' + e.last_name AS lecturer_name,
    COUNT(DISTINCT m.module_id) AS liczba_przedmiotow,
    SUM(m.hours) AS total_godzin,
    SUM(m.ects_credits) AS total_ects
FROM LECTURERS l
INNER JOIN EMPLOYEES e ON l.employee_id = e.employee_id
LEFT JOIN MODULES m ON l.lecturer_id = m.lecturer_id AND m.is_active = 1
WHERE e.is_active = 1
GROUP BY l.lecturer_id, e.first_name, e.last_name
HAVING COUNT(DISTINCT m.module_id) > 0
ORDER BY liczba_przedmiotow DESC;
```

---

### 4. Przychód z czesnego (bieżący rok)

```sql
SELECT 
    ay.year_name,
    COUNT(DISTINCT t.student_id) AS liczba_studentow,
    SUM(t.amount) AS total_czesne,
    SUM(CASE WHEN t.is_paid = 1 THEN t.amount ELSE 0 END) AS zaplacone,
    SUM(CASE WHEN t.is_paid = 0 THEN t.amount ELSE 0 END) AS zaleglosci
FROM TUITIONS t
INNER JOIN ACADEMIC_YEARS ay ON t.year_id = ay.year_id
WHERE ay.is_current = 1
GROUP BY ay.year_id, ay.year_name;
```

---

### 5. Zajęcia z niską frekwencją (poniżej 50%)

```sql
SELECT 
    mi.instance_id,
    m.module_name,
    mi.topic,
    mi.start_datetime,
    COUNT(smi.attendance_id) AS total_studentow,
    SUM(CASE WHEN smi.attended = 1 THEN 1 ELSE 0 END) AS presente,
    ROUND(
        CAST(SUM(CASE WHEN smi.attended = 1 THEN 1 ELSE 0 END) AS FLOAT) / 
        COUNT(smi.attendance_id) * 100,
        2
    ) AS procent_frekwencji
FROM STUDENTS_MODULE_INSTANCES smi
INNER JOIN MODULE_INSTANCES mi ON smi.instance_id = mi.instance_id
INNER JOIN MODULES m ON mi.module_id = m.module_id
GROUP BY mi.instance_id, m.module_name, mi.topic, mi.start_datetime
HAVING ROUND(
    CAST(SUM(CASE WHEN smi.attended = 1 THEN 1 ELSE 0 END) AS FLOAT) / 
    COUNT(smi.attendance_id) * 100,
    2
) < 50
ORDER BY procent_frekwencji;
```

---

## ⚡ Optymalizacja

### 1. Sprawdź brakujące indeksy

```sql
SELECT 
    OBJECT_NAME(migs.object_id) AS table_name,
    i.name AS index_name,
    migs.avg_total_user_cost,
    migs.user_updates,
    migs.avg_user_impact * (migs.user_seeks + migs.user_scans + migs.user_lookups) AS improvement_measure
FROM sys.dm_db_missing_index_details AS mid
INNER JOIN sys.dm_db_missing_index_groups AS mig ON mid.index_handle = mig.index_handle
INNER JOIN sys.dm_db_missing_index_groups_stats AS migs ON mig.index_group_id = migs.index_group_id
LEFT JOIN sys.indexes AS i ON mid.object_id = i.object_id
WHERE database_id = DB_ID()
ORDER BY (migs.avg_user_impact * (migs.user_seeks + migs.user_scans + migs.user_lookups)) DESC;
```

---

### 2. Sprawdź rozmiar tabel

```sql
SELECT 
    t.name AS table_name,
    SUM(p.rows) AS row_count,
    SUM(au.total_pages) * 8 AS total_size_kb,
    SUM(au.used_pages) * 8 AS used_size_kb
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units au ON p.partition_id = au.container_id
WHERE database_id = DB_ID()
GROUP BY t.name
ORDER BY SUM(p.rows) DESC;
```

---

### 3. Sprawdź fragmentację indeksów

```sql
SELECT 
    OBJECT_NAME(ips.object_id) AS table_name,
    i.name AS index_name,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 10
AND ips.page_count > 1000
ORDER BY ips.avg_fragmentation_in_percent DESC;
```

---

### 4. TOP 10 najwolniejszych queries

```sql
SELECT TOP 10
    st.text AS query_text,
    qs.execution_count,
    qs.total_elapsed_time / 1000000 AS total_elapsed_time_sec,
    qs.max_elapsed_time / 1000000 AS max_elapsed_time_sec,
    qs.total_logical_reads
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY qs.total_elapsed_time DESC;
```

---

**Ostatnia aktualizacja:** 3 grudnia 2025
**Wersja:** 1.0.0

💡 **TIP:** Zmień parametry (student_id, group_id itp) na swoje wartości testowe!

# 🎓 University Management System – Baza Danych

> **Kompleksowy system zarządzania uczelnią budowany na ASP.NET MVC z SQL Server**

## 📋 Przegląd

Ten dokument zawiera pełną specyfikację i implementację bazy danych dla systemu zarządzania uczelnią. Projekt przeznaczony dla zespołu programistów realizujących aplikację ASP.NET MVC.

**Status**: ✅ Gotowa do produkcji  
**Baza danych**: SQL Server / LocalDB  
**Wersja**: 1.0  
**Data**: Grudzień 2025

---

## 📁 Struktura projektu

```
Database/
├── SQL/
│   ├── create_database.sql        ← MAIN: Tworzenie bazy + triggery + views
│   ├── insert_sample_data.sql     ← Dane testowe do development
│   └── queries_examples.sql       ← Przydatne zapytania
│
├── Diagrams/
│   ├── database-schema.md         ← Pełna specyfikacja (ten plik!)
│   ├── ERD-diagram.png            ← Diagram relacyjny (wygeneruj z dbdiagram.io)
│   └── flow-diagrams.md           ← Diagramy przepływów danych
│
├── Documentation/
│   ├── README.md                  ← Ten plik
│   ├── INSTALLATION.md            ← Instrukcja instalacji
│   └── VIEWS-MAPPING.md           ← Mapping widoków do bazy
│
└── Backups/
    └── UniversityDB_backup.bak    ← Backup bazy (dodaj po testach)
```

---

## 🚀 Szybki start

### Wymagania
- **SQL Server 2019+** lub **LocalDB** (darmowy)
- **SQL Server Management Studio (SSMS)**
- **Visual Studio 2022+** (do projektu ASP.NET MVC)

### Instalacja bazy (3 kroki)

#### Krok 1: Otwórz SSMS i połącz się
```
Server: (localdb)\mssqllocaldb
Authentication: Windows
```

#### Krok 2: Uruchom skrypt
```sql
-- Otwórz plik: create_database.sql
-- Naciśnij: Ctrl+Shift+E (Execute)
```

#### Krok 3: Załaduj dane testowe (opcjonalne)
```sql
-- Otwórz plik: insert_sample_data.sql
-- Naciśnij: Ctrl+Shift+E
```

**Gotowe!** ✅ Baza `UniversityDB` jest utworzona i gotowa do użytku.

---

## 📊 Architektura bazy

### 18 tabel podzielonych na warstwy:

| Warstwa | Tabele | Przeznaczenie |
|---------|--------|---------------|
| **Walidacyjna** | ROLES, DEPARTMENTS, GROUPS, GRADES, GRADE_TYPES | Słowniki i wyliczenia |
| **Autentykacja** | USERS, ACADEMIC_YEARS | Logowanie i kontekst czasowy |
| **Studenci** | STUDENTS, TUITIONS | Dane studentów i płatności |
| **Pracownicy** | EMPLOYEES, LECTURERS | Dane pracowników i wykładowców |
| **Akademicka** | MODULES, GROUP_MODULES, MODULE_INSTANCES, STUDENT_GRADES, STUDENTS_MODULE_INSTANCES | Przedmioty, zajęcia, oceny, obecność |
| **Komunikacja** | ANNOUNCEMENTS, SYLLABUSES | Ogłoszenia i dokumentacja |

### Kluczowe relacje

```
┌─────────┐
│ USERS   │ ←── (logowanie + rola)
└────┬────┘
     │
  ┌──┴──┬──────────┐
  │     │          │
STUDENT EMPLOYEE LECTURER
  │     │          │
  ├→GROUPS      ├→MODULES  
  │             │     │
  ├→TUITIONS    └→GROUP_MODULES
  │                  │
  ├→STUDENT_GRADES←─┴─→MODULE_INSTANCES
  │                   │
  └→STUDENTS_MODULE_INSTANCES (obecność)
```

---

## 👥 Użytkownicy testowi

### Studenci (hasło: `Haslo123!`)
```
jan.kowalski      → Grupa 1A - Informatyka
maria.nowak       → Grupa 2A - Informatyka  
piotr.wisniewski  → Grupa 1A - Informatyka
anna.krol         → Grupa 2B - Informatyka
```

### Wykładowcy (hasło: `Haslo123!`)
```
anna.smith              → Dr, Informatyka (Matematyka dyskretna)
zbigniew.kuchta        → Prof, Informatyka (Algorytmy, Bazy danych)
katarzyna.lewandowska  → Dr, Matematyka (Analiza matematyczna)
```

---

## 🔧 Triggery (Walidacja danych)

Baza zawiera **3 triggery** zapewniające spójność:

### 1. `tr_student_role_check`
- **Kiedy**: Przed INSERT do STUDENTS
- **Logika**: Student musi mieć role='student' w USERS
- **Cel**: Uniemożliwić przypisanie pracownika do tabeli studentów

### 2. `tr_employee_role_check`
- **Kiedy**: Przed INSERT do EMPLOYEES
- **Logika**: Pracownik musi mieć role='employee' w USERS
- **Cel**: Uniemożliwić przypisanie studenta do tabeli pracowników

### 3. `tr_student_grades_validation`
- **Kiedy**: Przed INSERT do STUDENT_GRADES
- **Logika**: Student musi należeć do grupy przypisanej do modułu
- **Cel**: Zapobieganie wstawieniu oceny z niedostępnego przedmiotu

**Wniosek**: Triggery automatycznie zabezpieczają przed błędami logiki biznesowej!

---

## 📈 Indeksy (Optymalizacja)

Baza zawiera **20+ indeksów** na kluczowych polach:

```sql
-- Najważniejsze dla performance
idx_users_role                  -- Szybkie logowanie
idx_student_grades_student      -- Pobieranie ocen studenta
idx_module_instances_module     -- Harmonogram
idx_attendance_attended         -- Rejestracja obecności
idx_modules_lecturer            -- Moduły wykładowcy
```

**Efekt**: Zapytania SELECT działają błyskawicznie nawet dla 10k+ rekordów.

---

## 📡 7 Gotowych VIEWS (Widoków)

Baza zawiera **7 gotowych widoków** dla aplikacji MVC:

### 1. `vw_student_info`
```sql
-- Podstawowe dane studenta
SELECT * FROM vw_student_info WHERE nick = 'jan.kowalski';
```
**Wynik**: Imię, email, grupa, konto bankowe

### 2. `vw_lecturer_info`
```sql
-- Dane wykładowcy
SELECT * FROM vw_lecturer_info WHERE nick = 'anna.smith';
```
**Wynik**: Tytuł, wydział, data zatrudnienia

### 3. `vw_student_schedule`
```sql
-- Plan zajęć studenta
SELECT * FROM vw_student_schedule WHERE student_id = 1;
```
**Wynik**: Data, czas, sala, temat, wykładowca

### 4. `vw_group_modules`
```sql
-- Przedmioty grupy laboratoryjnej
SELECT * FROM vw_group_modules WHERE group_id = 1;
```
**Wynik**: Nazwa modułu, godziny, ECTS, termin egzaminu

### 5. `vw_student_grades_summary`
```sql
-- Oceny studenta
SELECT * FROM vw_student_grades_summary WHERE student_id = 1;
```
**Wynik**: Przedmiot, ocena, typ, data, wykładowca

### 6. `vw_student_tuitions`
```sql
-- Historia płatności
SELECT * FROM vw_student_tuitions WHERE student_id = 1;
```
**Wynik**: Kwota, termin, status, dni do płatności

### 7. `vw_group_students`
```sql
-- Studenci w grupie (dla wykładowcy)
SELECT * FROM vw_group_students WHERE group_id = 1;
```
**Wynik**: Nick, imię, nazwisko, rok rozpoczęcia

---

## 🎯 Mapowanie Widoków MVC do Views BD

| Widok MVC | Tabele/Views | Operacja |
|-----------|-------------|----------|
| **Student/Dashboard** | vw_student_info, ACADEMIC_YEARS | SELECT |
| **Student/Schedule** | vw_student_schedule | SELECT |
| **Student/Grades** | vw_student_grades_summary | SELECT |
| **Student/Modules** | vw_group_modules | SELECT |
| **Student/Tuitions** | vw_student_tuitions | SELECT |
| **Lecturer/Dashboard** | vw_lecturer_info, MODULES | SELECT |
| **Lecturer/MyGroups** | vw_group_students | SELECT |
| **Lecturer/Grades** | STUDENT_GRADES, GRADES | SELECT, INSERT, UPDATE |
| **Lecturer/Attendance** | vw_attendance_list | SELECT, UPDATE |
| **Lecturer/Announcements** | ANNOUNCEMENTS | SELECT, INSERT |
| **Auth/Login** | USERS | SELECT |
| **Auth/Register** | USERS, STUDENTS, ROLES | INSERT |

---

## 🔐 Bezpieczeństwo

### Hasła
- ✅ Przechowywane jako **SHA2_256 hash** (NIGDY plaintext!)
- ✅ Baza danych nie przechowuje hasła, tylko hash
- ✅ W aplikacji MVC: `BCrypt.Net.BCrypt.HashPassword()`

### Rola (Role-based access)
```sql
-- Student widzi tylko swoje dane
SELECT * FROM STUDENTS WHERE nick = @current_user;

-- Wykładowca widzi tylko swoich studentów
SELECT * FROM vw_group_students 
WHERE group_id IN (SELECT group_id FROM MODULES 
                   WHERE lecturer_id = @current_lecturer);
```

### Soft-delete (Archiwizacja)
```sql
-- Zamiast DELETE:
UPDATE STUDENTS SET is_active = 0, archived_at = GETDATE();

-- Zmiana zapytań:
SELECT * FROM STUDENTS WHERE is_active = 1;
```

---

## 📝 Przykładowe zapytania

### Zapytanie 1: Oceny studenta z roku 2024/2025
```sql
SELECT 
    m.module_name,
    g.grade_value,
    gt.grade_type_name,
    sg.grade_date
FROM STUDENT_GRADES sg
INNER JOIN STUDENTS s ON sg.student_id = s.student_id
INNER JOIN MODULES m ON sg.module_id = m.module_id
INNER JOIN GRADES g ON sg.grade_id = g.grade_id
INNER JOIN GRADE_TYPES gt ON sg.grade_type_id = gt.grade_type_id
INNER JOIN ACADEMIC_YEARS ay ON sg.year_id = ay.year_id
WHERE s.nick = 'jan.kowalski' AND ay.year_name = '2024/2025'
ORDER BY sg.grade_date DESC;
```

### Zapytanie 2: Frekwencja studenta
```sql
SELECT 
    m.module_name,
    COUNT(*) AS total_classes,
    SUM(CAST(smi.attended AS INT)) AS attended_classes,
    ROUND(100.0 * SUM(CAST(smi.attended AS INT)) / COUNT(*), 1) AS attendance_percent
FROM STUDENTS_MODULE_INSTANCES smi
INNER JOIN STUDENTS s ON smi.student_id = s.student_id
INNER JOIN MODULE_INSTANCES mi ON smi.instance_id = mi.instance_id
INNER JOIN MODULES m ON mi.module_id = m.module_id
WHERE s.nick = 'jan.kowalski'
GROUP BY m.module_name;
```

### Zapytanie 3: Zalegające płatności
```sql
SELECT 
    u.nick,
    u.first_name,
    u.last_name,
    SUM(t.amount) AS total_debt,
    MIN(t.due_date) AS earliest_due_date
FROM TUITIONS t
INNER JOIN STUDENTS s ON t.student_id = s.student_id
INNER JOIN USERS u ON s.nick = u.nick
WHERE t.is_paid = 0 AND t.due_date < CAST(GETDATE() AS DATE)
GROUP BY u.nick, u.first_name, u.last_name
ORDER BY total_debt DESC;
```

---

## 📋 Listy kontrolne dla zespołu

### Dla programisty – Backend (Core)

- [ ] Entity Framework Models (Users, Students, Modules, etc.)
- [ ] DbContext (UniversityDbContext.cs)
- [ ] Authentication Service (logowanie, weryfikacja hasła)
- [ ] Repositories (StudentRepository, LecturerRepository, etc.)
- [ ] Controllers (AuthController, BaseController)

### Dla programisty – Student Views

- [ ] Dashboard (vw_student_info)
- [ ] Schedule (vw_student_schedule)
- [ ] Grades (vw_student_grades_summary)
- [ ] Modules (vw_group_modules)
- [ ] Tuitions (vw_student_tuitions)
- [ ] Profile (vw_student_info + UPDATE)

### Dla programisty – Lecturer Views

- [ ] Dashboard (vw_lecturer_info, MODULES)
- [ ] My Groups (vw_group_students)
- [ ] Grades Management (INSERT, UPDATE STUDENT_GRADES)
- [ ] Attendance (UPDATE STUDENTS_MODULE_INSTANCES)
- [ ] Announcements (INSERT, SELECT ANNOUNCEMENTS)

### Dla DBA (przyszłe fazy)

- [ ] Backups (cotygodniowo)
- [ ] Query performance monitoring
- [ ] Index maintenance
- [ ] Security audit

---

## 🐛 Troubleshooting

### Problem: "Nie mogę zalogować się"
```sql
-- Sprawdź czy user istnieje i rola jest prawidłowa
SELECT nick, first_name, role_id FROM USERS WHERE nick = 'jan.kowalski';
-- Powinno zwrócić: jan.kowalski | Jan | 1 (student)
```

### Problem: "Student widzi oceny z innego przedmiotu"
```sql
-- Sprawdź trigger tr_student_grades_validation
SELECT * FROM STUDENT_GRADES 
WHERE student_id = 1 AND module_id NOT IN 
  (SELECT module_id FROM GROUP_MODULES WHERE group_id = 
   (SELECT lab_group_id FROM STUDENTS WHERE student_id = 1));
-- Nie powinno zwrócić żadnych rekordów!
```

### Problem: "Zapytanie jest wolne"
```sql
-- Sprawdź czy Index istnieje
SELECT * FROM sys.indexes WHERE name LIKE 'idx_%' AND object_id = OBJECT_ID('STUDENT_GRADES');
-- Jeśli brakuje → uruchom create_database.sql ponownie
```

---

## 📞 Kontakt i pytania

**Baza danych**: [Tu Twoje imię/nick]  
**Backend**: [Nick zespołu]  
**Frontend**: [Nick zespołu]  

---

## 📚 Dodatkowe zasoby

- 📖 [Database Schema (markdown)](./database-schema.md) – Pełna specyfikacja (25+ stron)
- 🔗 [Generuj diagram ERD](https://dbdiagram.io) – Wstaw `create_database.sql`
- 🎓 [SQL Server Docs](https://learn.microsoft.com/en-us/sql/)
- 🏗️ [Entity Framework Guide](https://learn.microsoft.com/en-us/ef/core/)

---

**Status**: ✅ Produkcja gotowa (v1.0)  
**Ostatnia aktualizacja**: Grudzień 2025  
**Licencja**: Projekt zespołowy – do użytku wewnętrznego

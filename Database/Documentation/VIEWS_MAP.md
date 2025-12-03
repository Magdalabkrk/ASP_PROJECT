# 📱 MAPA WIDOKÓW - ASP.NET Application

## 🏗️ Architektura Widoków

Aplikacja oparta na **18 tabelach**, **5 widokach SQL** i **3 triggerach**.

---

## 1️⃣ AUTHENTICATION & AUTHORIZATION

### 1.1 **Login Page** 
**Ścieżka:** `/Auth/Login`
**Rola:** Public (brak autentykacji)

**Dane potrzebne:**
- `USERS.nick` (username)
- `USERS.password` (hashed)
- `USERS.role` (student/employee)

**Funkcjonalność:**
- Formularz logowania (nick + hasło)
- Walidacja roli użytkownika
- Redirect do Dashboard na podstawie roli

**SQL Query:**
```sql
SELECT user_id, nick, role FROM USERS 
WHERE nick = @nick AND password = HASHBYTES('SHA2_256', @password)
```

---

### 1.2 **Register Page**
**Ścieżka:** `/Auth/Register`
**Rola:** Public

**Dane potrzebne:**
- `USERS` - nowy użytkownik
- `ROLES` - walidacja dostępnych ról

**Funkcjonalność:**
- Rejestracja nowego użytkownika
- Wybór roli (student/employee)
- Walidacja unikatowego nick'a
- Trigger automatycznie tworzy rekord w STUDENTS/EMPLOYEES

**SQL Query:**
```sql
INSERT INTO USERS (nick, password, first_name, last_name, birth_date, pesel, address, role_id)
VALUES (@nick, HASHBYTES('SHA2_256', @password), @first_name, ...)
```

---

## 2️⃣ STUDENT VIEWS (Role: Student)

### 2.1 **Student Dashboard**
**Ścieżka:** `/Student/Dashboard`
**Rola:** Student

**Dane potrzebne:**
- `STUDENTS.student_id`
- `GROUPS.group_id`, `GROUPS.group_name`
- `GROUP_MODULES` - przedmioty przypisane do grupy
- `STUDENT_GRADES` - oceny studenta
- `TUITIONS` - stan płatności

**Widzety:**
```
┌─────────────────────────────────┐
│ Witaj, [Student Name]!          │
├─────────────────────────────────┤
│ 📚 Twoja Grupa: 1A              │
│ 📊 Średnia Ocen: 4.2            │
│ 💳 Czesne: 2000 PLN (opłacone) │
│ 📅 Zajęcia Dzisiaj: 2 zajęcia  │
└─────────────────────────────────┘
```

**SQL Query:**
```sql
SELECT 
  s.student_id,
  s.first_name,
  g.group_name,
  COUNT(DISTINCT gm.module_id) as module_count,
  AVG(sg.grade) as avg_grade,
  SUM(CASE WHEN t.paid = 1 THEN 1 ELSE 0 END) as paid_tuitions
FROM STUDENTS s
JOIN GROUPS g ON s.lab_group_id = g.group_id
LEFT JOIN GROUP_MODULES gm ON g.group_id = gm.group_id
LEFT JOIN STUDENT_GRADES sg ON s.student_id = sg.student_id
LEFT JOIN TUITIONS t ON s.student_id = t.student_id
WHERE s.student_id = @student_id
GROUP BY s.student_id, s.first_name, g.group_name
```

---

### 2.2 **My Courses / Schedule**
**Ścieżka:** `/Student/Courses`
**Rola:** Student

**Dane potrzebne:**
- `GROUP_MODULES` - przedmioty grupy
- `MODULES` - dane przedmiotu
- `MODULE_INSTANCES` - konkretne zajęcia
- `LECTURERS` - prowadzący
- `STUDENTS_MODULE_INSTANCES` - frekwencja studenta

**Funkcjonalność:**
- Lista przedmiotów (razem z grupą)
- Plan zajęć (dzień, godzina, sala)
- Status obecności na zajęciach

**Tabela Przedmiotów:**
```
| Przedmiot | Wykładowca | Godziny | Sala | Ocena | Status |
|-----------|-----------|---------|------|-------|--------|
| Bazy Danych | Dr. X | 8 | 215A | 4.5 | ✓ Zaliczony |
| Algorytmy | Dr. Y | 8 | 220B | 4.0 | ✓ Zaliczony |
```

**SQL Query:**
```sql
SELECT 
  m.module_id,
  m.module_name,
  l.first_name + ' ' + l.last_name as lecturer,
  mi.date_start,
  mi.date_end,
  mi.room_number,
  sg.grade,
  CASE WHEN smi.attended = 1 THEN '✓' ELSE '✗' END as attendance
FROM GROUP_MODULES gm
JOIN MODULES m ON gm.module_id = m.module_id
JOIN LECTURERS l ON m.lecturer_id = l.lecturer_id
JOIN MODULE_INSTANCES mi ON m.module_id = mi.module_id
LEFT JOIN STUDENT_GRADES sg ON m.module_id = sg.module_id 
  AND sg.student_id = @student_id
LEFT JOIN STUDENTS_MODULE_INSTANCES smi ON mi.instance_id = smi.instance_id
  AND smi.student_id = @student_id
WHERE gm.group_id = (SELECT lab_group_id FROM STUDENTS WHERE student_id = @student_id)
ORDER BY mi.date_start
```

---

### 2.3 **Attendance Record**
**Ścieżka:** `/Student/Attendance`
**Rola:** Student

**Dane potrzebne:**
- `STUDENTS_MODULE_INSTANCES` - frekwencja
- `MODULE_INSTANCES` - zajęcia
- `MODULES` - nazwy przedmiotów

**Funkcjonalność:**
- Tabela frekwencji (przedmiot, data, status)
- Procent obecności na każdym przedmiocie

**Tabela Frekwencji:**
```
| Przedmiot | Data | Godzina | Status | Procent Obecności |
|-----------|------|---------|--------|-------------------|
| Bazy Danych | 2025-12-01 | 10:00 | ✓ Obecny | 92% |
| Bazy Danych | 2025-12-08 | 10:00 | ✗ Nieobecny | 92% |
```

---

### 2.4 **Grades**
**Ścieżka:** `/Student/Grades`
**Rola:** Student

**Dane potrzebne:**
- `STUDENT_GRADES` - oceny studenta
- `MODULES` - przedmioty
- `GRADES` - walidacja ocen
- `GRADE_TYPES` - typ oceny (egzamin/kolokwium)

**Funkcjonalność:**
- Lista wszystkich ocen
- Srednia ważona
- Historia ocen

**Tabela Ocen:**
```
| Przedmiot | Typ | Ocena | Data | Status |
|-----------|-----|-------|------|--------|
| Bazy Danych | Egzamin | 4.5 | 2025-12-01 | ✓ |
| Algorytmy | Kolokwium | 4.0 | 2025-11-25 | ✓ |
```

---

### 2.5 **Tuition Payment**
**Ścieżka:** `/Student/Tuitions`
**Rola:** Student

**Dane potrzebne:**
- `TUITIONS` - płatności
- `ACADEMIC_YEARS` - rok akademicki
- `STUDENTS` - dane studenta

**Funkcjonalność:**
- Historia płatności czesnego
- Status (opłacone/zaległa)
- Data płatności i termin

**Tabela Płatności:**
```
| Semestr | Kwota | Termin | Data Płatności | Status |
|---------|-------|--------|----------------|--------|
| 2025/1 | 2000 PLN | 2025-10-31 | 2025-10-30 | ✓ Opłacone |
| 2025/2 | 2000 PLN | 2025-02-28 | - | ⚠️ Zaległa |
```

---

## 3️⃣ LECTURER VIEWS (Role: Employee → Lecturer)

### 3.1 **Lecturer Dashboard**
**Ścieżka:** `/Lecturer/Dashboard`
**Rola:** Lecturer

**Dane potrzebne:**
- `LECTURERS.lecturer_id`
- `MODULES` - prowadzone przedmioty
- `GROUP_MODULES` - grupy na przedmiotu
- `STUDENTS_MODULE_INSTANCES` - frekwencja
- `STUDENT_GRADES` - oceny wystawione

**Widzety:**
```
┌──────────────────────────────────┐
│ Witaj, Dr. [Lecturer Name]!      │
├──────────────────────────────────┤
│ 📚 Prowadzę: 3 przedmioty        │
│ 👥 Łącznie Studentów: 75         │
│ ✍️ Wystawiłem Ocen: 150          │
│ 📊 Średnia Frekwencji: 88%       │
└──────────────────────────────────┘
```

---

### 3.2 **My Modules**
**Ścieżka:** `/Lecturer/Modules`
**Rola:** Lecturer

**Dane potrzebne:**
- `MODULES` - przedmioty wykładowcy
- `DEPARTMENTS` - wydział
- `GROUP_MODULES` - grupy
- `MODULE_INSTANCES` - instancje

**Funkcjonalność:**
- Lista prowadzonych przedmiotów
- Liczba godzin
- Grupy pracujące z przedmiotem
- Liczba instancji zajęć

**Tabela Przedmiotów:**
```
| Przedmiot | Wydział | Godziny | Grupy | Instancji | Akcje |
|-----------|---------|---------|-------|-----------|-------|
| Bazy Danych | Inf | 30 | 1A, 2A | 8 | Edytuj |
| Algorytmy | Inf | 30 | 2B, 3A | 10 | Edytuj |
```

---

### 3.3 **Group Schedule**
**Ścieżka:** `/Lecturer/Schedule`
**Rola:** Lecturer

**Dane potrzebne:**
- `MODULE_INSTANCES` - instancje
- `MODULES` - nazwy
- `GROUP_MODULES` - grupy

**Funkcjonalność:**
- Harmonogram zajęć (dzień, godzina, sala, grupa)

**Tabela Planu:**
```
| Data | Godzina | Przedmiot | Grupa | Sala | Temat |
|------|---------|-----------|-------|------|-------|
| 2025-12-08 | 10:00 | Bazy Danych | 1A | 215A | Normalizacja |
| 2025-12-08 | 14:00 | Algorytmy | 2B | 220B | Sortowanie |
```

---

### 3.4 **Attendance Management**
**Ścieżka:** `/Lecturer/Attendance/[module_id]/[instance_id]`
**Rola:** Lecturer

**Dane potrzebne:**
- `MODULE_INSTANCES` - konkretne zajęcia
- `GROUP_MODULES` - studenci grupy
- `STUDENTS_MODULE_INSTANCES` - frekwencja

**Funkcjonalność:**
- Lista studentów na zajęciach
- Zaznaczanie obecności (checkbox)
- Zapis do `STUDENTS_MODULE_INSTANCES.attended`

**Tabela Frekwencji (Do edycji):**
```
| Lp | Student | Imię | Nazwisko | Obecny |
|----|---------|------|----------|--------|
| 1  | STU001  | Jan  | Kowalski | ☑ |
| 2  | STU002  | Maria| Nowak    | ☐ |
| 3  | STU003  | Piotr| Lewicki  | ☑ |
```

---

### 3.5 **Grading**
**Ścieżka:** `/Lecturer/Grading/[module_id]`
**Rola:** Lecturer

**Dane potrzebne:**
- `STUDENT_GRADES` - oceny
- `STUDENTS` - lista studentów
- `GRADES` - walidacja ocen
- `GRADE_TYPES` - typ oceny

**Funkcjonalność:**
- Tabela do wprowadzania ocen
- Dropdown z dostępnymi ocenami (2.0, 2.5, ..., 5.0)
- Typ oceny (egzamin/kolokwium)
- Zapis do `STUDENT_GRADES`

**Tabela Oceniania:**
```
| Lp | Student | Imię | Nazwisko | Typ | Ocena |
|----|---------|------|----------|-----|-------|
| 1  | STU001  | Jan  | Kowalski | Egzamin | [4.5 ▼] |
| 2  | STU002  | Maria| Nowak    | Egzamin | [3.5 ▼] |
```

---

### 3.6 **Student Performance Report**
**Ścieżka:** `/Lecturer/Reports/Performance/[module_id]`
**Rola:** Lecturer

**Dane potrzebne:**
- `STUDENT_GRADES` - oceny
- `STUDENTS_MODULE_INSTANCES` - frekwencja
- `STUDENTS` - dane

**Funkcjonalność:**
- Ranking studentów (po ocenie)
- Procent frekwencji
- Średnia ocen

**Raport:**
```
| Lp | Student | Średnia Ocen | Frekwencja | Status |
|----|---------|--------------|------------|--------|
| 1  | Jan Kowalski | 4.5 | 95% | ✓ Zaliczony |
| 2  | Maria Nowak | 3.8 | 88% | ✓ Zaliczony |
| 3  | Piotr Lewicki | 2.5 | 60% | ✗ Do poprawy |
```

---

## 4️⃣ ADMIN VIEWS (Role: Employee → HR/Admin)

### 4.1 **Admin Dashboard**
**Ścieżka:** `/Admin/Dashboard`
**Rola:** Admin/HR

**Dane potrzebne:**
- `USERS` - liczba użytkowników
- `STUDENTS` - liczba studentów
- `EMPLOYEES` - liczba pracowników
- `MODULES` - liczba przedmiotów
- `DEPARTMENTS` - liczba wydziałów

**Widzety:**
```
┌──────────────────────────────────┐
│ 👥 Użytkownicy: 250              │
│ 🎓 Studenci: 180                 │
│ 👔 Pracownicy: 30                │
│ 📚 Przedmioty: 45                │
│ 🏢 Wydziały: 3                   │
└──────────────────────────────────┘
```

---

### 4.2 **Users Management**
**Ścieżka:** `/Admin/Users`
**Rola:** Admin

**Dane potrzebne:**
- `USERS` - wszyscy użytkownicy
- `ROLES` - role
- `STUDENTS`/`EMPLOYEES` - status

**Funkcjonalność:**
- Tabela wszystkich użytkowników
- Filtrowanie po roli
- Edycja (zmiana hasła, roli)
- Usuwanie

**Tabela Użytkowników:**
```
| Nick | Imię | Nazwisko | Rola | Akcje |
|------|------|----------|------|-------|
| jkowalski | Jan | Kowalski | Student | Edytuj | Usuń |
| mlewicki | Maria | Lewicki | Employee | Edytuj | Usuń |
```

---

### 4.3 **Students Management**
**Ścieżka:** `/Admin/Students`
**Rola:** Admin

**Dane potrzebne:**
- `STUDENTS` - lista studentów
- `GROUPS` - grupy
- `USERS` - dane osobowe

**Funkcjonalność:**
- Lista studentów
- Edycja grupy
- Historia płatności
- Status akademicki

**Tabela Studentów:**
```
| Imię | Nazwisko | PESEL | Grupa | Rok Studiów | Akcje |
|------|----------|-------|-------|-------------|-------|
| Jan | Kowalski | 00001 | 1A | 2024 | Edytuj |
| Maria | Nowak | 00002 | 1A | 2024 | Edytuj |
```

---

### 4.4 **Employees Management**
**Ścieżka:** `/Admin/Employees`
**Rola:** Admin

**Dane potrzebne:**
- `EMPLOYEES` - pracownicy
- `LECTURERS` - status wykładowcy
- `DEPARTMENTS` - wydział
- `USERS` - dane

**Funkcjonalność:**
- Lista pracowników
- Stanowisko
- Wynagrodzenie
- Przypisane moduły (jeśli lecturer)

**Tabela Pracowników:**
```
| Imię | Nazwisko | Stanowisko | Dział | Wynagrodzenie | Akcje |
|------|----------|-----------|-------|---------------|-------|
| Dr. | Zając | Profesor | Informatyka | 8000 | Edytuj |
| Dr. | Kot | Adiunkt | Matematyka | 6000 | Edytuj |
```

---

### 4.5 **Modules Management**
**Ścieżka:** `/Admin/Modules`
**Rola:** Admin

**Dane potrzebne:**
- `MODULES` - przedmioty
- `LECTURERS` - prowadzący
- `DEPARTMENTS` - dział
- `GROUP_MODULES` - grupy

**Funkcjonalność:**
- CRUD przedmiotów
- Przypisanie wykładowcy
- Przypisanie wydziału
- Liczba godzin

**Tabela Przedmiotów:**
```
| Nazwa | Godziny | Wykładowca | Dział | Grupy | Akcje |
|-------|---------|-----------|-------|-------|-------|
| Bazy Danych | 30 | Dr. Zając | Inf | 2 | Edytuj |
| Algorytmy | 30 | Dr. Kot | Inf | 2 | Edytuj |
```

---

### 4.6 **Groups Management**
**Ścieżka:** `/Admin/Groups`
**Rola:** Admin

**Dane potrzebne:**
- `GROUPS` - grupy
- `STUDENTS` - studenci w grupie
- `GROUP_MODULES` - przedmioty grupy

**Funkcjonalność:**
- CRUD grup
- Dodawanie/usuwanie studentów
- Przypisanie przedmiotów
- Liczba studentów (max 25)

**Tabela Grup:**
```
| Nazwa | Studenci | Przedmioty | Akcje |
|-------|----------|-----------|-------|
| 1A | 24/25 | 3 | Edytuj |
| 1B | 23/25 | 3 | Edytuj |
```

---

### 4.7 **Departments Management**
**Ścieżka:** `/Admin/Departments`
**Rola:** Admin

**Dane potrzebne:**
- `DEPARTMENTS` - wydziały
- `LECTURERS` - pracownicy
- `MODULES` - przedmioty

**Funkcjonalność:**
- CRUD wydziałów
- Liczba pracowników
- Liczba przedmiotów

**Tabela Wydziałów:**
```
| Nazwa | Pracownicy | Przedmioty | Akcje |
|-------|-----------|-----------|-------|
| Informatyka | 5 | 12 | Edytuj |
| Matematyka | 3 | 8 | Edytuj |
```

---

### 4.8 **Financial Reports**
**Ścieżka:** `/Admin/Reports/Financial`
**Rola:** Admin

**Dane potrzebne:**
- `TUITIONS` - wszystkie płatności
- `STUDENTS` - info studenta
- `ACADEMIC_YEARS` - rok

**Funkcjonalność:**
- Zestawienie przychodów
- Liczba studentów (opłacono/zaległa)
- Ranking dłużników

**Raport Finansowy:**
```
| Semestr | Liczba Studentów | Przychód | Zaległa |
|---------|-----------------|----------|---------|
| 2025/1 | 180 | 360 000 PLN | 3 |
| 2025/2 | 180 | 354 000 PLN | 5 |
```

---

### 4.9 **Academic Reports**
**Ścieżka:** `/Admin/Reports/Academic`
**Rola:** Admin

**Dane potrzebne:**
- `STUDENT_GRADES` - wszystkie oceny
- `STUDENTS` - info studenta
- `MODULES` - przedmioty

**Funkcjonalność:**
- Średnia ocen na uczelni
- Najbardziej wymagający przedmioty
- Najlepsi studenci

**Raport Akademicki:**
```
| Przedmiot | Średnia | Min | Max |
|-----------|--------|-----|-----|
| Bazy Danych | 3.8 | 2.0 | 5.0 |
| Algorytmy | 3.5 | 2.5 | 5.0 |
```

---

## 5️⃣ SYSTEM VIEWS (SQL Views w bazie)

### Istniejące Widoki (SQL):
```sql
vw_student_grades_summary      -- Podsumowanie ocen studenta
vw_student_attendance          -- Frekwencja studenta
vw_student_tuition_status      -- Status płatności
vw_lecturer_workload           -- Obciążenie wykładowcy
vw_academic_year_summary       -- Podsumowanie roku akademickiego
```

---

## 📊 MAPA PRZEPŁYWU DANYCH

```
LOGIN
  ├─→ STUDENT ROLE
  │   ├─→ Dashboard (USERS, STUDENTS, GROUPS, GROUP_MODULES, STUDENT_GRADES, TUITIONS)
  │   ├─→ Courses (MODULES, MODULE_INSTANCES, LECTURERS, STUDENTS_MODULE_INSTANCES)
  │   ├─→ Attendance (STUDENTS_MODULE_INSTANCES, MODULE_INSTANCES, MODULES)
  │   ├─→ Grades (STUDENT_GRADES, MODULES, GRADES, GRADE_TYPES)
  │   └─→ Tuitions (TUITIONS, ACADEMIC_YEARS)
  │
  ├─→ LECTURER ROLE (via EMPLOYEE)
  │   ├─→ Dashboard (LECTURERS, MODULES, GROUP_MODULES, STUDENTS_MODULE_INSTANCES, STUDENT_GRADES)
  │   ├─→ My Modules (MODULES, DEPARTMENTS, GROUP_MODULES, MODULE_INSTANCES)
  │   ├─→ Schedule (MODULE_INSTANCES, MODULES, GROUP_MODULES)
  │   ├─→ Attendance (MODULE_INSTANCES, GROUP_MODULES, STUDENTS_MODULE_INSTANCES) [WRITE]
  │   ├─→ Grading (STUDENT_GRADES, STUDENTS, GRADES, GRADE_TYPES) [WRITE]
  │   └─→ Reports (STUDENT_GRADES, STUDENTS_MODULE_INSTANCES, STUDENTS)
  │
  └─→ ADMIN ROLE (via EMPLOYEE)
      ├─→ Dashboard (USERS, STUDENTS, EMPLOYEES, MODULES, DEPARTMENTS)
      ├─→ Users (USERS, ROLES, STUDENTS, EMPLOYEES) [CRUD]
      ├─→ Students (STUDENTS, GROUPS, USERS) [CRUD]
      ├─→ Employees (EMPLOYEES, LECTURERS, DEPARTMENTS, USERS) [CRUD]
      ├─→ Modules (MODULES, LECTURERS, DEPARTMENTS, GROUP_MODULES) [CRUD]
      ├─→ Groups (GROUPS, STUDENTS, GROUP_MODULES) [CRUD]
      ├─→ Departments (DEPARTMENTS, LECTURERS, MODULES) [CRUD]
      ├─→ Financial Reports (TUITIONS, STUDENTS, ACADEMIC_YEARS)
      └─→ Academic Reports (STUDENT_GRADES, STUDENTS, MODULES)
```

---

## 🎯 PRIORYTET IMPLEMENTACJI

**Faza 1 - Core:**
1. ✅ Login / Register
2. ✅ Student Dashboard
3. ✅ Lecturer Attendance + Grading
4. ✅ Admin Users Management

**Faza 2 - Secondary:**
5. Student Courses + Attendance Record
6. Lecturer Schedule + Reports
7. Admin Modules + Groups Management

**Faza 3 - Advanced:**
8. Financial Reports
9. Academic Reports
10. Syllabus Management (jeśli potrzebna tabela SYLLABUSES)

---

**Ostatnia aktualizacja:** 3 grudnia 2025
**Status:** Gotowy do implementacji w ASP.NET MVC/Core
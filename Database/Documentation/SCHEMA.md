# 📊 SCHEMA.md - Schemat Bazy Danych

## 📋 Spis treści

1. [Diagram ERD](#diagram-erd)
2. [Opis tabel](#opis-tabel)
3. [Indeksy](#indeksy)
4. [Triggery](#triggery)
5. [Constraints](#constraints)

---

## 🗂️ Diagram ERD

```
┌─────────────────────────────────────────────────────────────────────┐
│                    BAZA DANYCH: UniversityDB                        │
└─────────────────────────────────────────────────────────────────────┘

                              ROLES
                          (role_id PK)
                               │
                               ├─── student
                               └─── employee

                              USERS
                    (user_id PK, role_id FK)
                          │           │
                    ┌─────┴─────┬─────┴─────┐
                    │           │           │
               STUDENTS    EMPLOYEES      (Abstract)
            (student_id)  (employee_id)
                    │
                    └──── LECTURERS (employee_id FK)
                              │
                              └─── MODULES

         DEPARTMENTS ◄─── MODULES ──► LECTURERS
         (dept_id)      (module_id)   (lecturer_id)
            │
            └─────────────────┐
                              │
                         GROUP_MODULES
                    (group_id FK, module_id FK)


                        ACADEMIC_YEARS
                        (year_id PK)
                              │
         ┌────────────────────┼────────────────────┐
         │                    │                    │
      MODULES          MODULE_INSTANCES      STUDENT_GRADES
      (year_id FK)   (year_id FK)           (year_id FK)
         │                    │                    │
         │            ┌───────┴────────┐           │
         │            │                │           │
      GROUPS    STUDENTS_MODULE_    STUDENTS
     (group_id)  INSTANCES (frekw)
         │            │                │
         │    ┌───────┴────────────────┤
         │    │                        │
      GROUP_MODULES ◄──────────────────┤
    (group_id, module_id)              │
         │                             │
         └─────────────────────────────┤
                                       │
                        ┌──────────────┤
                        │              │
                    TUITIONS      STUDENT_GRADES
                (student_id FK) (student_id FK)
                (year_id FK)    (module_id FK)
                                (year_id FK)
                                (grade_id FK)
                                (grade_type_id FK)
                                (lecturer_id FK)

                              GRADES
                           (grade_id PK)

                           GRADE_TYPES
                        (grade_type_id PK)

                            SYLLABUSES
                       (module_id FK)
                       (year_id FK)

                          ANNOUNCEMENTS
                        (created_by FK - USERS)
```

---

## 📑 Opis tabel

### 1️⃣ **ROLES** - Role użytkowników

| Kolumna | Typ | Opis |
|---------|-----|------|
| `role_id` | INT PK | ID roli (1, 2) |
| `role_name` | VARCHAR(50) | Nazwa roli (student, employee) |
| `description` | VARCHAR(255) | Opis roli |
| `is_active` | BIT | Status aktywności (1=aktywna) |

**Dane testowe:**
- 1 = student
- 2 = employee

---

### 2️⃣ **USERS** - Wszystkie użytkowniki (studenci + pracownicy)

| Kolumna | Typ | Opis |
|---------|-----|------|
| `user_id` | INT PK AI | ID użytkownika |
| `nick` | VARCHAR(50) UK | Login (unikalny) |
| `email` | VARCHAR(100) UK | Email (unikalny) |
| `email_verified` | BIT | Email zweryfikowany? |
| `password_hash` | VARCHAR(255) | Hash SHA2_256 hasła |
| `first_name` | VARCHAR(50) | Imię |
| `last_name` | VARCHAR(50) | Nazwisko |
| `birth_date` | DATE | Data urodzenia |
| `pesel` | VARCHAR(11) | PESEL (studenci) |
| `address` | VARCHAR(255) | Adres |
| `role_id` | INT FK | Rola użytkownika |
| `is_active` | BIT | Czy aktywny |
| `last_login` | DATETIME | Data ostatniego logowania |
| `created_at` | DATETIME | Data utworzenia |

**FK:** `role_id` → `ROLES.role_id`

---

### 3️⃣ **STUDENTS** - Dane studenta

| Kolumna | Typ | Opis |
|---------|-----|------|
| `student_id` | INT PK AI | ID studenta |
| `nick` | VARCHAR(50) FK UK | Login studenta |
| `lab_group_id` | INT FK | Grupa laboratoryjna |
| `index_number` | VARCHAR(20) UK | Numer indeksu |
| `bank_account` | VARCHAR(28) | IBAN bez spacji |
| `is_active` | BIT | Czy aktywny |

**FK:** 
- `nick` → `USERS.nick`
- `lab_group_id` → `GROUPS.group_id`

---

### 4️⃣ **EMPLOYEES** - Dane pracownika

| Kolumna | Typ | Opis |
|---------|-----|------|
| `employee_id` | INT PK AI | ID pracownika |
| `nick` | VARCHAR(50) FK UK | Login pracownika |
| `email` | VARCHAR(100) | Email pracownika |
| `email_verified` | BIT | Email zweryfikowany? |
| `password_hash` | VARCHAR(255) | Hash hasła |
| `first_name` | VARCHAR(50) | Imię |
| `last_name` | VARCHAR(50) | Nazwisko |
| `hire_date` | DATE | Data zatrudnienia |
| `role_id` | INT FK | Rola (employee) |
| `is_active` | BIT | Czy aktywny |
| `last_login` | DATETIME | Data ostatniego logowania |

**FK:** `role_id` → `ROLES.role_id`

---

### 5️⃣ **LECTURERS** - Wykładowcy (rozszerzenie EMPLOYEES)

| Kolumna | Typ | Opis |
|---------|-----|------|
| `lecturer_id` | INT PK AI | ID wykładowcy |
| `employee_id` | INT FK UK | ID pracownika |
| `academic_position` | VARCHAR(50) | Stanowisko (Dr, Prof) |
| `department_id` | INT FK | Wydział |

**FK:**
- `employee_id` → `EMPLOYEES.employee_id`
- `department_id` → `DEPARTMENTS.department_id`

---

### 6️⃣ **DEPARTMENTS** - Wydziały

| Kolumna | Typ | Opis |
|---------|-----|------|
| `department_id` | INT PK AI | ID wydziału |
| `department_name` | VARCHAR(100) UK | Nazwa wydziału |
| `description` | VARCHAR(255) | Opis |
| `is_active` | BIT | Czy aktywny |

**Dane testowe:**
- 1 = Informatyka
- 2 = Matematyka

---

### 7️⃣ **GROUPS** - Grupy laboratoryjna

| Kolumna | Typ | Opis |
|---------|-----|------|
| `group_id` | INT PK AI | ID grupy |
| `group_name` | VARCHAR(100) UK | Nazwa grupy |
| `max_students` | INT | Maks liczba studentów |
| `is_active` | BIT | Czy aktywna |

---

### 8️⃣ **MODULES** - Przedmioty/Kursy

| Kolumna | Typ | Opis |
|---------|-----|------|
| `module_id` | INT PK AI | ID modułu |
| `module_name` | VARCHAR(100) | Nazwa przedmiotu |
| `hours` | INT | Liczba godzin |
| `ects_credits` | INT | Punkty ECTS |
| `lecturer_id` | INT FK | Prowadzący |
| `department_id` | INT FK | Wydział |
| `description` | VARCHAR(500) | Opis |
| `is_active` | BIT | Czy aktywny |

**FK:**
- `lecturer_id` → `LECTURERS.lecturer_id`
- `department_id` → `DEPARTMENTS.department_id`

---

### 9️⃣ **ACADEMIC_YEARS** - Lata akademickie

| Kolumna | Typ | Opis |
|---------|-----|------|
| `year_id` | INT PK AI | ID roku |
| `year_name` | VARCHAR(20) UK | Nazwa (np. 2024/2025) |
| `start_date` | DATE | Data początkowa |
| `end_date` | DATE | Data końcowa |
| `is_current` | BIT | Czy bieżący rok |

---

### 🔟 **GROUP_MODULES** - Przypisanie grup do przedmiotów

| Kolumna | Typ | Opis |
|---------|-----|------|
| `group_module_id` | INT PK AI | ID |
| `group_id` | INT FK | ID grupy |
| `module_id` | INT FK | ID modułu |
| `exam_date` | DATE | Data egzaminu |

**FK:**
- `group_id` → `GROUPS.group_id`
- `module_id` → `MODULES.module_id`

**Constraints:** UNIQUE(group_id, module_id)

---

### 1️⃣1️⃣ **MODULE_INSTANCES** - Konkretne zajęcia

| Kolumna | Typ | Opis |
|---------|-----|------|
| `instance_id` | INT PK AI | ID instancji |
| `module_id` | INT FK | ID przedmiotu |
| `year_id` | INT FK | Rok akademicki |
| `topic` | VARCHAR(200) | Temat zajęć |
| `start_datetime` | DATETIME | Data/czas rozpoczęcia |
| `end_datetime` | DATETIME | Data/czas zakończenia |
| `room_no` | VARCHAR(20) | Nr sali |
| `description` | VARCHAR(500) | Opis |
| `required_materials` | VARCHAR(255) | Wymagane materiały |
| `is_active` | BIT | Czy aktywne |

**FK:**
- `module_id` → `MODULES.module_id`
- `year_id` → `ACADEMIC_YEARS.year_id`

---

### 1️⃣2️⃣ **STUDENTS_MODULE_INSTANCES** - Frekwencja

| Kolumna | Typ | Opis |
|---------|-----|------|
| `attendance_id` | INT PK AI | ID rekordu |
| `student_id` | INT FK | ID studenta |
| `instance_id` | INT FK | ID zajęć |
| `attended` | BIT | Czy obecny (1=tak, 0=nie) |

**FK:**
- `student_id` → `STUDENTS.student_id`
- `instance_id` → `MODULE_INSTANCES.instance_id`

**Constraints:** UNIQUE(student_id, instance_id)

---

### 1️⃣3️⃣ **GRADES** - Skale ocen

| Kolumna | Typ | Opis |
|---------|-----|------|
| `grade_id` | INT PK AI | ID oceny |
| `grade_value` | DECIMAL(3,1) | Wartość (2.0-5.5) |
| `grade_name` | VARCHAR(50) | Nazwa (Niedostateczny...) |
| `is_active` | BIT | Czy aktywna |

**Dane testowe:**
```
2.0 = Niedostateczny
3.0 = Dostateczny
3.5 = Dostateczny Plus
4.0 = Dobry
4.5 = Dobry Plus
5.0 = Bardzo dobry
5.5 = Bardzo dobry Plus
```

---

### 1️⃣4️⃣ **GRADE_TYPES** - Typy ocen

| Kolumna | Typ | Opis |
|---------|-----|------|
| `grade_type_id` | INT PK AI | ID typu |
| `grade_type_name` | VARCHAR(50) | Nazwa (egzamin, zaliczenie...) |
| `description` | VARCHAR(255) | Opis |
| `is_active` | BIT | Czy aktywny |

---

### 1️⃣5️⃣ **STUDENT_GRADES** - Oceny studenta

| Kolumna | Typ | Opis |
|---------|-----|------|
| `grade_record_id` | INT PK AI | ID rekordu |
| `student_id` | INT FK | ID studenta |
| `module_id` | INT FK | ID przedmiotu |
| `grade_id` | INT FK | ID oceny |
| `grade_type_id` | INT FK | Typ oceny |
| `lecturer_id` | INT FK | Wykładowca |
| `year_id` | INT FK | Rok akademicki |
| `grade_date` | DATE | Data oceny |
| `comment` | VARCHAR(500) | Komentarz |

**FK:**
- `student_id` → `STUDENTS.student_id`
- `module_id` → `MODULES.module_id`
- `grade_id` → `GRADES.grade_id`
- `grade_type_id` → `GRADE_TYPES.grade_type_id`
- `lecturer_id` → `LECTURERS.lecturer_id`
- `year_id` → `ACADEMIC_YEARS.year_id`

---

### 1️⃣6️⃣ **TUITIONS** - Płatności czesnego

| Kolumna | Typ | Opis |
|---------|-----|------|
| `tuition_id` | INT PK AI | ID płatności |
| `student_id` | INT FK | ID studenta |
| `amount` | DECIMAL(10,2) | Kwota (PLN) |
| `payment_date` | DATE | Data płatności |
| `due_date` | DATE | Termin płatności |
| `year_id` | INT FK | Rok akademicki |
| `is_paid` | BIT | Czy opłacone |

**FK:**
- `student_id` → `STUDENTS.student_id`
- `year_id` → `ACADEMIC_YEARS.year_id`

---

### 1️⃣7️⃣ **SYLLABUSES** - Sylabusy przedmiotów

| Kolumna | Typ | Opis |
|---------|-----|------|
| `syllabus_id` | INT PK AI | ID sylabusa |
| `module_id` | INT FK | ID przedmiotu |
| `year_id` | INT FK | Rok akademicki |
| `content` | VARCHAR(MAX) | Zawartość kursu |
| `learning_outcomes` | VARCHAR(MAX) | Efekty uczenia się |
| `grading_criteria` | VARCHAR(500) | Kryteria oceniania |
| `required_readings` | VARCHAR(500) | Wymagana literatura |
| `file_path` | VARCHAR(255) | Ścieżka do pliku PDF |

**FK:**
- `module_id` → `MODULES.module_id`
- `year_id` → `ACADEMIC_YEARS.year_id`

---

### 1️⃣8️⃣ **ANNOUNCEMENTS** - Ogłoszenia dla studentów

| Kolumna | Typ | Opis |
|---------|-----|------|
| `announcement_id` | INT PK AI | ID ogłoszenia |
| `title` | VARCHAR(200) | Tytuł |
| `content` | VARCHAR(MAX) | Zawartość |
| `created_by` | INT FK | ID autora (USERS) |
| `target_group_id` | INT FK | Grupa docelowa |
| `is_active` | BIT | Czy aktywne |
| `priority` | INT | Priorytet (1=wysoki) |
| `created_at` | DATETIME | Data utworzenia |

**FK:**
- `created_by` → `USERS.user_id`
- `target_group_id` → `GROUPS.group_id` (NULL=wszyscy)

---

## 🔑 Indeksy

### Indeksy PRIMARY KEY (automatyczne)
```sql
PK_USERS (user_id)
PK_STUDENTS (student_id)
PK_EMPLOYEES (employee_id)
PK_MODULES (module_id)
... itd
```

### Indeksy UNIQUE
```sql
UQ_USERS_nick          → USERS.nick
UQ_USERS_email         → USERS.email
UQ_STUDENTS_nick       → STUDENTS.nick
UQ_STUDENTS_index      → STUDENTS.index_number
UQ_GROUPS_name         → GROUPS.group_name
UQ_MODULE_name         → MODULES.module_name
UQ_ACADEMIC_YEARS_name → ACADEMIC_YEARS.year_name
```

### Indeksy dla Foreign Keys
```sql
IX_USERS_role_id
IX_STUDENTS_group_id
IX_EMPLOYEES_role_id
IX_LECTURERS_dept_id
IX_MODULES_lecturer_id
IX_MODULES_department_id
IX_MODULE_INSTANCES_year_id
IX_STUDENT_GRADES_year_id
IX_TUITIONS_year_id
IX_ANNOUNCEMENTS_group_id
```

### Indeksy dla wydajności
```sql
IX_STUDENT_GRADES_student_id    -- Szybkie wyszukiwanie ocen
IX_STUDENT_GRADES_module_id     -- Szybkie wyszukiwanie ocen po przedmiocie
IX_TUITIONS_student_id          -- Szybkie wyszukiwanie płatności
IX_MODULE_INSTANCES_module_id   -- Szybkie wyszukiwanie zajęć
IX_STUDENTS_MODULE_student_id   -- Szybkie wyszukiwanie frekwencji
```

---

## ⚡ Triggery

### 1. **trg_audit_users_changes**
- **Event:** AFTER INSERT, UPDATE, DELETE on USERS
- **Action:** Loguje zmiany do tabeli AUDIT_LOG
- **Powód:** Bezpieczeństwo - śledzenie modyfikacji użytkowników

### 2. **trg_check_grade_value**
- **Event:** BEFORE INSERT, UPDATE on STUDENT_GRADES
- **Action:** Waliduje czy grade_value jest w zakresie 2.0-5.5
- **Powód:** Integralność danych

### 3. **trg_tuition_payment_update**
- **Event:** AFTER UPDATE on TUITIONS
- **Action:** Aktualizuje is_paid jeśli payment_date != NULL
- **Powód:** Automatyzacja statusu

---

## 🔐 Constraints

### PRIMARY KEYS
```sql
PK_USERS, PK_STUDENTS, PK_EMPLOYEES, ... (18 tabel)
```

### FOREIGN KEYS
```sql
FK_STUDENTS_USERS           (nick → USERS.nick)
FK_STUDENTS_GROUPS          (lab_group_id → GROUPS.group_id)
FK_LECTURERS_EMPLOYEES      (employee_id → EMPLOYEES.employee_id)
FK_LECTURERS_DEPARTMENTS    (department_id → DEPARTMENTS.department_id)
FK_MODULES_LECTURERS        (lecturer_id → LECTURERS.lecturer_id)
FK_MODULES_DEPARTMENTS      (department_id → DEPARTMENTS.department_id)
FK_GROUP_MODULES_GROUPS     (group_id → GROUPS.group_id)
FK_GROUP_MODULES_MODULES    (module_id → MODULES.module_id)
FK_MODULE_INSTANCES_MODULES (module_id → MODULES.module_id)
FK_MODULE_INSTANCES_YEARS   (year_id → ACADEMIC_YEARS.year_id)
FK_STUDENTS_MODULE_STUDENTS (student_id → STUDENTS.student_id)
FK_STUDENTS_MODULE_INSTANCES(instance_id → MODULE_INSTANCES.instance_id)
FK_STUDENT_GRADES_STUDENTS  (student_id → STUDENTS.student_id)
FK_STUDENT_GRADES_MODULES   (module_id → MODULES.module_id)
FK_STUDENT_GRADES_GRADES    (grade_id → GRADES.grade_id)
FK_STUDENT_GRADES_TYPES     (grade_type_id → GRADE_TYPES.grade_type_id)
FK_STUDENT_GRADES_LECTURERS (lecturer_id → LECTURERS.lecturer_id)
FK_STUDENT_GRADES_YEARS     (year_id → ACADEMIC_YEARS.year_id)
FK_TUITIONS_STUDENTS        (student_id → STUDENTS.student_id)
FK_TUITIONS_YEARS           (year_id → ACADEMIC_YEARS.year_id)
FK_SYLLABUSES_MODULES       (module_id → MODULES.module_id)
FK_SYLLABUSES_YEARS         (year_id → ACADEMIC_YEARS.year_id)
FK_ANNOUNCEMENTS_USERS      (created_by → USERS.user_id)
FK_ANNOUNCEMENTS_GROUPS     (target_group_id → GROUPS.group_id)
```

### UNIQUE CONSTRAINTS
```sql
UQ_USERS_nick
UQ_USERS_email
UQ_STUDENTS_nick
UQ_STUDENTS_index_number
UQ_GROUPS_group_name
UQ_MODULES_module_name
UQ_ACADEMIC_YEARS_year_name
UQ_GROUP_MODULES (group_id, module_id)
UQ_STUDENTS_MODULE (student_id, instance_id)
```

### CHECK CONSTRAINTS
```sql
CHK_GRADE_VALUE: grade_value BETWEEN 2.0 AND 5.5
CHK_ECTS_CREDITS: ects_credits > 0
CHK_HOURS: hours > 0
CHK_MAX_STUDENTS: max_students > 0
CHK_AMOUNT: amount > 0
```

---

## 📈 Statystyki

| Element | Liczba |
|---------|--------|
| Tabele | 18 |
| Primary Keys | 18 |
| Foreign Keys | 24 |
| Unique Constraints | 8 |
| Check Constraints | 5 |
| Indeksy | 20+ |
| Triggery | 3 |
| Views | 5 |

---

**Ostatnia aktualizacja:** 3 grudnia 2025
**Wersja:** 1.0.0

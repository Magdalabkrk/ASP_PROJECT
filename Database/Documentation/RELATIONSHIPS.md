# 🔗 RELATIONSHIPS.md - Relacje Między Tabelami

## 📋 Spis treści

1. [One-to-Many](#one-to-many)
2. [Many-to-Many](#many-to-many)
3. [Hierarchie](#hierarchie)
4. [Cascade Rules](#cascade-rules)
5. [Data Flow](#data-flow)

---

## 🔁 One-to-Many

Relacje jeden-do-wielu (1:N)

### 1. **ROLES → USERS** (1:N)
```
ROLES (1) ─────────── (N) USERS
└─ role_id (PK)      └─ role_id (FK)

Jeden typ roli może mieć wielu użytkowników
```

**Przykład:**
- ROLES.role_id = 1 (student)
- USERS.role_id = 1 (Jan, Maria, Piotr, Anna)

---

### 2. **USERS → STUDENTS** (1:N - Specjalizacja)
```
USERS (1) ─────────── (N) STUDENTS
└─ nick (PK)        └─ nick (FK)

Jeden użytkownik to jeden student
(relacja one-to-one w praktyce)
```

---

### 3. **USERS → EMPLOYEES** (1:N - Specjalizacja)
```
USERS (1) ─────────── (N) EMPLOYEES
└─ nick (PK)        └─ nick (FK)

Jeden użytkownik to jeden pracownik
(relacja one-to-one w praktyce)
```

---

### 4. **EMPLOYEES → LECTURERS** (1:N - Specjalizacja)
```
EMPLOYEES (1) ─────────── (N) LECTURERS
└─ employee_id (PK)     └─ employee_id (FK)

Jeden pracownik może być tylko jednym wykładowcą
(relacja one-to-one w praktyce)
```

---

### 5. **DEPARTMENTS → LECTURERS** (1:N)
```
DEPARTMENTS (1) ─────────── (N) LECTURERS
└─ department_id (PK)      └─ department_id (FK)

Jeden wydział ma wielu wykładowców
```

---

### 6. **DEPARTMENTS → MODULES** (1:N)
```
DEPARTMENTS (1) ─────────── (N) MODULES
└─ department_id (PK)      └─ department_id (FK)

Jeden wydział oferuje wiele przedmiotów
```

**Przykład:**
```
Informatyka (1)
  ├─ Matematyka dyskretna
  ├─ Algorytmy i struktury danych
  └─ Bazy danych

Matematyka (2)
  └─ Analiza matematyczna I
```

---

### 7. **LECTURERS → MODULES** (1:N)
```
LECTURERS (1) ─────────── (N) MODULES
└─ lecturer_id (PK)     └─ lecturer_id (FK)

Jeden wykładowca prowadzi wiele przedmiotów
```

---

### 8. **GROUPS → STUDENTS** (1:N)
```
GROUPS (1) ─────────── (N) STUDENTS
└─ group_id (PK)     └─ lab_group_id (FK)

Jedna grupa ma wielu studentów
(max do 25)
```

---

### 9. **ACADEMIC_YEARS → MODULES** (1:N)
```
ACADEMIC_YEARS (1) ─────────── (N) MODULES
└─ year_id (PK)              └─ year_id (FK)

Jeden rok akademicki zawiera wiele instancji przedmiotów
```

---

### 10. **ACADEMIC_YEARS → MODULE_INSTANCES** (1:N)
```
ACADEMIC_YEARS (1) ──────────────── (N) MODULE_INSTANCES
└─ year_id (PK)                  └─ year_id (FK)

Jeden rok akademicki ma wiele konkretnych zajęć
```

---

### 11. **ACADEMIC_YEARS → STUDENT_GRADES** (1:N)
```
ACADEMIC_YEARS (1) ──────────────── (N) STUDENT_GRADES
└─ year_id (PK)                  └─ year_id (FK)

Jeden rok akademicki zawiera wiele ocen
```

---

### 12. **ACADEMIC_YEARS → TUITIONS** (1:N)
```
ACADEMIC_YEARS (1) ──────────────── (N) TUITIONS
└─ year_id (PK)                  └─ year_id (FK)

Jeden rok akademicki zawiera wiele płatności czesnego
```

---

### 13. **MODULES → MODULE_INSTANCES** (1:N)
```
MODULES (1) ─────────────── (N) MODULE_INSTANCES
└─ module_id (PK)         └─ module_id (FK)

Jeden przedmiot ma wiele konkretnych zajęć
(w różnych dniach/godzinach)

Przykład: "Bazy danych" ma 8 instancji w tygodniu
```

---

### 14. **MODULES → STUDENT_GRADES** (1:N)
```
MODULES (1) ─────────────── (N) STUDENT_GRADES
└─ module_id (PK)         └─ module_id (FK)

Jeden przedmiot ma wiele ocen (od różnych studentów)
```

---

### 15. **MODULES → SYLLABUSES** (1:N)
```
MODULES (1) ─────────────── (N) SYLLABUSES
└─ module_id (PK)       └─ module_id (FK)

Jeden przedmiot ma sylabusy dla różnych lat akademickich
```

---

### 16. **GRADES → STUDENT_GRADES** (1:N)
```
GRADES (1) ─────────── (N) STUDENT_GRADES
└─ grade_id (PK)    └─ grade_id (FK)

Jedna ocena (np. 4.0) ma wiele przypisań studentom
```

---

### 17. **GRADE_TYPES → STUDENT_GRADES** (1:N)
```
GRADE_TYPES (1) ─────────── (N) STUDENT_GRADES
└─ grade_type_id (PK)     └─ grade_type_id (FK)

Jeden typ oceny ma wiele przypisań
(np. egzamin ma 50 ocen)
```

---

### 18. **LECTURERS → STUDENT_GRADES** (1:N)
```
LECTURERS (1) ─────────────── (N) STUDENT_GRADES
└─ lecturer_id (PK)       └─ lecturer_id (FK)

Jeden wykładowca wystawia wiele ocen
```

---

### 19. **STUDENTS → STUDENT_GRADES** (1:N)
```
STUDENTS (1) ─────────────── (N) STUDENT_GRADES
└─ student_id (PK)        └─ student_id (FK)

Jeden student ma wiele ocen (z różnych przedmiotów)
```

---

### 20. **STUDENTS → TUITIONS** (1:N)
```
STUDENTS (1) ─────────── (N) TUITIONS
└─ student_id (PK)    └─ student_id (FK)

Jeden student ma wiele płatności czesnego
(np. co miesiąc lub co semestr)
```

---

### 21. **STUDENTS → STUDENTS_MODULE_INSTANCES** (1:N)
```
STUDENTS (1) ─────────────────────── (N) STUDENTS_MODULE_INSTANCES
└─ student_id (PK)                 └─ student_id (FK)

Jeden student ma wiele rejestrów frekwencji
(jeden dla każdych zajęć, na które chodzi)
```

---

### 22. **MODULE_INSTANCES → STUDENTS_MODULE_INSTANCES** (1:N)
```
MODULE_INSTANCES (1) ─────────────── (N) STUDENTS_MODULE_INSTANCES
└─ instance_id (PK)              └─ instance_id (FK)

Jedna instancja zajęć ma wiele rejestrów frekwencji
(jeden dla każdego uczestniczącego studenta)
```

---

### 23. **USERS → ANNOUNCEMENTS** (1:N)
```
USERS (1) ─────────── (N) ANNOUNCEMENTS
└─ user_id (PK)    └─ created_by (FK)

Jeden użytkownik tworzy wiele ogłoszeń
```

---

### 24. **GROUPS → ANNOUNCEMENTS** (1:N)
```
GROUPS (1) ─────────── (N) ANNOUNCEMENTS
└─ group_id (PK)   └─ target_group_id (FK)

Jedno ogłoszenie kierowane do jednej grupy
```

---

## 🔀 Many-to-Many

Relacje wiele-do-wielu (N:M)

### 1. **GROUPS ↔ MODULES** (N:M via GROUP_MODULES)

```
GROUPS (N) ──┐
             ├─── GROUP_MODULES (Junction Table) ──┐
MODULES (M) ─┤                                      └─── MODULES
             │
             └─── MODULES (M)

Jedna grupa pracuje z wieloma przedmiotami
Jeden przedmiot prowadzony dla wielu grup
```

**Struktura:**
```
GROUP_MODULES (Junction Table)
├─ group_module_id (PK)
├─ group_id (FK) ─────────────────── GROUPS
├─ module_id (FK) ─────────────────── MODULES
└─ exam_date (DATE)
```

**Przykład:**
```
Grupa 1A pracuje z: Matematyka dyskretna, Algorytmy, Bazy danych
Grupa 2A pracuje z: Matematyka dyskretna, Algorytmy, Bazy danych
Grupa 2B pracuje z: Algorytmy, Analiza matematyczna
Grupa 3A pracuje z: Analiza matematyczna
```

**Constraint:** UNIQUE(group_id, module_id) - każda grupa nie może mieć tego samego przedmiotu dwa razy

---

### 2. **STUDENTS ↔ MODULE_INSTANCES** (N:M via STUDENTS_MODULE_INSTANCES)

```
STUDENTS (N) ──┐
               ├─── STUDENTS_MODULE_INSTANCES ──┐
MODULE_INSTANCES ─┤    (Attendance Table)       └─── MODULE_INSTANCES
               │
               └─── MODULE_INSTANCES (M)

Jeden student uczęszcza na wiele zajęć
Jedne zajęcia mają wielu studentów
```

**Struktura:**
```
STUDENTS_MODULE_INSTANCES (Junction Table)
├─ attendance_id (PK)
├─ student_id (FK) ────────────── STUDENTS
├─ instance_id (FK) ───────────── MODULE_INSTANCES
└─ attended (BIT)
```

**Przykład:**
```
Student 1 (Jan) uczęszcza na:
  - Matematyka dyskretna - temat "Logika" - 10:00
  - Matematyka dyskretna - temat "Kombinatoryka" - 12:00
  - Algorytmy - temat "Bubble Sort" - 14:00

Zajęcia "Logika" (10:00) mają:
  - Studenta 1 (Jan) - obecny
  - Studenta 2 (Maria) - nieobecna
  - Studenta 3 (Piotr) - obecny
```

**Constraint:** UNIQUE(student_id, instance_id) - student nie może być zarejestrowany dwa razy na te same zajęcia

---

## 🏛️ Hierarchie

### 1. Hierarchia użytkowników

```
                    USERS (top level)
                    /              \
              STUDENTS         EMPLOYEES
                              /    |    \
                    LECTURERS   HR  ADMIN
                    /
              MODULES (prowadzone przez)
```

### 2. Hierarchia akademicka

```
DEPARTMENTS
  ├─ LECTURERS (pracownicy wydziału)
  │   └─ MODULES (przedmioty prowadzone)
  │       ├─ ACADEMIC_YEARS (roczniki)
  │       │   ├─ MODULE_INSTANCES (konkretne zajęcia)
  │       │   │   └─ STUDENTS_MODULE_INSTANCES (frekwencja)
  │       │   ├─ STUDENT_GRADES (oceny)
  │       │   └─ SYLLABUSES (sylabusy)
  │       └─ GROUP_MODULES (grupy pracujące z przedmiotem)
  │           └─ GROUPS (grupy laboratoryjna)
  │               └─ STUDENTS (członkowie grupy)
```

### 3. Hierarchia finansowa

```
STUDENTS
  └─ TUITIONS
      └─ ACADEMIC_YEARS
```

---

## 🔄 Cascade Rules

Reguły kaskadowe dla FK

### DELETE Actions

| FK | DELETE Rule | Opis |
|---|---|---|
| USERS.role_id → ROLES | CASCADE? | Nie usuwaj roli jeśli są użytkownicy |
| STUDENTS.nick → USERS | CASCADE | Usuń studenta jeśli usunięty użytkownik |
| STUDENTS.lab_group_id → GROUPS | SET NULL? | Nie usuwaj grupy jeśli są studenci |
| MODULES.lecturer_id → LECTURERS | CASCADE | Nie usuwaj wykładowcy jeśli prowadzi przedmioty |
| MODULES.department_id → DEPARTMENTS | CASCADE | Nie usuwaj wydziału jeśli ma przedmioty |
| MODULE_INSTANCES.module_id → MODULES | CASCADE | Usuń zajęcia jeśli usunięty przedmiot |
| STUDENT_GRADES.student_id → STUDENTS | CASCADE | Usuń oceny jeśli usunięty student |
| TUITIONS.student_id → STUDENTS | CASCADE | Usuń płatności jeśli usunięty student |

---

## 🌊 Data Flow

### Przepływ danych: Od rejestracji do oceny

```
1. REGISTRATION (Rejestracja)
   └─ USERS (tworzenie konta)
      ├─ role_id = 1 (student)
      └─ STUDENTS (profil studenta)
         └─ lab_group_id = 1 (Grupa 1A)

2. ASSIGNMENT (Przypisanie do przedmiotów)
   └─ GROUP_MODULES (Grupa 1A dostaje przedmioty)
      ├─ module_id = 1 (Matematyka dyskretna)
      ├─ module_id = 2 (Algorytmy)
      └─ module_id = 3 (Bazy danych)

3. SCHEDULING (Planowanie zajęć)
   └─ MODULE_INSTANCES (konkretne zajęcia)
      ├─ Matematyka dyskretna - Poniedziałek 10:00
      ├─ Matematyka dyskretna - Środa 10:00
      ├─ Algorytmy - Wtorek 12:00
      └─ ... (itd)

4. ATTENDANCE (Frekwencja)
   └─ STUDENTS_MODULE_INSTANCES
      ├─ Student 1 na zajęciach - obecny ✓
      ├─ Student 2 na zajęciach - nieobecny ✗
      └─ Student 3 na zajęciach - obecny ✓

5. GRADING (Oceny)
   └─ STUDENT_GRADES
      ├─ Student 1 - Matematyka - 4.0 (Dobry)
      ├─ Student 2 - Matematyka - 3.0 (Dostateczny)
      └─ Student 3 - Matematyka - 5.0 (Bardzo dobry)

6. BILLING (Rozliczenie)
   └─ TUITIONS
      ├─ Student 1 - 2000 PLN - Opłacone ✓
      ├─ Student 2 - 2000 PLN - Zaległa ⚠️
      └─ Student 3 - 2000 PLN - Opłacone ✓

7. REPORTING (Raporty)
   └─ Views aggregujące dane
      ├─ vw_student_grades_summary
      ├─ vw_student_attendance
      └─ vw_student_tuition_status
```

---

## 📊 Macierz relacji

```
                USER  STUD  EMPL  LECT  DEPT  MODU  ACAD  GROU  INST  GMOD  STMI  GRAD  GRAT  SGRA  TUIT  SYLL  ANNO
USERS (USER)     -    1:1   1:1    -     -     -     -     -     -     -     -     -     -     1:N   -     -    1:N
STUDENTS (STUD)  1:1   -     -     -     -     -     -     N:1   -     -     1:N   -     -     1:N   1:N   -     -
EMPLOYEES (EMPL) 1:1   -     -     1:1   -     -     -     -     -     -     -     -     -     -     -     -     -
LECTURERS (LECT)  -    -     1:1   -     N:1   1:N   -     -     -     -     -     -     1:N   1:N   -     -     -
DEPARTMENTS(DEPT) -    -     -     1:N   -     1:N   -     -     -     -     -     -     -     -     -     -     -
MODULES (MODU)   -     -     -     N:1   N:1   -     -     N:M   1:N   N:M   -     1:N   -     1:N   -     1:N   -
ACAD_YEARS(ACAD) -     -     -     -     -     1:N   -     -     1:N   -     -     1:N   1:N   1:N   1:N   1:N   -
GROUPS (GROU)    -     1:N   -     -     -     N:M   -     -     -     N:M   -     -     -     -     -     -     1:N
INSTANCES(INST)  -     -     -     -     -     N:1   N:1   -     -     -     1:N   -     -     -     -     -     -
GMOD             -     -     -     -     -     N:M   -     N:M   -     -     -     -     -     -     -     -     -
STMI             -     N:M   -     -     -     -     -     -     N:M   -     -     -     -     -     -     -     -
GRADES           -     -     -     -     -     1:N   -     -     -     -     -     -     1:N   -     -     -     -
GRADE_TYPES      -     -     -     1:N   -     -     -     -     -     -     -     1:N   -     1:N   -     -     -
STUD_GRADES      -     1:N   -     1:N   -     1:N   1:N   -     -     -     -     N:1   N:1   -     -     -     -
TUITIONS         -     1:N   -     -     -     -     1:N   -     -     -     -     -     -     -     -     -     -
SYLLABUSES       -     -     -     -     -     1:N   1:N   -     -     -     -     -     -     -     -     -     -
ANNOUNCE         1:N   -     -     -     -     -     -     1:N   -     -     -     -     -     -     -     -     -
```

---

**Ostatnia aktualizacja:** 3 grudnia 2025
**Wersja:** 1.0.0

💡 **TIP:** Użyj tego dokumentu razem z SCHEMA.md aby zrozumieć całą architekturę bazy!

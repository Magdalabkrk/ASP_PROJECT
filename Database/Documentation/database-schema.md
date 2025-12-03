# Specyfikacja Bazy Danych – University Management System

**Wersja**: 1.0  
**Data utworzenia**: Grudzień 2025  
**Status**: Gotowa do implementacji  
**Baza danych**: SQL Server (T-SQL) / LocalDB  

---

## 📋 Spis treści

1. [Przegląd systemu](#przegląd-systemu)
2. [Architektura logiczna](#architektura-logiczna)
3. [Opis tabel](#opis-tabel)
4. [Relacje między tabelami](#relacje-między-tabelami)
5. [Triggery i walidacje](#triggery-i-walidacje)
6. [Indeksy optymalizacyjne](#indeksy-optymalizacyjne)
7. [Przepływy danych](#przepływy-danych)
8. [Scenariusze użycia](#scenariusze-użycia)

---

## 🎯 Przegląd systemu

### Cel
Kompleksowy system zarządzania uczelnią umożliwiający:
- Logowanie studentów i pracowników z rozróżnieniem ról
- Zarządzanie przedmiotami (modułami) i grupami
- Planowanie zajęć i harmonogramowanie
- Rejestrowanie obecności studentów
- Wystawianie i przechowywanie ocen
- Zarządzanie płatnościami czesnego
- Komunikację poprzez ogłoszenia
- Audyt zmian i historię zdarzeń

### Użytkownicy systemu
- **Student** – przeglądanie planu zajęć, ocen, harmonogramu płatności
- **Wykładowca (Lecturer)** – zarządzanie grupami, wystawianie ocen, publikowanie ogłoszeń
- **Pracownik administracyjny** – pełna kontrola nad systemem (przyszłe fazy)

---

## 🏗️ Architektura logiczna

```
┌──────────────────────────────────────────────────────────────┐
│                    SYSTEM ZARZĄDZANIA UCZELNIĄ                │
└──────────────────────────────────────────────────────────────┘

┌─────────────────────────────────┐
│    WARSTWA AUTENTYKACJI         │
├─────────────────────────────────┤
│ USERS (wszystcy użytkownicy)    │
│ ROLES (walidacja ról)           │
└─────────────────────────────────┘
         │
         ├─────────────────┬───────────────────┐
         │                 │                   │
    ┌────▼────┐      ┌─────▼──────┐    ┌──────▼────┐
    │ STUDENTS │      │ EMPLOYEES  │    │ LECTURERS │
    │ (1:1)    │      │ (1:1)      │    │ (1:1)     │
    └─────────┘      └────────────┘    └───────────┘
         │                                     │
         │                              1:N    │
         │ 1:N                                 │
         │                      ┌──────────────┘
    ┌────▼──────────┐           │
    │ GROUP_MODULES │◄──────────┤
    │ (N:M)         │      ┌─────▼──────┐
    └─────┬────────┘       │  MODULES   │
          │                │ (przedmioty)│
    ┌─────▼─────────┐      └────────────┘
    │ GROUPS        │
    │ (grupy lab)   │
    └───────────────┘

┌──────────────────────────────────────┐
│     WARSTWA AKADEMICKA               │
├──────────────────────────────────────┤
│ ACADEMIC_YEARS (lata akademickie)   │
│ MODULE_INSTANCES (spotkania zajęć)  │
│ STUDENTS_MODULE_INSTANCES (obecność)│
│ STUDENT_GRADES (oceny)              │
│ GRADE_TYPES (typ oceny)             │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│     WARSTWA ADMINISTRACYJNA          │
├──────────────────────────────────────┤
│ TUITIONS (płatności czesnego)       │
│ ANNOUNCEMENTS (ogłoszenia)          │
│ SYLLABUSES (syllabusy przedmiotów)  │
│ DEPARTMENTS (wydziały)               │
│ GRADES (tablica ocen - walidacja)   │
└──────────────────────────────────────┘
```

---

## 📊 Opis tabel

### Warstwa 1: AUTENTYKACJA I ROLE

#### **ROLES** (Tablica walidacyjna – role użytkowników)
```
Przeznaczenie: Słownik dozwolonych ról w systemie
Rekordy: 2 (student, employee)

Kolumny:
├─ role_id (INT, PK) – identyfikator roli
└─ role_name (VARCHAR 50, UNIQUE) – nazwa roli
```

**Dozwolone wartości**: `student`, `employee`

**Użycie**: Walidacja pola `role_id` w tabeli USERS

---

#### **USERS** (Tabela bazowa – wszyscy użytkownicy)
```
Przeznaczenie: Centralne przechowywanie danych logowania i profilu każdego użytkownika
Typ klucza: nick (VARCHAR) – klucz główny (zamiast INT)

Kolumny:
├─ nick (VARCHAR 50, PK) – login do systemu
├─ password_hash (VARCHAR 255) – hash hasła (PBKDF2 lub bcrypt)
├─ first_name (VARCHAR 50) – imię
├─ last_name (VARCHAR 50) – nazwisko
├─ address (VARCHAR 255) – adres zamieszkania
├─ pesel (VARCHAR 11) – numer PESEL
├─ birth_date (DATE) – data urodzenia
├─ email (VARCHAR 255, UNIQUE) – adres email
├─ email_verified (BIT, DEFAULT 0) – czy email zweryfikowany
├─ role_id (INT, FK → ROLES) – rola: student lub employee
├─ is_active (BIT, DEFAULT 1) – czy konto aktywne
├─ last_login (DATETIME) – ostatnie logowanie (dla audytu)
├─ created_at (DATETIME, DEFAULT GETDATE()) – data utworzenia
└─ updated_at (DATETIME, DEFAULT GETDATE()) – data ostatniej zmiany
```

**Constraints**:
- PK: nick
- FK: role_id → ROLES(role_id)
- UNIQUE: nick, email (nullable)
- INDEX: role_id, email

**Uwagi**:
- `nick` jest kluczem głównym, zamiast auto-increment INT
- `password_hash` zawiera zahashowane hasło (NIGDY nie przechowywać plaintext!)
- `email_verified` dla weryfikacji email (do wysyłania notyfikacji)
- `last_login` do audytu bezpieczeństwa
- `is_active` dla soft-delete (archiwizacji bez utraty danych)

---

### Warstwa 2: STUDENCI

#### **STUDENTS** (Dane studenta – rozszerzenie USERS)
```
Przeznaczenie: Szczegółowe dane studenta (1:1 z USERS)
Liczba rekordów: Liczba studentów

Kolumny:
├─ student_id (INT, PK, IDENTITY) – identyfikator studenta
├─ nick (VARCHAR 50, FK, UNIQUE) – powiązanie z USERS (1:1)
├─ study_start_date (DATE) – data rozpoczęcia studiów
├─ lab_group_id (INT, FK → GROUPS) – grupa laboratoryjna studenta
├─ bank_account (VARCHAR 34) – numer konta bankowego (IBAN)
├─ is_active (BIT, DEFAULT 1) – czy student aktywny (soft-delete)
├─ created_at (DATETIME, DEFAULT GETDATE()) – gdy dodano studenta
├─ updated_at (DATETIME, DEFAULT GETDATE()) – ostatnia modyfikacja
└─ archived_at (DATETIME, NULLABLE) – data archiwizacji (jeśli is_active=0)
```

**Constraints**:
- PK: student_id
- FK: nick → USERS(nick) [1:1]
- FK: lab_group_id → GROUPS(group_id)
- UNIQUE: nick (zapewnia relację 1:1)
- INDEX: nick, lab_group_id, is_active

**Trigger**: `tr_student_role_check`
```
Reguła: Uniemożliwić utworzenie rekordu w STUDENTS jeśli:
  USERS.role_id ≠ 'student'
Błąd: "Nie można utworzyć studenta dla użytkownika z rolą 'employee'"
```

**Uwagi**:
- Jeden student = jeden nick w USERS
- Każdy student przypisany do dokładnie jednej grupy laboratoryjnej
- `is_active` pozwala archiwizować studentów bez usuwania danych historycznych
- Bank account przechowuje IBAN dla zwrotów opłat

---

#### **TUITIONS** (Płatności czesnego)
```
Przeznaczenie: Rejestracja każdej płatności czesnego studenta
Liczba rekordów: Liczba płatności (miesięczne/semestralne)

Kolumny:
├─ tuition_id (INT, PK, IDENTITY) – unikalny numer płatności
├─ student_id (INT, FK → STUDENTS) – student płacący
├─ amount (DECIMAL 10,2) – kwota płatności
├─ payment_date (DATE, NULLABLE) – data rzeczywistej płatności (NULL jeśli nie zapłacił)
├─ due_date (DATE) – termin płatności
├─ year_id (INT, FK → ACADEMIC_YEARS) – rok akademicki
├─ is_paid (BIT, DEFAULT 0) – czy zapłacono
├─ created_at (DATETIME, DEFAULT GETDATE()) – data utworzenia płatności
└─ updated_at (DATETIME, DEFAULT GETDATE()) – ostatnia aktualizacja
```

**Constraints**:
- PK: tuition_id
- FK: student_id → STUDENTS(student_id)
- FK: year_id → ACADEMIC_YEARS(year_id)
- INDEX: student_id, year_id, is_paid, due_date

**Logika biznesowa**:
- Jeden wpis = jedna płatność (np. za styczeń 2024)
- `payment_date` = NULL oznacza niepłaconą płatność
- `is_paid` = 0 oznacza zaległość
- Studenci mogą mieć wiele płatności dla różnych lat akademickich

---

### Warstwa 3: PRACOWNICY I WYKŁADOWCY

#### **EMPLOYEES** (Pracownicy uczelni – rozszerzenie USERS)
```
Przeznaczenie: Szczegółowe dane pracownika (1:1 z USERS)
Liczba rekordów: Liczba pracowników (w tym wykładowcy)

Kolumny:
├─ employee_id (INT, PK, IDENTITY) – identyfikator pracownika
├─ nick (VARCHAR 50, FK, UNIQUE) – powiązanie z USERS (1:1)
├─ employment_start_date (DATE) – data zatrudnienia
├─ gross_salary (DECIMAL 10,2) – wynagrodzenie brutto
├─ created_at (DATETIME, DEFAULT GETDATE()) – data zatrudnienia
├─ updated_at (DATETIME, DEFAULT GETDATE()) – ostatnia modyfikacja
└─ is_active (BIT, DEFAULT 1) – czy pracownik aktywny
```

**Constraints**:
- PK: employee_id
- FK: nick → USERS(nick) [1:1]
- UNIQUE: nick
- INDEX: nick, is_active

**Trigger**: `tr_employee_role_check`
```
Reguła: Uniemożliwić utworzenie rekordu w EMPLOYEES jeśli:
  USERS.role_id ≠ 'employee'
Błąd: "Nie można utworzyć pracownika dla użytkownika z rolą 'student'"
```

**Uwagi**:
- Pracownik może być zwykłym adminem, sekretarką, lub wykładowcą
- Jeśli pracownik jest wykładowcą, będzie miał wpis w tabeli LECTURERS
- `is_active` dla soft-delete i archiwizacji

---

#### **LECTURERS** (Wykładowcy – specjalizacja EMPLOYEES)
```
Przeznaczenie: Dane specyficzne dla wykładowców
Liczba rekordów: Liczba wykładowców

Kolumny:
├─ lecturer_id (INT, PK, IDENTITY) – identyfikator wykładowcy
├─ employee_id (INT, FK, UNIQUE → EMPLOYEES) – powiązanie (1:1)
├─ academic_position (VARCHAR 50) – tytuł akademicki (Dr, Prof, Asystent, etc.)
├─ department_id (INT, FK, NULLABLE → DEPARTMENTS) – wydział
├─ created_at (DATETIME, DEFAULT GETDATE())
└─ updated_at (DATETIME, DEFAULT GETDATE())
```

**Constraints**:
- PK: lecturer_id
- FK: employee_id → EMPLOYEES(employee_id) [1:1]
- FK: department_id → DEPARTMENTS(department_id) [0:1]
- UNIQUE: employee_id
- INDEX: employee_id, department_id

**Uwagi**:
- Nie każdy pracownik jest wykładowcą (są tacy bez wpisu w LECTURERS)
- Wykładowca może pracować bez przypisania do konkretnego wydziału
- Tytuł akademicki: Dr, Prof, Asystent, Lektor, itp.

---

#### **DEPARTMENTS** (Tablica walidacyjna – wydziały)
```
Przeznaczenie: Słownik wydziałów/działów na uczelni
Rekordy: Zależy od struktury uczelni (np. 5-10)

Kolumny:
├─ department_id (INT, PK, IDENTITY) – identyfikator wydziału
├─ department_name (VARCHAR 100, UNIQUE) – nazwa wydziału
├─ building (VARCHAR 50, NULLABLE) – budynek (np. "A", "B")
├─ phone (VARCHAR 20, NULLABLE) – telefon do wydziału
├─ created_at (DATETIME, DEFAULT GETDATE())
└─ updated_at (DATETIME, DEFAULT GETDATE())
```

**Constraints**:
- PK: department_id
- UNIQUE: department_name
- INDEX: department_name

**Przykładowe rekordy**:
```
Informatyka, Matematyka, Fizyka, Filologia, Historia
```

---

### Warstwa 4: GRUPY I MODUŁY

#### **GROUPS** (Tablica walidacyjna – grupy laboratoryjne)
```
Przeznaczenie: Słownik grup laboratoryjnych (każdy student przypisany do jednej)
Liczba rekordów: Zależy od liczby studentów i wielkości grup (np. 20-50)

Kolumny:
├─ group_id (INT, PK, IDENTITY) – identyfikator grupy
├─ group_name (VARCHAR 100, UNIQUE) – nazwa grupy (np. "Grupa 1A", "Grupa 2B")
├─ max_students (INT, NULLABLE) – maksymalna liczba studentów w grupie
├─ created_at (DATETIME, DEFAULT GETDATE())
└─ updated_at (DATETIME, DEFAULT GETDATE())
```

**Constraints**:
- PK: group_id
- UNIQUE: group_name
- INDEX: group_name

**Uwagi**:
- Każdy student w STUDENTS.lab_group_id przypisany do dokładnie jednej grupy
- Grupy lab mogą być różnych typów (ćwiczeniowe, wykładowe, laboratoryjna, konwersatorium)
- `max_students` służy do kontroli czy grupa nie jest przepełniona

---

#### **MODULES** (Przedmioty/kursy)
```
Przeznaczenie: Katalog przedmiotów prowadzonych na uczelni
Liczba rekordów: Liczba przedmiotów (np. 50-200)

Kolumny:
├─ module_id (INT, PK, IDENTITY) – identyfikator modułu
├─ module_name (VARCHAR 100, UNIQUE) – nazwa przedmiotu
├─ hours (INT) – liczba godzin zajęć w semestrze
├─ ects_credits (INT, NULLABLE) – punkty ECTS
├─ lecturer_id (INT, FK → LECTURERS) – główny prowadzący
├─ department_id (INT, FK, NULLABLE → DEPARTMENTS) – wydział
├─ description (NVARCHAR MAX, NULLABLE) – opis przedmiotu
├─ is_active (BIT, DEFAULT 1) – czy moduł aktywny
├─ created_at (DATETIME, DEFAULT GETDATE())
└─ updated_at (DATETIME, DEFAULT GETDATE())
```

**Constraints**:
- PK: module_id
- FK: lecturer_id → LECTURERS(lecturer_id)
- FK: department_id → DEPARTMENTS(department_id)
- UNIQUE: module_name
- INDEX: lecturer_id, department_id, is_active

**Uwagi**:
- Jeden moduł ma jednego głównego prowadzącego (lecturka)
- Jeden moduł może mieć wiele instancji (MODULE_INSTANCES)
- `ects_credits` – punkty ECTS na moduł

---

#### **GROUP_MODULES** (Przypisanie grup do modułów – relacja N:M)
```
Przeznaczenie: Określenie które grupy mają dany moduł
Liczba rekordów: Liczba przypisań (grupy × moduły)

Kolumny:
├─ group_module_id (INT, PK, IDENTITY) – identyfikator przypisania
├─ group_id (INT, FK → GROUPS) – grupa
├─ module_id (INT, FK → MODULES) – moduł
├─ exam_date (DATE, NULLABLE) – data zaplanowanego egzaminu
├─ created_at (DATETIME, DEFAULT GETDATE())
└─ updated_at (DATETIME, DEFAULT GETDATE())
```

**Constraints**:
- PK: group_module_id
- FK: group_id → GROUPS(group_id)
- FK: module_id → MODULES(module_id)
- UNIQUE: (group_id, module_id) – grupa nie może być 2× przypisana do modułu
- INDEX: group_id, module_id

**Logika biznesowa**:
```
Student (grupa 1) → GROUP_MODULES → Module "Matematyka"
↓
Student widzi "Matematyka" na swojej liście przedmiotów
```

**Uwagi**:
- Studenci z grupy mają dostęp do modułu poprzez to przypisanie
- `exam_date` – data zaliczenia/egzaminu dla całej grupy

---

### Warstwa 5: AKADEMICKA (Lata, Zajęcia, Oceny)

#### **ACADEMIC_YEARS** (Lata akademickie)
```
Przeznaczenie: Definiowanie okresów akademickich (semestrów, lat)
Liczba rekordów: 1 na rok akademicki (np. "2023/2024")

Kolumny:
├─ year_id (INT, PK, IDENTITY) – identyfikator roku akademickiego
├─ year_name (VARCHAR 20, UNIQUE) – nazwa (np. "2023/2024")
├─ start_date (DATE) – data początku roku akademickiego
├─ end_date (DATE) – data końca roku akademickiego
├─ is_current (BIT, DEFAULT 1) – czy bieżący rok akademicki
├─ created_at (DATETIME, DEFAULT GETDATE())
└─ updated_at (DATETIME, DEFAULT GETDATE())
```

**Constraints**:
- PK: year_id
- UNIQUE: year_name
- INDEX: is_current

**Przykładowe rekordy**:
```
year_name: "2023/2024", start_date: "2023-10-01", end_date: "2024-09-30"
year_name: "2024/2025", start_date: "2024-10-01", end_date: "2025-09-30"
```

**Uwagi**:
- Pozwala śledzić oceny i harmonogramy w kontekście roku akademickiego
- `is_current` wskazuje bieżący rok (dla szybkiego wyszukiwania)

---

#### **MODULE_INSTANCES** (Konkretne spotkania zajęciowe)
```
Przeznaczenie: Konkretne spotkania danego przedmiotu (np. 15 spotkań z Matematyki)
Liczba rekordów: Liczba spotkań (duża – wszystkie zajęcia)

Kolumny:
├─ instance_id (INT, PK, IDENTITY) – unikalny ID zajęć
├─ module_id (INT, FK → MODULES) – który przedmiot
├─ year_id (INT, FK → ACADEMIC_YEARS) – rok akademicki
├─ topic (VARCHAR 255) – temat zajęć (np. "Logika i teoria zbiorów")
├─ start_datetime (DATETIME) – data/godzina rozpoczęcia
├─ end_datetime (DATETIME) – data/godzina zakończenia
├─ room_no (VARCHAR 20) – numer sali
├─ description (NVARCHAR MAX, NULLABLE) – szczegółowy opis
├─ required_materials (VARCHAR 500, NULLABLE) – materiały do przyniesienia
├─ is_active (BIT, DEFAULT 1) – czy zajęcia odbywają się
├─ created_at (DATETIME, DEFAULT GETDATE())
└─ updated_at (DATETIME, DEFAULT GETDATE())
```

**Constraints**:
- PK: instance_id
- FK: module_id → MODULES(module_id)
- FK: year_id → ACADEMIC_YEARS(year_id)
- INDEX: module_id, year_id, start_datetime, room_no

**Logika biznesowa**:
```
Module "Matematyka" (30 godzin) posiada ~15 MODULE_INSTANCES
Każda instancja trwa ~2 godziny (jedna lekcja)
```

**Uwagi**:
- Separacja "przedmiotu" (MODULES) od "konkretnego spotkania" (MODULE_INSTANCES)
- `description` – co się będzie robić na zajęciach
- `required_materials` – przygotowanie studenta

---

#### **GRADES** (Tablica walidacyjna – skala ocen)
```
Przeznaczenie: Słownik dozwolonych ocen
Rekordy: 7 (polska skala ocen)

Kolumny:
├─ grade_id (INT, PK, IDENTITY) – identyfikator oceny
└─ grade_value (DECIMAL 3,1, UNIQUE) – wartość (2.0, 2.5, 3.0, ...)
```

**Dozwolone wartości**:
```
2.0 (niedostateczna)
2.5
3.0 (dostateczna)
3.5
4.0 (dobra)
4.5
5.0 (bardzo dobra)
```

**Constraints**:
- PK: grade_id
- UNIQUE: grade_value

---

#### **GRADE_TYPES** (Tablica walidacyjna – typy ocen)
```
Przeznaczenie: Rodzaj oceny (egzamin, zaliczenie, kolokwium, itp.)
Rekordy: 4-5

Kolumny:
├─ grade_type_id (INT, PK, IDENTITY) – identyfikator typu
└─ grade_type_name (VARCHAR 50, UNIQUE) – nazwa typu
```

**Dozwolone wartości**:
```
egzamin (egzamin końcowy)
zaliczenie (zaliczenie przedmiotu)
kolokwium (sprawdzian cząstkowy)
aktywność (ocena za aktywność na zajęciach)
```

**Constraints**:
- PK: grade_type_id
- UNIQUE: grade_type_name

---

#### **STUDENT_GRADES** (Oceny studentów)
```
Przeznaczenie: Przechowywanie wszystkich ocen studenta
Liczba rekordów: Liczba ocen (każdy student × każdy przedmiot × kilka ocen)

Kolumny:
├─ student_grade_id (INT, PK, IDENTITY) – unikalny ID oceny
├─ student_id (INT, FK → STUDENTS) – student
├─ module_id (INT, FK → MODULES) – przedmiot
├─ grade_id (INT, FK → GRADES) – wartość oceny
├─ grade_type_id (INT, FK → GRADE_TYPES) – typ oceny (egzamin/zaliczenie)
├─ lecturer_id (INT, FK → LECTURERS) – kto wystawił ocenę
├─ year_id (INT, FK → ACADEMIC_YEARS) – rok akademicki
├─ grade_date (DATE) – kiedy wstawiono ocenę
├─ comment (VARCHAR 255, NULLABLE) – komentarz do oceny
├─ created_at (DATETIME, DEFAULT GETDATE()) – timestamp utworzenia
└─ updated_at (DATETIME, DEFAULT GETDATE()) – timestamp modyfikacji
```

**Constraints**:
- PK: student_grade_id
- FK: student_id → STUDENTS(student_id)
- FK: module_id → MODULES(module_id)
- FK: grade_id → GRADES(grade_id)
- FK: grade_type_id → GRADE_TYPES(grade_type_id)
- FK: lecturer_id → LECTURERS(lecturer_id)
- FK: year_id → ACADEMIC_YEARS(year_id)
- INDEX: student_id, module_id, year_id, grade_type_id

**Trigger**: `tr_student_grades_validation`
```
Reguła: Uniemożliwić wstawienie oceny jeśli:
  Student NIE jest przypisany do modułu poprzez swoją grupę
Logika:
  SELECT * FROM STUDENTS s
  INNER JOIN GROUP_MODULES gm ON s.lab_group_id = gm.group_id
  WHERE s.student_id = @student_id AND gm.module_id = @module_id
  
  Jeśli brak rekordu → RAISERROR
Błąd: "Student nie ma dostępu do tego modułu"
```

**Uwagi**:
- Przechowuje kompletną historię ocen
- `created_at` i `updated_at` pozwala śledzić kiedy zmieniono ocenę
- Każda ocena ma przypisanego wykładowcę (kto ją wystawił)
- `comment` – np. "Poprawiał na egzaminie"

---

#### **STUDENTS_MODULE_INSTANCES** (Rejestracja obecności)
```
Przeznaczenie: Śledzenie uczestnictwa studentów w konkretnych zajęciach
Liczba rekordów: Liczba obecności (bardzo duża)

Kolumny:
├─ attendance_id (INT, PK, IDENTITY) – unikalny ID rejestracji
├─ student_id (INT, FK → STUDENTS) – student
├─ instance_id (INT, FK → MODULE_INSTANCES) – konkretne zajęcia
├─ attended (BIT, DEFAULT 0) – czy był obecny (1=tak, 0=nie)
├─ created_at (DATETIME, DEFAULT GETDATE()) – kiedy dodano
└─ updated_at (DATETIME, DEFAULT GETDATE()) – ostatnia zmiana
```

**Constraints**:
- PK: attendance_id
- FK: student_id → STUDENTS(student_id)
- FK: instance_id → MODULE_INSTANCES(instance_id)
- UNIQUE: (student_id, instance_id) – student nie może być 2× na tej samej lekcji
- INDEX: student_id, instance_id, attended

**Logika biznesowa**:
```
Jeśli student_id=1 jest w GROUP_MODULES z module_id=5
→ dodaj attendance record dla każdej MODULE_INSTANCES gdzie module_id=5
→ Wykładowca zaznacza był/nie był (attended=1/0)
```

**Uwagi**:
- Jeden wpis = jeden student na jednych zajęciach
- `attended=1` → obecny, `attended=0` → nieobecny
- Umożliwia śledzenie frekwencji

---

### Warstwa 6: KOMUNIKACJA I DOKUMENTY

#### **ANNOUNCEMENTS** (Ogłoszenia szkolne)
```
Przeznaczenie: System komunikacji – ogłoszenia dla studentów
Liczba rekordów: Zależy od aktywności (mogą być dziesiątki dziennie)

Kolumny:
├─ announcement_id (INT, PK, IDENTITY) – unikalny ID ogłoszenia
├─ title (NVARCHAR 255) – tytuł ogłoszenia
├─ content (NVARCHAR MAX) – treść (może być długa)
├─ created_by (INT, FK → LECTURERS) – kto opublikował
├─ created_at (DATETIME, DEFAULT GETDATE()) – kiedy opublikowano
├─ updated_at (DATETIME, DEFAULT GETDATE()) – ostatnia edycja
├─ target_group_id (INT, FK, NULLABLE → GROUPS) – dla której grupy
├─ is_active (BIT, DEFAULT 1) – czy widoczne
└─ priority (INT, DEFAULT 0) – priorytet (0=normalny, 1=ważne, 2=pilne)
```

**Constraints**:
- PK: announcement_id
- FK: created_by → LECTURERS(lecturer_id)
- FK: target_group_id → GROUPS(group_id)
- INDEX: target_group_id, created_at, is_active

**Logika biznesowa**:
```
Jeśli target_group_id = NULL → ogłoszenie globalne (dla wszystkich)
Jeśli target_group_id = 1 → ogłoszenie tylko dla grupy 1

Student widzi ogłoszenia gdzie:
  target_group_id = sua_grupa OR target_group_id = NULL
```

**Uwagi**:
- `created_by` – żaden pracownik nie może publikować (tylko LECTURERS)
- `is_active=0` – soft-delete, archiwizacja ogłoszenia

---

#### **SYLLABUSES** (Syllabusy przedmiotów)
```
Przeznaczenie: Dokumentacja przedmiotu – czego będą się uczyć studenci
Liczba rekordów: Liczba przedmiotów × liczba lat akademickich

Kolumny:
├─ syllabus_id (INT, PK, IDENTITY) – identyfikator sylabusa
├─ module_id (INT, FK → MODULES) – przedmiot
├─ year_id (INT, FK → ACADEMIC_YEARS) – rok akademicki
├─ content (NVARCHAR MAX) – zagadnienia/tematy
├─ learning_outcomes (NVARCHAR MAX) – efekty kształcenia
├─ grading_criteria (NVARCHAR MAX) – kryteria oceny
├─ required_readings (NVARCHAR MAX) – obowiązkowe lektury
├─ file_path (VARCHAR 255, NULLABLE) – ścieżka do PDF/DOC
├─ created_at (DATETIME, DEFAULT GETDATE())
└─ updated_at (DATETIME, DEFAULT GETDATE())
```

**Constraints**:
- PK: syllabus_id
- FK: module_id → MODULES(module_id)
- FK: year_id → ACADEMIC_YEARS(year_id)
- UNIQUE: (module_id, year_id) – jeden syllabus na rok
- INDEX: module_id, year_id

**Uwagi**:
- Syllabus może się zmieniać każdy rok akademicki
- `file_path` – przechowuje link do dokumentu PDF/DOC
- Studenci mogą przeglądać syllabus każdego przedmiotu
- Wykładowca zarządza sylabusem

---

## 🔗 Relacje między tabelami

### Mapa powiązań (1:N, N:M, 1:1)

```
┌─────────────┐
│   ROLES     │◄──────────────┐
└─────────────┘               │1
      ▲                       │
      │ 1:N                   │ FK
      │                       │
      │                   ┌───────┐
      │                   │ USERS │ (tabela centralna)
      │                   └───────┘
      │                       │
   FK │                   N:1 │ (każdy user ma rolę)
      │                       │
      │     ┌─────────────────┼──────────────────┬──────────────────┐
      │     │                 │                  │                  │
      │ 1:1 │             1:1 │              1:1 │              1:1 │
      │     ▼                 ▼                  ▼                  ▼
  ┌────────────────┐  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐
  │ (Validation)   │  │  STUDENTS   │  │  EMPLOYEES   │  │  (Future)   │
  └────────────────┘  └─────────────┘  └──────────────┘  └─────────────┘
                            │                    │
                        1:N │                1:1 │
                            │                    │
                      ┌─────▼────────┐      ┌────▼───────────┐
                      │  TUITIONS    │      │   LECTURERS    │
                      └──────────────┘      └────┬───────────┘
                                                 │
                                             1:N │
                                                 │
                                           ┌─────▼─────────┐
                                           │   MODULES     │
                                           └─────┬─────────┘
                                                 │
                                             1:N │
                                                 │
                    ┌────────────────────────────┼────────────────────────┐
                    │                            │                        │
                N:M │                    GROUP_MODULES              1:N   │
                    │                   (junction table)                  │
                    ▼                            │                        ▼
            ┌──────────────┐              ┌──────▼──────┐      ┌─────────────────┐
            │   GROUPS     │              │  (join)     │      │ MODULE_INSTANCES│
            └──────────────┘              └─────────────┘      └────────┬────────┘
                    ▲                                                    │
                    │                                              1:N   │
                    │ FK (lab_group_id)                                  │
                    │                                           ┌────────▼─────────┐
                    │                       ┌─────────────────►│ STUDENTS_MODULE_ │
              ┌─────┴──────┐                │                  │    INSTANCES     │
              │ STUDENTS   │────────────────┴──────────────────┴──────────┬───────┘
              └────────────┘ (N:1)                             (junction)
                    │
                    │ 1:N
                    │
              ┌─────▼──────────┐
              │ STUDENT_GRADES │
              └────────────────┘

Dodatkowo:
┌────────────┐     ┌──────────────┐     ┌─────────────┐
│  GRADES    │────►│ STUDENT_    │◄────│ GRADE_      │
│(validation)│  1:N│ GRADES      │  N:1│ TYPES       │
└────────────┘     └──────────────┘     │(validation) │
                                        └─────────────┘

┌─────────────┐                  ┌──────────────────┐
│ DEPARTMENTS │◄───────────┬─────│ ANNOUNCEMENTS    │
│(validation) │         N:1│     │ (komunikacja)    │
└─────────────┘            │     └──────────────────┘
      ▲                    │
      │ FK                 │ FK (created_by)
      │                    │
   1:N│              ┌─────┴──────┐
      │              │ LECTURERS  │
      └──────────────┤(employee)  │
                     └────────────┘

┌──────────────────┐
│ ACADEMIC_YEARS   │ (przechowuje rok akademicki – używana w:)
│ (validation)     │  - MODULE_INSTANCES.year_id
└──────────────────┘  - STUDENT_GRADES.year_id
                      - TUITIONS.year_id
                      - SYLLABUSES.year_id

┌──────────────────┐
│ SYLLABUSES       │ (dokumentacja przedmiotów)
│ (komunikacja)    │
└──────────────────┘
```

---

## 🔧 Triggery i walidacje

### Trigger 1: Walidacja roli dla STUDENTS

**Nazwa**: `tr_student_role_check`

**Kiedy się uruchamia**: Przed INSERT do tabeli STUDENTS

**Logika**:
```sql
IF (student.nick zalogowany w USERS ma role_id ≠ 'student')
  THEN RAISERROR('Nie można utworzyć studenta dla użytkownika z rolą employee')
  ELSE INSERT normalnie
```

**Cel**: Uniemożliwić przypadkowe przypisanie pracownika do tabeli studentów

---

### Trigger 2: Walidacja roli dla EMPLOYEES

**Nazwa**: `tr_employee_role_check`

**Kiedy się uruchamia**: Przed INSERT do tabeli EMPLOYEES

**Logika**:
```sql
IF (employee.nick zalogowany w USERS ma role_id ≠ 'employee')
  THEN RAISERROR('Nie można utworzyć pracownika dla użytkownika z rolą student')
  ELSE INSERT normalnie
```

**Cel**: Uniemożliwić przypisanie studenta do tabeli pracowników

---

### Trigger 3: Walidacja oceny – dostęp studenta do modułu

**Nazwa**: `tr_student_grades_validation`

**Kiedy się uruchamia**: Przed INSERT do tabeli STUDENT_GRADES

**Logika**:
```sql
IF NOT EXISTS (
  SELECT 1 FROM STUDENTS s
  INNER JOIN GROUP_MODULES gm ON s.lab_group_id = gm.group_id
  WHERE s.student_id = @inserted_student_id 
    AND gm.module_id = @inserted_module_id
)
THEN RAISERROR('Student nie ma dostępu do tego modułu')
ELSE INSERT normalnie
```

**Cel**: 
- Zapobieganie błędom – nie można wstawić oceny z przedmiotu, którego student nie bierze
- Audyt spójności – każda ocena gwarantuje poprawne przypisanie

---

## 📈 Indeksy optymalizacyjne

Indeksy dla szybkiego wyszukiwania:

```sql
-- Autentykacja
CREATE INDEX idx_users_role ON USERS(role_id);
CREATE INDEX idx_users_email ON USERS(email);
CREATE INDEX idx_users_active_login ON USERS(is_active, last_login);

-- Studenci
CREATE INDEX idx_students_nick ON STUDENTS(nick);
CREATE INDEX idx_students_group ON STUDENTS(lab_group_id);
CREATE INDEX idx_students_active ON STUDENTS(is_active);

-- Pracownicy
CREATE INDEX idx_employees_nick ON EMPLOYEES(nick);
CREATE INDEX idx_lecturers_employee ON LECTURERS(employee_id);
CREATE INDEX idx_lecturers_department ON LECTURERS(department_id);

-- Moduły
CREATE INDEX idx_modules_lecturer ON MODULES(lecturer_id);
CREATE INDEX idx_modules_department ON MODULES(department_id);
CREATE INDEX idx_modules_active ON MODULES(is_active);

-- Grupy i przypisania
CREATE INDEX idx_group_modules_group ON GROUP_MODULES(group_id);
CREATE INDEX idx_group_modules_module ON GROUP_MODULES(module_id);

-- Zajęcia i obecność
CREATE INDEX idx_module_instances_module ON MODULE_INSTANCES(module_id);
CREATE INDEX idx_module_instances_year ON MODULE_INSTANCES(year_id);
CREATE INDEX idx_module_instances_datetime ON MODULE_INSTANCES(start_datetime);

CREATE INDEX idx_attendance_student ON STUDENTS_MODULE_INSTANCES(student_id);
CREATE INDEX idx_attendance_instance ON STUDENTS_MODULE_INSTANCES(instance_id);
CREATE INDEX idx_attendance_attended ON STUDENTS_MODULE_INSTANCES(attended);

-- Oceny
CREATE INDEX idx_student_grades_student ON STUDENT_GRADES(student_id);
CREATE INDEX idx_student_grades_module ON STUDENT_GRADES(module_id);
CREATE INDEX idx_student_grades_lecturer ON STUDENT_GRADES(lecturer_id);
CREATE INDEX idx_student_grades_year ON STUDENT_GRADES(year_id);
CREATE INDEX idx_student_grades_date ON STUDENT_GRADES(grade_date);

-- Płatności
CREATE INDEX idx_tuitions_student ON TUITIONS(student_id);
CREATE INDEX idx_tuitions_year ON TUITIONS(year_id);
CREATE INDEX idx_tuitions_paid ON TUITIONS(is_paid);
CREATE INDEX idx_tuitions_due ON TUITIONS(due_date);

-- Ogłoszenia
CREATE INDEX idx_announcements_group ON ANNOUNCEMENTS(target_group_id);
CREATE INDEX idx_announcements_created ON ANNOUNCEMENTS(created_at);
CREATE INDEX idx_announcements_active ON ANNOUNCEMENTS(is_active);

-- Syllabusy
CREATE INDEX idx_syllabuses_module ON SYLLABUSES(module_id);
CREATE INDEX idx_syllabuses_year ON SYLLABUSES(year_id);
```

**Cel**: Przyspieszenie zapytań SELECT, szczególnie dla:
- Logowania (USERS.role)
- Znajdowania modułów wykładowcy
- Pobierania ocen studenta
- Filtrowania aktywnych rekordów

---

## 🔄 Przepływy danych

### Przepływ 1: Logowanie użytkownika

```
1. Użytkownik wpisuje: nick = "jan.kowalski", hasło = "tajne123"
   ↓
2. System wyszukuje w USERS WHERE nick = "jan.kowalski"
   ↓
3. System sprawdza password_hash (czy zgadza się hasło)
   ↓
4. System pobiera role_id z USERS
   ↓
5a. Jeśli role = 'student':
    - Szuka w STUDENTS WHERE nick = "jan.kowalski"
    - Pobiera lab_group_id (grupa)
    - Wczytuje listę przedmiotów z GROUP_MODULES
    - Kieruje na dashboard STUDENT
   ↓
5b. Jeśli role = 'employee':
    - Szuka w LECTURERS czy employee_id istnieje
    - Jeśli tak → wczytuje moduły i grupy
    - Kieruje na dashboard LECTURER
```

---

### Przepływ 2: Student przegląda swoje oceny

```
1. Student loguje się → pobierany STUDENTS.student_id = 1
   ↓
2. System wyszukuje: SELECT * FROM STUDENT_GRADES 
   WHERE student_id = 1
   ↓
3. Dla każdej oceny łączy:
   - module_id → MODULES (nazwa przedmiotu)
   - grade_id → GRADES (wartość 4.5)
   - grade_type_id → GRADE_TYPES (egzamin/zaliczenie)
   - lecturer_id → LECTURERS (imię wykładowcy)
   - year_id → ACADEMIC_YEARS (rok 2023/2024)
   ↓
4. Wyświetla tabelę:
   | Przedmiot | Ocena | Typ | Wykładowca | Rok |
   |-----------|-------|-----|------------|-----|
   | Matematyka | 4.5 | egzamin | Dr Smith | 2023/2024 |
```

---

### Przepływ 3: Wykładowca wstawia ocenę studentowi

```
1. Wykładowca loguje się → pobierany LECTURERS.lecturer_id = 5
   ↓
2. Wykładowca otwiera "Zarządzanie ocenami"
   - System wyszukuje MODULES WHERE lecturer_id = 5
   - Dla każdego modułu szuka GROUP_MODULES
   - Dla każdej grupy szuka STUDENTS
   ↓
3. Wykładowca wybiera:
   - Student: "Jan Kowalski" (student_id = 1)
   - Przedmiot: "Matematyka" (module_id = 15)
   - Ocena: 4.5 (grade_id = 6)
   - Typ: "egzamin" (grade_type_id = 1)
   ↓
4. TRIGGER: tr_student_grades_validation
   - Sprawdza: Czy student_id=1 należy do grupy przypisanej do module_id=15?
   - Zapytanie: SELECT * FROM STUDENTS s
             INNER JOIN GROUP_MODULES gm ON s.lab_group_id = gm.group_id
             WHERE s.student_id = 1 AND gm.module_id = 15
   - Jeśli BRAK rekordu → ERROR
   - Jeśli OK → INSERT do STUDENT_GRADES
   ↓
5. System wstawia rekord do STUDENT_GRADES:
   (student_id=1, module_id=15, grade_id=6, lecturer_id=5, ...)
   ↓
6. Studenci widzą nową ocenę na swoim dashboardzie
```

---

### Przepływ 4: Student przegląda harmonogram zajęć

```
1. Student loguje się → pobierany STUDENTS.lab_group_id = 1 (Grupa 1A)
   ↓
2. System wyszukuje:
   SELECT mi.* FROM MODULE_INSTANCES mi
   INNER JOIN GROUP_MODULES gm ON mi.module_id = gm.module_id
   WHERE gm.group_id = 1 AND year_id = (current year)
   ↓
3. Dla każdej instancji pobiera:
   - module_id → MODULES (nazwa)
   - start_datetime, end_datetime (czas)
   - room_no (sala)
   - topic (temat zajęć)
   ↓
4. Wyświetla harmonogram:
   | Dzień | Czas | Przedmiot | Sala | Temat |
   |------|------|-----------|------|-------|
   | Pn | 10:00-11:30 | Matematyka | A102 | Logika |
   | Wt | 12:00-13:30 | Algorytmy | B205 | Sortowanie |
```

---

### Przepływ 5: Rejestracja obecności na zajęciach

```
1. Zajęcia się zaczynają (MODULE_INSTANCES.start_datetime)
   ↓
2. System automatycznie tworzy rekordy w STUDENTS_MODULE_INSTANCES:
   - Dla każdego studenta z grupy przypisanej do modułu
   - WITH attended = 0 (domyślnie nieobecny)
   ↓
3. Wykładowca wczytuje listę studentów:
   SELECT s.* FROM STUDENTS s
   INNER JOIN STUDENTS_MODULE_INSTANCES smi 
     ON s.student_id = smi.student_id
   WHERE smi.instance_id = [konkretne zajęcia]
   ↓
4. Wykładowca zaznacza obecność:
   UPDATE STUDENTS_MODULE_INSTANCES 
   SET attended = 1 
   WHERE student_id = 1 AND instance_id = 50
   ↓
5. System aktualizuje attend record
```

---

## 📚 Scenariusze użycia

### Scenariusz 1: Rejestracja nowego studenta

**Aktorzy**: Administrator, Student

**Kroki**:
```
1. Admin tworzy USERS:
   nick='anna.nowak', hasło, imię, nazwisko, ..., role_id=1 (student)
   ↓
2. System tworzy STUDENTS:
   nick='anna.nowak', study_start_date='2024-10-01', 
   lab_group_id=2, bank_account='...'
   ↓
3. TRIGGER tr_student_role_check:
   - Sprawdza role_id w USERS
   - Jeśli NOT 'student' → ERROR
   - Jeśli OK → INSERT
   ↓
4. Student loguje się:
   - System łączy USERS → STUDENTS → GROUPS
   - Widzi: swoją grupę, przedmioty, plan zajęć
```

---

### Scenariusz 2: Semestr akademicki się zaczyna

**Aktorzy**: Administrator

**Kroki**:
```
1. Admin dodaje nowy rok akademicki:
   INSERT ACADEMIC_YEARS (year_name='2024/2025', ...)
   ↓
2. Admin definiuje MODULE_INSTANCES dla każdego modułu:
   - Matematyka: 15 spotkań (15 MODULE_INSTANCES)
   - Algorytmy: 20 spotkań
   ↓
3. Dla każdej instancji tworzy się automat rejestracji obecności:
   - Dla każdego studenta z grupy przypisanej do modułu
   - INSERT do STUDENTS_MODULE_INSTANCES
   ↓
4. Studenci widzą plan zajęć, wykładowcy mogą prowadzić
```

---

### Scenariusz 3: Koniec semestru – wstawianie ocen

**Aktorzy**: Wykładowcy

**Kroki**:
```
1. Wykładowca ma moduł "Matematyka" dla grupy "1A"
   ↓
2. Otwiera "Zarządzanie ocenami":
   - System pobiera studentów z grupy 1A
   - Dla każdego studenta tworzy formularz
   ↓
3. Dla każdego studenta wstawia:
   - Ocenę z zaliczenia (grade_type='zaliczenie')
   - Ocenę z egzaminu (grade_type='egzamin')
   - Opcjonalnie: bonus za aktywność
   ↓
4. TRIGGER tr_student_grades_validation:
   - Sprawdza: czy student jest z grupy przypisanej do modułu?
   - Jeśli NIE → ERROR "Student nie ma dostępu"
   - Jeśli TAK → INSERT do STUDENT_GRADES
   ↓
5. Studenci widzą oceny na dashboardzie
```

---

### Scenariusz 4: Student sprawdza czesne

**Aktorzy**: Student

**Kroki**:
```
1. Student loguje się
   ↓
2. Otwiera "Moje płatności":
   SELECT * FROM TUITIONS 
   WHERE student_id = 1 
   ORDER BY due_date DESC
   ↓
3. Widzi:
   | Kwota | Termin | Status | Data zapłaty |
   |-------|--------|--------|--------------|
   | 2000 | 31.10.2024 | Opłacono | 15.10.2024 |
   | 2000 | 30.11.2024 | ZALEGŁA | – |
   ↓
4. Może zobaczyć: ile winien, jakie terminy, historię
```

---

## 🎓 Dodatkowe uwagi implementacyjne

### Password Hashing
- **NIGDY** nie przechowywać hasła w plaintext!
- Użyć: bcrypt lub PBKDF2
- Przykład C#: `var hash = BCrypt.Net.BCrypt.HashPassword(password, 10);`

### Email Verification
- `email_verified=0` po rejestracji
- Po weryfikacji: `email_verified=1`
- Wysyłać notyfikacje tylko do zweryfikowanych emaili

### Soft Delete vs Hard Delete
- Zamiast `DELETE FROM STUDENTS` → `UPDATE STUDENTS SET is_active=0`
- Pozwala archiwizować dane bez utraty historii ocen/płatności

### Performance Tips
- **Nie** pobierać zawsze całą historię (paginate, limit)
- Używać indeksów do filtrowania (`is_active`, `year_id`, `created_at`)
- Cache'ować dane walidacyjne (ROLES, GRADES, GRADE_TYPES)

### Year-based Queries
- Zawsze filtrować `year_id` w zapytaniach historycznych
- Przykład: `WHERE year_id = (SELECT year_id FROM ACADEMIC_YEARS WHERE is_current=1)`

---

## 📝 Podsumowanie

| Aspekt | Liczba tabel | Uwagi |
|--------|-------------|-------|
| **Tabele walidacyjne** | 5 | ROLES, DEPARTMENTS, GROUPS, GRADES, GRADE_TYPES |
| **Tabele użytkowników** | 4 | USERS, STUDENTS, EMPLOYEES, LECTURERS |
| **Tabele akademickie** | 5 | MODULES, GROUP_MODULES, MODULE_INSTANCES, ACADEMIC_YEARS, SYLLABUSES |
| **Tabele ocen/obecności** | 2 | STUDENT_GRADES, STUDENTS_MODULE_INSTANCES |
| **Tabele administracyjne** | 2 | TUITIONS, ANNOUNCEMENTS |
| **RAZEM** | **18 tabel** | Kompleksowy system dla mid-size university |

---

**Status**: ✅ Gotowa do wdrożenia  
**Data**: Grudzień 2025  
**Autor**: Specyfikacja bazy danych dla projektu ASP.NET MVC
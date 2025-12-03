# 🎓 ASP_PROJECT - System Zarządzania Uniwersytetem

> Aplikacja do kompleksowego zarządzania uniwersytetem - studentami, pracownikami, ocenami, zajęciami i finansami.

## 📋 Spis treści

- [O projekcie](#o-projekcie)
- [Technologia](#technologia)
- [Struktura projektu](#struktura-projektu)
- [📚 Dokumentacja](#-dokumentacja)
- [Instalacja bazy danych](#instalacja-bazy-danych)
- [Mapę Widoków](#mapa-widoków---aplicacja)
- [Schemat bazy](#schemat-bazy)
- [Użytkownicy testowi](#użytkownicy-testowi)
- [Contributing](#contributing)
- [Licencja](#licencja)

---

## 📖 O projekcie

**ASP_PROJECT** to zaawansowany system zarządzania uniwersytetem zbudowany na platformie ASP.NET z bazą danych SQL Server. System wspiera:

✅ Zarządzanie studentami i pracownikami  
✅ Rejestracja zajęć i modułów edukacyjnych  
✅ Śledzenie ocen i frekwencji  
✅ Zarządzanie płatnościami czesnego  
✅ Generowanie raportów akademickich  
✅ Ogłoszenia dla studentów  
✅ Zarządzanie sylabuami przedmiotów  

---

## 🛠️ Technologia

| Warstwa | Technologia |
|---------|------------|
| **Backend** | ASP.NET (C#) |
| **Baza danych** | SQL Server 2019+ |
| **Język skryptów DB** | T-SQL |
| **Wersja .NET** | .NET Framework / .NET 6+ |
| **IDE** | Visual Studio 2019+ |
| **Version Control** | Git / GitHub |

---

## 📁 Struktura projektu

```
ASP_PROJECT/
├── 📂 Database/
│   ├── 📄 Scripts/
│   │   ├── 1_create_database_FIXED_GO.sql      ← Tabele + triggery + indeksy
│   │   ├── 2_create_views.sql                  ← 5 gotowych views
│   │   ├── 3_insert_sample_FINAL.sql           ← Dane testowe
│   │   └── 4_stored_procedures.sql             (przyszłość)
│   │
│   ├── 📄 Documentation/
│   │   ├── SCHEMA.md                           ← Diagram bazy
│   │   ├── SETUP.md                            ← Instrukcja instalacji
│   │   ├── STRUCTURE.md                        ← Opis struktury projektu
│   │   ├── RELATIONSHIPS.md                    ← Relacje między tabelami
│   │   └── VIEWS_MAP.md                        ← Mapa widoków aplikacji (NOWE!)
│   │
│   └── 📄 Backups/
│       └── university_backup.bak               (po konfiguracji)
│
├── 📂 ApplicationCode/
│   ├── 📂 Controllers/
│   ├── 📂 Models/
│   ├── 📂 Views/
│   └── README.md                               
│
├── 📄 README.md                                ← Ten plik!
├── 📄 .gitignore
├── 📄 CONTRIBUTING.md
└── 📄 LICENSE
```

---

## 📚 Dokumentacja

### 🗂️ Baza Danych

| Dokument | Opis |
|----------|------|
| **[SETUP.md](Database/Documentation/SETUP.md)** | 📋 Krok po kroku instrukcja instalacji bazy danych |
| **[SCHEMA.md](Database/Documentation/SCHEMA.md)** | 📊 Pełny schemat bazy - 18 tabel z opisami |
| **[STRUCTURE.md](Database/Documentation/STRUCTURE.md)** | 🏗️ Opis struktury projektu i konwencji |
| **[RELATIONSHIPS.md](Database/Documentation/RELATIONSHIPS.md)** | 🔗 Relacje między tabelami (1:N, N:M, hierarchie) |

### 🎨 Aplikacja ASP.NET

| Dokument | Opis |
|----------|------|
| **[VIEWS_MAP.md](Database/Documentation/VIEWS_MAP.md)** | 📱 Kompletna mapa widoków aplikacji |

---

## ⚙️ Instalacja bazy danych

### Wymagania wstępne
- **SQL Server 2019** lub nowszy
- **SQL Server Management Studio (SSMS) 18+**
- **Git**
- Dostęp do linii poleceń PowerShell lub CMD

### Krok 1: Sklonuj repozytorium

```bash
git clone https://github.com/Magdalabrkrk/ASP_PROJECT.git
cd ASP_PROJECT
```

### Krok 2: Otwórz skrypty w SSMS

1. Otwórz **SQL Server Management Studio**
2. Połącz się z lokalnym serwerem (`(local)` lub `.\\SQLEXPRESS`)
3. W Object Explorerze kliknij **New Query**

### Krok 3: Uruchom skrypty w kolejności

**Krok 3a: Utwórz bazę + tabele + triggery**
```
File → Open → Database/Scripts/1_create_database_FIXED_GO.sql
Ctrl+Shift+E
```
✅ Status: Baza `UniversityDB` utworzona

**Krok 3b: Dodaj widoki**
```
File → Open → Database/Scripts/2_create_views.sql
Ctrl+Shift+E
```
✅ Status: 5 views dodanych

**Krok 3c: Załaduj dane testowe**
```
File → Open → Database/Scripts/3_insert_sample_FINAL.sql
Ctrl+Shift+E
```
✅ Status: 100+ rekordów załadowanych

### Krok 4: Weryfikacja

```sql
-- Test 1: Sprawdź liczbę studentów
SELECT COUNT(*) AS liczba_studentow FROM STUDENTS;
-- Powinno być: 4 ✅

-- Test 2: Sprawdź oceny
SELECT COUNT(*) AS liczba_ocen FROM STUDENT_GRADES;
-- Powinno być: 5 ✅

-- Test 3: Sprawdź plan zajęć
SELECT * FROM vw_student_schedule WHERE student_id = 1;
-- Powinno zwrócić wyniki ✅
```

---

## 📱 Mapa Widoków - Aplikacja

### 🎯 Struktura Widoków

Aplikacja zawiera **20+ widoków** zorganizowanych w 4 główne role:

#### 🔐 **Autentykacja** (2 widoki)
- Login Page - `/Auth/Login`
- Register Page - `/Auth/Register`

#### 🎓 **Student** (5 widoków)
- Dashboard - Podsumowanie + średnia ocen + stan czesnego
- Courses - Lista przedmiotów grupy
- Attendance Record - Frekwencja na zajęciach
- Grades - Historia ocen
- Tuition Payment - Historia płatności czesnego

#### 👨‍🏫 **Lecturer (Wykładowca)** (6 widoków)
- Dashboard - Prowadzone przedmioty + statystyki
- My Modules - Lista przedmiotów
- Group Schedule - Plan zajęć
- Attendance Management - Zaznaczanie frekwencji
- Grading - Wpisywanie ocen
- Performance Report - Raport o postępach studentów

#### 🏢 **Admin** (9 widoków)
- Dashboard - Statystyki systemu
- Users Management - Zarządzanie użytkownikami
- Students Management - Zarządzanie studentami
- Employees Management - Zarządzanie pracownikami
- Modules Management - Zarządzanie przedmiotami
- Groups Management - Zarządzanie grupami
- Departments Management - Zarządzanie wydziałami
- Financial Reports - Raporty finansowe
- Academic Reports - Raporty akademickie

### 📖 Pełna dokumentacja widoków

**[→ VIEWS_MAP.md](Database/Documentation/VIEWS_MAP.md)** zawiera dla każdego widoku:
- ✅ Ścieżka URL
- ✅ Wymagane tabele z bazy
- ✅ Szczegółową funkcjonalność
- ✅ Przykład HTML tabeli
- ✅ Gotowe SQL Query
- ✅ Priorytet implementacji

---

## 👥 Użytkownicy testowi

### Studenci

| Login | Hasło | Grupa | Status |
|-------|-------|-------|--------|
| jan.kowalski | Haslo123! | Grupa 1A - Informatyka | ✅ Aktywny |
| maria.nowak | Haslo123! | Grupa 2A - Informatyka | ✅ Aktywny |
| piotr.wisniewski | Haslo123! | Grupa 1A - Informatyka | ✅ Aktywny |
| anna.krol | Haslo123! | Grupa 2B - Matematyka | ✅ Aktywny |

### Pracownicy / Wykładowcy

| Login | Hasło | Stanowisko | Wydział |
|-------|-------|-----------|---------| 
| anna.smith | Haslo123! | Dr | Informatyka |
| zbigniew.kuchta | Haslo123! | Prof | Informatyka |
| katarzyna.lewandowska | Haslo123! | Dr | Matematyka |

**Hasło (SHA2_256):**
```
a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3
```

---

## 📊 Schemat bazy

Baza zawiera **18 tabel** z relacjami:

```
USERS (studenci i pracownicy)
├── STUDENTS
│   ├── STUDENTS_MODULE_INSTANCES (frekwencja)
│   ├── STUDENT_GRADES (oceny)
│   └── TUITIONS (czesne)
│
├── EMPLOYEES
│   └── LECTURERS (wykładowcy)
│
ROLES (role użytkowników)

DEPARTMENTS (wydziały)
└── MODULES (przedmioty)
    ├── LECTURERS
    ├── GROUP_MODULES
    └── MODULE_INSTANCES (konkretne zajęcia)
        └── STUDENTS_MODULE_INSTANCES

GROUPS (grupy laboratoryjna)

ACADEMIC_YEARS (lata akademickie)

GRADES (skale ocen)
GRADE_TYPES (typy ocen: egzamin, zaliczenie, etc.)

SYLLABUSES (sylabusy przedmiotów)

ANNOUNCEMENTS (ogłoszenia)
```

**Szczegółowy schemat:** [SCHEMA.md](Database/Documentation/SCHEMA.md)

---

## 📈 Dostępne SQL Views (Widoki)

| View | Opis |
|------|------|
| `vw_student_grades_summary` | Szczegółowe oceny studenta z wszystkimi informacjami |
| `vw_student_schedule` | Plan zajęć studenta z informacją o frekwencji |
| `vw_student_grades_avg` | Średnie oceny na poszczególne przedmioty |
| `vw_student_attendance` | Procentowa frekwencja studenta |
| `vw_student_tuition_status` | Status opłacenia czesnego (opłacone/zaległa/czekające) |

**Przykład użycia:**
```sql
-- Pokaż oceny studenta Jan Kowalski
SELECT * FROM vw_student_grades_summary WHERE student_id = 1;

-- Pokaż plan zajęć
SELECT * FROM vw_student_schedule WHERE student_id = 1;

-- Pokaż frekwencję
SELECT * FROM vw_student_attendance WHERE student_id = 1;
```

---

## 🔧 Triggery (Automatyzacja)

Baza zawiera 3 triggery:

1. **trg_audit_users_changes** - Log zmian w tabeli USERS
2. **trg_check_grade_value** - Walidacja wartości ocen
3. **trg_tuition_payment_update** - Aktualizacja statusu płatności

---

## 🚀 Dalszy rozwój

### Funkcjonalności do implementacji w kodzie ASP.NET:

- [ ] Autoryzacja i autentykacja użytkowników
- [ ] CRUD operacje dla studentów
- [ ] CRUD operacje dla pracowników
- [ ] Rejestracja na przedmioty
- [ ] Wgrywanie ocen
- [ ] Generowanie świadectw
- [ ] System powiadomień
- [ ] Export raportów do PDF
- [ ] Integracja z emailem

---

## 🤝 Współpraca (Contributing)

Jeśli chcesz wnieść wkład:

1. Utwórz nową gałąź (`git checkout -b feature/nova-funkcjonalnosc`)
2. Commituj zmiany (`git commit -m 'Dodaj nową funkcjonalność'`)
3. Wypchnij gałąź (`git push origin feature/nova-funkcjonalnosc`)
4. Otwórz Pull Request

Więcej w [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 📝 Licencja

Projekt licencjonowany na warunkach licencji **MIT**. Zobacz [LICENSE](LICENSE) aby dowiedzieć się więcej.

---

## 👤 Autor

**Magdalena T.**
- GitHub: [@Magdalabrkrk](https://github.com/Magdalabrkrk)
- Email: magdalena.tomczak@microsoft.wsei.edu.pl
**Tomasz P.**
**Kamil M.**
**Patryja S.**

---

## ❓ FAQ

**P: Czy mogę modyfikować schemat bazy?**  
O: Tak! Pamiętaj aby aktualizować dokumentację w `SCHEMA.md` i `RELATIONSHIPS.md`

**P: Gdzie dodać nowe tabele?**  
O: Utwórz nowy plik SQL w `Database/Scripts/` i zmerguj z głównym skryptem tworzenia

**P: Jak zrobić backup bazy?**  
O: SSMS → Database → Tasks → Back Up... (lub `BACKUP DATABASE` w skrypcie)

**P: Jak zaplanować widoki aplikacji?**  
O: Zobacz [VIEWS_MAP.md](Database/Documentation/VIEWS_MAP.md) - zawiera kompletną mapę z priorytetami

**P: Kod aplikacji gdzie?**  
O: Aplikacja ASP.NET będzie w folderze `ApplicationCode/` 

---

**Ostatnia aktualizacja:** 3 grudnia 2025  
**Wersja:** 1.1.0  
**Status:** ✅ Baza danych gotowa + 📱 Mapa widoków gotowa do integracji z aplikacją


# 📁 STRUCTURE.md - Struktura Projektu ASP_PROJECT

## 📂 Completa struktura folderu

```
ASP_PROJECT/
│
├── 📄 README.md                           ← Start tutaj! Główna dokumentacja
├── 📄 .gitignore                          ← Konfiguracja Git
├── 📄 LICENSE                             ← Licencja MIT
├── 📄 CONTRIBUTING.md                     ← Wytyczne współpracy
│
├── 📂 Database/                           ⭐ GŁÓWNA BAZA DANYCH
│   │
│   ├── 📂 Scripts/                        ← Skrypty SQL do uruchomienia w SSMS
│   │   ├── 📄 1_create_database_FIXED_GO.sql
│   │   │   ├─ Tworzy bazę UniversityDB
│   │   │   ├─ 18 tabel
│   │   │   ├─ 3 triggery
│   │   │   ├─ 20+ indeksów
│   │   │   └─ Wszystkie relacje (FK)
│   │   │
│   │   ├── 📄 2_create_views.sql
│   │   │   ├─ vw_student_grades_summary      (oceny)
│   │   │   ├─ vw_student_schedule            (plan zajęć)
│   │   │   ├─ vw_student_grades_avg          (średnie)
│   │   │   ├─ vw_student_attendance          (frekwencja)
│   │   │   └─ vw_student_tuition_status      (czesne)
│   │   │
│   │   ├── 📄 3_insert_sample_FINAL.sql
│   │   │   ├─ 7 użytkowników testowych
│   │   │   ├─ 4 studenci (Jan, Maria, Piotr, Anna)
│   │   │   ├─ 3 pracownicy (Anna, Zbigniew, Katarzyna)
│   │   │   ├─ 4 przedmioty
│   │   │   ├─ 8 instancji zajęć
│   │   │   ├─ 5 ocen
│   │   │   ├─ 8 płatności
│   │   │   └─ 100+ rekordów
│   │   │
│   │   └── 📄 4_stored_procedures.sql       (przyszłość)
│   │       └─ Do implementacji: raporty, audyty, etc.
│   │
│   ├── 📂 Documentation/                  ← Dokumentacja techniczna
│   │   ├── 📄 SCHEMA.md
│   │   │   ├─ Diagram bazy danych
│   │   │   ├─ Opis każdej tabeli
│   │   │   ├─ Relacje FK/PK
│   │   │   ├─ Indeksy
│   │   │   └─ Triggery
│   │   │
│   │   ├── 📄 QUERIES.md
│   │   │   ├─ Przydatne zapytania SELECT
│   │   │   ├─ JOINy dla raportów
│   │   │   ├─ Analiza danych
│   │   │   └─ Przykłady dla developera
│   │   │
│   │   └── 📄 RELATIONSHIPS.md
│   │       ├─ Relacje pomiędzy tabelami
│   │       ├─ Diagram ERD
│   │       └─ Constraints
│   │
│   └── 📂 Backups/                       ← Kopie zapasowe
│       ├── 📄 university_2025_12_03.bak  (po pierwszej konfiguracji)
│       ├── 📄 .gitkeep                   (pusty folder w Git)
│       └── ℹ️ Dodaj tutaj pliki .bak z regularnym backupem
│
├── 📂 ApplicationCode/                    ⭐ KOD ASP.NET (INNY DEVELOPER)
│   │
│   ├── 📂 Controllers/
│   │   ├── 📄 HomeController.cs
│   │   ├── 📄 StudentController.cs        (CRUD dla studentów)
│   │   ├── 📄 TeacherController.cs        (CRUD dla nauczycieli)
│   │   ├── 📄 GradeController.cs          (Zarządzanie ocenami)
│   │   ├── 📄 AttendanceController.cs     (Frekwencja)
│   │   └── 📄 ReportController.cs         (Generowanie raportów)
│   │
│   ├── 📂 Models/
│   │   ├── 📄 Student.cs                  (Model studenta)
│   │   ├── 📄 User.cs                     (Model użytkownika)
│   │   ├── 📄 Module.cs                   (Model przedmiotu)
│   │   ├── 📄 Grade.cs                    (Model oceny)
│   │   ├── 📄 ModuleInstance.cs           (Instancja zajęć)
│   │   ├── 📄 Tuition.cs                  (Model czesnego)
│   │   └── 📄 UniversityContext.cs        (EF DbContext)
│   │
│   ├── 📂 Views/
│   │   ├── 📂 Home/
│   │   │   ├── 📄 Index.cshtml
│   │   │   └── 📄 About.cshtml
│   │   │
│   │   ├── 📂 Student/
│   │   │   ├── 📄 Index.cshtml
│   │   │   ├── 📄 Details.cshtml
│   │   │   ├── 📄 Create.cshtml
│   │   │   ├── 📄 Edit.cshtml
│   │   │   └── 📄 Delete.cshtml
│   │   │
│   │   ├── 📂 Grade/
│   │   │   ├── 📄 Index.cshtml
│   │   │   ├── 📄 AddGrade.cshtml
│   │   │   └── 📄 ViewGrades.cshtml
│   │   │
│   │   └── 📂 Shared/
│   │       ├── 📄 _Layout.cshtml          (Master page)
│   │       └── 📄 _Footer.cshtml
│   │
│   ├── 📂 Services/
│   │   ├── 📄 IStudentService.cs
│   │   ├── 📄 StudentService.cs
│   │   ├── 📄 IGradeService.cs
│   │   ├── 📄 GradeService.cs
│   │   └── 📄 IReportService.cs
│   │
│   ├── 📂 Security/
│   │   ├── 📄 AuthenticationService.cs    (Logowanie)
│   │   ├── 📄 AuthorizationFilter.cs      (Role i uprawnienia)
│   │   └── 📄 PasswordHasher.cs
│   │
│   ├── 📂 Infrastructure/
│   │   ├── 📄 Dependency.cs               (DI Container)
│   │   ├── 📄 Logger.cs
│   │   └── 📄 ErrorHandler.cs
│   │
│   ├── 📄 Web.config                      (Konfiguracja ASP.NET)
│   ├── 📄 Global.asax                     (Lifecycle aplikacji)
│   ├── 📄 Global.asax.cs
│   └── 📄 README.md                       (Dokumentacja kodu)
│
├── 📂 Tests/                              ← Testy (przyszłość)
│   ├── 📂 Unit/
│   │   ├── 📄 StudentServiceTests.cs
│   │   ├── 📄 GradeServiceTests.cs
│   │   └── 📄 ValidationTests.cs
│   │
│   └── 📂 Integration/
│       ├── 📄 DatabaseTests.cs
│       └── 📄 APITests.cs
│
├── 📂 Documentation/                      ← Dokumentacja ogólna
│   ├── 📄 ARCHITECTURE.md                 (Architektura aplikacji)
│   ├── 📄 API.md                          (Dokumentacja API endpoints)
│   ├── 📄 DEPLOYMENT.md                   (Wdrożenie na produkcję)
│   ├── 📄 SECURITY.md                     (Bezpieczeństwo)
│   └── 📄 PERFORMANCE.md                  (Optymalizacja)
│
├── 📂 Configuration/
│   ├── 📄 appsettings.json                (Konfiguracja production)
│   ├── 📄 appsettings.Development.json    (Development - NIE w Git)
│   ├── 📄 Web.config                      (IIS config)
│   └── 📄 web.Release.config
│
├── 📂 Deployment/                         ← Wdrożenie
│   ├── 📄 docker-compose.yml              (Docker konteneryzacja)
│   ├── 📄 Dockerfile                      (Obraz aplikacji)
│   └── 📄 .dockerignore
│
├── 📂 Tools/                              ← Narzędzia pomocnicze
│   ├── 📂 Scripts/
│   │   ├── 📄 restore_database.ps1        (PowerShell - restore bazy)
│   │   ├── 📄 backup_database.ps1         (PowerShell - backup)
│   │   └── 📄 setup.bat                   (Setup script dla Windows)
│   │
│   └── 📂 SQL/
│       ├── 📄 common_queries.sql          (Przydatne zapytania)
│       └── 📄 performance_analysis.sql
│
├── 📂 Assets/                             ← Multimedia
│   ├── 📂 Images/
│   │   ├── 📄 logo.png
│   │   ├── 📄 screenshot_dashboard.png
│   │   └── 📄 diagram_erd.png
│   │
│   ├── 📂 Styles/
│   │   ├── 📄 main.css
│   │   ├── 📄 responsive.css
│   │   └── 📄 dark-theme.css
│   │
│   └── 📂 Scripts/
│       ├── 📄 validation.js
│       ├── 📄 ajax-handlers.js
│       └── 📄 chart-integration.js
│
├── 📄 SETUP.md                            ← Instrukcja instalacji ⭐
├── 📄 CHANGELOG.md                        ← Historia zmian
│
└── .gitignore                             ← Pliki do ignorowania w Git

```

---

## 📌 Opis kluczowych folderów

### 🗄️ Database/ - **BAZA DANYCH** (Twoja część)

| Folder | Przeznaczenie |
|--------|--------------|
| `Scripts/` | Skrypty SQL do uruchomienia w SSMS |
| `Documentation/` | Dokumentacja bazy danych |
| `Backups/` | Kopie zapasowe `.bak` |

**Status:** ✅ **GOTOWE** - zawiera wszystkie skrypty

---

### 💻 ApplicationCode/ - **KOD ASP.NET** (Drugi developer)

| Folder | Przeznaczenie |
|--------|--------------|
| `Controllers/` | Logika biznesowa (CRUD, walidacja) |
| `Models/` | Klasy danych (Entity Framework) |
| `Views/` | HTML/Razor szablony interfejsu |
| `Services/` | Warstawa serwisów (biznesowa logika) |
| `Security/` | Autentykacja, autoryzacja |

**Status:** ⏳ **DO WYKONANIA** - będzie pracować inny developer

---

### 📚 Documentation/ - **DOKUMENTACJA TECHNICZNA**

| Plik | Opis |
|------|------|
| `ARCHITECTURE.md` | Jak aplikacja jest zbudowana |
| `API.md` | Endpoints REST API |
| `DEPLOYMENT.md` | Jak wdrożyć na produkcję |
| `SECURITY.md` | Bezpieczeństwo i best practices |

---

## 🎯 Workflow dla projektanta (Ciebie)

```
┌─────────────────────────────────────────┐
│ 1. Konfiguracja Bazy Danych             │
│    └─ Database/Scripts/*.sql            │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ 2. Dokumentacja Bazy                    │
│    └─ Database/Documentation/*.md       │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ 3. Push do GitHuba                      │
│    └─ git add . && git commit           │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ 4. Backup & Deploy                      │
│    └─ Database/Backups/                 │
└─────────────────────────────────────────┘
```

## 🎯 Workflow dla developera ASP.NET (Drugi developer)

```
┌─────────────────────────────────────────┐
│ 1. Konfiguracja EF Models               │
│    └─ ApplicationCode/Models/            │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ 2. Tworzenie Controllers                │
│    └─ ApplicationCode/Controllers/       │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ 3. Implementacja Views                  │
│    └─ ApplicationCode/Views/             │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ 4. Services & Business Logic            │
│    └─ ApplicationCode/Services/          │
└─────────────────────────────────────────┘
```

---

## 📤 Jak załadować na GitHub

### 1. Przygotuj lokalne pliki

```bash
# W CMD/PowerShell, w głównym folderze projektu
cd C:\ścieżka\do\ASP_PROJECT

# Sprawdź czy Git jest zainicjowany
git status

# Jeśli NIE, zainicjuj:
git init
```

### 2. Dodaj pliki do Git

```bash
# Dodaj wszystkie pliki (oprócz .gitignore)
git add .

# Sprawdź co będzie dodane
git status

# Commituj
git commit -m "Inicjalna konfiguracja bazy danych - 18 tabel, 3 triggery, 5 views"
```

### 3. Połącz z GitHub

```bash
# Dodaj remote (zmień URL na swój)
git remote add origin https://github.com/Magdalabrkrk/ASP_PROJECT.git

# Prześlij na GitHub
git branch -M main
git push -u origin main
```

### 4. Sprawdzenie

Otwórz GitHub w przeglądarce:
- ✅ Powinieneś zobaczyć wszystkie pliki
- ✅ README.md powinno się wyświetlić
- ✅ Foldery Database/ powinny być widoczne

---

## 🔐 Bezpieczeństwo - NIGDY nie commituj

❌ **Nie dodawaj do Git:**
- `appsettings.Development.json` (connection strings)
- `web.config` z hasłami
- `credentials.json`
- Klucze API
- `.bak` backupy baz danych

✅ **Zawsze dodawaj do .gitignore** (już zrobione!)

---

## 📋 Checklist - Przed pushem na GitHub

- [ ] Wszystkie skrypty SQL w `Database/Scripts/`
- [ ] Dokumentacja w `Database/Documentation/`
- [ ] .gitignore skonfigurowany
- [ ] README.md zaktualizowany
- [ ] LICENSE plik dodany
- [ ] Brak haseł / credential w plikach
- [ ] Brak `.bak` plików w commicie
- [ ] Git status czysty (`git status` pokazuje "nothing to commit")

✅ **Gotowe do push!**

---

**Ostatnia aktualizacja:** 3 grudnia 2025
**Wersja:** 1.0.0

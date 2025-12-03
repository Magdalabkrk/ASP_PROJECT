# 🔧 SETUP.md - Konfiguracja Bazy Danych

## 📋 Spis treści

1. [Wymagania systemowe](#wymagania-systemowe)
2. [Instalacja SQL Server](#instalacja-sql-server)
3. [Konfiguracja SSMS](#konfiguracja-ssms)
4. [Instalacja bazy krok po kroku](#instalacja-bazy-krok-po-kroku)
5. [Weryfikacja instalacji](#weryfikacja-instalacji)
6. [Troubleshooting](#troubleshooting)
7. [Backup i Restore](#backup-i-restore)

---

## ⚙️ Wymagania systemowe

### Minimalne wymagania

| Składnik | Wersja | Link |
|----------|--------|------|
| **SQL Server** | 2019 SP2+ | [Pobierz](https://www.microsoft.com/pl-pl/sql-server/sql-server-downloads) |
| **SSMS** | 21+ | [Pobierz](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms) |
| **Windows** | 10 / 11 / Server 2019+ | - |
| **RAM** | Min 4GB | Zalecane 8GB |
| **Miejsce na dysku** | Min 5GB | - |
| **Git** | 2.35+ | [Pobierz](https://git-scm.com/download/win) |

---

## 📥 Instalacja SQL Server

### Windows 10/11

#### Opcja 1: SQL Server Express (Bezpłatna) ✅ REKOMENDOWANA

1. Pobierz: https://go.microsoft.com/fwlink/?linkid=2215158
2. Uruchom instalator `.exe`
3. Wybierz **Basic** installation
4. Zaakceptuj licencję
5. Wybierz folder instalacji (domyślnie OK)
6. Czekaj na instalację (~10 minut)
7. **WAŻNE:** Zapamiętaj **Instance Name** (domyślnie `SQLEXPRESS`)

#### Opcja 2: SQL Server Developer Edition

1. Zarejestruj się na: https://www.microsoft.com/sql-server/sql-server-downloads
2. Pobierz **Developer Edition**
3. Postępuj jak wyżej

### Weryfikacja instalacji

```bash
# Otwórz PowerShell i sprawdź
sqlcmd -S .\SQLEXPRESS -U sa
```

Jeśli połączenie się nie powiedzie, zobacz [Troubleshooting](#troubleshooting)

---

## 🖥️ Konfiguracja SSMS

### 1. Instalacja SSMS

1. Pobierz: https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms
2. Uruchom `.exe` (rozmiar ~500MB)
3. Zainstaluj w lokalizacji domyślnej
4. Restartuj komputer

### 2. Pierwsza konfiguracja

1. Otwórz **SQL Server Management Studio**
2. W oknie **Connect to Server**:
   - **Server name:** `(local)\SQLEXPRESS` lub `.\SQLEXPRESS`
   - **Authentication:** Windows Authentication
   - Kliknij **Connect**

3. Jeśli połączenie OK → gotowe! ✅

---

## 🚀 Instalacja bazy krok po kroku

### Krok 1: Sklonuj projekt z GitHuba

```bash
# Otwórz PowerShell/CMD i wykonaj:
git clone https://github.com/Magdalabrkrk/ASP_PROJECT.git
cd ASP_PROJECT
```

### Krok 2: Otwórz SSMS i wykonaj skrypty

#### **SKRYPT 1: Tworzenie bazy + tabele + triggery**

```
Łańcuch działań:
1. Otwórz SSMS
2. File → Open → Database/Scripts/1_create_database_FIXED_GO.sql
3. Ctrl+Shift+E  (lub Query → Execute)
4. Czekaj na komunikat: "========== BAZA STWORZONA POMYŚLNIE =========="
```

✅ **Co się stało:**
- Baza `UniversityDB` utworzona
- 18 tabel stworzonych
- 3 triggery zarejestrowane
- 20+ indeksów dodanych

#### **SKRYPT 2: Dodaj widoki (Views)**

```
1. File → Open → Database/Scripts/2_create_views.sql
2. Ctrl+Shift+E
3. Czekaj na: "========== WSZYSTKIE VIEWS DZIAŁAJĄ! =========="
```

✅ **Co się stało:**
- 5 gotowych widoków
- Test queries wykonane
- Dane testowe widoczne

#### **SKRYPT 3: Załaduj dane testowe**

```
1. File → Open → Database/Scripts/3_insert_sample_FINAL.sql
2. Ctrl+Shift+E
3. Czekaj na: "========== KONIEC =========="
```

✅ **Co się stało:**
- 7 użytkowników załadowanych
- 4 studenci
- 3 pracownicy
- 100+ rekordów w tabelach

---

## ✅ Weryfikacja instalacji

Po załadowaniu wszystkich skryptów, wykonaj testy:

### Test 1: Sprawdź bazę

```sql
-- Połącz się z UniversityDB
USE UniversityDB;
GO

-- Pokaż wszystkie tabele
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_NAME;
```

**Powinno być: 18 tabel** ✅

### Test 2: Sprawdź dane

```sql
-- Liczba studentów
SELECT COUNT(*) AS 'Liczba studentów' FROM STUDENTS;
-- ↳ Powinno: 4

-- Liczba pracowników
SELECT COUNT(*) AS 'Liczba pracowników' FROM EMPLOYEES;
-- ↳ Powinno: 3

-- Liczba ocen
SELECT COUNT(*) AS 'Liczba ocen' FROM STUDENT_GRADES;
-- ↳ Powinno: 5

-- Liczba płatności
SELECT COUNT(*) AS 'Liczba płatności' FROM TUITIONS;
-- ↳ Powinno: 8
```

### Test 3: Testuj Views

```sql
-- Test widoku ocen
SELECT TOP 5 * FROM vw_student_grades_summary;

-- Test widoku planu zajęć
SELECT TOP 5 * FROM vw_student_schedule;

-- Test frekwencji
SELECT * FROM vw_student_attendance;
```

### Test 4: Zaloguj się jako student testowy

```sql
-- Sprawdź użytkownika
SELECT * FROM USERS WHERE nick = 'jan.kowalski';

-- Sprawdź studenta
SELECT * FROM STUDENTS WHERE nick = 'jan.kowalski';
```

---

## 🔍 Troubleshooting

### ❌ Problem: "Cannot connect to server"

**Przyczyna:** SQL Server nie jest uruchomiony

**Rozwiązanie:**

```powershell
# Otwórz PowerShell jako Administrator
Get-Service MSSQLSERVER

# Jeśli Status = Stopped, uruchom:
Start-Service MSSQLSERVER

# Weryfikacja
Get-Service MSSQLSERVER | Select Status
```

### ❌ Problem: "Msg 2628: String or binary data would be truncated"

**Przyczyna:** Dane testowe nie pasują do kolumn

**Rozwiązanie:**
- Użyj plik `insert_sample_FINAL.sql` (już poprawiony)
- Bank account powinien być: `PL61109010140000071219812874` (bez spacji)

### ❌ Problem: "Msg 547: The INSERT statement conflicted with a FOREIGN KEY constraint"

**Przyczyna:** Brak powiązanego rekordu w tabeli nadrzędnej

**Rozwiązanie:**
- Uruchom skrypty w prawidłowej kolejności:
  1. `1_create_database_FIXED_GO.sql`
  2. `2_create_views.sql`
  3. `3_insert_sample_FINAL.sql`

### ❌ Problem: Nie widzę bazy "UniversityDB"

**Przyczyna:** Baza nie została stworzona

**Rozwiązanie:**
```sql
-- Sprawdź czy baza istnieje
SELECT name FROM sys.databases WHERE name = 'UniversityDB';

-- Jeśli nie istnieje, uruchom ponownie skrypt 1
-- Lub utwórz ręcznie:
CREATE DATABASE UniversityDB;
```

### ❌ Problem: "Database 'UniversityDB' already exists"

**Przyczyna:** Baza już istnieje

**Rozwiązanie:**
```sql
-- Opcja 1: Usuń starą bazę
DROP DATABASE UniversityDB;
GO

-- Potem uruchom skrypty od nowa

-- Opcja 2: Zaloguj się do istniejącej bazy
USE UniversityDB;
GO
```

---

## 💾 Backup i Restore

### Zrób Backup

```sql
-- W SSMS:
BACKUP DATABASE UniversityDB 
TO DISK = 'C:\Backups\UniversityDB_2025_12_03.bak'
WITH INIT;
```

### Restore z Backup'u

```sql
-- Jeśli baza istnieje
DROP DATABASE UniversityDB;
GO

-- Restore
RESTORE DATABASE UniversityDB 
FROM DISK = 'C:\Backups\UniversityDB_2025_12_03.bak';
```

### Exportuj do skryptu

1. Object Explorer → Baza `UniversityDB`
2. Right-click → Tasks → Generate Scripts
3. Wybierz tabele, triggery, views
4. Zapisz do pliku `.sql`

---

## 📱 Łączenie z aplikacją ASP.NET

Po konfiguracji bazy, Twój kolega może pracować nad aplikacją.

### Connection String dla C#

```csharp
// Web.config lub appsettings.json
{
  "ConnectionStrings": {
    "UniversityDB": "Server=.\\SQLEXPRESS;Database=UniversityDB;Trusted_Connection=true;Encrypt=false"
  }
}
```

### Modele Entity Framework

```csharp
// DbContext
public class UniversityContext : DbContext
{
    public DbSet<Student> Students { get; set; }
    public DbSet<User> Users { get; set; }
    public DbSet<Module> Modules { get; set; }
    // ... inne tabele
    
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.UseSqlServer("Server=.\\SQLEXPRESS;Database=UniversityDB;Trusted_Connection=true");
    }
}
```

---

## 🎯 Checklist - Wszystko gotowe?

- [ ] SQL Server zainstalowany i uruchomiony
- [ ] SSMS zainstalowany i połączony
- [ ] Projekt sklonowany z GitHuba
- [ ] Skrypt 1 wykonany (baza + tabele + triggery)
- [ ] Skrypt 2 wykonany (widoki)
- [ ] Skrypt 3 wykonany (dane testowe)
- [ ] Wszystkie testy przebiegły pomyślnie
- [ ] Widoki działają poprawnie
- [ ] Backup zrobiony

✅ **Jeśli wszystko zaznaczone - GOTOWE!**

---

## 📞 Pomoc

Jeśli gdzieś się zatknąłeś:
1. Sprawdź FAQ w README.md
2. Przeczytaj Messages w SSMS (dolny panel)
3. Google szukaj błędu
4. Otwórz Issue na GitHubie

---

**Ostatnia aktualizacja:** 3 grudnia 2025
**Wersja:** 1.0.0

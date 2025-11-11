# Comment Lancer JMeter

Guide complet pour exécuter vos tests de charge JMeter.

---

## Table des matières

1. [Prérequis](#1-prérequis)
2. [Méthode 1 : Interface Graphique (GUI)](#2-méthode-1--interface-graphique-gui)
3. [Méthode 2 : Ligne de Commande (Non-GUI)](#3-méthode-2--ligne-de-commande-non-gui)
4. [Scripts de Lancement Automatique](#4-scripts-de-lancement-automatique)
5. [Vérification des Résultats](#5-vérification-des-résultats)
6. [Dépannage](#6-dépannage)

---

## 1. Prérequis

### Vérifications avant de lancer

- ✅ **Backend démarré** : Votre serveur backend doit être en cours d'exécution sur `http://localhost:8080`
- ✅ **Base de données** : PostgreSQL doit être accessible et peuplée avec des données de test
- ✅ **Fichiers CSV** : Vérifier que les fichiers CSV existent :
  - `category_ids.csv`
  - `item_ids.csv`
  - `payloads_1k.csv` (pour les scénarios MIXED)
  - `payloads_5k.csv` (pour le scénario HEAVY-body)
- ✅ **InfluxDB** (optionnel) : Si vous voulez visualiser dans Grafana, InfluxDB doit être démarré

### Vérification rapide du backend

```bash
# Tester si le backend répond
curl http://localhost:8080/api/categories

# Ou ouvrir dans le navigateur
# http://localhost:8080/api/categories
```

---

## 2. Méthode 1 : Interface Graphique (GUI)

### Étape 1 : Démarrer JMeter

**Windows** :
```bash
# Option A : Double-cliquer sur jmeter.bat
# Chemin : C:\apache-jmeter-5.6.3\bin\jmeter.bat

# Option B : Via la ligne de commande
cd C:\apache-jmeter-5.6.3\bin
jmeter.bat
```

**Linux/Mac** :
```bash
cd /path/to/apache-jmeter-5.6.3/bin
./jmeter.sh
```

### Étape 2 : Ouvrir un fichier de test

1. Dans JMeter, cliquer sur **File** → **Open**
2. Naviguer vers votre répertoire de projet
3. Sélectionner un fichier `.jmx` :
   - `1_read_heavy.jmx`
   - `2_join_filter.jmx`
   - `3_mixed.jmx`
   - `4_heavy_body.jmx`

### Étape 3 : Vérifier la configuration

1. **Vérifier les chemins CSV** :
   - Ouvrir **CSV Data Set Config** (Category IDs, Item IDs, etc.)
   - Vérifier que les chemins des fichiers CSV sont corrects
   - Si nécessaire, mettre à jour avec des chemins absolus

2. **Vérifier les variables** :
   - Ouvrir **User Defined Variables** dans le Test Plan
   - Vérifier :
     - `HOST` = `localhost`
     - `PORT` = `8080`
     - `API_PATH` = `/api`

3. **Vérifier le Backend Listener** (si InfluxDB est utilisé) :
   - Vérifier que `influxdbUrl` pointe vers `http://localhost:8086`
   - Vérifier que le token est correct

### Étape 4 : Lancer le test

1. **Désactiver View Results Tree** (pour les performances) :
   - Clic droit sur **View Results Tree** → **Disable**
   - Ou le supprimer temporairement

2. **Lancer le test** :
   - Cliquer sur le bouton **▶ Start** (vert) dans la barre d'outils
   - Ou **Run** → **Start**

3. **Observer les résultats** :
   - Regarder **Summary Report** ou **Aggregate Report**
   - Les métriques se mettent à jour en temps réel

### Étape 5 : Arrêter le test

- Cliquer sur **⏹ Stop** (rouge) pour arrêter immédiatement
- Cliquer sur **⏸ Shutdown** pour arrêter gracieusement

---

## 3. Méthode 2 : Ligne de Commande (Non-GUI)

### Commande de base

```bash
jmeter -n -t <fichier_test.jmx> -l <fichier_resultats.jtl>
```

### Exemples pour vos scénarios

#### Scénario 1 : READ-heavy
```bash
jmeter -n -t 1_read_heavy.jmx -l results_read_heavy.jtl -e -o report_read_heavy
```

#### Scénario 2 : JOIN-filter
```bash
jmeter -n -t 2_join_filter.jmx -l results_join_filter.jtl -e -o report_join_filter
```

#### Scénario 3 : MIXED
```bash
jmeter -n -t 3_mixed.jmx -l results_mixed.jtl -e -o report_mixed
```

#### Scénario 4 : HEAVY-body
```bash
jmeter -n -t 4_heavy_body.jmx -l results_heavy_body.jtl -e -o report_heavy_body
```

### Options de la ligne de commande

| Option | Description |
|--------|-------------|
| `-n` | Mode non-GUI (obligatoire pour ligne de commande) |
| `-t` | Fichier de test (.jmx) |
| `-l` | Fichier de résultats (.jtl) |
| `-e` | Générer un rapport HTML après le test |
| `-o` | Répertoire de sortie pour le rapport HTML |
| `-J` | Définir une propriété JMeter |
| `-G` | Définir une propriété globale |
| `-H` | Proxy host |
| `-P` | Proxy port |
| `-u` | Username pour authentification |
| `-p` | Password pour authentification |

### Exemples avec options supplémentaires

```bash
# Avec propriétés personnalisées
jmeter -n -t 1_read_heavy.jmx -l results.jtl -JHOST=192.168.1.100 -JPORT=8080

# Avec proxy
jmeter -n -t 1_read_heavy.jmx -l results.jtl -H proxy.example.com -P 8080

# Avec rapport HTML détaillé
jmeter -n -t 1_read_heavy.jmx -l results.jtl -e -o report_html --jmeterproperty reportgenerator.exporter.html.series_filter="^(Success|Failure|Total)$"
```

---

## 4. Scripts de Lancement Automatique

### Script Windows : run_jmeter_test.bat

Créez un fichier `run_jmeter_test.bat` :

```batch
@echo off
echo ========================================
echo   Lancement Test JMeter
echo ========================================
echo.

if "%1"=="" (
    echo Usage: run_jmeter_test.bat <scenario>
    echo.
    echo Scenarios disponibles:
    echo   1 - READ-heavy
    echo   2 - JOIN-filter
    echo   3 - MIXED
    echo   4 - HEAVY-body
    echo.
    pause
    exit /b 1
)

set SCENARIO=%1
set JMETER_HOME=C:\apache-jmeter-5.6.3
set TEST_DIR=%~dp0

if "%SCENARIO%"=="1" (
    set TEST_FILE=1_read_heavy.jmx
    set RESULT_FILE=results_read_heavy.jtl
    set REPORT_DIR=report_read_heavy
) else if "%SCENARIO%"=="2" (
    set TEST_FILE=2_join_filter.jmx
    set RESULT_FILE=results_join_filter.jtl
    set REPORT_DIR=report_join_filter
) else if "%SCENARIO%"=="3" (
    set TEST_FILE=3_mixed.jmx
    set RESULT_FILE=results_mixed.jtl
    set REPORT_DIR=report_mixed
) else if "%SCENARIO%"=="4" (
    set TEST_FILE=4_heavy_body.jmx
    set RESULT_FILE=results_heavy_body.jtl
    set REPORT_DIR=report_heavy_body
) else (
    echo Scenario invalide: %SCENARIO%
    pause
    exit /b 1
)

echo [1/3] Verification du backend...
curl -s http://localhost:8080/api/categories >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Le backend n'est pas accessible sur http://localhost:8080
    echo Veuillez demarrer le backend avant de lancer le test
    pause
    exit /b 1
)
echo [OK] Backend accessible

echo.
echo [2/3] Lancement du test: %TEST_FILE%
echo.

"%JMETER_HOME%\bin\jmeter.bat" -n -t "%TEST_DIR%%TEST_FILE%" -l "%TEST_DIR%%RESULT_FILE%" -e -o "%TEST_DIR%%REPORT_DIR%"

if errorlevel 1 (
    echo.
    echo [ERREUR] Le test a echoue
    pause
    exit /b 1
)

echo.
echo [3/3] Test termine avec succes !
echo.
echo Resultats:
echo   - Fichier JTL: %RESULT_FILE%
echo   - Rapport HTML: %REPORT_DIR%\index.html
echo.
echo Ouvrir le rapport: start %REPORT_DIR%\index.html
echo.
pause
```

### Utilisation du script

```bash
# Lancer le scénario 1 (READ-heavy)
run_jmeter_test.bat 1

# Lancer le scénario 2 (JOIN-filter)
run_jmeter_test.bat 2

# Lancer le scénario 3 (MIXED)
run_jmeter_test.bat 3

# Lancer le scénario 4 (HEAVY-body)
run_jmeter_test.bat 4
```

### Script Linux/Mac : run_jmeter_test.sh

```bash
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./run_jmeter_test.sh <scenario>"
    echo ""
    echo "Scenarios disponibles:"
    echo "  1 - READ-heavy"
    echo "  2 - JOIN-filter"
    echo "  3 - MIXED"
    echo "  4 - HEAVY-body"
    exit 1
fi

SCENARIO=$1
JMETER_HOME=/path/to/apache-jmeter-5.6.3
TEST_DIR=$(dirname "$0")

case $SCENARIO in
    1)
        TEST_FILE=1_read_heavy.jmx
        RESULT_FILE=results_read_heavy.jtl
        REPORT_DIR=report_read_heavy
        ;;
    2)
        TEST_FILE=2_join_filter.jmx
        RESULT_FILE=results_join_filter.jtl
        REPORT_DIR=report_join_filter
        ;;
    3)
        TEST_FILE=3_mixed.jmx
        RESULT_FILE=results_mixed.jtl
        REPORT_DIR=report_mixed
        ;;
    4)
        TEST_FILE=4_heavy_body.jmx
        RESULT_FILE=results_heavy_body.jtl
        REPORT_DIR=report_heavy_body
        ;;
    *)
        echo "Scénario invalide: $SCENARIO"
        exit 1
        ;;
esac

echo "[1/3] Vérification du backend..."
if ! curl -s http://localhost:8080/api/categories > /dev/null; then
    echo "[ERREUR] Le backend n'est pas accessible sur http://localhost:8080"
    exit 1
fi
echo "[OK] Backend accessible"

echo ""
echo "[2/3] Lancement du test: $TEST_FILE"
echo ""

$JMETER_HOME/bin/jmeter -n -t "$TEST_DIR/$TEST_FILE" -l "$TEST_DIR/$RESULT_FILE" -e -o "$TEST_DIR/$REPORT_DIR"

if [ $? -ne 0 ]; then
    echo ""
    echo "[ERREUR] Le test a échoué"
    exit 1
fi

echo ""
echo "[3/3] Test terminé avec succès !"
echo ""
echo "Résultats:"
echo "  - Fichier JTL: $RESULT_FILE"
echo "  - Rapport HTML: $REPORT_DIR/index.html"
echo ""
```

Rendre exécutable :
```bash
chmod +x run_jmeter_test.sh
```

---

## 5. Vérification des Résultats

### Fichiers générés

Après l'exécution, vous aurez :

1. **Fichier .jtl** : Résultats bruts (CSV)
   - Exemple : `results_read_heavy.jtl`
   - Peut être ouvert dans Excel ou analysé avec des outils

2. **Rapport HTML** (si `-e -o` utilisé) :
   - Exemple : `report_read_heavy/index.html`
   - Ouvrir dans un navigateur pour voir les graphiques

### Visualiser le rapport HTML

```bash
# Windows
start report_read_heavy\index.html

# Linux
xdg-open report_read_heavy/index.html

# Mac
open report_read_heavy/index.html
```

### Visualiser dans Grafana

Si InfluxDB est configuré :
1. Ouvrir Grafana : http://localhost:3000
2. Ouvrir le dashboard JMeter
3. Les métriques apparaissent en temps réel pendant le test

### Analyser le fichier .jtl

Le fichier `.jtl` contient :
- Timestamp
- Temps de réponse
- Statut (succès/échec)
- Nombre d'octets
- Etc.

Ouvrir dans Excel ou utiliser des outils d'analyse.

---

## 6. Dépannage

### Erreur : Cannot find JMeter

**Solution** :
- Vérifier que JMeter est installé
- Ajouter JMeter au PATH
- Ou utiliser le chemin complet : `C:\apache-jmeter-5.6.3\bin\jmeter.bat`

### Erreur : File not found (fichier .jmx)

**Solution** :
- Vérifier que vous êtes dans le bon répertoire
- Utiliser un chemin absolu
- Vérifier que le fichier existe

### Erreur : CSV file not found

**Solution** :
- Vérifier les chemins dans les CSV Data Set Config
- Utiliser des chemins absolus
- Vérifier que les fichiers CSV existent

### Erreur : Connection refused

**Solution** :
- Vérifier que le backend est démarré
- Vérifier HOST et PORT dans les variables
- Tester avec curl : `curl http://localhost:8080/api/categories`

### Erreur : Out of memory

**Solution** :
- Augmenter la mémoire JMeter
- Modifier `jmeter.bat` ou `jmeter.sh` :
  ```bash
  set HEAP=-Xms1g -Xmx4g -XX:MaxMetaspaceSize=256m
  ```

### Test trop lent

**Solutions** :
- Désactiver View Results Tree
- Réduire le nombre de threads
- Utiliser le mode non-GUI (`-n`)
- Désactiver les listeners inutiles

---

## Commandes Rapides

### Windows

```bash
# Lancer un test simple
jmeter -n -t 1_read_heavy.jmx -l results.jtl

# Avec rapport HTML
jmeter -n -t 1_read_heavy.jmx -l results.jtl -e -o report

# Vérifier la syntaxe du fichier
jmeter -t 1_read_heavy.jmx -l /dev/null -n
```

### Linux/Mac

```bash
# Lancer un test simple
./jmeter.sh -n -t 1_read_heavy.jmx -l results.jtl

# Avec rapport HTML
./jmeter.sh -n -t 1_read_heavy.jmx -l results.jtl -e -o report
```

---

## Conseils de Performance

1. **Utiliser le mode non-GUI** : Plus rapide et consomme moins de ressources
2. **Désactiver les listeners** : View Results Tree, etc.
3. **Utiliser des rapports HTML** : Générés après le test, pas pendant
4. **Surveiller les ressources** : CPU, RAM, réseau
5. **Tester progressivement** : Commencer avec peu de threads, puis augmenter

---

## Exemple de Workflow Complet

```bash
# 1. Vérifier le backend
curl http://localhost:8080/api/categories

# 2. Vérifier InfluxDB (si utilisé)
curl http://localhost:8086/health

# 3. Lancer le test
jmeter -n -t 1_read_heavy.jmx -l results.jtl -e -o report

# 4. Ouvrir le rapport
start report\index.html

# 5. Visualiser dans Grafana (si configuré)
# Ouvrir http://localhost:3000
```

---

**Dernière mise à jour** : Guide complet pour lancer JMeter


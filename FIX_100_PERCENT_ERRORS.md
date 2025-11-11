# Solution : 100% d'erreurs JMeter

Le backend fonctionne (testé avec curl), donc le problème est dans la configuration JMeter.

## Diagnostic rapide

### Étape 1 : Ouvrir JMeter en mode GUI

```bash
C:\JMeter\bin\jmeter.bat
```

### Étape 2 : Charger le test et activer View Results Tree

1. **File** → **Open** → `1_read_heavy.jmx`
2. **View Results Tree** → Clic droit → **Enable**
3. Modifier le Thread Group :
   - Number of Threads: **1**
   - Ramp-up: **1**
   - Loop Count: **1**
4. **Run** → **Start**
5. Cliquer sur la première requête dans View Results Tree

### Étape 3 : Vérifier l'erreur

Regardez :
- **Response Code** : Quel code HTTP ? (404, 500, etc.)
- **Response Message** : Quel message d'erreur ?
- **Request** : Quelle URL est appelée ?

## Causes probables

### 1. Fichiers CSV introuvables

**Symptôme** : Variables `${csvCatId}` ou `${csvItemId}` vides

**Solution** :
1. Vérifier que les fichiers existent :
   ```bash
   dir category_ids.csv
   dir item_ids.csv
   ```

2. Vérifier les chemins dans JMeter :
   - Ouvrir **CSV Data Set Config** (Category IDs)
   - Vérifier le chemin : `C:/Users/ULTRA PC/Desktop/architecture/TP-binome/V-A/category_ids.csv`
   - Utiliser des **chemins absolus**

### 2. Variables CSV non définies

**Symptôme** : Les requêtes utilisent `${csvCatId}` mais la variable est vide

**Solution** :
1. Vérifier que les CSV Data Set Config sont **avant** les HTTP Requests
2. Vérifier que `variableNames` = `csvCatId` (pas d'espace)
3. Vérifier que `recycle` = `true`

### 3. Chemin d'URL incorrect

**Symptôme** : 404 Not Found

**Vérification** :
- HTTP Request Defaults : Path = `${API_PATH}` = `/api`
- HTTP Request : Path = `/items`
- URL finale devrait être : `http://localhost:8080/api/items`

**Si l'URL est incorrecte** :
- Vérifier que les chemins ne sont pas dupliqués
- Vérifier les variables HOST, PORT, API_PATH

### 4. Problème avec les IDs dans les CSV

**Symptôme** : 404 Not Found pour des IDs spécifiques

**Solution** :
1. Vérifier que les IDs dans `category_ids.csv` existent dans la base de données
2. Tester manuellement :
   ```bash
   curl.exe "http://localhost:8080/api/items?categoryId=1"
   ```

## Solution rapide : Test minimal

Créez un test minimal pour isoler le problème :

1. **Nouveau Test Plan**
2. **Thread Group** (1 thread, 1 loop)
3. **HTTP Request Defaults** :
   - Server: `localhost`
   - Port: `8080`
   - Path: `/api`
4. **HTTP Request** :
   - Method: GET
   - Path: `/categories`
5. **View Results Tree**
6. **Lancer**

Si ce test fonctionne → Le problème est dans votre configuration
Si ce test échoue → Vérifier la connexion au backend

## Vérifications spécifiques

### Vérifier les fichiers CSV

```bash
# Vérifier que les fichiers existent
dir "C:\Users\ULTRA PC\Desktop\architecture\TP-binome\V-A\category_ids.csv"
dir "C:\Users\ULTRA PC\Desktop\architecture\TP-binome\V-A\item_ids.csv"

# Vérifier le contenu (premières lignes)
type category_ids.csv | more
```

### Vérifier les variables dans JMeter

1. Ouvrir le test plan
2. **User Defined Variables** :
   - `HOST` = `localhost`
   - `PORT` = `8080`
   - `API_PATH` = `/api`

### Vérifier l'ordre des éléments

L'ordre doit être :
1. **User Defined Variables** (dans Test Plan)
2. **HTTP Request Defaults**
3. **CSV Data Set Config** (avant les HTTP Requests)
4. **HTTP Requests**

## Solution probable : Fichiers CSV

Le problème le plus probable est que les fichiers CSV ne sont pas lus correctement.

### Solution 1 : Vérifier les chemins

Dans JMeter, pour chaque **CSV Data Set Config** :
- Utiliser un chemin absolu
- Vérifier que le fichier existe
- Vérifier les permissions de lecture

### Solution 2 : Tester sans CSV

Temporairement, remplacez `${csvCatId}` par une valeur fixe (ex: `1`) pour voir si ça fonctionne.

## Action immédiate

1. **Ouvrir JMeter GUI**
2. **Charger `1_read_heavy.jmx`**
3. **Activer View Results Tree**
4. **Modifier Thread Group** : 1 thread, 1 loop
5. **Lancer le test**
6. **Regarder la première requête** dans View Results Tree
7. **Me donner** :
   - Response Code
   - Response Message
   - L'URL complète dans Request

Avec ces informations, je pourrai identifier le problème exact !


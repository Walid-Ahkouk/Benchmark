# Dépannage JMeter - 100% d'erreurs

## Problème : 100% d'erreurs dans les résultats JMeter

```
Err: 1125226 (100.00%)
```

Toutes les requêtes échouent. Voici comment diagnostiquer et résoudre.

---

## 1. Vérifications de base

### Vérifier que le backend fonctionne

```bash
# Test manuel du backend
curl.exe http://localhost:8080/api/categories

# Devrait retourner du JSON, pas une erreur
```

**Si ça ne fonctionne pas** :
- Vérifier que le backend est démarré
- Vérifier le port (8080)
- Vérifier les logs du backend

### Vérifier la configuration JMeter

1. **Ouvrir le fichier .jmx dans JMeter**
2. **Vérifier HTTP Request Defaults** :
   - Server Name: `localhost` ou `${HOST}`
   - Port: `8080` ou `${PORT}`
   - Path: `/api` ou `${API_PATH}`

3. **Vérifier les variables utilisateur** :
   - `HOST` = `localhost`
   - `PORT` = `8080`
   - `API_PATH` = `/api`

---

## 2. Analyser les erreurs détaillées

### Méthode 1 : View Results Tree (dans JMeter GUI)

1. Ouvrir JMeter en mode GUI
2. Charger votre test plan
3. **Activer View Results Tree** (clic droit → Enable)
4. Lancer le test
5. Cliquer sur chaque requête pour voir :
   - **Response Code** : Quel code HTTP est retourné ?
   - **Response Data** : Quel est le message d'erreur ?
   - **Request** : La requête est-elle correcte ?

### Méthode 2 : Analyser le fichier .jtl

```bash
# Ouvrir le fichier results.jtl dans un éditeur de texte
# Chercher les lignes avec "false" (erreurs)
# Regarder la colonne "responseMessage"
```

### Méthode 3 : Vérifier les logs JMeter

Les erreurs sont aussi dans la console où vous avez lancé JMeter.

---

## 3. Erreurs courantes et solutions

### Erreur : Connection refused / ConnectException

**Cause** : Le backend n'est pas accessible

**Solutions** :
```bash
# 1. Vérifier que le backend est démarré
# 2. Vérifier le port
netstat -an | findstr :8080

# 3. Tester manuellement
curl.exe http://localhost:8080/api/categories

# 4. Vérifier le firewall Windows
```

### Erreur : 404 Not Found

**Cause** : Mauvais chemin d'endpoint

**Solutions** :
1. Vérifier que `API_PATH` = `/api`
2. Vérifier les chemins dans les HTTP Request :
   - Devrait être `/items` pas `/api/items` (car API_PATH est déjà dans HTTP Request Defaults)
3. Tester manuellement :
   ```bash
   curl.exe http://localhost:8080/api/items
   curl.exe http://localhost:8080/api/categories
   ```

### Erreur : 400 Bad Request

**Cause** : Requête mal formée

**Solutions** :
1. **Pour POST/PUT** : Vérifier le format JSON
2. **Pour POST /items** : Vérifier que `categoryId` est fourni en query parameter
3. Vérifier le Content-Type header : `application/json`

### Erreur : 500 Internal Server Error

**Cause** : Erreur côté serveur

**Solutions** :
1. Vérifier les logs du backend
2. Vérifier la base de données (connexion, données)
3. Tester manuellement avec curl pour voir l'erreur exacte

### Erreur : Timeout / Read timed out

**Cause** : Le backend est trop lent ou surchargé

**Solutions** :
1. Augmenter le timeout dans JMeter :
   - HTTP Request → Advanced → Timeouts
   - Connect: 60000 ms
   - Response: 60000 ms
2. Réduire le nombre de threads
3. Vérifier les performances du backend

### Erreur : CSV file not found

**Cause** : Fichiers CSV introuvables

**Solutions** :
1. Vérifier les chemins dans CSV Data Set Config
2. Utiliser des chemins absolus :
   ```
   C:\Users\ULTRA PC\Desktop\architecture\TP-binome\V-A\category_ids.csv
   ```
3. Vérifier que les fichiers existent

---

## 4. Test de diagnostic rapide

### Créer un test simple

1. **Ouvrir JMeter**
2. **Créer un nouveau Test Plan**
3. **Ajouter Thread Group** :
   - Number of Threads: 1
   - Ramp-up: 1
   - Loop Count: 1

4. **Ajouter HTTP Request Defaults** :
   - Server: `localhost`
   - Port: `8080`
   - Path: `/api`

5. **Ajouter HTTP Request** :
   - Method: GET
   - Path: `/categories`

6. **Ajouter View Results Tree**

7. **Lancer le test**

Si ce test simple fonctionne, le problème est dans votre configuration de test.
Si ce test échoue, le problème est la connexion au backend.

---

## 5. Vérifications spécifiques pour vos scénarios

### Scénario READ-heavy

**Vérifier** :
1. Les endpoints GET fonctionnent :
   ```bash
   curl.exe http://localhost:8080/api/items?page=1&size=50
   curl.exe http://localhost:8080/api/categories?page=1&size=50
   ```

2. Les fichiers CSV existent :
   - `category_ids.csv`
   - `item_ids.csv`

3. Les IDs dans les CSV sont valides (existent dans la base de données)

### Scénario MIXED / HEAVY-body

**Vérifier** :
1. Les endpoints POST fonctionnent :
   ```bash
   curl.exe -X POST http://localhost:8080/api/categories ^
     -H "Content-Type: application/json" ^
     -d "{\"code\":\"TEST\",\"name\":\"Test Category\"}"
   ```

2. Le format des payloads dans `payloads_1k.csv` et `payloads_5k.csv` :
   - Doit être du JSON valide
   - Une ligne = un objet JSON complet

3. Pour POST /items, vérifier que `categoryId` est fourni :
   ```bash
   curl.exe -X POST "http://localhost:8080/api/items?categoryId=1" ^
     -H "Content-Type: application/json" ^
     -d "{\"sku\":\"TEST\",\"name\":\"Test\",\"price\":10.0,\"stock\":100}"
   ```

---

## 6. Script de diagnostic

Créez un fichier `test_backend.bat` :

```batch
@echo off
echo ========================================
echo   Test de Diagnostic Backend
echo ========================================
echo.

echo [1/5] Test GET /categories
curl.exe -v http://localhost:8080/api/categories
echo.
echo.

echo [2/5] Test GET /categories avec pagination
curl.exe -v "http://localhost:8080/api/categories?page=1&size=10"
echo.
echo.

echo [3/5] Test GET /items
curl.exe -v "http://localhost:8080/api/items?page=1&size=10"
echo.
echo.

echo [4/5] Test GET /items avec categoryId
curl.exe -v "http://localhost:8080/api/items?categoryId=1&page=1&size=10"
echo.
echo.

echo [5/5] Test GET /categories/{id}/items
curl.exe -v "http://localhost:8080/api/categories/1/items?page=1&size=10"
echo.
echo.

echo ========================================
echo   Diagnostic termine
echo ========================================
pause
```

Exécutez ce script pour voir quels endpoints fonctionnent.

---

## 7. Solutions rapides

### Solution 1 : Vérifier les chemins dans HTTP Request

Dans vos fichiers .jmx, vérifiez que les chemins sont corrects :

**Correct** :
- HTTP Request Defaults : Path = `/api`
- HTTP Request : Path = `/items` (pas `/api/items`)

**Incorrect** :
- HTTP Request Defaults : Path = `/api`
- HTTP Request : Path = `/api/items` (doublon)

### Solution 2 : Vérifier les variables

Assurez-vous que les variables sont définies dans "User Defined Variables" :
- `HOST` = `localhost`
- `PORT` = `8080`
- `API_PATH` = `/api`

### Solution 3 : Tester avec un seul thread

1. Ouvrir le test dans JMeter
2. Modifier le Thread Group :
   - Number of Threads: 1
   - Ramp-up: 1
   - Loop Count: 1
3. Activer View Results Tree
4. Lancer le test
5. Analyser la première requête

### Solution 4 : Vérifier les logs du backend

Les logs du backend peuvent indiquer le problème :
- Erreurs de connexion base de données
- Erreurs de parsing JSON
- Erreurs de validation

---

## 8. Checklist de vérification

- [ ] Backend démarré et accessible sur port 8080
- [ ] Test manuel avec curl fonctionne
- [ ] Variables JMeter correctes (HOST, PORT, API_PATH)
- [ ] Chemins des endpoints corrects (pas de doublon avec API_PATH)
- [ ] Fichiers CSV existent et sont accessibles
- [ ] Content-Type header présent pour POST/PUT
- [ ] Format JSON valide dans les payloads
- [ ] View Results Tree activé pour voir les erreurs détaillées
- [ ] Logs du backend vérifiés

---

## 9. Commandes utiles

```bash
# Vérifier que le port 8080 est utilisé
netstat -an | findstr :8080

# Tester un endpoint spécifique
curl.exe -v http://localhost:8080/api/categories

# Tester avec des paramètres
curl.exe -v "http://localhost:8080/api/items?page=1&size=50&categoryId=1"

# Tester POST
curl.exe -X POST http://localhost:8080/api/categories ^
  -H "Content-Type: application/json" ^
  -d "{\"code\":\"TEST\",\"name\":\"Test\"}"

# Voir les erreurs JMeter en détail
# Ouvrir View Results Tree dans JMeter GUI
```

---

## 10. Prochaines étapes

1. **Exécuter le script de diagnostic** (`test_backend.bat`)
2. **Ouvrir JMeter en mode GUI** et activer View Results Tree
3. **Lancer un test simple** (1 thread, 1 requête)
4. **Analyser la première erreur** dans View Results Tree
5. **Corriger le problème** identifié
6. **Relancer le test**

---

**Dernière mise à jour** : Guide de dépannage pour 100% d'erreurs JMeter


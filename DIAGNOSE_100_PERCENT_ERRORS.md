# Diagnostic : 100% d'erreurs JMeter

Le test se lance maintenant, mais toutes les requêtes échouent. Voici comment diagnostiquer.

## Diagnostic immédiat

### Étape 1 : Vérifier dans JMeter GUI

1. **Ouvrir JMeter en mode GUI** :
   ```bash
   C:\JMeter\bin\jmeter.bat
   ```

2. **Charger le test** : File → Open → `1_read_heavy.jmx`

3. **Ajouter View Results Tree** (si pas déjà présent) :
   - Clic droit sur Thread Group → Add → Listener → View Results Tree

4. **Modifier le Thread Group pour tester** :
   - Number of Threads: **1**
   - Ramp-up: **1**
   - Loop Count: **1**

5. **Lancer le test** : Run → Start

6. **Cliquer sur la première requête** dans View Results Tree

7. **Regarder** :
   - **Response Code** : Quel code HTTP ? (404, 500, Connection refused, etc.)
   - **Response Message** : Quel message d'erreur exact ?
   - **Request** : Quelle URL complète est appelée ?
   - **Response Data** : Quel est le contenu de la réponse ?

## Causes probables

### 1. Variables CSV vides

**Symptôme** : Les requêtes utilisent `${csvCatId}` mais la variable est vide

**Vérification** :
- Dans View Results Tree, regarder l'onglet "Request"
- Chercher `categoryId=` dans l'URL
- Si c'est vide ou `${csvCatId}`, le CSV n'est pas chargé

**Solution** :
- Vérifier que les fichiers CSV existent
- Vérifier les chemins dans CSV Data Set Config
- Vérifier que `variableNames` = `csvCatId` (sans espace)

### 2. Fichiers CSV introuvables

**Vérification** :
```bash
dir "C:\Users\ULTRA PC\Desktop\architecture\TP-binome\V-A\category_ids.csv"
dir "C:\Users\ULTRA PC\Desktop\architecture\TP-binome\V-A\item_ids.csv"
```

**Si les fichiers n'existent pas** :
- Créer les fichiers CSV
- Ou mettre à jour les chemins dans JMeter

### 3. URL incorrecte

**Vérification** :
- Dans View Results Tree → Request
- L'URL devrait être : `http://localhost:8080/api/items?page=1&size=50`
- Pas : `http://localhost:8080/api/api/items` (doublon)
- Pas : `http://localhost:8080/items` (manque /api)

### 4. Backend non accessible

**Vérification** :
- Le backend doit être démarré
- Tester manuellement : `curl.exe http://localhost:8080/api/categories`

## Solution rapide : Test minimal

Créez un test minimal pour isoler le problème :

1. **Nouveau Test Plan** dans JMeter
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

Si ce test simple fonctionne → Le problème est dans votre configuration
Si ce test échoue → Le problème est la connexion au backend

## Action immédiate

**Ouvrez JMeter GUI et regardez View Results Tree pour voir l'erreur exacte !**

C'est la seule façon de savoir pourquoi 100% des requêtes échouent.


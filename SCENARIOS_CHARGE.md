# Scénarios de Charge JMeter

Ce document décrit les 4 scénarios de charge créés pour tester le backend.

## Fichiers de Test

1. **1_read_heavy.jmx** - Scénario READ-heavy (relation incluse)
2. **2_join_filter.jmx** - Scénario JOIN-filter ciblé
3. **3_mixed.jmx** - Scénario MIXED (écritures sur deux entités)
4. **4_heavy_body.jmx** - Scénario HEAVY-body (payload 5 KB)

---

## Scénario 1: READ-heavy (relation incluse)

**Fichier**: `1_read_heavy.jmx`

### Distribution des requêtes
- **50%** - `GET /items?page=1&size=50`
- **20%** - `GET /items?categoryId=...&page=1&size=50`
- **20%** - `GET /categories/{id}/items?page=1&size=50`
- **10%** - `GET /categories?page=1&size=50`

### Configuration de charge
- **Concurrence**: 50 → 100 → 200 threads (paliers)
- **Ramp-up**: 60 secondes
- **Durée par palier**: 10 minutes (600 secondes)

### Fichiers CSV requis
- `category_ids.csv` - IDs des catégories
- `item_ids.csv` - IDs des items

---

## Scénario 2: JOIN-filter ciblé

**Fichier**: `2_join_filter.jmx`

### Distribution des requêtes
- **70%** - `GET /items?categoryId=...&page=1&size=50`
- **30%** - `GET /items/{id}`

### Configuration de charge
- **Concurrence**: 60 → 120 threads
- **Ramp-up**: 60 secondes
- **Durée par palier**: 8 minutes (480 secondes)

### Fichiers CSV requis
- `category_ids.csv` - IDs des catégories
- `item_ids.csv` - IDs des items

---

## Scénario 3: MIXED (écritures sur deux entités)

**Fichier**: `3_mixed.jmx`

### Distribution des requêtes
- **40%** - `GET /items?page=1&size=50`
- **20%** - `POST /items?categoryId=...` (payload 1 KB)
- **10%** - `PUT /items/{id}` (payload 1 KB)
- **10%** - `DELETE /items/{id}`
- **10%** - `POST /categories` (payload 0.5-1 KB)
- **10%** - `PUT /categories/{id}`

### Configuration de charge
- **Concurrence**: 50 → 100 threads
- **Ramp-up**: 60 secondes
- **Durée par palier**: 10 minutes (600 secondes)

### Fichiers CSV requis
- `category_ids.csv` - IDs des catégories
- `item_ids.csv` - IDs des items
- `payloads_1k.csv` - Payloads JSON de 1 KB pour items

### Notes
- Les payloads pour POST/PUT categories sont générés dynamiquement avec des fonctions JMeter
- Les payloads pour POST/PUT items proviennent du fichier CSV

---

## Scénario 4: HEAVY-body (payload 5 KB)

**Fichier**: `4_heavy_body.jmx`

### Distribution des requêtes
- **50%** - `POST /items?categoryId=...` (payload 5 KB)
- **50%** - `PUT /items/{id}` (payload 5 KB)

### Configuration de charge
- **Concurrence**: 30 → 60 threads
- **Ramp-up**: 60 secondes
- **Durée par palier**: 8 minutes (480 secondes)

### Fichiers CSV requis
- `category_ids.csv` - IDs des catégories
- `item_ids.csv` - IDs des items
- `payloads_5k.csv` - Payloads JSON de 5 KB

---

## Configuration Commune

### Variables utilisateur (User Defined Variables)

Tous les scénarios utilisent ces variables configurables :

| Variable | Valeur par défaut | Description |
|----------|-------------------|-------------|
| `HOST` | `localhost` | Adresse du serveur backend |
| `PORT` | `8080` | Port du serveur backend |
| `API_PATH` | `/api` | Chemin de base de l'API |
| `PAGE_SIZE` | `50` | Taille de page pour la pagination |
| `RAMP_UP` | `60` | Temps de montée en charge (secondes) |
| `PALIER_DURATION` | Variable selon scénario | Durée de chaque palier (secondes) |

### Configuration HTTP

- **Protocole**: HTTP
- **Implémentation**: HttpClient4
- **Content-Type**: `application/json` (pour POST/PUT)
- **Keep-Alive**: Activé

### Backend Listener (InfluxDB)

Tous les scénarios incluent un Backend Listener configuré pour InfluxDB :
- **URL**: `http://localhost:8086/api/v2/write?org=myorg&bucket=jmeter`
- **Application**: `benchmark-va`
- **Percentiles**: 90, 95, 99

---

## Prérequis

### 1. Installation JMeter
- JMeter 5.6.3 ou supérieur
- Plugin **Stepping Thread Group** (jp@gc)

### 2. Fichiers CSV
Assurez-vous que les fichiers CSV suivants existent dans le répertoire du projet :
- `category_ids.csv` - Liste des IDs de catégories (une par ligne)
- `item_ids.csv` - Liste des IDs d'items (une par ligne)
- `payloads_1k.csv` - Payloads JSON de 1 KB (une par ligne)
- `payloads_5k.csv` - Payloads JSON de 5 KB (une par ligne)

### 3. Backend
- Le serveur backend doit être démarré sur `http://localhost:8080`
- La base de données doit être accessible et peuplée avec des données de test

### 4. InfluxDB (optionnel)
- InfluxDB doit être démarré si vous souhaitez utiliser le Backend Listener
- Configuration : `http://localhost:8086`
- Organisation : `myorg`
- Bucket : `jmeter`

---

## Exécution des Tests

### Via l'interface graphique JMeter
1. Ouvrir JMeter
2. Charger le fichier `.jmx` souhaité
3. Vérifier les chemins des fichiers CSV (chemins absolus)
4. Cliquer sur "Run" → "Start"

### Via la ligne de commande
```bash
jmeter -n -t 1_read_heavy.jmx -l results_read_heavy.jtl -e -o report_read_heavy
```

Options :
- `-n` : Mode non-GUI
- `-t` : Fichier de test
- `-l` : Fichier de résultats
- `-e` : Générer un rapport HTML
- `-o` : Répertoire de sortie du rapport

---

## Format des Fichiers CSV

### category_ids.csv
```
1
2
3
...
```

### item_ids.csv
```
1
2
3
...
```

### payloads_1k.csv
```
{"sku":"SKU-1K-001","name":"...","price":19.99,"stock":100,"categoryId":1}
{"sku":"SKU-1K-002","name":"...","price":29.99,"stock":200,"categoryId":2}
...
```

### payloads_5k.csv
```
{"sku":"SKU-5K-001","name":"...","price":99.99,"stock":50,"categoryId":2}
{"sku":"SKU-5K-002","name":"...","price":199.99,"stock":100,"categoryId":3}
...
```

**Note**: Les payloads doivent être des objets JSON valides sur une seule ligne, sans saut de ligne.

---

## Personnalisation

### Modifier les chemins CSV
Dans chaque fichier `.jmx`, rechercher les éléments `CSVDataSet` et modifier la propriété `filename` :

```xml
<stringProp name="filename">C:/Users/ULTRA PC/Desktop/architecture/TP-binome/V-A/category_ids.csv</stringProp>
```

### Modifier la distribution des requêtes
Ajuster les valeurs `percentThroughput` dans les `ThroughputController` :

```xml
<FloatProperty>
  <name>ThroughputController.percentThroughput</name>
  <value>50.0</value>  <!-- Modifier cette valeur -->
</FloatProperty>
```

### Modifier la configuration de charge
Dans les variables utilisateur ou directement dans le `SteppingThreadGroup` :
- `StartUsersCount` : Nombre initial d'utilisateurs
- `ThreadGroup.num_threads` : Nombre maximum d'utilisateurs
- `rampUp` : Temps de montée en charge
- `flighttime` : Durée de chaque palier

---

## Analyse des Résultats

### Métriques importantes
- **Throughput** : Requêtes par seconde
- **Response Time** : Temps de réponse (moyenne, médiane, p90, p95, p99)
- **Error Rate** : Taux d'erreur (%)
- **Active Threads** : Nombre de threads actifs

### Rapports JMeter
- **Summary Report** : Vue d'ensemble des résultats
- **Aggregate Report** : Statistiques agrégées
- **View Results Tree** : Détails de chaque requête (désactiver en production)

### InfluxDB + Grafana
Si InfluxDB est configuré, visualiser les métriques en temps réel avec Grafana.

---

## Dépannage

### Erreur : Fichier CSV non trouvé
- Vérifier que les chemins absolus dans les `CSVDataSet` sont corrects
- Vérifier que les fichiers CSV existent et sont accessibles

### Erreur : Connection refused
- Vérifier que le backend est démarré sur le port 8080
- Vérifier les variables `HOST` et `PORT`

### Erreur : 404 Not Found
- Vérifier que `API_PATH` est défini à `/api`
- Vérifier que les endpoints sont corrects

### Erreur : 400 Bad Request
- Vérifier le format des payloads JSON
- Vérifier que `categoryId` est fourni pour POST /items
- Vérifier le Content-Type header

---

## Notes Importantes

1. **Stepping Thread Group** : Ce plugin doit être installé pour que les tests fonctionnent
2. **Chemins absolus** : Les chemins CSV utilisent des chemins absolus Windows - adapter selon votre système
3. **Données de test** : S'assurer que la base de données contient suffisamment de données pour les tests
4. **Ressources système** : Surveiller l'utilisation CPU/RAM pendant les tests
5. **Backend Listener** : Désactiver si InfluxDB n'est pas disponible

---

**Dernière mise à jour** : Basé sur les spécifications des scénarios de charge


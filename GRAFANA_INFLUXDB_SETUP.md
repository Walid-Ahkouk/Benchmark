# Configuration Grafana et InfluxDB pour JMeter

Ce guide explique comment configurer InfluxDB et Grafana pour visualiser les métriques de performance JMeter en temps réel.

---

## Table des matières

1. [Installation d'InfluxDB](#1-installation-dinfluxdb)
2. [Configuration d'InfluxDB](#2-configuration-dinfluxdb)
3. [Configuration JMeter pour InfluxDB](#3-configuration-jmeter-pour-influxdb)
4. [Installation de Grafana](#4-installation-de-grafana)
5. [Configuration de Grafana](#5-configuration-de-grafana)
6. [Création d'un Dashboard JMeter](#6-création-dun-dashboard-jmeter)
7. [Dépannage](#7-dépannage)

---

## 1. Installation d'InfluxDB

### Option A: Installation via Docker (Recommandé)

```bash
# Créer un réseau Docker
docker network create jmeter-network

# Lancer InfluxDB 2.x
docker run -d \
  --name influxdb \
  --network jmeter-network \
  -p 8086:8086 \
  -v influxdb-storage:/var/lib/influxdb2 \
  -v influxdb-config:/etc/influxdb2 \
  -e DOCKER_INFLUXDB_INIT_MODE=setup \
  -e DOCKER_INFLUXDB_INIT_USERNAME=admin \
  -e DOCKER_INFLUXDB_INIT_PASSWORD=admin123 \
  -e DOCKER_INFLUXDB_INIT_ORG=myorg \
  -e DOCKER_INFLUXDB_INIT_BUCKET=jmeter \
  -e DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=0g6tixIL9cA2cqiuYKCXU3IjW1z_0Xg53stFC75BuEaS9w1uaeXejWJKTiyarp5f8OVLv6SEokreKWN3nZE22A== \
  influxdb:2.7
```

### Option B: Installation Windows (Téléchargement)

1. Télécharger InfluxDB 2.x depuis : https://www.influxdata.com/downloads/
2. Extraire l'archive
3. Exécuter `influxd.exe` depuis le répertoire d'extraction

### Option C: Installation Linux

```bash
# Ubuntu/Debian
wget https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.4-linux-amd64.tar.gz
tar xvzf influxdb2-2.7.4-linux-amd64.tar.gz
cd influxdb2-2.7.4-linux-amd64
./influxd
```

---

## 2. Configuration d'InfluxDB

### Configuration initiale (Premier démarrage)

1. **Accéder à l'interface web** : http://localhost:8086

2. **Configuration initiale** (si pas déjà fait via Docker) :
   - **Username** : `admin`
   - **Password** : `admin123` (ou votre mot de passe)
   - **Organization** : `myorg`
   - **Bucket** : `jmeter`

3. **Créer un Token API** :
   - Aller dans **Data** → **Tokens** → **Generate API Token**
   - Sélectionner **Read/Write Token**
   - Scope : **Read/Write** pour le bucket `jmeter`
   - Copier le token généré (exemple : `0g6tixIL9cA2cqiuYKCXU3IjW1z_0Xg53stFC75BuEaS9w1uaeXejWJKTiyarp5f8OVLv6SEokreKWN3nZE22A==`)

4. **Vérifier le bucket** :
   - Aller dans **Data** → **Buckets**
   - Vérifier que le bucket `jmeter` existe
   - Si non, créer un nouveau bucket nommé `jmeter`

### Vérification de la connexion

```bash
# Tester la connexion avec curl
curl http://localhost:8086/health
```

Résultat attendu : `{"status":"ok"}`

---

## 3. Configuration JMeter pour InfluxDB

### Les fichiers JMeter sont déjà configurés !

Les fichiers de test (`1_read_heavy.jmx`, `2_join_filter.jmx`, `3_mixed.jmx`, `4_heavy_body.jmx`) contiennent déjà un **Backend Listener** configuré pour InfluxDB.

### Vérification de la configuration

Ouvrez un fichier `.jmx` dans JMeter et vérifiez le **Backend Listener** :

1. **Classe** : `org.apache.jmeter.visualizers.backend.influxdb.InfluxdbBackendListenerClient`
2. **Paramètres** :
   - `influxdbUrl` : `http://localhost:8086/api/v2/write?org=myorg&bucket=jmeter`
   - `influxdbToken` : Votre token API (à mettre à jour si différent)
   - `application` : `benchmark-va`
   - `measurement` : `jmeter`

### Mise à jour du token (si nécessaire)

Si votre token InfluxDB est différent, modifiez-le dans chaque fichier `.jmx` :

1. Ouvrir le fichier `.jmx` dans un éditeur de texte
2. Rechercher : `<stringProp name="Argument.name">influxdbToken</stringProp>`
3. Mettre à jour la valeur dans la ligne suivante

Ou via l'interface JMeter :
1. Ouvrir JMeter
2. Charger le test plan
3. Sélectionner **Backend Listener**
4. Modifier le paramètre `influxdbToken`

### Installation du plugin JMeter (si nécessaire)

Le Backend Listener InfluxDB est inclus dans JMeter 5.2+. Si vous utilisez une version antérieure :

1. Télécharger le plugin : https://jmeter-plugins.org/
2. Installer via JMeter Plugins Manager :
   - Options → Plugins Manager
   - Rechercher "InfluxDB Backend Listener"
   - Installer

---

## 4. Installation de Grafana

### Option A: Installation via Docker (Recommandé)

```bash
# Lancer Grafana
docker run -d \
  --name grafana \
  --network jmeter-network \
  -p 3000:3000 \
  -v grafana-storage:/var/lib/grafana \
  grafana/grafana:latest
```

### Option B: Installation Windows

1. Télécharger Grafana depuis : https://grafana.com/grafana/download?platform=windows
2. Installer le fichier `.msi`
3. Grafana démarrera automatiquement comme service Windows

### Option C: Installation Linux

```bash
# Ubuntu/Debian
sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```

### Accès à Grafana

- **URL** : http://localhost:3000
- **Identifiants par défaut** :
  - Username : `admin`
  - Password : `admin`
  - (Vous serez invité à changer le mot de passe au premier login)

---

## 5. Configuration de Grafana

### Étape 1: Ajouter InfluxDB comme source de données

1. **Se connecter à Grafana** : http://localhost:3000

2. **Ajouter une source de données** :
   - Cliquer sur l'icône ⚙️ (Configuration) → **Data Sources**
   - Cliquer sur **Add data source**
   - Sélectionner **InfluxDB**

3. **Configurer InfluxDB** :
   - **Query Language** : Flux (recommandé) ou InfluxQL
   - **URL** : `http://localhost:8086`
   - **Organization** : `myorg`
   - **Token** : Votre token API InfluxDB
   - **Default Bucket** : `jmeter`
   - Cliquer sur **Save & Test**

   ✅ Vous devriez voir : "Data source is working"

### Étape 2: Vérifier les données

1. Aller dans **Explore** (icône boussole)
2. Sélectionner la source de données **InfluxDB**
3. Exécuter une requête de test :

**Pour Flux** :
```flux
from(bucket: "jmeter")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "jmeter")
  |> limit(n: 10)
```

**Pour InfluxQL** :
```sql
SELECT * FROM "jmeter" WHERE time > now() - 1h LIMIT 10
```

4. Si vous voyez des données, la configuration est correcte !

---

## 6. Création d'un Dashboard JMeter

### Option A: Importer un dashboard existant

1. **Télécharger un dashboard JMeter** :
   - Dashboard ID : `5496` (JMeter Load Test Dashboard)
   - Ou rechercher "JMeter" dans https://grafana.com/grafana/dashboards/

2. **Importer dans Grafana** :
   - Aller dans **Dashboards** → **Import**
   - Entrer l'ID : `5496`
   - Sélectionner votre source de données InfluxDB
   - Cliquer sur **Import**

### Option B: Créer un dashboard personnalisé

#### 1. Créer un nouveau dashboard

- **Dashboards** → **New Dashboard** → **Add visualization**

#### 2. Ajouter des panneaux (Panels)

##### Panel 1: Throughput (Requêtes par seconde)

**Configuration** :
- **Visualization** : Stat
- **Query (Flux)** :
```flux
from(bucket: "jmeter")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "jmeter")
  |> filter(fn: (r) => r["_field"] == "okCount" or r["_field"] == "koCount")
  |> aggregateWindow(every: v.windowPeriod, fn: sum, createEmpty: false)
  |> yield(name: "mean")
```
- **Field** : `_value`
- **Calculation** : Last
- **Title** : Throughput (req/s)

##### Panel 2: Response Time (Temps de réponse)

**Configuration** :
- **Visualization** : Time series
- **Query (Flux)** :
```flux
from(bucket: "jmeter")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "jmeter")
  |> filter(fn: (r) => r["_field"] == "meanResponseTime" or r["_field"] == "maxResponseTime")
  |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
```
- **Title** : Response Time (ms)

##### Panel 3: Error Rate (Taux d'erreur)

**Configuration** :
- **Visualization** : Time series
- **Query (Flux)** :
```flux
from(bucket: "jmeter")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "jmeter")
  |> filter(fn: (r) => r["_field"] == "koCount" or r["_field"] == "okCount")
  |> aggregateWindow(every: v.windowPeriod, fn: sum, createEmpty: false)
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> map(fn: (r) => ({ r with errorRate: (float(v: r.koCount) / float(v: r.okCount + r.koCount)) * 100.0 }))
```
- **Title** : Error Rate (%)

##### Panel 4: Active Threads (Threads actifs)

**Configuration** :
- **Visualization** : Time series
- **Query (Flux)** :
```flux
from(bucket: "jmeter")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "jmeter")
  |> filter(fn: (r) => r["_field"] == "threads")
  |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
```
- **Title** : Active Threads

##### Panel 5: Response Time Percentiles (P90, P95, P99)

**Configuration** :
- **Visualization** : Time series
- **Query (Flux)** :
```flux
from(bucket: "jmeter")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "jmeter")
  |> filter(fn: (r) => r["_field"] == "pct90.0" or r["_field"] == "pct95.0" or r["_field"] == "pct99.0")
  |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
```
- **Title** : Response Time Percentiles

##### Panel 6: Requests by Sampler (Requêtes par endpoint)

**Configuration** :
- **Visualization** : Bar chart
- **Query (Flux)** :
```flux
from(bucket: "jmeter")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "jmeter")
  |> filter(fn: (r) => r["_field"] == "okCount" or r["_field"] == "koCount")
  |> group(columns: ["transaction"])
  |> sum()
```
- **Title** : Requests by Sampler

#### 3. Sauvegarder le dashboard

- Cliquer sur **Save** (icône disquette)
- Donner un nom : "JMeter Performance Dashboard"
- Choisir un dossier (optionnel)

---

## 7. Dépannage

### Problème : Aucune donnée dans Grafana

**Vérifications** :
1. ✅ InfluxDB est démarré : `curl http://localhost:8086/health`
2. ✅ Le test JMeter est en cours d'exécution
3. ✅ Le Backend Listener est activé dans JMeter
4. ✅ Le token InfluxDB est correct
5. ✅ Le bucket `jmeter` existe dans InfluxDB

**Vérifier les données dans InfluxDB** :
- Aller dans InfluxDB UI : http://localhost:8086
- **Data Explorer** → Sélectionner le bucket `jmeter`
- Vérifier que des données arrivent

### Problème : Erreur de connexion InfluxDB

**Solutions** :
1. Vérifier que InfluxDB écoute sur le port 8086 :
   ```bash
   netstat -an | findstr 8086  # Windows
   netstat -an | grep 8086     # Linux
   ```

2. Vérifier les logs InfluxDB :
   ```bash
   docker logs influxdb  # Si Docker
   ```

3. Vérifier le firewall Windows/Linux

### Problème : Token invalide

**Solution** :
1. Aller dans InfluxDB UI → **Data** → **Tokens**
2. Générer un nouveau token
3. Mettre à jour dans JMeter et Grafana

### Problème : Données anciennes seulement

**Solution** :
- Vérifier la plage de temps dans Grafana (en haut à droite)
- Sélectionner "Last 1 hour" ou "Last 5 minutes"

### Problème : Requêtes Flux ne fonctionnent pas

**Solution** :
- Utiliser InfluxQL à la place de Flux
- Ou mettre à jour InfluxDB vers la dernière version

---

## Commandes utiles

### Docker

```bash
# Démarrer InfluxDB
docker start influxdb

# Démarrer Grafana
docker start grafana

# Voir les logs
docker logs -f influxdb
docker logs -f grafana

# Arrêter
docker stop influxdb grafana

# Supprimer (attention : supprime les données)
docker rm -f influxdb grafana
```

### Vérification des services

```bash
# InfluxDB
curl http://localhost:8086/health

# Grafana
curl http://localhost:3000/api/health
```

---

## Structure des données JMeter dans InfluxDB

Les données sont stockées avec les champs suivants :

- **Measurement** : `jmeter`
- **Fields** :
  - `okCount` : Nombre de requêtes réussies
  - `koCount` : Nombre de requêtes échouées
  - `meanResponseTime` : Temps de réponse moyen (ms)
  - `maxResponseTime` : Temps de réponse maximum (ms)
  - `minResponseTime` : Temps de réponse minimum (ms)
  - `pct90.0`, `pct95.0`, `pct99.0` : Percentiles
  - `threads` : Nombre de threads actifs
  - `sentBytes` : Octets envoyés
  - `receivedBytes` : Octets reçus

- **Tags** :
  - `application` : Nom de l'application (ex: `benchmark-va`)
  - `transaction` : Nom du sampler (ex: `GET /items`)
  - `statut` : Statut de la requête

---

## Workflow complet

1. **Démarrer InfluxDB** :
   ```bash
   docker start influxdb
   # Ou démarrer le service Windows
   ```

2. **Démarrer Grafana** :
   ```bash
   docker start grafana
   # Ou démarrer le service Windows
   ```

3. **Vérifier les services** :
   - InfluxDB : http://localhost:8086
   - Grafana : http://localhost:3000

4. **Lancer un test JMeter** :
   ```bash
   jmeter -n -t 1_read_heavy.jmx -l results.jtl
   ```

5. **Visualiser dans Grafana** :
   - Ouvrir le dashboard JMeter
   - Les métriques apparaissent en temps réel

---

## Ressources supplémentaires

- **Documentation InfluxDB** : https://docs.influxdata.com/influxdb/v2.7/
- **Documentation Grafana** : https://grafana.com/docs/grafana/latest/
- **JMeter Backend Listener** : https://jmeter.apache.org/usermanual/component_reference.html#Backend_Listener
- **Dashboards Grafana JMeter** : https://grafana.com/grafana/dashboards/?search=jmeter

---

**Dernière mise à jour** : Guide de configuration InfluxDB + Grafana pour JMeter


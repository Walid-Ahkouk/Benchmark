# Démarrage Rapide : Grafana + InfluxDB pour JMeter

## 🚀 Démarrage en 5 minutes

### 1. Démarrer InfluxDB (Docker)

```bash
docker run -d \
  --name influxdb \
  -p 8086:8086 \
  -v influxdb-storage:/var/lib/influxdb2 \
  -e DOCKER_INFLUXDB_INIT_MODE=setup \
  -e DOCKER_INFLUXDB_INIT_USERNAME=admin \
  -e DOCKER_INFLUXDB_INIT_PASSWORD=admin123 \
  -e DOCKER_INFLUXDB_INIT_ORG=myorg \
  -e DOCKER_INFLUXDB_INIT_BUCKET=jmeter \
  -e DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=0g6tixIL9cA2cqiuYKCXU3IjW1z_0Xg53stFC75BuEaS9w1uaeXejWJKTiyarp5f8OVLv6SEokreKWN3nZE22A== \
  influxdb:2.7
```

**Accès** : http://localhost:8086
- Username : `admin`
- Password : `admin123`

### 2. Démarrer Grafana (Docker)

```bash
docker run -d \
  --name grafana \
  -p 3000:3000 \
  -v grafana-storage:/var/lib/grafana \
  grafana/grafana:latest
```

**Accès** : http://localhost:3000
- Username : `admin`
- Password : `admin` (changé au premier login)

### 3. Configurer Grafana

1. **Se connecter** : http://localhost:3000
2. **Ajouter source de données** :
   - Configuration ⚙️ → Data Sources → Add data source
   - Sélectionner **InfluxDB**
   - **URL** : `http://localhost:8086`
   - **Organization** : `myorg`
   - **Token** : `0g6tixIL9cA2cqiuYKCXU3IjW1z_0Xg53stFC75BuEaS9w1uaeXejWJKTiyarp5f8OVLv6SEokreKWN3nZE22A==`
   - **Default Bucket** : `jmeter`
   - **Save & Test**

### 4. Importer Dashboard JMeter

1. **Dashboards** → **Import**
2. **Dashboard ID** : `5496`
3. Sélectionner votre source InfluxDB
4. **Import**

### 5. Lancer un test JMeter

```bash
jmeter -n -t 1_read_heavy.jmx -l results.jtl
```

### 6. Visualiser dans Grafana

- Ouvrir le dashboard importé
- Les métriques apparaissent en temps réel ! 📊

---

## ✅ Vérification rapide

```bash
# Vérifier InfluxDB
curl http://localhost:8086/health
# Résultat attendu : {"status":"ok"}

# Vérifier Grafana
curl http://localhost:3000/api/health
# Résultat attendu : {"commit":"...","database":"ok",...}
```

---

## 🔧 Commandes utiles

```bash
# Voir les logs
docker logs -f influxdb
docker logs -f grafana

# Arrêter
docker stop influxdb grafana

# Redémarrer
docker start influxdb grafana

# Supprimer (⚠️ supprime les données)
docker rm -f influxdb grafana
```

---

## 📝 Notes importantes

- Les fichiers JMeter (`.jmx`) sont **déjà configurés** avec le Backend Listener InfluxDB
- Le token utilisé est celui configuré dans les fichiers `.jmx`
- Si vous changez le token, mettez-le à jour dans JMeter ET Grafana

---

## 🆘 Problèmes courants

**Aucune donnée ?**
- Vérifier que le test JMeter est en cours
- Vérifier que le Backend Listener est activé dans JMeter
- Vérifier les logs : `docker logs influxdb`

**Erreur de connexion ?**
- Vérifier que les ports 8086 et 3000 sont libres
- Vérifier le firewall Windows

**Token invalide ?**
- Générer un nouveau token dans InfluxDB UI
- Mettre à jour dans JMeter et Grafana


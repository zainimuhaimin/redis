# Redis — Docker Compose (dev & prod)

Setup Redis yang maintainable pakai pola **base + override**: config bersama ada
di satu file, yang beda per-environment dipisah. Jadi nggak ada duplikasi dan
gampang di-review.

## Struktur

```
redis-docker/
├── docker-compose.yml         # base: image, network, volume, healthcheck
├── docker-compose.dev.yml     # override dev: port terbuka, no-auth, GUI
├── docker-compose.prod.yml    # override prod: password, limit, log rotation
├── config/
│   └── redis.prod.conf        # tuning persistence & keamanan buat prod
├── .env.example               # template env (copy jadi .env)
├── Makefile                   # shortcut command
└── README.md
```

## Cara pakai

```bash
cp .env.example .env      # lalu isi REDIS_PASSWORD untuk prod

make dev                  # jalankan dev  (Redis :6379, GUI :8081)
make prod                 # jalankan prod
make help                 # lihat semua command
```

Tanpa Makefile:

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml  up -d
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## Beda dev vs prod

| Aspek        | Dev                          | Prod                                   |
|--------------|------------------------------|----------------------------------------|
| Password     | Tidak ada                    | Wajib (`REDIS_PASSWORD` dari `.env`)   |
| Port         | `6379` (semua interface)     | `127.0.0.1:6379` (localhost saja)      |
| Config       | Flag command sederhana       | `config/redis.prod.conf`               |
| Logging      | `debug`                      | `notice` + rotasi (10m × 3)            |
| Resource     | Tanpa limit                  | Limit memory + reservation             |
| GUI          | Redis Commander (`:8081`)    | Tidak ada                              |

## Kenapa desainnya begini

- **Password & memory lewat env**, bukan ditulis di file config, jadi rahasia
  nggak ikut ter-commit. Command-line arg meng-override `redis.conf`.
- **`REDIS_PASSWORD:?...`** bikin `make prod` gagal cepat kalau password belum
  diisi — mencegah prod jalan tanpa auth.
- **Port prod bind ke `127.0.0.1`**. Kalau app kamu juga container, hapus blok
  `ports` di `docker-compose.prod.yml` dan akses Redis via hostname `redis`
  lewat network `redis-net`.

## Catatan produksi

- Simpan `.env` di secret manager, jangan di git (tambahkan ke `.gitignore`).
- Pertimbangkan buka `rename-command` di `redis.prod.conf` untuk mematikan
  command berbahaya (`FLUSHALL`, `KEYS`, dll).
- `maxmemory` prod default `512mb`; limit container `768M` memberi headroom
  buat overhead. Sesuaikan dua-duanya kalau naikin memory.
```

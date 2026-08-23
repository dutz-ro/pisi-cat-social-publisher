# pisi.cat Social Publisher

Repository privat pentru infrastructura de publicare socială pisi.cat. Conține stratul Postiz
self-hosted și ajustarea temporară TikTok Sandbox. Nu conține logica Django/Wagtail, conținut,
tokenuri OAuth, chei API, baze de date sau media.

## Responsabilități

- rulează Postiz, PostgreSQL, Redis și Temporal;
- expune UI/API la `https://social.pisi.cat`;
- gestionează conexiunile OAuth Facebook/Instagram/TikTok;
- oferă API-ul consumat de `pisi-cat-web`;
- în Sandbox, reduce TikTok la `user.info.basic` + `video.upload` pentru Inbox Upload.

Integrarea aplicației este în repository-ul privat
[`dutz-ro/pisi-cat-web`](https://github.com/dutz-ro/pisi-cat-web), în special:

- `home/social_services.py`;
- `home/social_webhooks.py`;
- `deploy/SOCIAL_PUBLISHING.md`.

## Instalare

Repository-ul oficial Postiz Compose rămâne sursa stackului complet. Acest repo se clonează
lângă el și override-ul se aplică peste compose-ul oficial:

```bash
git clone https://github.com/gitroomhq/postiz-docker-compose /opt/postiz-upstream
git clone git@github.com:dutz-ro/pisi-cat-social-publisher.git /opt/pisi-cat-social-publisher
cp /opt/pisi-cat-social-publisher/.env.example /opt/pisi-cat-social-publisher/.env
chmod 600 /opt/pisi-cat-social-publisher/.env
```

Completează `.env` local. Nu îl comite. Pornește cu:

```bash
docker compose \
  -f /opt/postiz-upstream/docker-compose.yaml \
  -f /opt/pisi-cat-social-publisher/docker-compose.override.yaml \
  --project-directory /opt/pisi-cat-social-publisher \
  up -d --build
```

Instalează `nginx/social.pisi.cat.conf` în instanța nginx comună numai după verificarea
hostname-ului, upstreamului și certificatului TLS. Rulează obligatoriu `nginx -t` înainte de
reload.

## Operare

```bash
docker compose ps
docker logs --since 30m postiz
docker stats --no-stream postiz postiz-postgres postiz-redis temporal temporal-elasticsearch
curl -I https://social.pisi.cat/
```

Postiz trebuie să asculte pe `172.19.0.1:4007`, nu pe `0.0.0.0`. UI-ul rămâne public pentru
OAuth și review, dar înregistrările sunt dezactivate după crearea ownerului.

## Upgrade

1. Păstrează `dry_run=True` în pisi-cat-web.
2. Trage ultima versiune a compose-ului oficial și imaginea Postiz.
3. Construiește derivarea; buildul eșuează intenționat dacă upstream a schimbat blocul patchuit.
4. Pornește stackul și verifică healthchecks.
5. Testează OAuth TikTok Sandbox și un UPLOAD privat.
6. Reactivează trimiterea din Django.

Patchul Sandbox este temporar. La aprobarea aplicației Production, treci la scope-urile oficiale
necesare și elimină derivarea dacă upstream Postiz funcționează fără ea.

## Secrete și rotație

Secretele sunt numai în `.env` de pe server. După expunere sau rotație:

1. actualizează `.env`;
2. recreează doar serviciul Postiz;
3. reconectează canalul OAuth;
4. actualizează Integration ID în `/opt/pisi-cat/.env`, dacă s-a schimbat;
5. testează în `dry_run`.

Nu comite `.env`, dumpuri, volume, access/refresh tokenuri sau cheia API Postiz.

## Starea și ce urmează

Vezi [`docs/STATUS.md`](docs/STATUS.md) și [`docs/OPERATIONS.md`](docs/OPERATIONS.md).

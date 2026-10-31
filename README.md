# Postiz Social Publisher

Stack self-hosted de publicare socială, pregătit să fie folosit **independent de orice
aplicație sau domeniu**. Repository-ul conține doar stratul de infrastructură peste
[Postiz](https://github.com/gitroomhq/postiz-app): override-ul Docker Compose, o imagine
derivată opțională pentru TikTok Sandbox, un exemplu de reverse proxy nginx și documentația de
operare.

Nu depinde de pisi.cat, de Django/Wagtail sau de vreun client anume. Tot ce este specific unui
domeniu sau unei instalări se configurează prin `.env`; aplicația care creează campaniile
folosește API-ul public Postiz.

## Ce conține

| Fișier | Rol |
|---|---|
| `docker-compose.override.yaml` | suprapune peste compose-ul oficial Postiz: URL public, port de bind, imagine construită local |
| `Dockerfile` | pornește de la imaginea oficială Postiz; opțional limitează scope-urile TikTok pentru Sandbox |
| `.env.example` | toate variabilele necesare, fără valori reale |
| `nginx/social-publisher.conf` | exemplu TLS + reverse proxy, cu domeniu de înlocuit |
| `docs/OPERATIONS.md` | operare canale, TikTok UPLOAD, backup, incidente |
| `docs/STATUS.md` | scop, stare și limite cunoscute |

Repository-ul **nu** conține logica aplicației client, baza de date, media, tokenuri OAuth sau
chei API.

## Cerințe

- Docker Engine cu Docker Compose v2.24+ (pentru `!override` în compose)
- un hostname public și certificat TLS (Let's Encrypt sau altul)
- minim 4 GB RAM recomandat; stack-ul Postiz include PostgreSQL, Redis și Temporal
- acces la `ghcr.io/gitroomhq/postiz-app:latest`

## Pornire rapidă

```bash
# 1. Stack-ul oficial Postiz rămâne sursa serviciilor
git clone https://github.com/gitroomhq/postiz-docker-compose /opt/postiz-upstream

# 2. Acest repository, lângă el
git clone https://github.com/dutz-ro/pisi-cat-social-publisher /opt/social-publisher
cd /opt/social-publisher

# 3. Configurație locală
cp .env.example .env
chmod 600 .env
# editează PUBLIC_URL, JWT_SECRET, POSTIZ_DB_PASSWORD și cheile OAuth dorite
```

Completează cel puțin:

```text
PUBLIC_URL=https://social.example.com
JWT_SECRET=<64+ caractere aleatorii>
POSTIZ_DB_PASSWORD=<parolă lungă, aleatorie>
```

Pornește:

```bash
docker compose \
  -f /opt/postiz-upstream/docker-compose.yaml \
  -f /opt/social-publisher/docker-compose.override.yaml \
  --project-directory /opt/social-publisher \
  up -d --build
```

Verifică:

```bash
docker compose \
  -f /opt/postiz-upstream/docker-compose.yaml \
  -f /opt/social-publisher/docker-compose.override.yaml \
  --project-directory /opt/social-publisher ps
curl -I "$PUBLIC_URL"
```

Prima accesare a UI-ului creează contul owner. `DISABLE_REGISTRATION=true` împiedică
înregistrările ulterioare.

### Reverse proxy și TLS

Editează domeniul din exemplu și instalează-l:

```bash
sed "s/social.example.com/your.host/g" nginx/social-publisher.conf \
  | sudo tee /etc/nginx/sites-available/social-publisher.conf
sudo ln -s /etc/nginx/sites-available/social-publisher.conf /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

Configurația presupune că Postiz ascultă pe `127.0.0.1:4007`. Dacă schimbi `BIND_ADDRESS` sau
`BIND_PORT`, actualizează și `proxy_pass`.

## Configurație

Toate variabilele se pun în `.env`; fișierul este ignorat de git.

| Variabilă | Implicit | Semnificație |
|---|---|---|
| `PUBLIC_URL` | — (obligatoriu) | URL-ul public, fără `/` final; folosit pentru OAuth și linkuri |
| `BIND_ADDRESS` | `127.0.0.1` | adresa hostului pe care se publică portul containerului |
| `BIND_PORT` | `4007` | portul hostului mapat la `5000` în container |
| `POSTIZ_IMAGE` | `postiz-custom:latest` | numele imaginii construite local |
| `TIKTOK_SANDBOX_PATCH` | `true` | limitează scope-urile TikTok la `user.info.basic` + `video.upload` |
| `JWT_SECRET` | — (obligatoriu) | secret de sesiune Postiz |
| `POSTIZ_DB_PASSWORD` | — (obligatoriu) | parola PostgreSQL intern |
| `DISABLE_REGISTRATION` | `true` | blochează înregistrarea de conturi noi |
| `FACEBOOK_APP_ID` / `FACEBOOK_APP_SECRET` | gol | aplicația Meta, dacă publici pe Facebook/Instagram |
| `TIKTOK_CLIENT_ID` / `TIKTOK_CLIENT_SECRET` | gol | aplicația TikTok, Sandbox sau Production |

### TikTok

`TIKTOK_SANDBOX_PATCH=true` este potrivit exclusiv pentru aplicații TikTok aflate în Sandbox:
permite doar upload în inbox și elimină scope-urile de profil care ar face requestul invalid.
Pentru o aplicație Production aprobată, sau dacă nu folosești TikTok, setează:

```text
TIKTOK_SANDBOX_PATCH=false
```

și reconstruiește imaginea (`up -d --build`). Fără patch, Postiz folosește scope-urile oficiale
din upstream.

## Folosire din orice aplicație

Repository-ul nu impune un client anume. Orice aplicație poate:

1. crea o cheie API în Postiz (Settings → API);
2. programa postări prin API-ul public, de exemplu `POST $PUBLIC_URL/api/public/v1/posts`;
3. încărca media prin endpoint-ul de upload;
4. primi evenimente printr-un webhook configurat în UI.

Astfel, stack-ul poate deservi un CMS, un script sau un serviciu propriu, fără să depindă de
codul sau de modelele pisi.cat. Documentația Postiz pentru API și webhook-uri rămâne referința
pentru forma payload-urilor.

## Actualizare

1. Trage ultima versiune a compose-ului oficial și a imaginii Postiz.
2. Reconstruiește imaginea locală.
3. Pornește stack-ul și verifică healthcheck-urile.
4. Testează OAuth și o publicare privată înainte de a activa publicarea reală.

Buildul eșuează intenționat dacă upstream a schimbat blocurile modificate de
`TIKTOK_SANDBOX_PATCH`; în acest caz actualizează șabloanele din `Dockerfile` sau setează
patch-ul pe `false`.

## Secrete și backup

- păstrează `.env` doar pe server, cu permisiuni `600`, și în afara git;
- nu comite dumpuri, volume, tokenuri OAuth sau chei API;
- fă backup la baza PostgreSQL, volumele de upload și configurația criptată;
- testează restaurarea înainte de a te baza pe backup.

## Migrare de la instalarea pisi.cat

Valorile implicite anterioare (domeniul `social.pisi.cat`, bind pe `172.19.0.1`, imaginea
`postiz-pisicat`) nu mai sunt hardcodate. Pentru a păstra comportamentul existent, setează în
`.env`:

```text
PUBLIC_URL=https://social.pisi.cat
BIND_ADDRESS=172.19.0.1
BIND_PORT=4007
POSTIZ_IMAGE=postiz-pisicat:latest
```

Fișierul nginx a fost redenumit din `nginx/social.pisi.cat.conf` în
`nginx/social-publisher.conf`; conținutul este identic, cu domeniul înlocuit cu un exemplu.

## Operare

Vezi [`docs/OPERATIONS.md`](docs/OPERATIONS.md) și [`docs/STATUS.md`](docs/STATUS.md).

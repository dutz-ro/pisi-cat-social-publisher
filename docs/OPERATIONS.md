# Operare Postiz și canale

Acest ghid presupune că stack-ul este pornit cu `docker-compose.override.yaml` din acest
repository, peste compose-ul oficial Postiz.

## UI Postiz

Folosește Postiz pentru:

- conectarea/reconectarea canalelor;
- verificarea calendarului și a previzualizării;
- investigarea unui job eșuat;
- crearea cheii API și configurarea webhook-urilor.

Dacă un client extern a creat deja o campanie, nu apăsa `Post` din UI: poți dubla publicarea.
Pentru TikTok `UPLOAD`, după statusul `SEND_TO_USER_INBOX`, pasul rămas se face în aplicația
TikTok.

## TikTok UPLOAD

1. Clientul programează campania prin API-ul Postiz.
2. Postiz încarcă MP4 în inboxul TikTok.
3. Operatorul finalizează publicarea în aplicația TikTok în maximum 24 de ore.
4. Clientul marchează publicarea ca finalizată în propriul audit.

Dacă nu publică:

- reminder înainte de expirare;
- expirare locală la 24 de ore;
- retrimiterea aceluiași MP4, fără regenerare.

Aceste reguli de business aparțin clientului; stack-ul oferă doar transportul și statusurile
Postiz.

## Facebook și Instagram

1. creează o aplicație Meta Business;
2. configurează redirecturile Postiz pentru Facebook și Instagram;
3. solicită numai scope-urile cerute de Postiz;
4. setează credențialele în `.env` și recreează serviciul Postiz;
5. conectează canalele în UI;
6. copiază Integration IDs în aplicația client;
7. testează întâi cu conținut privat/de test.

## Backup minim

Trebuie salvate:

- baza PostgreSQL Postiz;
- volumele upload Postiz;
- configurația `.env` printr-un secret manager sau backup criptat;
- configurația nginx și certificatul prin procedura comună a serverului.

Nu include Temporal Elasticsearch într-un backup logic critic dacă workflow-urile pot fi
recreate, dar documentează impactul și testează restaurarea PostgreSQL înainte de a decide.

## Incident

1. Oprește temporizatoarele clientului care creează campanii, dacă există risc de duplicate.
2. Verifică Postiz, apoi Temporal/Postgres/Redis.
3. Nu șterge volume și nu recrea nginx comun.
4. Pentru token expirat, rotește/reconectează canalul; nu edita tokenul direct în baza de date.
5. După remediere, rulează o singură campanie de test și urmărește statusul cap-coadă.

Comenzi utile:

```bash
docker compose ps
docker logs --since 30m postiz
docker stats --no-stream postiz postiz-postgres postiz-redis
curl -I https://social.example.com/
```

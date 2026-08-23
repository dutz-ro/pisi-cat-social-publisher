# Operare Postiz și canale

## UI Postiz

Folosește Postiz pentru:

- conectarea/reconectarea canalelor;
- verificarea calendarului și preview-ului;
- investigarea unui job eșuat;
- crearea cheii API și configurarea webhookurilor.

Nu apăsa `Post` pentru o campanie deja creată de pisi-cat-web: poți dubla uploadul. Pentru
TikTok `UPLOAD`, după statusul `SEND_TO_USER_INBOX`, pasul rămas este în aplicația TikTok.

## TikTok UPLOAD

1. Django programează campania prin API Postiz.
2. Postiz încarcă MP4 în inboxul TikTok.
3. Operatorul primește Telegram cu link Wagtail și link exact Postiz.
4. Operatorul finalizează în aplicația TikTok în 24h.
5. Confirmă în Wagtail `Am publicat clipul în TikTok`.

Dacă nu publică:

- reminder la 20h;
- expirare locală la 24h;
- butonul Wagtail retrimite MP4-ul existent fără regenerare.

## Facebook și Instagram

După ce Meta Developers este disponibil:

1. creează Meta Business app;
2. configurează redirecturile Postiz pentru Facebook și Instagram;
3. solicită numai scope-urile cerute de Postiz;
4. setează credențialele în `.env` și recreează Postiz;
5. conectează canalele în UI;
6. copiază Integration IDs în pisi-cat-web;
7. testează întâi în dry-run și apoi cu conținut privat/de test.

## Backup minim

Trebuie salvate:

- baza Postgres Postiz;
- volumele upload Postiz;
- configurația `.env` printr-un secret manager/backup criptat;
- configurația nginx și certificatul prin procedura comună a serverului.

Nu include Temporal Elasticsearch într-un backup logic critic dacă workflow-urile pot fi
recreate, dar documentează impactul și testează restaurarea Postgres înainte de a decide.

## Incident

1. Activează `dry_run=True` în Wagtail.
2. Oprește timerele sociale dacă există risc de duplicate.
3. Verifică Postiz, apoi Temporal/Postgres/Redis.
4. Nu șterge volume și nu recrea nginx comun.
5. Pentru token expirat, rotește/reconectează canalul; nu edita tokenul direct în DB.
6. După remediere, rulează o singură campanie de test și urmărește statusul cap-coadă.

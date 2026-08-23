# Stare și lucruri rămase

## Implementat la 23 august 2026

- Postiz self-hosted la `https://social.pisi.cat`, cu TLS;
- registration dezactivat după crearea ownerului;
- stack Postiz/Postgres/Redis/Temporal sănătos;
- TikTok Sandbox conectat ca Target User;
- workaround minimal pentru scope-uri Sandbox;
- upload real TikTok în inbox confirmat prin `SEND_TO_USER_INBOX`;
- pisi-cat-web generează 9:16 cu audio și ține auditul/reminderele;
- 4 GiB swap persistent adăugat hostului pentru vârfuri de memorie.

## Stare aplicație

- automatizarea Django este activă, dar `dry_run=True` după test;
- TikTok este activ în modul `UPLOAD`;
- Facebook și Instagram sunt dezactivate;
- există un upload TikTok care așteaptă finalizarea manuală;
- cheile TikTok folosite în configurare trebuie rotite.

## De făcut

1. Rotește Client Secret TikTok Sandbox și actualizează `.env`.
2. Reconectează canalul TikTok și actualizează Integration ID în pisi-cat-web dacă se schimbă.
3. Creează aplicația Meta și conectează Facebook Page + Instagram Professional.
4. Configurează webhookul Postiz către pisi.cat și validează payloadul real cu Send Test.
5. Adaugă backup pentru volume și un test documentat de restore.
6. Adaugă monitorizare pentru healthchecks, disc, memorie și erori Temporal.
7. Decide viitorul TikTok:
   - păstrare `UPLOAD` cu finalizare manuală; sau
   - composer public conform și audit Direct Post.
8. Elimină patchul Sandbox după migrarea pe aplicația Production aprobată.

TikTok Direct Post nu trebuie activat doar prin schimbarea unei variabile. Necesită audit și
UX conform: creator info, preview, selecții manuale fără defaults, disclosure comercial,
Music Usage Confirmation și consimțământ explicit.

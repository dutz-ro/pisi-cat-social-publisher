# Scop, stare și limite

## Scop

Repository-ul oferă un stack Postiz self-hosted, reutilizabil pentru orice domeniu și orice
aplicație client. Nu conține logică de business, modele editoriale, baze de date, media sau
secrete.

## Ce oferă

- Postiz, PostgreSQL, Redis și Temporal, prin compose-ul oficial;
- URL public și port de bind configurabile prin `.env`;
- imagine derivată local, cu patch opțional pentru TikTok Sandbox;
- exemplu de reverse proxy nginx cu TLS;
- proceduri de operare, upgrade, backup și incidente.

## Stare

- configurația compose a fost validată local cu Docker Compose v2.24+; stack-ul complet se
  verifică pe hostul fiecărei instalări;
- patch-ul TikTok Sandbox este opțional și se activează prin `TIKTOK_SANDBOX_PATCH`;
- nu există garanție pentru versiuni viitoare ale Postiz: buildul eșuează intenționat dacă
  upstream schimbă blocurile modificate.

## Limite cunoscute

- necesită compose-ul oficial Postiz clonat separat;
- nu administrează certificatele TLS și nici DNS-ul;
- nu include monitorizare, alertare sau backup automat;
- patch-ul TikTok Sandbox este temporar și nu înlocuiește aprobarea Production;
- TikTok Direct Post necesită audit și un flux conform în aplicația client.

## Checklist înainte de producție

1. `PUBLIC_URL` este corect și fără `/` final.
2. `JWT_SECRET` și `POSTIZ_DB_PASSWORD` sunt aleatorii și unice.
3. `DISABLE_REGISTRATION=true` după crearea ownerului.
4. Postiz nu este expus direct; reverse proxy-ul termină TLS.
5. Backup pentru PostgreSQL și volume, cu restore testat.
6. O publicare de test a trecut cap-coadă.
7. Cheile OAuth pot fi rotite fără pierderea canalelor.

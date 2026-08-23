FROM ghcr.io/gitroomhq/postiz-app:latest

# Sandbox-ul TikTok folosit temporar de pisi.cat permite numai Inbox Upload.
# Cerem strict user.info.basic + video.upload și nu solicităm username, care
# necesită user.info.profile și ar invalida întregul request în Sandbox.
RUN python3 - <<'PY'
from pathlib import Path

paths = [
    Path('/app/apps/backend/dist/libraries/nestjs-libraries/src/integrations/social/tiktok.provider.js'),
    Path('/app/apps/orchestrator/dist/libraries/nestjs-libraries/src/integrations/social/tiktok.provider.js'),
]
old = """this.scopes = [
            'video.list',
            'user.info.basic',
            'video.publish',
            'video.upload',
            'user.info.profile',
            'user.info.stats',
        ];"""
new = """this.scopes = [
            'user.info.basic',
            'video.upload',
        ];"""
for path in paths:
    text = path.read_text()
    if old not in text:
        raise RuntimeError(f'Expected TikTok scope block not found in {path}')
    text = text.replace(old, new, 1)
    text = text.replace(
        'fields=open_id,avatar_url,display_name,union_id,username',
        'fields=open_id,avatar_url,display_name,union_id',
    )
    path.write_text(text)

# Postiz ascunde implicit cauza excepțiilor OAuth neașteptate. Logăm numai
# numele și mesajul, fără tokenuri sau corpul requestului.
controller = Path('/app/apps/backend/dist/apps/backend/src/api/routes/no.auth.integrations.controller.js')
text = controller.read_text()
old_catch = """                return res({
                    error: 'Authentication failed',"""
new_catch = """                console.error('OAuth provider authentication failed', {
                    name: err?.name || 'Error',
                    message: err?.message || String(err),
                });
                return res({
                    error: 'Authentication failed',"""
if old_catch not in text:
    raise RuntimeError('Expected OAuth catch block not found')
controller.write_text(text.replace(old_catch, new_catch, 1))
PY

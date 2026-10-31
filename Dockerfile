FROM ghcr.io/gitroomhq/postiz-app:latest

# Optional TikTok Sandbox workaround. Sandbox apps may only request
# user.info.basic + video.upload and reject requests that ask for profile
# scopes. Set TIKTOK_SANDBOX_PATCH=false to keep the upstream scope list.
ARG TIKTOK_SANDBOX_PATCH=true

RUN TIKTOK_SANDBOX_PATCH="$TIKTOK_SANDBOX_PATCH" python3 - <<'PY'
import os
from pathlib import Path

if os.environ.get("TIKTOK_SANDBOX_PATCH", "true").lower() not in {"1", "true", "yes"}:
    print("TikTok Sandbox patch disabled; upstream scopes are unchanged.")
    raise SystemExit(0)

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

# Postiz hides the cause of unexpected OAuth exceptions. Log only the name and
# message, never tokens or request bodies.
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

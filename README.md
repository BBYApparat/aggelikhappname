Product Brief — “RealNow”
A mobile app that prompts users once per day at a random time to capture and share a dual-camera photo within 2 minutes. Friends see your post only if you also posted. Late posts are marked. Reactions use mini selfies (“RealMojis”). Optional location & caption. Focus on authenticity, privacy, and anti-cheat.

Core Mechanics
Daily Prompt: Server picks a random timestamp per region/timezone each day; sends push.

Posting Window: 2 minutes “on-time” window; late allowed but labeled “Late ⏰ +XhYm”.

Dual Camera: Capture rear + front simultaneously (or near-simultaneous merge).

Visibility Rule: You can view friends’ feed only after you’ve posted that day.

RealMojis: Tap a post to reply with a quick selfie sticker; optionally text comment.

Retakes: Allow up to N retakes (configurable, default 1); store retake count server-side.

Location: Optional precise/approximate (city) with user setting.

Reminders: If not posted within 30 min of prompt, send a gentle nudge (one retry).

Privacy: Posts auto-expire from public discovery after 24h; user’s archive is private.

Platforms & Stack
Mobile: Flutter (iOS/Android) or React Native. Access to native camera (front+rear), background push handling, biometric/attestation hooks.

Backend:

API: Node.js (NestJS/Express) or Go (Fiber).

DB: PostgreSQL (primary), Redis (ephemeral + rate limits).

Object Storage + CDN: S3-compatible (AWS S3) + CloudFront.

Realtime: WebSockets (Socket.IO) or Firebase RTDB for live reactions.

Queue: RabbitMQ/SQS for push fanout & media processing.

Infra: Docker, Terraform, CI/CD (GitHub Actions).

Observability: Sentry (errors), Prometheus/Grafana (metrics), OpenTelemetry.

Integrations:

Auth: Firebase Auth (Apple, Google, Email/Password).

Push: FCM (Android/iOS via APNs through FCM).

Maps (optional): Mapbox or Google Maps (approx. location chip).

Analytics: Amplitude or Mixpanel.

Anti-cheat: Google Play Integrity API (Android), Apple DeviceCheck (iOS).

Email (account recovery): SendGrid.

Media processing: AWS Lambda or FFmpeg container (strip EXIF, create thumbnails).

Data Model (simplified)
scss
Αντιγραφή
Επεξεργασία
User(id, handle, display_name, avatar_url, phone_or_email, country, tz, settings{location_opt_in, who_can_friend}, created_at)

Friendship(id, user_id, friend_id, status{pending,accepted,blocked}, created_at)

DailyPrompt(id, region, date_utc, prompt_at_utc)

Post(
  id, user_id, date_utc, created_at, on_time boolean,
  retakes int, caption text, location_geo (nullable), location_label,
  media_rear_url, media_front_url, media_composite_url, late_by_seconds int
)

Reaction(
  id, post_id, user_id, type{realmoji,comment},
  emoji (nullable), text (nullable),
  selfie_url (for realmoji), created_at
)

DeviceAttestation(id, user_id, platform, result, integrity_score, created_at)
Indexes on (user_id, date_utc) for one-post-per-day checks; feed queries by friend_id with pagination.

Key Flows & Screens
Onboarding

Sign in with Apple/Google/Email.

Pick handle & display name.

Grant camera, notifications, (optional) location.

Add friends (contacts permission optional) or search by handle/QR.

Home (pre-post)

Disabled blurred feed with message “Post today to see your friends.”

Big “Take Today’s Real” button (if prompt started).

Countdown (2:00 → 0:00) for “on time”.

Capture

Dual-camera UI (rear preview full, front PiP top-left).

Snap once → capture both; if device cannot truly simult, shoot near-simult + compose.

Retake counter.

Toggle flash, switch which camera is main/PiP.

Optional caption & location (approximate or off).

Post

Upload composite + originals (rear/front) → server → strip EXIF → store.

Get server time → compute on-time vs late deterministically.

After success, unlock feed.

Feed

Friends’ posts for today, reverse-chrono.

Tap to expand; double-tap to RealMoji (open mini front camera to snap).

Comment thread (lightweight).

Label chips: “On time”, “Late +2h”, “Retakes: 1”.

Archive (Me)

Private daily grid; share/export single day (watermark optional).

Delete post (soft delete by default).

Notifications

Daily prompt; late reminder; friend request; reaction/comment.

Anti-Cheat & Authenticity
Server clock is source of truth for window; client window is advisory.

Attestation: On post, request DeviceCheck/Play Integrity token; backend validates.

Sensor hints: Optionally attach hardware metadata (device model, OS, capture timestamps, camera IDs).

EXIF: Strip all EXIF from uploaded images; store only server-generated metadata.

Retake limits enforced server-side; uploads after N retakes are rejected.

Jailbreak/root heuristics (best-effort; don’t block legit users incorrectly—log for review).

Privacy & Safety
GDPR-ready: data export/delete endpoints.

Location off by default; if on, store approx lat/lng → reverse-geocode to city; never store exact unless user opts-in.

Media ACL: private bucket + signed URLs; URLs short-lived (e.g., 15 min).

Moderation: user report endpoint; hash-list checking (PhotoDNA-like) optional; admin review tools.

Block/mute users; hide all content bi-directionally on block.

API (sample, REST-ish)
bash
Αντιγραφή
Επεξεργασία
POST /v1/auth/login
POST /v1/users     (create profile after Firebase Auth)
GET  /v1/me
PATCH /v1/me

POST /v1/friends/requests         {to_user}
POST /v1/friends/requests/:id/accept
GET  /v1/friends                  (list)

GET  /v1/prompt/today             -> {date_utc, prompt_at_utc, window_secs}
GET  /v1/feed/today               -> requires posted=true
POST /v1/posts
  Body: { caption, location_opt_in, lat?, lng?, retake_idx, attestation_token }
  Files: rear.jpg, front.jpg, (client_composite optional)
  Returns: {post_id, on_time, media_urls}

GET  /v1/posts/:id
DELETE /v1/posts/:id              (soft delete)
GET  /v1/me/archive?cursor=...

POST /v1/posts/:id/reactions      (type=realmoji|comment)
  Files (if realmoji): selfie.jpg
  Body (if comment): {text}

POST /v1/reports                  {target_type, target_id, reason}
POST /v1/privacy/export
POST /v1/privacy/delete
Notes

All requests authenticated with Firebase ID token → backend verifies.

Uploads via multipart; server generates composite if client didn’t.

Pagination with cursor.

Push Logic
Daily job by region creates DailyPrompt & sends push (FCM topics by region/timezone).

Late reminder exactly +30 min if !has_posted.

Silent push can pre-warm the capture view.

Media Pipeline
On upload:

Virus scan (optional).

Strip EXIF, normalize orientation.

Create composite (rear full, front inset) server-side for consistency; generate thumbnail.

Store to S3 with private ACL; return signed URLs.

CDN CloudFront fronting S3; signed cookies/URLs for images.

Analytics (examples)
prompt_received, capture_opened, post_success, post_late, retake_count, realmoji_sent, comment_sent, feed_unlocked, archive_viewed, onboarding_completed, push_opt_in.

Non-Functionals
Perf: Post create < 800 ms (excluding media upload).

Scale: 50k concurrent uploads/minute burst (queue + autoscale workers).

Cost: Media egress via CDN; thumbnails on feed list to reduce bytes.

Security: Signed URLs, rate limits, WAF, audit logs.

Milestones
MVP (3–4 weeks)

Auth, friends, daily prompt, capture & post, feed unlock, basic reactions, archive, push.

Hardening (2–3 weeks)

Attestation, moderation, privacy export/delete, analytics, CDN & media pipeline.

Polish (ongoing)

RealMojis UX, richer comments, discoverability with strict privacy, performance.

Acceptance Criteria (high-level)
Daily Prompt is generated server-side per region/timezone and delivered via push within <60s.

Users cannot view today’s feed until they post; after posting, feed shows friends’ posts within <5s.

Posting within window marks On Time; outside marks Late with accurate delta.

Retake limit enforced server-side; client cannot bypass by re-installing app.

Images in feed have no EXIF, and media URLs are signed & expire.

Reactions: RealMojis upload and display in real-time (<2s) to other viewers.

Location is off by default; if enabled, shows only approximate label unless user explicitly opts into precise.

GDPR: User can export and request delete; delete removes media & PII within SLA.

Anti-cheat tokens are validated; posts without valid attestation are flagged and rate-limited/queued for review.

Observability: SLO dashboards for post success rate, latency, push delivery, media errors.

Developer Notes / Edge Cases
If device can’t truly dual-capture, capture sequentially within <500ms and compose with timestamp watermark (optional).

Handle offline capture: allow capture when offline and queue upload; but on-time is based on server receipt within grace (e.g., 90s).

Timezone changes & travel: server uses user’s registered tz until next app open to avoid abuse; realign daily.

Accessibility: captions for UI, large buttons in capture, haptics on prompt.
# Prompt 1 — **Claude Code**: Generate a Production‑Grade Django SaaS with AI + Comms Integrations

## Goal

Build a full Django 5 SaaS platform with PostgreSQL, HTML/CSS/JS front end, REST APIs, and integrations for AI chat and voice agents, WhatsApp and Telegram chatbots, Jotform intake, and Twilio voice + WhatsApp. Target domain: **get-hub.io**.

## High‑Level Requirements

* **Stack**: Python 3.11+, Django 5.x, DRF, PostgreSQL 15+, Redis, Celery, Channels (WebSockets), Gunicorn, Nginx (prod). Front end: server‑rendered HTML + modular JS.
* **SaaS**: Multi‑tenant (schema or domain based). Plans, subscriptions, billing, usage metering, and roles. Stripe billing.
* **AI**: Pluggable providers via env (OpenAI, Anthropic, Azure OpenAI). RAG-ready service module. Conversation store.
* **Voice/Telecom**: Twilio Voice IVR + programmable voice for AI call agent. Twilio WhatsApp webhook. Telegram bot.
* **Forms**: Jotform webhook listener + OAuth for pulling submissions.
* **Observability**: Structured logging, Sentry, health checks, OpenAPI schema.
* **DX**: Makefile tasks, devcontainer, pre‑commit, pytest, Ruff, MyPy, seed data.
* **Deployment**: Docker Compose for dev; Terraform + GitHub Actions for prod (PG + Redis + app on cloud). Domain **get-hub.io**.

## Directory and Apps

* Project: `gethub/` (settings split: base/dev/prod/test). `core/` app for common, `accounts/` for users/auth, `billing/` for Stripe, `tenancy/` for multi‑tenant, `chat/` for chatbots & RAG, `voice/` for Twilio voice, `integrations/` for Jotform & providers, `api/` for DRF endpoints, `ops/` for IaC & CI.

## Key Packages

```
Django, djangorestframework, django-filter, django-environ, psycopg[binary], django-anymail, django-allauth,
stripe, django-axes, whitenoise, channels, channels-redis, celery, redis, drf-spectacular,
ruff, mypy, pytest, pytest-django, pytest-cov, pre-commit
python-telegram-bot, twilio, jotform, httpx, pydantic,
openai, anthropic, tiktoken, langchain-core, faiss-cpu (or pgvector),
django-tenant-schemas (or django-tenants), django-csp
```

## Environment

```
DJANGO_SECRET_KEY=...
DJANGO_DEBUG=true
ALLOWED_HOSTS=.get-hub.io,localhost,127.0.0.1
DATABASE_URL=postgres://user:pass@postgres:5432/gethub
REDIS_URL=redis://redis:6379/0
STRIPE_SECRET_KEY=...
STRIPE_WEBHOOK_SECRET=...
OPENAI_API_KEY=...
ANTHROPIC_API_KEY=...
TELEGRAM_BOT_TOKEN=...
TELEGRAM_WEBHOOK_SECRET=...
TWILIO_ACCOUNT_SID=...
TWILIO_AUTH_TOKEN=...
TWILIO_WHATSAPP_NUMBER=whatsapp:+1...
TWILIO_VOICE_NUMBER=+1...
JOTFORM_API_KEY=...
SENTRY_DSN=...
```

## Tasks for You (Claude Code)

1. **Scaffold** Django project `gethub` with the apps listed above. Add `apps.py`, `urls.py`, `admin.py` stubs and tests.
2. **Settings** split with `django-environ`. CSP, SecurityMiddleware, WhiteNoise. Static and media settings.
3. **PostgreSQL** config with `psycopg`. Create initial models: Tenant, SubscriptionPlan, Subscription, Organization, Role, User (email login), APIKey.
4. **Multi‑tenancy**: Use `django-tenants` or `django-tenant-schemas`. Support subdomain tenants like `acme.get-hub.io`. Middleware, schema router, migration flow, tenant-aware queryset mixins.
5. **Auth**: Django allauth + JWT endpoints via DRF. Role‑based permissions. API keys per tenant.
6. **Billing**: Stripe products, prices, subscription webhooks. Usage metering for AI tokens and minutes. Admin UI pages.
7. **AI core**: Abstraction `ai/providers.py` with providers OpenAI and Anthropic selected by env. Chat endpoint: `/api/v1/chat/` storing messages per tenant. RAG service with pluggable vector store (pgvector if available, else FAISS). Document upload + chunking + embedding.
8. **Voice**: Twilio Voice webhook `/voice/incoming/`. Call flow: greet, transfer to AI agent via streaming API (use placeholder stream handler). Call transcripts saved to Conversation.
9. **WhatsApp**: Twilio WhatsApp webhook `/chat/whatsapp/` for inbound, reply via Twilio API. Session state per user + tenant.
10. **Telegram**: Bot webhook `/chat/telegram/` using `python-telegram-bot` webhook handler. Commands `/start`, `/help`, and chat relay to AI core.
11. **Jotform**: Webhook endpoint `/integrations/jotform/webhook/`. Store submission JSON, map to Contact or Lead models. Add `/integrations/jotform/oauth/` if using API pull.
12. **APIs**: DRF routers for tenants, users, conversations, messages, documents, leads. OpenAPI via drf‑spectacular at `/api/schema/` and Swagger UI.
13. **Async**: Celery for embedding jobs and background message processing. Channels for live chat UI.
14. **Front end**: Server‑rendered pages with base template, login, tenant switcher, conversations dashboard, document upload, billing portal link.
15. **Ops**: Dockerfiles, docker‑compose.dev.yml (Django, Postgres, Redis, worker), Makefile (`make up`, `down`, `migrate`, `tenant_create`, `seed`). GitHub Actions CI (lint, type, test). Terraform stubs for prod infra and DNS for `get-hub.io`.
16. **Security/Compliance**: HTTPS, CSRF, JWT rotation, rate limiting, audit fields, PII redaction in logs.
17. **Fixtures**: Seed admin user, sample tenant, sample plan.

## Success Criteria

* `docker compose up` starts web:8000, worker, postgres:5432, redis:6379. Healthcheck OK.
* Create tenant and login, create conversation, upload document, ask question, receive answer. WhatsApp and Telegram webhooks accept POST and respond. Twilio Voice webhook returns TwiML. Stripe test checkout flows.
* `pytest` passes. `ruff` and `mypy` clean. OpenAPI docs render.

## Output Format

* Generate all files with complete code. Include tests. Provide a tree and full file contents.

---

# Prompt 2 — **Cursor**: Autogenerate the Same Project in the Cursor IDE

You are building the **same Django SaaS** described above. Follow these Cursor‑specific instructions:

## What to Build

Replicate the "Claude Code" spec 1:1. Same apps, models, APIs, webhooks, and infra. Domain: **get-hub.io**. Multi‑tenant, Stripe billing, AI chat and call agents, WhatsApp + Telegram bots, Jotform integration.

## Cursor Execution Plan

* Create repo with `/gethub` Django project and the listed apps.
* Add `pyproject.toml` with Ruff and MyPy config, `requirements.txt`, `Dockerfile`, `docker-compose.dev.yml`, `Makefile`, `.pre-commit-config.yaml`.
* Implement settings split, env, logging, security headers, CSP.
* Implement models and migrations for tenancy, auth, billing, chat, voice, integrations.
* Implement DRF routers and schema with drf‑spectacular.
* Implement Celery, Channels, Redis config. Seed tasks and consumers.
* Implement Twilio voice webhook and Twilio WhatsApp inbound. Implement Telegram webhook. Implement Jotform webhook.
* Implement AI provider abstraction and RAG service.
* Implement HTML templates for auth, dashboard, conversations, documents, billing.
* Implement tests and CI.

## Requirements and Constraints

* Bind Django to `0.0.0.0:8000` in dev. Static via WhiteNoise.
* Prefer `pgvector` if available for embeddings. Fallback to FAISS in local dev.
* No hard‑coded secrets. Everything via env.
* Strong input validation on webhooks. Verify Twilio signatures and Telegram secret token. Jotform secret.
* Per‑tenant rate limits and usage counters.
* Provide `POST /api/v1/ai/chat` and `POST /api/v1/ai/rag/query` endpoints. Store all messages and usage.
* Provide `POST /voice/incoming/`, `POST /chat/whatsapp/`, `POST /chat/telegram/`, `POST /integrations/jotform/webhook/`.

## Dev Shortcuts (include in repo)

* `scripts/dev_bootstrap.sh` to create venv, install deps, run migrations, create superuser, create sample tenant and API key.
* `scripts/tunnel.sh` template to set a public webhook URL for local dev via `ngrok`.
* `postman/collection.json` for endpoints.

## Tests to Include

* Tenant routing, JWT auth, role permissions.
* Stripe webhook signature verify.
* Twilio, Telegram, Jotform webhook signature verify.
* AI provider selection and token accounting.
* RAG pipeline unit tests.

## Deliverables

* Minimal tree, then full file contents for each file.
* Clear README with setup, env examples, and make targets.
* OpenAPI schema URL and screenshots instruction for verification.

## Done Definition

* End‑to‑end flow works locally with docker compose.
* Webhooks accept test payloads. Stripe test subscription succeeds.
* Lint, type check, tests pass in CI.

---

## Notes/Assumptions

* Use Twilio for both Voice and WhatsApp. If WhatsApp Cloud API is preferred, add a provider switch.
* If `pgvector` is not available in ops, fall back to FAISS.
* If Anthropic/OpenAI is not configured, provide a stub echo provider so chat still functions in dev.
* Keep front end simple: Django templates + HTMX or light vanilla JS modules.

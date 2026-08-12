---
name: configure-alipay-ai-payment
description: Configure, validate, troubleshoot, or document an Alipay AI Pay / Alipay Open Platform RSA2 direct-payment integration. Use when setting up AppID, SellerID, application private key, Alipay platform public key, production or sandbox gateway, payment callbacks, order querying, or secure payment reconciliation in SynthApi or a comparable service.
---

# Configure Alipay AI Payment

Use this skill for official Alipay direct payment. Do not use it for QR-code receipt listeners, aggregator gateways, or payment-page visual design.

## Workflow

1. Read [Alipay Open Platform](references/alipay-open-platform.md) before requesting or entering platform credentials.
2. Read [SynthApi Configuration](references/synthapi-configuration.md) for the existing integration contract and routes.
3. Prepare the public HTTPS callback paths before enabling payment. Never use a loopback, private address, or a URL behind interactive authentication for an Alipay callback.
4. Store the application private key only in a secret store or the protected administrator configuration API. Never put it in source, browser code, shell history, issue text, logs, or a repository.
5. Validate the configuration structurally with `scripts/validate-alipay-config.sh <redacted-config-file>`; it reports only key names and validation states.
6. Test sandbox order creation, signature verification, a successful asynchronous notification, return-page query, duplicate notification, and a failed/closed order. Move to production only after every case passes.
7. For production incidents, use [Callback Security](references/callback-security.md) and [Troubleshooting](references/troubleshooting.md). Keep the payment path idempotent and use active order querying as the recovery path.

## Required Safety Rules

- Use RSA2 with a 2048-bit-or-larger RSA application key.
- Verify Alipay notifications before trusting `trade_status`, amount, seller, application, or provider trade number.
- Treat the synchronous browser return as advisory. Credit only after verified notification or a verified active query.
- Match `app_id`, `auth_app_id` when present, `seller_id`, `out_trade_no`, and exact decimal amount against the local order.
- Return literal `success` only after durable idempotent completion. Return `fail` for a transient handling failure so Alipay can retry.
- Log identifiers and outcomes, never raw private keys, complete signed payloads, or customer data beyond the operational minimum.

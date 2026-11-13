---
name: configure-alipay-ai-payment
description: Configure, validate, troubleshoot, or document an Alipay AI Pay / Alipay Open Platform RSA2 direct-payment integration. Use when setting up AppID, SellerID, application private key, Alipay platform public key, production or sandbox gateway, payment callbacks, order querying, or secure payment reconciliation in SynthApi or a comparable service.
---

# Configure Alipay AI Payment

Use this skill for official Alipay direct payment. Do not use it for QR-code receipt listeners, aggregator gateways, or payment-page visual design.

## Workflow

1. Read [Alipay Open Platform](references/alipay-open-platform.md) before requesting or entering platform credentials.
2. Read [SynthApi Configuration](references/synthapi-configuration.md) for the existing integration contract and routes. Read [Profile-based setup](references/deployment-profiles.md) only when the deployment uses multiple merchant profiles.
3. Prepare the public HTTPS callback paths before enabling payment. Never use a loopback, private address, or a URL behind interactive authentication for an Alipay callback.
4. Resolve each credential from the target site's secret manager or protected administrator configuration. Never put a private key, API token, admin session, or plaintext credential in source, browser code, shell history, issue text, logs, or a repository. Public configuration examples must contain secret references or placeholders only.
5. For a SynthApi deployment with multiple merchant profiles, read [Profile-based setup](references/deployment-profiles.md). Save and validate one profile at a time; activating it changes which profile new orders use.
6. Validate configuration structure with `scripts/validate-alipay-config.sh <local-secret-file>`; it reports only field names and validation states. Keep the temporary file outside the repository and delete it according to the site's secret-handling process.
7. Test order creation, signature verification, an asynchronous notification, return-page query, duplicate notification, and failed/closed orders. Move to production only after those cases pass.
8. For production incidents, use [Callback Security](references/callback-security.md) and [Troubleshooting](references/troubleshooting.md). Keep settlement idempotent and use verified active order querying as the recovery path.

## Required Safety Rules

- Use RSA2 with a 2048-bit-or-larger RSA application key.
- Verify Alipay notifications before trusting `trade_status`, amount, seller, application, or provider trade number.
- Treat the synchronous browser return as advisory. Credit only after verified notification or a verified active query.
- Match `app_id`, `auth_app_id` when present, `seller_id`, `out_trade_no`, and exact decimal amount against the local order.
- Return literal `success` only after durable idempotent completion. Return `fail` for a transient handling failure so Alipay can retry.
- Log identifiers and outcomes, never raw private keys, complete signed payloads, or customer data beyond the operational minimum.
- Do not activate a production profile unless the user explicitly requested the live switch. Saving or validating a profile is not the same as enabling its traffic.

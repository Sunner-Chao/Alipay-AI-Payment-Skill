# Alipay AI Payment Agent Skill

A reusable Codex Agent Skill for configuring and validating official Alipay Open Platform RSA2 direct payment in SynthApi-compatible services.

It documents the complete flow from application preparation and key roles through callback security, order reconciliation, production rollout, and incident diagnosis. The included validator checks configuration shape without printing credential values.

## Install

Place `configure-alipay-ai-payment` in the Codex skills directory:

```bash
cp -R configure-alipay-ai-payment "${CODEX_HOME:-$HOME/.codex}/skills/"
```

Then invoke it with a request such as:

```text
Use $configure-alipay-ai-payment to configure Alipay RSA2 direct payment for my SynthApi deployment.
```

## Validate the Skill

```bash
python3 /path/to/skill-creator/scripts/quick_validate.py configure-alipay-ai-payment
```

## Security

This repository contains placeholders only. Never commit an application private key, production callback payload, AppID/SellerID pair tied to a real merchant, database credential, or session token.

The validation helper reports field names and pass/fail states only. Structural validation does not prove that an Alipay product is authorized or that a private key matches the uploaded application public key.

## Scope

This Skill covers official Alipay RSA2 page payment and active order query. It does not cover personal receipt scraping, SMS forwarding, proprietary payment adapters, or bypassing provider authorization.

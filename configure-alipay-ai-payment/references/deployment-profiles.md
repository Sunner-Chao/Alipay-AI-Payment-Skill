# Profile-Based Setup for SynthApi

Use this reference when a SynthApi site has more than one Alipay merchant configuration. The API supports separate `legacy` and `secondary` profiles. A profile can be complete and enabled without being active; the active profile is used for new orders only.

## Fast Setup Path

1. Read the current profile list with `GET /api/option/alipay-profiles` using the root administrator session. The response must show only readiness flags such as `private_key_configured`, `platform_public_key_configured`, and `configuration_ready`; it must not return key contents.
2. Choose the target profile ID (`legacy` or `secondary`) and confirm its owner, AppID/SellerID pairing, payment product authorization, and production/sandbox environment with the operator.
3. Load the exact profile credentials from the site's secret manager or approved administrator secret store. Do not copy them into this repository, chat, tickets, terminal history, screenshots, or build variables.
4. Save through `POST /api/option/alipay-profiles/save`. Submit blank private-key or platform-public-key fields only when the intent is to preserve their existing values. Check the response readiness flags and ensure the intended callback URLs and minimum payment amount are correct.
5. Confirm the public notification endpoint accepts the provider's form POST without login, CAPTCHA, browser challenge, or an unstable tunnel. An invalid unsigned probe should be rejected; it is only a routing check, not a payment test.
6. Verify an end-to-end order with a payment the merchant is authorized to make. Check provider status, exact amount, local order status, and a single wallet credit or subscription entitlement. Repeat the notification only in a controlled test and verify idempotency.
7. Activate with `POST /api/option/alipay-profiles/activate` only when the operator explicitly requested switching live traffic. Confirm a newly created order records the chosen profile version. Existing orders must continue resolving their original saved profile version.

The active-profile switch does not migrate, rewrite, refund, or complete existing orders. Never repair a suspected missing payment by changing the order or balance before verifying the provider transaction.

## Safe Site Template

`examples/synthapi-production-profile.example.yaml` is a documentation template, not an executable secrets file. It records non-secret routing and profile intent while leaving credentials as external secret references. Refresh its timestamp and active profile from the authenticated administrator interface before using it; a committed snapshot can become stale.

For other SynthApi sites, replace the public base URL, callback paths, profile IDs supported by that deployed version, and secret-manager reference names. Do not copy one merchant's private keys or assume an AppID can settle to another merchant.

## API Payload Shape

Save one profile at a time. Values below are placeholders and must never be filled into a committed example:

```json
{
  "id": "secondary",
  "name": "Secondary Alipay profile",
  "enabled": true,
  "app_id": "<from secret manager>",
  "seller_id": "<from secret manager>",
  "private_key": "<from secret manager>",
  "platform_public_key": "<from secret manager>",
  "sandbox": false,
  "notify_url": "https://pay.example.com/api/alipay/notify",
  "return_url": "https://pay.example.com/api/alipay/return",
  "min_topup": 0.1
}
```

The profile endpoints are administrator-only. Never put the payload or its secret fields in shell history or an issue. Use an authenticated HTTPS client that reads secret values from a protected file descriptor or secret manager integration, and suppress request-body logging.

## Current SynthApi Snapshot

This is an operational snapshot checked on 2026-11-13, not a promise that production state will remain unchanged:

- `legacy` and `secondary` were both enabled in production mode and reported configured credentials.
- `secondary` was the active profile at the time of inspection.
- Both profiles used `https://synthapi.asia/api/alipay/notify` and `https://synthapi.asia/api/alipay/return`, with a minimum recharge amount of CNY 0.10.
- The actual AppIDs, SellerIDs, application private keys, and Alipay platform public keys are deliberately excluded. Retrieve current values only from the authenticated root-admin profile interface or the protected secret store.

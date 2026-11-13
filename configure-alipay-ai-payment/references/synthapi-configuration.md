# SynthApi Configuration

## Existing Contract

SynthApi stores direct-payment configuration as administrator options and exposes dedicated root-admin payment endpoints. Do not use a generic option-update path for private keys. In the two-profile version, `legacy` and `secondary` are stable profile IDs; each saved order records the profile credential version used to create it, so later profile edits or switches must not invalidate historical callbacks or queries.

| Field | Meaning | Constraint |
| --- | --- | --- |
| `enabled` | Enables official Alipay direct payment | Require payment compliance confirmation first |
| `app_id` | Alipay application ID | 16 numeric digits |
| `seller_id` | Settlement merchant ID | 16 digits beginning with `2088` |
| `private_key` | Application RSA private key | PKCS#1 or PKCS#8, at least 2048 bits |
| `platform_public_key` | Alipay platform RSA public key | At least 2048 bits |
| `sandbox` | Switches to sandbox gateway | Keep production and sandbox separate |
| `notify_url` | Asynchronous provider callback | Public HTTPS URL |
| `return_url` | Browser return | Public HTTPS URL |
| `min_topup` | Minimum recharge amount | At least `0.01` |

For the two-profile integration, use these root-admin endpoints over HTTPS from an authenticated administrator session:

| Route | Method | Purpose |
| --- | --- | --- |
| `/api/option/alipay-profiles` | GET | Read profile metadata and readiness flags; key material is redacted |
| `/api/option/alipay-profiles/save` | POST | Save one profile; blank key fields preserve stored values |
| `/api/option/alipay-profiles/activate` | POST | Select the profile used for new orders |

The legacy compatibility endpoint `POST /api/option/alipay-direct/save` remains available in deployments that still use the single-profile configuration. Do not place private keys in frontend bundles or command-line arguments.

## Routes

| Route | Method | Role |
| --- | --- | --- |
| `/api/user/self/alipay/pay` | POST | Create authenticated recharge order |
| `/api/user/self/alipay/status/:trade_no` | GET | Query authenticated recharge order |
| `/api/subscription/alipay/pay` | POST | Create authenticated subscription order |
| `/api/option/alipay-profiles` | GET | Root-admin profile status |
| `/api/option/alipay-profiles/save` | POST | Root-admin profile save |
| `/api/option/alipay-profiles/activate` | POST | Root-admin profile switch |
| `/api/alipay/notify` | POST | Provider asynchronous notification, no user auth |
| `/api/alipay/return` | GET | Browser return handler |

The authenticated user routes are nested under the site's API router. Verify the route tree and permission middleware in the checked-out release before automating against a different SynthApi version.

## Deployment Order

1. Confirm the selected profile is authorized for production page payments and that its AppID and SellerID are the intended merchant pair.
2. Confirm the reverse proxy forwards the notification path without request-body rewriting, challenge pages, or unstable tunnels.
3. Confirm DNS, certificate validity, and public reachability of both callback URLs from outside the origin network.
4. Save and validate the intended profile. Do not activate it merely because its fields are complete.
5. Test order creation, verified asynchronous settlement, duplicate notification idempotency, active query after an interrupted browser return, and a failed or closed order.
6. Activate the production profile only after compliance confirmation and successful production-path checks.

## Recovery

The service has a bounded polling recovery path for pending top-ups and subscriptions. It must query Alipay using the stored local order number and perform the same amount, seller, app, and terminal-status validation as the notification handler. Do not credit based solely on a user-provided provider trade number or screenshot.

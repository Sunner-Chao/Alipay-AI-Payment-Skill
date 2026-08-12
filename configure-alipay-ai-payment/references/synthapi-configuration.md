# SynthApi Configuration

## Existing Contract

SynthApi stores direct-payment configuration as administrator options and exposes a dedicated root-admin save endpoint. Do not use a generic option-update path for private keys.

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

The root-admin configuration endpoint is `POST /api/option/alipay-direct/save`. Send it only over HTTPS from an authenticated administrator session; never place the private key in a frontend build variable.

## Routes

| Route | Method | Role |
| --- | --- | --- |
| `/api/user/self/alipay/pay` | POST | Create authenticated recharge order |
| `/api/user/self/alipay/status/:trade_no` | GET | Query authenticated recharge order |
| `/api/subscription/alipay/pay` | POST | Create authenticated subscription order |
| `/api/alipay/notify` | POST | Provider asynchronous notification, no user auth |
| `/api/alipay/return` | GET | Browser return handler |

Verify route prefixes in the checked-out version before documenting external integration because the authenticated user route is nested by the API router.

## Deployment Order

1. Confirm the reverse proxy forwards the notification path without request-body rewriting.
2. Confirm DNS, certificate validity, and public reachability of both URLs.
3. Save disabled sandbox configuration, validate it, then create a low-value test order.
4. Confirm the asynchronous notification produces a durable order transition and a single quota/subscription update.
5. Confirm the status endpoint can reconcile an order if the browser return is interrupted.
6. Enable production only after payment compliance is confirmed and production tests pass.

## Recovery

The service has a bounded polling recovery path for pending top-ups and subscriptions. It must query Alipay using the stored local order number and perform the same amount, seller, app, and terminal-status validation as the notification handler. Do not credit based solely on a user-provided provider trade number or screenshot.

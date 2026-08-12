# Alipay Open Platform

## Scope

This integration uses the official page-payment API and RSA2 signing:

| Concern | Value |
| --- | --- |
| Create a browser payment | `alipay.trade.page.pay` |
| Reconcile a payment | `alipay.trade.query` |
| Production gateway | `https://openapi.alipay.com/gateway.do` |
| Sandbox gateway | `https://openapi-sandbox.dl.alipaydev.com/gateway.do` |
| Signature algorithm | RSA2 / SHA-256 with RSA |
| Charset | `utf-8` |
| Format | `JSON` |

## Platform Preparation

1. Create or select the Alipay Open Platform application authorized for the intended payment product.
2. Record the numeric AppID and authorized seller/merchant ID. Do not assume an application can settle to an arbitrary merchant.
3. Generate the application RSA keypair in a controlled environment. Upload only the application public key to Alipay.
4. Copy the Alipay platform public key from the application configuration. Keep it distinct from the application public key.
5. Configure a public HTTPS notification URL and return URL. The notification URL must be reachable without login, CAPTCHA, browser challenge, or an unstable tunnel.
6. Start in sandbox. Production and sandbox credentials, gateway hosts, and order records must not be mixed.

## Request Construction

Build common parameters with `app_id`, `method`, `format=JSON`, `charset=utf-8`, `sign_type=RSA2`, `timestamp`, `version=1.0`, `notify_url`, `return_url`, and `biz_content`. Create a deterministic canonical string and sign it with the application private key. URL-encode only after signing according to the provider protocol.

For page pay, include at least `out_trade_no`, `product_code=FAST_INSTANT_TRADE_PAY`, `total_amount` as a two-decimal CNY string, and a concise subject. Generate `out_trade_no` server-side and reserve it before redirecting the user.

## Key Handling

- Treat the application private key as a credential. Restrict access and rotate it on suspected disclosure.
- Use the platform public key only to verify incoming signed content. Do not verify notifications with the application public key.
- Do not paste private-key material or complete production callback payloads into chat, tickets, or source control.

Consult current official Alipay Open Platform documentation before enabling a product, because product entitlement and compliance requirements can change.

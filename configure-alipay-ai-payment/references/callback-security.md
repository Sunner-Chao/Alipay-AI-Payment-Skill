# Callback Security

## Processing Sequence

1. Limit request-body size and parse form data defensively.
2. Extract one value per signed parameter; reject ambiguous or missing required fields.
3. Remove `sign` and `sign_type`, sort remaining signed parameters, and verify RSA2 with the Alipay platform public key.
4. Load the local order by `out_trade_no`.
5. Require exact matches for AppID, optional `auth_app_id`, SellerID, and amount. Require a provider trade number for a successful terminal state.
6. Accept only documented terminal states. Query Alipay when the notification cannot independently establish a safe terminal transition.
7. In one database transaction, move the local order, record the provider trade number, and credit quota or activate the subscription exactly once.
8. Return `success` only after that transaction commits.

## Idempotency

Alipay can deliver notifications more than once and browser return can race with notification or active query. Model order state as monotonic: a completed order stays completed and produces no second credit. Keep a unique local order number and retain the provider transaction reference for audit and reconciliation.

## Network Requirements

- Keep the notify endpoint publicly reachable by HTTPS. Test it outside the origin VPC.
- Avoid Cloudflare browser challenges or Turnstile on the provider callback route.
- Preserve form request bodies through Nginx or tunnels.
- Do not rely on source IP alone for authenticity; signature verification is mandatory.

## Logging

Log timestamp, local order number, provider trade number, terminal status, safe error classification, and caller IP where lawful. Redact keys, full signatures, and private customer fields. Use immutable audit logs for credits and refunds.

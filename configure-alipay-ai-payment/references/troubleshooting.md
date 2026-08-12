# Troubleshooting

| Symptom | Likely cause | Safe response |
| --- | --- | --- |
| Orders cannot be created | Product not authorized, bad AppID/key, unsupported gateway | Validate sandbox/production pairing and local config |
| Notification keeps retrying | Callback inaccessible, certificate failure, handler returned non-success, signature mismatch | Test public POST routing and verify platform key/canonicalization |
| Browser shows success but quota is unchanged | Return is ahead of notification or user closed page | Query through the authenticated status endpoint and rely on verified provider query |
| Amount mismatch | Client-controlled amount, stale order, decimal conversion issue | Reject and audit; use server-side two-decimal CNY values |
| Duplicate credit | Missing unique state transition or non-transactional credit | Repair with an idempotent transaction, then reconcile affected orders |
| Sandbox works but production fails | Production authorization, merchant binding, production public key | Re-check entitlement and merchant authorization; never reuse sandbox credentials |

For a suspect payment, preserve the local order number and a minimal redacted event timeline. Query the provider from the server, not the browser. Any refund should enter manual review when evidence is incomplete or inconsistent.

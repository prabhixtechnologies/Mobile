# MobiStack device test â€” 2026-10-01

Device: Samsung SM-F415F (Android, 1080Ã—2340). App: MobiStack 1.3.1 (10), from Play.
Account: system admin, shop "Bihar Mobile Union" on the COMPATIBILITY plan until 2026-10-14.

Driven over USB with adb: every tab, every page reachable from it, the main action on each.
Request timings are the app's own log (`mobistack â† 200 â€¦ 142ms`).

## Root cause behind most failures

`/auth/me` tells a system admin that every feature is on and that the shop is neither unpaid
nor catalog-only, so the app shows Stock, Sales, Repairs and the rest. The server's gates
(`CatalogOnlyFilter`, `CatalogPlanFilter`, `WorkspaceGuardFilter`, `BillingService.require*`)
had no such exemption and answered 402 to each of those calls. Every "broken" row marked
**402** below is this one mismatch.

## Results

| # | Screen | What happened | Kind |
|---|---|---|---|
| 1 | Startup | `/sync/snapshot`, `/users`, `/suppliers`, `/purchases`, `/inventory/transactions`, `/compatibility-groups` all return 402 | Broken (402) |
| 2 | Stock | Empty ("No stock cached yet") â€” the inventory read is refused | Broken (402) |
| 3 | Stock â†’ New part â†’ Save | Refused; the snackbar shows the raw `DioException [bad response] â€¦` developer text | Broken (402) + view |
| 4 | Back from Stock, Sales, Repairs, Catalog | System Back closes the app instead of returning Home | Broken |
| 5 | Repairs â†’ New repair | Asks only Problem, IMEI, Estimate; no customer or phone model. Silently attaches the job to the first customer in the list | Broken |
| 6 | Repairs â†’ saved job | Goes to the outbox, never appears; "Syncing 1 queued changeâ€¦" banner stays forever with no reason and no way to clear it | Broken |
| 7 | Sales â†’ Add with empty stock | "No matching SKU in cached stock" | OK |
| 8 | Billing | Banner "Razorpay is not configured on the server yet â€” DEV confirm may still activate a plan" (developer text) | View |
| 9 | Billing | Active Compatibility plan shows an **Activate** button | View |
| 10 | Billing | Only the â‚¹50 Compatibility plan is offered. Full shop (â‚¹199) is hidden on purpose since 2026-09-23, so a shop cannot upgrade from the phone | Decision, not changed |
| 11 | Home stat tiles | "0 SALES / 0 TICKETS / 0 REPAIRS / 0 LOW": no â‚¹, unclear labels, not tappable | View |
| 12 | Home â†’ Scan barcode | Black camera view with no frame, hint, torch or manual entry (phone was face down; permission granted) | View |
| 13 | Catalog â†’ Battery â†’ Apple â†’ iPhone 11 | Shows the DB part "Apple iPhone 11 Battery Â· Exact" â€” 3 calls, 351 + 75 + 57 ms | OK, fast |
| 14 | Catalog â†’ part â†’ Confirm | "Confirmed. That spare stays in the shared catalog." 483 ms | OK |
| 15 | More â†’ Private fitment notes | 402, raw DioException text | Broken (402) + view |
| 16 | More â†’ Standing | Prints the raw map `{accepted: 0, rejected: 0, trusted: false, banned: false}` | View |
| 17 | More â†’ Catalog import | 402, raw DioException text | Broken (402) + view |
| 18 | More â†’ Purchases | 402 after 1443 ms, raw DioException text | Broken (402) + view |
| 19 | More â†’ Movements | 402, raw DioException text | Broken (402) + view |
| 20 | More â†’ Workspaces | "1 shops"; subtitle is the raw shop UUID | View |
| 21 | More â†’ Reports | Chips read `today / 7d / this_month`; nothing loads until a chip is tapped; amounts without â‚¹ | View |
| 22 | More â†’ Inbox | "payment for WORKSPACE ACTIVATION â€¦ until 2026-10-14T13:08:10.881442241Z" | View |
| 23 | More â†’ Notifications | Raw codes `PASSWORD_RESET / Push`, `JOIN_REQUEST_APPROVED / Push` â€¦ | View |
| 24 | More â†’ Audit | 402, raw DioException text | Broken (402) + view |
| 25 | More â†’ Health | 402, raw DioException text as the page subtitle | Broken (402) + view |
| 26 | More â†’ Support | Loads (455 ms) | OK |
| 27 | More â†’ Settings | Shows API base URL, Identity issuer, "Allow create-account prompt", "Flush outbox 1" â€” developer entries | View |
| 28 | More â†’ Profile | Raw user id and raw feature codes (`COMPATIBILITY`, `MOVEMENTS` â€¦) | View |
| 29 | Push notifications | Skipped: FirebaseOptions missing from the Android build | Config, not changed |
| 30 | Speed | Every 200 response was under 600 ms. The slowness seen was the 402 failures and the stuck outbox, not slow endpoints | â€” |

## Fixes (MobiStack 1.3.2+12 and mobistack-backend 269b12c)

- Server: every billing gate now exempts a system admin, matching `/auth/me` (rows 1â€“3, 15, 17â€“19, 24, 25).
- App: one `describeError` shows the server's sentence, or a plain line per failure kind, everywhere `'$e'` was shown (rows 3, 15, 17â€“19, 24, 25).
- App: Back on a shell screen returns to the first tab; only the first tab exits (row 4).
- App: New repair asks customer name, phone, phone model, problem, IMEI, estimate. Matches an existing customer by phone; otherwise keeps the details on the job (row 5).
- App: the outbox keeps the reason a change was refused. The bar turns red with that reason, and tapping it offers Try again or Discard (row 6).
- App: Billing banner reads as customer text; the live plan shows **Current** (rows 8, 9).
- App: Home tiles read â‚¹ Sales, Bills, Repairs, Low stock and open their screen (row 11).
- App: scanner has an aiming frame, hint, torch, "Type the code", and a camera-error message (row 12).
- App: Standing, Workspaces, Reports, Notifications, Health, Settings and Profile show words, not codes (rows 16, 20, 21, 23, 27, 28).
- Server: payment inbox messages use "Workspace activation" and "14 Oct 2026" (row 22). Existing inbox rows keep their old text.

Not changed: row 10 (hiding Full shop is a product decision) and row 29 (needs the Firebase config file).

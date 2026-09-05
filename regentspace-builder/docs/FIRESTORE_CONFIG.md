# Firestore Configuration for Regentspace Apps

Each generated app has a unique `app-id` (from the canva JSON `app.id` field). All multi-tenant data is stored under `apps/{appId}/...` in a shared Firestore database.

## Required Firestore Documents

You must manually create these documents in Firestore before the app can use VTPass, Monnify, or other services.

### 1. VTPass Credentials

**Path:** `apps/{appId}/config/vtpass`

```json
{
  "apiKey": "your-vtpass-api-key",
  "secretKey": "your-vtpass-secret-key",
  "publicKey": "your-vtpass-public-key",
  "baseUrl": "https://sandbox.vtpass.com/api"
}
```

| Field | Description |
|-------|-------------|
| `apiKey` | VTPass API key (used in `api-key` header for POST requests) |
| `secretKey` | VTPass secret key (used in `secret-key` header for POST requests) |
| `publicKey` | VTPass public key (used in `public-key` header for GET requests) |
| `baseUrl` | API base URL — use `https://sandbox.vtpass.com/api` for testing, `https://vtpass.com/api` for production |

### 2. Monnify Credentials

**Path:** `apps/{appId}/config/monnify`

```json
{
  "apiKey": "your-monnify-api-key",
  "secretKey": "your-monnify-secret-key",
  "contractCode": "your-monnify-contract-code",
  "baseUrl": "https://sandbox.monnify.com",
  "useDirect": true
}
```

| Field | Description |
|-------|-------------|
| `apiKey` | Monnify API key |
| `secretKey` | Monnify secret key |
| `contractCode` | Monnify contract code |
| `baseUrl` | API base URL — use `https://sandbox.monnify.com` for testing, `https://api.monnify.com` for production |
| `useDirect` | `true` for direct charges (no wallet funding needed), `false` for wallet-based payments |

### 3. App Wallet Balance (Optional)

**Path:** `apps/{appId}/config/wallet`

```json
{
  "currency": "NGN",
  "lowBalanceThreshold": "1000"
}
```

## Data Structure

All app data is scoped under `apps/{appId}/`:

```
apps/
  {appId}/
    config/
      vtpass/          ← VTPass API credentials
      monnify/         ← Monnify API credentials
      wallet/          ← Wallet settings (optional)
    users/
      {uid}/           ← Per-user data (profile, wallet, etc.)
    vtpass_transactions/
      {txnId}          ← VTPass transaction history
    monnify_reserved_accounts/
      {accountId}      ← Monnify reserved account details
    notifications/
      {notifId}        ← User notifications
```

## Example: Setting Up `regentpay_v1`

For the example app with `app.id = "regentpay_v1"`:

1. **Create VTPass config:**
   ```
   firestore> apps> regentpay_v1> config> vtpass
   ```

2. **Create Monnify config:**
   ```
   firestore> apps> regentpay_v1> config> monnify
   ```

3. **Deploy Firestore rules:**
   ```
   firebase deploy --only firestore:rules
   ```

## Firestore Rules

The `firestore.rules` file in the template enforces tenant isolation:

- Users can only read/write their own data under `apps/{appId}/users/{uid}`
- VTPass transactions are scoped to `apps/{appId}/vtpass_transactions`
- Config documents are read-only for clients (written by admin/server)

## Testing with Sandbox

For initial testing:

1. Use VTPass sandbox URLs and test credentials
2. Use Monnify sandbox environment
3. Create test Firestore documents with sandbox credentials
4. Switch to production URLs and credentials before launch

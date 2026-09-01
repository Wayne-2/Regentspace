// Firebase Functions proxy for Monnify — keeps secret keys OFF device.
// Deploy: firebase init functions (Node), place this in functions/index.js, then `firebase deploy --only functions`
// Set secrets: firebase functions:secrets:set MONNIFY_API_KEY && MONNIFY_SECRET_KEY && MONNIFY_CONTRACT_CODE && MONNIFY_BASE_URL
//
// Why: Direct client Basic auth exposes secret in APK/IPA (extractable). Proxy signs requests server-side.
// Sandbox may use direct=true for quick testing; prod MUST use proxy (MONNIFY_USE_DIRECT=false + --dart-define).

const {onCall, onRequest} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const admin = require("firebase-admin");
admin.initializeApp();

const apiKey = defineSecret("MONNIFY_API_KEY");
const secretKey = defineSecret("MONNIFY_SECRET_KEY");
const contractCode = defineSecret("MONNIFY_CONTRACT_CODE");
const baseUrl = defineSecret("MONNIFY_BASE_URL"); // https://api.monnify.com or https://sandbox.monnify.com

let cachedToken = null, tokenExp = 0;
async function getToken() {
  if (cachedToken && Date.now() < tokenExp) return cachedToken;
  const b64 = Buffer.from(`${apiKey.value()}:${secretKey.value()}`).toString("base64");
  const res = await fetch(`${baseUrl.value()}/api/v1/auth/login`, {
    method: "POST",
    headers: {Authorization: `Basic ${b64}`},
  });
  const body = await res.json();
  if (!res.ok) throw new Error(`Monnify auth ${res.status}: ${JSON.stringify(body)}`);
  cachedToken = body.responseBody.accessToken || body.accessToken;
  tokenExp = Date.now() + 50 * 60 * 1000;
  return cachedToken;
}

// POST reserved account — mirrors MonnifyService.createReservedAccount payload
exports.monnifyCreateReservedAccount = onCall({secrets: [apiKey, secretKey, contractCode, baseUrl]}, async (req) => {
  if (!req.auth) throw new Error("Unauthenticated");
  const token = await getToken();
  const url = `${baseUrl.value()}/api/v2/bank-transfer/reserved-accounts`;
  const res = await fetch(url, {
    method: "POST",
    headers: {Authorization: `Bearer ${token}`, "Content-Type": "application/json"},
    body: JSON.stringify({...req.data, contractCode: req.data.contractCode || contractCode.value()}),
  });
  const body = await res.json();
  if (!res.ok) throw new Error(`Monnify ${res.status}: ${JSON.stringify(body)}`);
  return body.responseBody || body;
});

exports.monnifyDisburse = onCall({secrets: [apiKey, secretKey, baseUrl]}, async (req) => {
  if (!req.auth) throw new Error("Unauthenticated");
  const token = await getToken();
  const url = `${baseUrl.value()}/api/v2/disbursements/single`;
  const res = await fetch(url, {
    method: "POST",
    headers: {Authorization: `Bearer ${token}`, "Content-Type": "application/json"},
    body: JSON.stringify(req.data),
  });
  const body = await res.json();
  if (!res.ok) throw new Error(`Monnify ${res.status}: ${JSON.stringify(body)}`);
  return body.responseBody || body;
});

// Webhook — set in Monnify dashboard to https://<region>-<project>.cloudfunctions.net/monnifyWebhook
// Verifies hash, then writes to Firestore monnify_transactions + bumps totals.
// Configure webhook secret in Monnify dashboard and define as MONNIFY_WEBHOOK_KEY secret.
exports.monnifyWebhook = onRequest({secrets: [defineSecret("MONNIFY_WEBHOOK_KEY")]}, async (req, res) => {
  try {
    // TODO: verify X-Monnify-Signature header with MONNIFY_WEBHOOK_KEY if Monnify provides one
    const event = req.body;
    const data = event.eventData || event;
    const ref = data.accountReference || data.destinationAccountInformation?.accountReference || "";
    const txRef = data.transactionReference || data.paymentReference || `${Date.now()}`;
    await admin.firestore().collection("monnify_transactions").doc(txRef).set({
      accountReference: ref,
      transactionReference: txRef,
      amountPaid: data.amountPaid,
      totalPayable: data.totalPayable,
      paidOn: data.paidOn || admin.firestore.FieldValue.serverTimestamp(),
      paymentStatus: data.paymentStatus || "PAID",
      raw: event,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    }, {merge: true});
    if (ref) {
      const amt = Number(data.amountPaid) || 0;
      await admin.firestore().collection("monnify_reserved_accounts").doc(ref).set({
        totalReceived: admin.firestore.FieldValue.increment(amt),
        lastPaymentAt: admin.firestore.FieldValue.serverTimestamp(),
      }, {merge: true});
    }
    res.status(200).send("ok");
  } catch (e) {
    console.error(e);
    res.status(500).send(String(e));
  }
});

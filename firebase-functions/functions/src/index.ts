/**
 * Import function triggers from their respective submodules:
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import Razorpay from "razorpay";
import firebaseAdmin from "firebase-admin";
import * as functions from "firebase-functions";
import * as https from "firebase-functions/v2/https";


// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// Initialize Firebase Admin SDK
if (!firebaseAdmin.apps.length) {
  firebaseAdmin.initializeApp();
} else {
  console.log("FAILED TO INITIALIZE.");
}


const db = firebaseAdmin.firestore();

const storeOrder = async (
  order_id: string,
  donor_id: string, // firebase uid
  beneficiary_id: string // firebase uid
) => {
  await db.collection("orders").doc(order_id).set({
    id: order_id,
    donor_id,
    beneficiary_id,
    created_at: firebaseAdmin.firestore.FieldValue.serverTimestamp(),
  });
};


const getOrder = async (order_id: string) => {
  const doc = await db.collection("orders").doc(order_id).get();

  if (!doc.exists) {
    throw new Error(`Order with ID ${order_id} does not exist.`);
  }

  return doc.data();
};


const deleteOrder = async (order_id: string) => {
  await db.collection("orders").doc(order_id).delete();
};


const createSubscriptionRecord = async (
  subscription_id: string,
  plan_id: string,
  donor_id: string, // firebase uids
  beneficiary_id: string, // firebase uids
) => {
  await db.collection("subscriptions").doc(subscription_id).set(
    {
      id: subscription_id,
      plan_id,
      status: "created",
      donor_id,
      beneficiary_id,
      created_at: firebaseAdmin.firestore.FieldValue.serverTimestamp(),
    }
  );
};

const updateSubscriptionRecord = async (
  subscription_id: string,
  status: string
) => {
  // firebase uids
  await db.collection("subscriptions").doc(subscription_id).update(
    {
      status,
    }
  );
};

const createTransaction = async (
  transaction_id: string,
  subscription_payment: boolean,
  amount: number,
  currency: string,
  donor_id: string,
  beneficiary_id: string,
) => {
  await db.collection("transaction").doc(transaction_id).set(
    {
      id: transaction_id,
      subscription_payment,
      amount,
      currency,
      donor_id,
      beneficiary_id,
      created_at: firebaseAdmin.firestore.FieldValue.serverTimestamp(),
    }
  );
};


export const createOneTimeCheckout = https.onCall(async (request) => {
  try {
    // Checking auth
    if (!request.auth) throw new https.HttpsError("failed-precondition", "The function must be called while authenticated.");

    // Getting data.
    const {beneficiary_id, amount, currency}: { beneficiary_id: string; amount: number, currency: string } = request.data;


    // SECRETS
    const RAZORPAY_KEY_ID = process.env.RAZORPAY_KEY_ID;
    const RAZORPAY_SECRET = process.env.RAZORPAY_SECRET;

    const razorpay = new Razorpay({
      key_id: RAZORPAY_KEY_ID,
      key_secret: RAZORPAY_SECRET,
    });


    // Creating order.
    const order = await razorpay.orders.create({
      amount,
      currency,
      notes: {
        beneficiary_id,
        donor_id: request.auth.uid,
      },
    });

    await storeOrder(order.id, request.auth.uid, beneficiary_id);
    return {order_id: order.id};
  } catch (error) {
    throw new https.HttpsError("internal", "Failed to generate one time checkout.");
  }
});


export const createSubscriptionCheckout = https.onCall(async (request) => {
  try {
    // Checking auth
    if (!request.auth) throw new https.HttpsError("failed-precondition", "The function must be called while authenticated.");

    // Getting data.
    const {beneficiary_id, plan_id}: { beneficiary_id: string; plan_id: string } = request.data;

    // SECRETS
    const RAZORPAY_KEY_ID = process.env.RAZORPAY_KEY_ID;
    const RAZORPAY_SECRET = process.env.RAZORPAY_SECRET;

    const razorpay = new Razorpay({
      key_id: RAZORPAY_KEY_ID,
      key_secret: RAZORPAY_SECRET,
    });


    // Creating subscription.
    const subscription = await razorpay.subscriptions.create({
      plan_id,
      total_count: 24,
      notes: {
        beneficiary_id,
        donor_id: request.auth.uid,
      },
    });

    createSubscriptionRecord(subscription.id, plan_id, request.auth.uid, beneficiary_id);

    return {subscription_id: subscription.id};
  } catch (error) {
    throw new https.HttpsError("internal", "Failed to generate one time checkout.");
  }
});


export const cancelSubscription = https.onCall(async (request) => {
  try {
    // Checking auth
    if (!request.auth) throw new https.HttpsError("failed-precondition", "The function must be called while authenticated.");

    // Getting data.
    const {subscription_id}: { subscription_id: string } = request.data;

    // SECRETS
    const RAZORPAY_KEY_ID = process.env.RAZORPAY_KEY_ID;
    const RAZORPAY_SECRET = process.env.RAZORPAY_SECRET;

    const razorpay = new Razorpay({
      key_id: RAZORPAY_KEY_ID,
      key_secret: RAZORPAY_SECRET,
    });

    // Creating subscription.
    await razorpay.subscriptions.cancel(subscription_id);
    return {};
  } catch (error) {
    throw new https.HttpsError("internal", "Failed to generate one time checkout.");
  }
});


export const razorpayCallbackSubscription = functions.https.onRequest(async (req, res) => {
  try {
    const data = req.body;

    const event = data.event;
    const payload = data.payload;

    const subscription = payload?.subscription?.entity;
    const payment = payload?.payment?.entity;

    const status = subscription?.status;
    const subscription_id = subscription?.id;

    if (!event || (!subscription_id && !payment?.id)) {
      res.status(400).json({error: "Missing event or necessary IDs."});
      return;
    }

    if (event === "subscription.activated") {
      await updateSubscriptionRecord(subscription_id, status);
    } else if (event === "subscription.charged") {
      const transaction_id = payment?.id;
      const amount = payment?.amount;
      const currency = payment?.currency;

      if (payment?.status === "captured") {
        const subDoc = await db.collection("subscriptions").doc(subscription_id).get();

        if (!subDoc.exists) {
          console.warn(`Subscription ${subscription_id} not found`);
          res.status(404).json({error: "Subscription not found."});
          return;
        }

        const subData = subDoc.data();

        await createTransaction(
          transaction_id,
          true,
          amount,
          currency,
          subData?.donor_id,
          subData?.beneficiary_id
        );
      }
    } else if (event === "subscription.cancelled") {
      await updateSubscriptionRecord(subscription_id, status);
    } else if (event === "subscription.authenticated") {
      await updateSubscriptionRecord(subscription_id, "active");
    } else if (event === "payment.captured") {
      const transaction_id = payment?.id;
      const amount = payment?.amount;
      const currency = payment?.currency;

      const order_id = payment?.order_id;
      const order = await getOrder(order_id);

      if (!order) {
        console.warn(`Order ${order_id} not found`);
        res.status(404).json({error: "Order not found."});
        return;
      }

      await createTransaction(
        transaction_id,
        false,
        amount,
        currency,
        order?.donor_id,
        order?.beneficiary_id
      );

      await deleteOrder(order_id);
    }

    res.status(200).json({success: true});
  } catch (error) {
    console.error("Error in razorpayCallbackSubscription:", error);
    res.status(500).json({error: "Internal server error."});
  }
});

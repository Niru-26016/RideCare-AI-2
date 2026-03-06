import { initializeApp } from "firebase/app";
import { getFirestore, collection, getDocs, setDoc, doc } from "firebase/firestore";
import dotenv from 'dotenv';
dotenv.config();

const firebaseConfig = {
    apiKey: process.env.VITE_FIREBASE_API_KEY,
    authDomain: process.env.VITE_FIREBASE_AUTH_DOMAIN,
    projectId: process.env.VITE_FIREBASE_PROJECT_ID,
    storageBucket: process.env.VITE_FIREBASE_STORAGE_BUCKET,
    messagingSenderId: process.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
    appId: process.env.VITE_FIREBASE_APP_ID,
    measurementId: process.env.VITE_FIREBASE_MEASUREMENT_ID
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function testFirebase() {
    try {
        console.log("Testing write...");
        await setDoc(doc(db, "vehicles", "test"), { test: true });
        console.log("Write successful!");

        console.log("Testing read...");
        const snap = await getDocs(collection(db, "vehicles"));
        console.log("Read successful! Found", snap.size, "documents.");
        process.exit(0);
    } catch (err) {
        console.error("Firebase Error:", err.code, err.message);
        process.exit(1);
    }
}

testFirebase();

// Test data seeder for Firestore — run once with: node seed-data.js
import { initializeApp } from 'firebase/app';
import { getFirestore, collection, doc, setDoc, Timestamp } from 'firebase/firestore';

const firebaseConfig = {
    apiKey: process.env.VITE_FIREBASE_API_KEY,
    authDomain: "ridecare-2.firebaseapp.com",
    projectId: "ridecare-2",
    storageBucket: "ridecare-2.firebasestorage.app",
    messagingSenderId: "541470688100",
    appId: "1:541470688100:web:e9953e4c76cead3652f071",
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// Test fleet — vehicles around Chennai, India
const testVehicles = [
    {
        id: 'TN07AB1234',
        info: { driver: 'Ravi', type: 'Car', model: 'Swift Dzire' },
        temperature: 78, voltage: 12.5, mileageSinceService: 2200,
        vibration: 12, fuelEfficiency: 17, baseVib: 10, baseFuel: 18,
        score: 95, state: 'Healthy', issues: [],
        vehicleState: 'Driving', prediction: 'Operating optimally.',
        location: { lat: 13.0827, lng: 80.2707 }, // Chennai Central
    },
    {
        id: 'TN09XY9876',
        info: { driver: 'Kumar', type: 'Car', model: 'Toyota Innova' },
        temperature: 98, voltage: 12.1, mileageSinceService: 5500,
        vibration: 14, fuelEfficiency: 16, baseVib: 10, baseFuel: 18,
        score: 70, state: 'Attention Needed', issues: ['Running Hot', 'Service Due Soon'],
        vehicleState: 'Traffic', prediction: 'Schedule maintenance within 3 days.',
        location: { lat: 13.0604, lng: 80.2496 }, // T. Nagar
    },
    {
        id: 'TN10CD5678',
        info: { driver: 'Arun', type: 'Car', model: 'Hyundai Xcent' },
        temperature: 110, voltage: 11.4, mileageSinceService: 9200,
        vibration: 38, fuelEfficiency: 8, baseVib: 10, baseFuel: 18,
        score: 15, state: 'Critical', issues: ['Critical Overheating', 'Battery Critically Low', 'Service Overdue', 'Severe Engine Knocking', 'Poor Fuel Economy'],
        vehicleState: 'Idle', prediction: 'URGENT: Multiple critical failures detected. Vehicle unsafe for operation.',
        location: { lat: 13.0674, lng: 80.2376 }, // Kodambakkam
    },
    {
        id: 'TN01EF4321',
        info: { driver: 'Mani', type: 'Auto', model: 'Bajaj RE' },
        temperature: 82, voltage: 12.4, mileageSinceService: 3100,
        vibration: 22, fuelEfficiency: 27, baseVib: 20, baseFuel: 28,
        score: 90, state: 'Healthy', issues: [],
        vehicleState: 'Driving', prediction: 'Operating optimally.',
        location: { lat: 13.0878, lng: 80.2785 }, // Egmore
    },
    {
        id: 'TN02GH8765',
        info: { driver: 'Suresh', type: 'Auto', model: 'Piaggio Ape' },
        temperature: 96, voltage: 11.9, mileageSinceService: 6200,
        vibration: 32, fuelEfficiency: 24, baseVib: 20, baseFuel: 28,
        score: 55, state: 'Service Soon', issues: ['Running Hot', 'Battery Weak', 'Service Due Soon', 'Abnormal Vibration'],
        vehicleState: 'Traffic', prediction: 'Battery and engine issues developing. Service within 48 hours.',
        location: { lat: 13.0443, lng: 80.2345 }, // Saidapet
    },
    {
        id: 'TN05IJ1234',
        info: { driver: 'Ramesh', type: 'Auto', model: 'Bajaj Maxima' },
        temperature: 72, voltage: 12.6, mileageSinceService: 1800,
        vibration: 21, fuelEfficiency: 27, baseVib: 20, baseFuel: 28,
        score: 100, state: 'Healthy', issues: [],
        vehicleState: 'Resting', prediction: 'Operating optimally.',
        location: { lat: 13.1067, lng: 80.2842 }, // Chetpet
    },
    {
        id: 'TN04KL5678',
        info: { driver: 'Karthik', type: 'Bike', model: 'Honda Activa' },
        temperature: 70, voltage: 12.5, mileageSinceService: 4800,
        vibration: 16, fuelEfficiency: 44, baseVib: 15, baseFuel: 45,
        score: 95, state: 'Healthy', issues: [],
        vehicleState: 'Driving', prediction: 'Operating optimally.',
        location: { lat: 13.0524, lng: 80.2508 }, // Nungambakkam
    },
    {
        id: 'TN03MN9012',
        info: { driver: 'Vignesh', type: 'Bike', model: 'TVS Jupiter' },
        temperature: 88, voltage: 12.3, mileageSinceService: 7500,
        vibration: 28, fuelEfficiency: 40, baseVib: 15, baseFuel: 45,
        score: 60, state: 'Attention Needed', issues: ['Service Due Soon', 'Abnormal Vibration'],
        vehicleState: 'Idle', prediction: 'Engine vibration increasing. Schedule inspection.',
        location: { lat: 13.0339, lng: 80.2430 }, // Guindy
    },
    {
        id: 'TN06OP3456',
        info: { driver: 'Balaji', type: 'Bike', model: 'Hero Splendor' },
        temperature: 65, voltage: 12.6, mileageSinceService: 900,
        vibration: 15, fuelEfficiency: 45, baseVib: 15, baseFuel: 45,
        score: 100, state: 'Healthy', issues: [],
        vehicleState: 'Resting', prediction: 'Operating optimally.',
        location: { lat: 13.0732, lng: 80.2610 }, // Mylapore
    },
];

async function seedData() {
    console.log('🚀 Seeding test data to Firestore...\n');

    for (const vehicle of testVehicles) {
        const { id, ...data } = vehicle;
        const docRef = doc(db, 'vehicles', id);
        await setDoc(docRef, {
            ...data,
            lastUpdated: Date.now(),
            timestamp: Timestamp.now(),
        }, { merge: true });

        const emoji = data.score >= 80 ? '✅' : data.score >= 60 ? '⚠️' : '🔴';
        console.log(`${emoji} ${id} — ${data.info.driver} (${data.info.model}) — Score: ${data.score} — ${data.state}`);
    }

    console.log('\n✨ Done! All 9 vehicles seeded successfully.');
    process.exit(0);
}

seedData().catch(err => {
    console.error('Error seeding data:', err);
    process.exit(1);
});

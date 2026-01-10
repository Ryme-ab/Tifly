const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const admin = require('firebase-admin');
const { createClient } = require('@supabase/supabase-js');

// 1. Configuration
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// 2. Initialize Firebase Admin SDK
// Ideally, the service account key should be loaded securely (e.g. from environment variable or file)
// For this setup, we assume serviceAccountKey.json is in the root of the backend folder.
// INSTRUCTIONS: Download your Firebase Service Account Key and save it as 'serviceAccountKey.json'
try {
  const serviceAccount = require('./serviceAccountKey.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log('✅ Firebase Admin Initialized');
} catch (error) {
  console.error('❌ Failed to initialize Firebase Admin. Please ensure serviceAccountKey.json is present.', error.message);
}

const db = admin.firestore();

// 3. Initialize Supabase Client (For Auth Verification)
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY; // Service Role Key/Anon Key depending on usage, but Anon is enough for verify? No, verifying JWT usually needs secret or just client.getUser()
// Actually, to verify a JWT securely on backend, we typically use the Supabase Auth GoTrue client or simply call auth.getUser(token).

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Supabase URL and Key are required in .env file');
}

const supabase = createClient(supabaseUrl, supabaseKey);

// 4. Authentication Middleware
async function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing or invalid Authorization header' });
  }

  const token = authHeader.split(' ')[1];

  try {
    // Verify the token by calling Supabase Auth
    const { data: { user }, error } = await supabase.auth.getUser(token);

    if (error || !user) {
      console.error('Auth verification failed:', error?.message);
      return res.status(401).json({ error: 'Invalid or expired token' });
    }

    // Attach user to request
    req.user = user;
    next();
  } catch (e) {
    console.error('Unexpected auth error:', e);
    return res.status(500).json({ error: 'Internal Server Error during authentication' });
  }
}

// 5. Routes

// Health Check
app.get('/', (req, res) => {
  res.send('Tifli Secure Backend is running 🚀');
});

/**
 * GET /appointments
 * Returns appointments for the authenticated user only.
 */
app.get('/appointments', authenticate, async (req, res) => {
  try {
    const userId = req.user.id;
    console.log(`📥 Fetching appointments for user: ${userId}`);

    const snapshot = await db.collection('appointments')
      .where('userId', '==', userId)
      .orderBy('date', 'asc') // Assuming 'date' field exists and we want them ordered
      .get();

    if (snapshot.empty) {
      return res.status(200).json([]);
    }

    const appointments = [];
    snapshot.forEach(doc => {
      appointments.push({ id: doc.id, ...doc.data() });
    });

    res.status(200).json(appointments);
  } catch (error) {
    console.error('Error fetching appointments:', error);
    res.status(500).json({ error: 'Failed to fetch appointments' });
  }
});

/**
 * POST /appointments
 * Creates a new appointment securely for the authenticated user.
 */
app.post('/appointments', authenticate, async (req, res) => {
  try {
    const userId = req.user.id;
    const { date, time, description, doctorName, childId } = req.body;

    // Basic Validation
    if (!date || !time) {
      return res.status(400).json({ error: 'Date and Time are required' });
    }

    const newAppointment = {
      userId: userId, // ENFORCE userId from token
      childId: childId || null,
      date: date,
      time: time,
      description: description || '',
      doctorName: doctorName || '',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };

    const docRef = await db.collection('appointments').add(newAppointment);

    console.log(`✅ Appointment created with ID: ${docRef.id} for user: ${userId}`);

    res.status(201).json({
      id: docRef.id,
      ...newAppointment,
      message: 'Appointment created successfully'
    });

  } catch (error) {
    console.error('Error creating appointment:', error);
    res.status(500).json({ error: 'Failed to create appointment' });
  }
});

// Start Server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`\n---------------------------------------------------------`);
  console.log(`🔐 Tifli Backend listening on http://0.0.0.0:${PORT}`);
  console.log(`---------------------------------------------------------\n`);
  console.log(`👉 IMPORTANT SETUP STEPS:`);
  console.log(`   1. Place 'serviceAccountKey.json' in /backend folder.`);
  console.log(`   2. Create '.env' file with SUPABASE_URL and SUPABASE_KEY.`);
  console.log(`   3. Run 'npm install'`);
  console.log(`   4. Run 'npm start'`);
  console.log(`---------------------------------------------------------\n`);
});

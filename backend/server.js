const express = require('express');
const bodyParser = require('body-parser');
const MongoClient = require('mongodb').MongoClient;

const app = express();
const port = 3000;

app.use(bodyParser.json());

const mongoUrl = 'mongodb+srv://test:test@abhi.c5ekv3s.mongodb.net/test?retryWrites=true&w=majority&appName=abhi';
const dbName = 'test';

app.post('/saveData', async (req, res) => {
  try {
    const client = await MongoClient.connect(mongoUrl, { useNewUrlParser: true, useUnifiedTopology: true });
    const db = client.db(dbName);
    const collection = db.collection('users');

    const { name, password, videoDetails } = req.body;

    const result = await collection.insertOne({
      name: name,
      password: password,
      videoDetails: videoDetails,
    });

    client.close();

    res.status(200).send('Data saved to MongoDB');
  } catch (err) {
    console.error('Error saving data:', err);
    res.status(500).send('Failed to save data to MongoDB');
  }
});

app.get('/getData', async (req, res) => {
  try {
    const client = await MongoClient.connect(mongoUrl, { useNewUrlParser: true, useUnifiedTopology: true });
    const db = client.db(dbName);
    const collection = db.collection('users');

    const data = await collection.find().toArray();

    client.close();

    res.status(200).json(data);
  } catch (err) {
    console.error('Error fetching data:', err);
    res.status(500).send('Failed to fetch data from MongoDB');
  }
});

app.listen(port, () => {
  console.log(`Backend server listening at http://localhost:${port}`);
});

const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'event_planning',
  password: '1429',
  port: 5432,
});

// Test route
app.get('/', (req, res) => {
  res.json({ message: 'Event Planning API is running' });
});

// Get all events
app.get('/events', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM events');
    console.log('Fetched events:', rows);
    res.json(rows);
  } catch (err) {
    console.error('Error fetching events:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Add a new event
app.post('/events', async (req, res) => {
  const { title, date, location, image_url, event_type } = req.body;
  try {
    const { rows } = await pool.query(
      'INSERT INTO events (title, date, location, image_url, event_type) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [title, date, location, image_url, event_type]
    );
    console.log('Inserted event:', rows[0]);
    res.status(201).json(rows[0]);
  } catch (err) {
    console.error('Error inserting event:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Get events by type
app.get('/events/:type', async (req, res) => {
  const { type } = req.params;
  try {
    let query = 'SELECT * FROM events';
    let params = [];

    if (type.toLowerCase() !== 'all') {
      query += ' WHERE LOWER(event_type) = LOWER($1)';
      params.push(type);
    }

    const { rows } = await pool.query(query, params);
    console.log(`Fetched ${type} events:`, rows);
    res.json(rows);
  } catch (err) {
    console.error(`Error fetching ${type} events:`, err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Delete an event
app.delete('/events/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const { rowCount } = await pool.query('DELETE FROM events WHERE id = $1', [id]);
    if (rowCount === 0) {
      res.status(404).json({ message: 'Event not found' });
    } else {
      console.log(`Deleted event with id: ${id}`);
      res.json({ message: 'Event deleted successfully' });
    }
  } catch (err) {
    console.error(`Error deleting event with id ${id}:`, err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Update an event
app.put('/events/:id', async (req, res) => {
  const { id } = req.params;
  const { title, date, location, image_url, event_type } = req.body;
  try {
    const { rows } = await pool.query(
      'UPDATE events SET title = $1, date = $2, location = $3, image_url = $4, event_type = $5 WHERE id = $6 RETURNING *',
      [title, date, location, image_url, event_type, id]
    );
    if (rows.length === 0) {
      res.status(404).json({ message: 'Event not found' });
    } else {
      console.log('Updated event:', rows[0]);
      res.json(rows[0]);
    }
  } catch (err) {
    console.error(`Error updating event with id ${id}:`, err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
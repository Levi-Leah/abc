const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const app = express();
const port = 3000;
const db = new sqlite3.Database(path.resolve(__dirname, 'db.sqlite'));

// Middleware
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Root route: Display form and user list
app.get('/', (req, res) => {
    db.all('SELECT * FROM users', [], (err, users) => {
        if (err) {
            console.error('Error fetching users:', err);
            return res.send(`
                <h1>Error</h1>
                <p>${err.message}</p>
            `);
        }
        const userList = users.length 
            ? users.map(({ name, email }) => `<li>${name} (${email})</li>`).join('') 
            : '<p>No users found.</p>';

        res.send(`
            <h1>User Management</h1>
            <form method="POST" action="/add-user">
                <label>Name: <input type="text" name="name" required></label>
                <label>Email: <input type="email" name="email" required></label>
                <button type="submit">Add User</button>
            </form>
            <h2>Users:</h2>
            <ul>${userList}</ul>
        `);
    });
});

// Route to add a user
app.post('/add-user', (req, res) => {
    const { name, email } = req.body;
    db.run('INSERT INTO users (name, email) VALUES (?, ?)', [name, email], (err) => {
        if (err) {
            console.error('Error adding user:', err);
            return res.send(`<h1>Error</h1><p>${err.message}</p><a href="/">Go back</a>`);
        }
        res.redirect('/');
    });
});

// Initialize users table
db.run(`
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL
    )
`);

// Start server
app.listen(port, () => console.log(`App is running on http://localhost:${port}`));

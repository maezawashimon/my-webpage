const express = require('express');
const bodyParser = require('body-parser');
const sqlite3 = require('sqlite3').verbose();
const app = express();
const port = 3000;

// ボディパーサーの設定
app.use(bodyParser.urlencoded({ extended: true }));

// データベース接続
const db = new sqlite3.Database('./users.db', (err) => {
    if (err) {
        console.error(err.message);
    }
    console.log('Connected to the users database.');
});

// ユーザーテーブルの作成
db.run(`CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    password TEXT NOT NULL
)`);

// フォームを提供するルート
app.get('/', (req, res) => {
    res.sendFile(__dirname + '/index.html');
});

// フォームから送信されたデータを保存するルート
app.post('/register', (req, res) => {
    const username = req.body.username;
    const password = req.body.password;

    // データベースに挿入
    db.run('INSERT INTO users (username, password) VALUES (?, ?)', [username, password], (err) => {
        if (err) {
            return console.log(err.message);
        }
        res.send('User registered successfully!');
    });
});

// サーバーの起動
app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});

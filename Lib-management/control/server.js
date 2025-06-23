const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(express.json());
app.use(bodyParser.json());


//登陆
const usersFilePath = './data/users.json';
const adminsFilePath = './data/admins.json';
const SECRET_KEY = '12345678';

// 读取用户或管理员数据
function readData(filePath) {
  if (!fs.existsSync(filePath)) {
    fs.writeFileSync(filePath, JSON.stringify([]));
  }
  const data = fs.readFileSync(filePath);
  return JSON.parse(data);
}

// 写入用户或管理员数据
function writeData(filePath, data) {
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
}

// 中间件：验证 JWT
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.sendStatus(401);

  jwt.verify(token, SECRET_KEY, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
}

// 用户注册
app.post('/register', async (req, res) => {
  const { username, password, email } = req.body;
  const hashedPassword = await bcrypt.hash(password, 10);
  const newUser = { username, password: hashedPassword, email };

  const users = readData(usersFilePath);
  const existingUser = users.find(user => user.username === username);
  if (existingUser) return res.status(400).send('User already exists');

  users.push(newUser);
  writeData(usersFilePath, users);
  res.status(201).send('User registered successfully');
});

// 用户登录
app.post('/login', async (req, res) => {
  const { username, password } = req.body;
  const users = readData(usersFilePath);
  const user = users.find(user => user.username === username);
  if (!user) return res.status(400).send('Invalid credentials');

  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) return res.status(400).send('Invalid credentials');

  const token = jwt.sign({ username: user.username, role: 'user' }, SECRET_KEY, { expiresIn: '1h' });
  res.json({ message: 'Login successful!', token });
});




// 在管理员注册时添加安全码
app.post('/admin/register', async (req, res) => {
  const { username, password, securityCode } = req.body;
  const hashedPassword = await bcrypt.hash(password, 10);
  const newAdmin = { username, password: hashedPassword, securityCode };

  const admins = readData(adminsFilePath);
  const existingAdmin = admins.find(admin => admin.username === username);
  if (existingAdmin) return res.status(400).send('Admin already exists');

  admins.push(newAdmin);
  writeData(adminsFilePath, admins);
  res.status(201).send('Admin registered successfully');
});


// 管理员登录
app.post('/admin/login', async (req, res) => {
  const { username, password, securityCode } = req.body;
  const admins = readData(adminsFilePath);
  const admin = admins.find(admin => admin.username === username);
  if (!admin) return res.status(400).send('Invalid credentials');

  const isMatch = await bcrypt.compare(password, admin.password);
  if (!isMatch) return res.status(400).send('Invalid credentials');

  if (securityCode && admin.securityCode !== securityCode) {
    return res.status(400).send('Invalid security code');
  }

  const token = jwt.sign({ username: admin.username, role: 'admin' }, SECRET_KEY, { expiresIn: '1h' });
  res.json({ message: 'Login successful!', token });
});

// 获取当前用户
app.get('/api/user/current_user', authenticateToken, (req, res) => {
  if (req.user.role === 'user') {
    res.json({ username: req.user.username });
  } else {
    res.status(403).send('Access denied');
  }
});

// 获取当前管理员
app.get('/api/admin/current_user', authenticateToken, (req, res) => {
  if (req.user.role === 'admin') {
    res.json({ username: req.user.username });
  } else {
    res.status(403).send('Access denied');
  }
});



//书的管理
const BOOKS_FILE = path.join(__dirname, 'data', 'books.json');

// 读取书籍数据
function readBooks() {
  try {
    const data = fs.readFileSync(BOOKS_FILE);
    return JSON.parse(data);
  } catch (error) {
    console.error('Error reading books file:', error);
    return [];
  }
}

// 写入书籍数据
function writeBooks(books) {
  try {
    fs.writeFileSync(BOOKS_FILE, JSON.stringify(books, null, 2));
  } catch (error) {
    console.error('Error writing to books file:', error);
  }
}

// 检查 ISBN 是否已存在
app.get('/api/check-isbn', (req, res) => {
  const isbn = req.query.isbn;
  const books = readBooks();
  const isISBNExists = books.some(book => book.isbn === isbn);
  res.json({ exists: isISBNExists });
});

// 添加书籍
app.post('/api/books', (req, res) => {
  const newBook = req.body;

  // 读取现有书籍数据
  let books = readBooks();

  // 检查 ISBN 是否已存在
  const isISBNExists = books.some(book => book.isbn === newBook.isbn);
  if (isISBNExists) {
    return res.status(400).json({ error: 'ISBN already exists' });
  }

  // 生成一个新的 bookId
  const newBookId = books.length > 0 ? books[books.length - 1].bookId + 1 : 1;
  newBook.bookId = newBookId;

  // 添加新书
  books.push(newBook);

  // 写入更新后的书籍数据
  writeBooks(books);

  res.status(201).json(newBook);
});

// 获取所有书籍
app.get('/api/books', (req, res) => {
  const books = readBooks();
  res.json(books);
});

// 更新书籍
app.put('/api/books/:id', (req, res) => {
  const bookId = parseInt(req.params.id);
  const updatedBook = req.body;
  let books = readBooks();
  const index = books.findIndex(book => book.bookId === bookId);

  if (index !== -1) {
    books[index] = { bookId, ...updatedBook };
    writeBooks(books);
    res.status(200).json(books[index]);
  } else {
    res.status(404).send('Book not found');
  }
});

// 删除书籍
app.delete('/api/books/:id', async (req, res) => {
  const bookId = parseInt(req.params.id);

  try {
    let books = await readBooks();
    const index = books.findIndex(book => book.bookId === bookId);

    if (index === -1) {
      return res.status(404).json({ error: 'Book not found' });
    }

    // 使用 splice 方法删除找到的书籍
    books.splice(index, 1);

    // 写入更新后的数据
    await writeBooks(books);

    res.status(200).json({ message: `Book with ID ${bookId} deleted successfully.` });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const BORROWER_FILE = path.join(__dirname, 'data', 'lend_list.json');

// 读取借阅记录数据
function readBorrowers() {
  try {
    const data = fs.readFileSync(BORROWER_FILE);
    return JSON.parse(data);
  } catch (error) {
    console.error('Error reading borrower file:', error);
    return [];
  }
}

// 写入借阅记录数据
function writeBorrowers(borrowers) {
  try {
    fs.writeFileSync(BORROWER_FILE, JSON.stringify(borrowers, null, 2));
  } catch (error) {
    console.error('Error writing to borrower file:', error);
  }
}

// 检查借阅记录是否存在
app.get('/api/check-borrower', (req, res) => {
  const borrowerId = req.query.bookId;
  const borrowers = readBorrowers();
  const isBorrowerExists = borrowers.some(borrower => borrower.bookId === borrowerId);
  res.json({ exists: isBorrowerExists });
  });

// 添加借阅记录
app.post('/api/lend_list', (req, res) => {
  const newBorrower = req.body;

  // 读取现有借阅记录数据
  let borrowers = readBorrowers();

  // 检查 borrowerId 是否已存在
  const isBorrowerExists = borrowers.some(borrower => borrower.bookId === newBorrower.bookId);
  if (isBorrowerExists) {
    return res.status(400).json({ error: 'Borrower ID already exists' });
  }

  // 生成一个新的 borrowerId
  const newBorrowerId = borrowers.length > 0 ? borrowers[borrowers.length - 1].bookId + 1 : 1;
  newBorrower.borrowerId = newBorrowerId;

  // 添加新的借阅记录
  borrowers.push(newBorrower);

  // 写入更新后的借阅记录数据
  writeBorrowers(borrowers);

  res.status(201).json(newBorrower);
});




// 获取所有借阅记录
app.get('/api/lend_list', (req, res) => {
  const borrowers = readBorrowers();
  res.json(borrowers);
});

// 更新借阅记录
app.put('/api/book/:id', (req, res) => {
  const borrowerId = parseInt(req.params.id);
  const updatedBorrower = req.body;
  let borrowers = readBorrowers();
  const index = borrowers.findIndex(borrower => borrower.bookId === bookId);

  if (index !== -1) {
    borrowers[index] = { bookrId, ...updatedBorrower };
    writeBorrowers(borrowers);
    res.status(200).json(borrowers[index]);
  } else {
    res.status(404).send('Borrower not found');
  }
});

// 删除借阅记录
app.delete('/api/lend_list/:id', async (req, res) => {
  const borrowerId = parseInt(req.params.id);
  try {
    let borrowers = await readBorrowers();
    const index = borrowers.findIndex(borrower => borrower.bookId === borrowerId);
    if (index === -1) {
      return res.status(404).json({ error: 'Borrower not found' });
    }

    // 使用 splice 方法删除找到的借阅记录
    borrowers.splice(index, 1);

    // 写入更新后的数据
    await writeBorrowers(borrowers);

    let books = await readBooks();
    const bookIndex = books.findIndex(book => book.bookId === borrowerId);
    if (bookIndex !== -1 && books[bookIndex].number >= 0) {
      books[bookIndex].number += 1; // 增加书籍数量
      await writeBooks(books);
    }

    res.status(200).json({ message: `Borrower with ID ${borrowerId} deleted successfully.` });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


// 读取lend_list.json文件的内容
function readLendList() {
  try {
    // 确保路径正确指向你的 lend_list.json 文件
    const data = fs.readFileSync(path.join(__dirname, 'data', 'lend_list.json'));
    return JSON.parse(data);
  } catch (error) {
    console.error('Error reading lend_list.json file:', error);
    return [];
  }
}

// 路由：获取lend_list.json文件的内容
app.get('/api/user_lend_list', (req, res) => {
  const { username } = req.query;  // 从查询参数中获取用户名
  console.log('Fetching lend list for username:', username);

  const lendList = readLendList();  // 假设这是您读取借阅日志的函数
  console.log('Lend list:', lendList); // 打印借阅列表到控制台

  // 根据用户名过滤借阅日志
  const filteredLendList = lendList.filter(log => log.username === username);

  console.log('Filtered lend list:', filteredLendList); // 打印过滤后的借阅列表到控制台
  res.json(filteredLendList); // 返回过滤后的借阅列表
});


// 确保所有数据文件存在并初始化
function ensureDataFilesExist() {
  const files = [usersFilePath, adminsFilePath, path.join(__dirname, 'data', 'books.json'), path.join(__dirname, 'data', 'lend_list.json')];
  files.forEach(filePath => {
    if (!fs.existsSync(filePath)) {
      if (filePath.includes('lend_list.json')) {
        fs.writeFileSync(filePath, JSON.stringify([], null, 2)); // 初始化为空数组
      } else {
        fs.writeFileSync(filePath, JSON.stringify([]));
      }
    }
  });
}

ensureDataFilesExist();

// 写入借阅数据
async function writeLendList(lendList) {
  try {
    await fs.promises.writeFile(
      path.join(__dirname, 'data', 'lend_list.json'),
      JSON.stringify(lendList, null, 2)
    );
  } catch (error) {
    console.error('Error writing to lend_list.json file:', error);
    throw error; // 抛出错误，让调用者知道发生了什么
  }
}



app.post('/api/lend', async (req, res) => {
  const { bookId, bookname, lendDate, returnDate, username } = req.body;

  let lendList = readLendList();
  const newLendRecord = {
    bookId,
    bookname,
    lendDate,
    returnDate,
    username
  };

  let books = readBooks();
  const bookIndex = books.findIndex(book => book.bookId === bookId);

  // Check if the book exists and has a number greater than 0
  if (bookIndex !== -1 && books[bookIndex].number > 0) {
    lendList.push(newLendRecord);
    writeLendList(lendList);

    books[bookIndex].number -= 1; // Decrease the number of available books
    writeBooks(books);

    res.status(201).json({ message: 'Book lent successfully!', lendRecord: newLendRecord });
  } else {
    // If the book does not exist or the number is less than or equal to 0, return an error
    res.status(400).json({ message: 'Book not available for lending.' });
  }
});

async function hasUnreturnedLend(bookId) {
  const lendList = readLendList();
  const now = new Date().toISOString().split('T')[0]; // 获取当前日期并格式化为 YYYY-MM-DD

  const unreturned = lendList.some(record =>
    record.bookId === bookId &&
    (!record.returnDate || isAfter(record.returnDate, now))
  );

  return unreturned;
}

// 添加一个新的路由来检查书籍借阅状态
app.get('/api/check-lend-status', async (req, res) => {
  const { bookId } = req.query;

  if (!bookId) {
    return res.status(400).json({ error: 'Book ID is required.' });
  }

  try {
    // 这里假设 readLendList() 函数从 JSON 文件读取借阅列表
    const lendList = readLendList();
    const now = new Date().toISOString().split('T')[0]; // 获取当前日期并格式化为 YYYY-MM-DD

    // 查找是否有未归还的记录
    const hasUnreturned = lendList.some(record =>
      record.bookId === parseInt(bookId) && // 确保 bookId 是数字类型
      (!record.returnDate || new Date(record.returnDate) > new Date(now))
    );

    res.json({ isLent: hasUnreturned });
  } catch (error) {
    console.error('Error checking lend status:', error);
    res.status(500).json({ error: 'An error occurred while checking the lend status of the book.' });
  }
});


// 启动服务器
app.listen(5000, () => {
  console.log('Server is running on http://localhost:5000');
});

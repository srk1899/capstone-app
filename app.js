const express = require('express');
const app = express();
const port = process.env.PORT || 80;

app.get('/', (req, res) => res.send('Hello from Task-12!'));
app.listen(port, '0.0.0.0', () => console.log(`Server is running on http://0.0.0.0:${port}`));
                                                                                                                                       

const db = require('better-sqlite3')('./data.sqlite', {readonly: true});
const toTitleCase = require('to-title-case');

const id = '10001';

const row = db.prepare('SELECT * FROM zip WHERE zipCode=?').get(id);
console.log(toTitleCase(row.City));
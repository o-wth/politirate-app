const express = require('express')
const router = require('./api');
const bodyParser = require('body-parser');

const app = express();
const PORT = process.env.PORT || 80;


app.use(
    bodyParser.urlencoded({
        extended: false
    })
);
app.use(bodyParser.json());
app.use(router);

app.listen(PORT, () => {
    console.log("Started server, listening on " + PORT);
});

var request = require('request');

let url = "https://theunitedstates.io/congress-legislators/legislators-current.json"
let nameReq = "Chip Roy"
request.get(url, (err, res, body) => {
    JSON.parse(body).forEach((legislator, i) => {
        let name = legislator.name.official_full;
        if(name == nameReq) {
            console.log(legislator.terms[legislator.terms.length-1].party)
        }
    })
})

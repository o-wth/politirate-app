const router = require('express').Router();
const Twitter = require('twitter');
const AYLIENTextAPI = require('aylien_textapi');
const request = require('request')

const keys = require('./endpoints');
const tKeys = require('./twitterKeys');
const client = new Twitter(tKeys);
const textapi = new AYLIENTextAPI({
    application_id: keys.aylienID,
    application_key: keys.aylienKey
});

var AylienNewsApi = require('aylien-news-api');

var apiInstance = new AylienNewsApi.DefaultApi();

// Configure API key authorization: app_id
var app_id = apiInstance.apiClient.authentications['app_id'];
app_id.apiKey = "80cf748a";

// Configure API key authorization: app_key
var app_key = apiInstance.apiClient.authentications['app_key'];
app_key.apiKey = "a5d6415e79d70d5dd60dc3b4f00ee524";


router.get('/politician/', async (req, res) => {
    const fullname = req.query.fullname;
    let twitterHandle = req.query.twitterhandle;
    const phone2action = await checkIfContainsName(fullname)
    console.log(phone2action)

    if(fullname == undefined) {
        return res.status(400).json({message: "Define fullname"})
    }

    if(!phone2action) {
        let url = "https://theunitedstates.io/congress-legislators/legislators-current.json"
        var { party, bioguide, phone, state, chambername } = await new Promise((resolve, reject) => {
            request.get(url, async (err, res, body) => {
                if(err) return(err)
                JSON.parse(body).forEach((legislator, i) => {
                    let name = legislator.name.official_full;
                    if(name == fullname) {
                        return resolve({party: legislator.terms[legislator.terms.length-1].party, bioguide: legislator.id.bioguide, phone: legislator.terms[legislator.terms.length-1].phone,
                        state: legislator.terms[legislator.terms.length-1].state, chambername: legislator.terms[legislator.terms.length-1].type})
                    }
                });
            })
        });
    } else {
        const opts = {
            url: keys.phone2action,
            headers: {
                'X-API-Key': keys.phone2actionKey
            },
            qs: {address:"Virginia"}
        }

        var action = await new Promise((resolve, reject) => {
            request.get(opts, async (err, res, body) => {
                let bodyParsed = JSON.parse(body)
                bodyParsed.officials.forEach((legislator, i) => {
                    let splitName = fullname.split(' ');
                    if(splitName[0] == legislator.first_name && splitName[splitName.length-1] == legislator.last_name) {
                        let val;
                        legislator.socials.forEach((social, i) => {
                            if(legislator.identifier_type='TWITTER')
                                val = i;
                        })
                        return resolve({party: legislator.party, twitterHandle: legislator.socials[val].identifier_value, phone: legislator.office_location.phone_1,
                        state: legislator.office_details.state, chambername: legislator.office_details.chamber_details.name})
                    }
                })
            })
        });

        var party = action.party;
        var phone = action.phone;
        if(twitterHandle == null)
            twitterHandle = action.twitterHandle;
        var chambername = action.chambername;
        var state = action.state;

    }


    if(twitterHandle == undefined) {
        twitterHandle = await new Promise((resolve, reject) => {
            request.get("https://theunitedstates.io/congress-legislators/legislators-social-media.json", async (err, res, body) => {
                JSON.parse(body).forEach((legislator, i) => {
                    let bGuide = legislator.id.bioguide;
                    if(bGuide == bioguide) {
                        return resolve(legislator.social.twitter)
                    }
                });
            })
        });
    }

    let {score, threeStories} = await getScore(twitterHandle, fullname);

    let resData = {
        score: score,
        profile_picture: "https://twitter.com/"+twitterHandle+"/profile_image?size=original",
        threeStories: threeStories,
        party: party,
        phone: phone,
        state: state,
        chambername: chambername
    }

    return res.status(200).json(resData);
});

async function makeTwitterReq(username) {
    return new Promise(async (resolve, reject) => {
        client.get('statuses/user_timeline.json', {screen_name: username, count: 3, exclude_replies: true}, (err, tweets, response) => {
            if(err) return reject(err);
            let tweets_arr = []
            for(i = 0; i < tweets.length; i++) {
                tweets_arr.push(tweets[i].text)
            }
            return resolve(tweets_arr);
        });
    });
}

async function getScore(username, name) {
    return new Promise(async (resolveOuter, rejectOuter) => {
        let arr = await makeTwitterReq(username)
        let twitterScore = await new Promise(async (resolve, reject) => {
            let twitterScore = 0;
            let count = 0
            arr.forEach((tweet, j) => {
                textapi.sentiment({
                    'text': tweet
                }, (err, res) => {
                    if(err) {
                        return reject(err);
                    }
                    count+=1;
                    if(res !== null) {
                        switch(res.polarity) {
                            case('negative'):
                                twitterScore-=1;
                                break;
                            case('positive'):
                                twitterScore+=2;
                                break;
                            case('neutral'):
                                twitterScore++;
                                break;
                        }
                        if(count == arr.length) {
                            return resolve(twitterScore)
                        }
                    }
                })
            });
        }).then(twitterScore => {
            let opts = {
                'title': "\""+name+"\"",
                'sortBy': 'recency',
                'language': ['en'],
                'publishedAtStart': 'NOW-30DAYS',
                'publishedAtEnd': 'NOW',
            };


            let callback = async function(error, data, response) {

                let {nScore, threeStories} = await new Promise(async (resolve, reject) => {
                    let newsScore = 0;
                    let arr = []
                    if (error) {
                        reject(error);
                    } else {
                        for (var i = 0; i < data.stories.length; i++){

                            if(arr.length < 3)
                                arr.push(data.stories[i].title);

                            switch(data.stories[i].sentiment.title.polarity) {

                                case('negative'):
                                    newsScore-=2;
                                    break;
                                case('positive'):
                                    newsScore+=4;
                                    break;
                                case('neutral'):
                                    newsScore+=2;
                                    break;
                            }
                        }
                    }
                    return resolve({nScore: newsScore, threeStories: arr})
                });
                return resolveOuter({score: nScore + twitterScore, threeStories: threeStories})
            };
            apiInstance.listStories(opts, callback);
        })
    })
}

async function checkIfContainsName(fullname) {
    const opts = {
        url: keys.phone2action,
        headers: {
            'X-API-Key': keys.phone2actionKey
        },
        qs: {address:"Virginia"}
    }
    return new Promise((resolve, reject) => {
        request.get(opts, async (err, res, body) => {
            let bodyParsed = JSON.parse(body)
            bodyParsed.officials.forEach((legislator, i) => {
                let splitName = fullname.split(' ');
                if(splitName[0] == legislator.first_name && splitName[splitName.length-1] == legislator.last_name) {
                    resolve(true)
                }
            }); resolve(false);
        })
    });
}

module.exports = router;

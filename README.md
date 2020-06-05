# Politi-Rate

![Project frozen](https://img.shields.io/badge/status-frozen-blue.png) ![Project unmaintained](https://img.shields.io/badge/project-unmaintained-red.svg)

We are archiving this repository. We have developed a new [API](https://github.com/o-wth/politirate-api) and a new [app](https://github.com/o-wth/politirate-app). 

---

A public platform for evaluating politicians and their social media presence using sentiment analysis and language processing.

## To-Do List:

-   [ ] only 1000 AYLIEN API requests per day, so only 25 Node API requests per day (not enough)
-   [ ] Aylien API key is expired
-   [x] hide API keys
-   [ ] show information about scores when score FAB is clicked

## Setup

-   create `api/endpoints.js` with the following contents:

```js
module.exports = {
    aylien: 'https://api.aylien.com/api/v1',
    aylienKey: '<AYLIEN KEY>',
    aylienID: '<AYLIEN ID>',
    phone2action: 'https://fmrrixuk32.execute-api.us-east-1.amazonaws.com/hacktj/legislators',
    phone2actionKey: '<PHONE2ACTION KEY>',

}
```

-   create `api/twitterKeys.js` with the following contents:

```js
module.exports = {
    consumer_key: '<TWITTER CONSUMER KEY>',
    consumer_secret: '<TWITTER CONSUMER SECRET>',
    access_token_key: '<TWITTER ACCESS TOKEN KEY>',
    access_token_secret: '<TWITTER ACCESS TOKEN SECRET>'
}
```

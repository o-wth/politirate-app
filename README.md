See <https://github.com/o-wth/politirate/tree/master/v3> for the monorepo.

# App

## Stack

-   [Flutter](https://github.com/flutter/flutter)
    -   [`graphql_flutter`](https://github.com/zino-app/graphql-flutter)

## Features

-   **search history** local to the device (so no cloud storage of data) because we don't want to require account-creation
-   **conversations** use GPT-3 to allow users to ask political questions to and converse with chat-bots that emulate speaking with a politician themself
    - TODO: ethics! and in the UI we must make it clear that the chat-bot is not the actual politician
-   **line charts** using the [cache](https://github.com/o-wth/politirate-api/blob/v3/README.md#routes) route from the API, we show a line graph of the politician's scores with one line per [subscore](https://github.com/o-wth/politirate/tree/master/v3#algorithm) along with a line for the politician's combined score

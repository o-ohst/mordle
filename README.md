# Mordle (Alpha 0.00 Demo)
Team: Crowded Cow (Apollo)

Mordle is a multiplayer wordle game that makes use of websocket connections to enable real-time connections between multiple users. 
This prorotype demonstrates the room-joining and live updates feature which is central to the project.

## Aim 

We hope to create a fun, casual, competitive Wordle game that you can play with friends as a mobile-responsive web app.


## User Stories

As a Wordle player, I find that Wordle is very much a single player game and wish that there is a mode where I am able to compete with friends spontaneously.

As a friend, I would like to have a casual, competitive game to play with friends during parties and outings. This new game, Mordle, is easy to set up and easy to understand.

As a party/orientation organiser, I would like a fun, competitive game for participants. It has private room creation for the teams in my event to compete for the best score!


## How to play
- Join a room with a room code.
- Guess 5-letter words. (Wordle)
- First player to guess it wins the round!
- Each game lasts 3 rounds.


## Stack
- React, JavaScript (frontend)
- TailwindCSS
- Phoenix, Elixir (server)
- Redis (database)

# Code
Unfortunately we have not managed to deploy successfully as of now, please watch the video for demo or try it yourself! (warning: potential headaches)
[Server repo](https://github.com/o-ohst/mordle-server)

install elixir, phoenix, then:

`mix phx.server`

[Frontend repo](https://github.com/o-ohst/mordle-client)

`npm run start`

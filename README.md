Astronaut Twitter Bot <img src="img/woman-astronaut-emoji.png" alt="drawing" width="25"/>
---------------------

This is the repository for [@astronautcount](https://twitter.com/astronautcount), the astronaut count twitter bot.

### Structure

Project structure consists of

- `terraform/` - houses the IaC to build a backend (spot) instance that a Flask-based inbound webhook handler resides on.
- `src/` - which contains two small Python packages, including
  - `handler`, the Flask app already mentioned, and
  - `bot`, a Python-based bot that CircleCI executes every day for a daily morning tweet.

### Where does the data come from?

At-current, this bot pulls data from [Open Notify's API](http://open-notify.org/Open-Notify-API/People-In-Space/), which is maintained by Nathan Bergey ([@natronics](https://twitter.com/natronics)). This is, as far as I'm aware, both the only publicly-accessible and regularly updated API for these data.

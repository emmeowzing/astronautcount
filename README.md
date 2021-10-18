Astronaut Twitter Bot <img src="img/woman-astronaut-emoji.png" alt="drawing" width="25"/>
---------------------

This is the repository for [@astronautcount](https://twitter.com/astronautcount), the astronaut count twitter bot.

### Structure

Project structure consists of

- `terraform/` - houses the IaC to build a backend (spot) instance that a Flask-based inbound webhook handler resides on, and
- `src/` - which contains two small Python packages, including
  - `handler`, the Flask app already mentioned, and
  - `bot`, a Python-based bot that CircleCI executes every day for a daily morning tweet.

### Development

Don't forget to increment `src/bot/__init__.__version__` for new releases!

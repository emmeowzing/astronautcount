#! /bin/bash
# Run the Gunicorn-wrapped Flask API.

gunicorn -c src/handler/gunicorn.py handler.handler:app &
disown

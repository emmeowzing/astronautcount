#! /bin/bash
# Register my instance to receive webhook requests from Twitter using twitter-autohook.
# https://developer.twitter.com/en/docs/tutorials/how-to-build-a-complete-twitter-autoresponder-autohook


ssh -p "$SSH_PORT" \
    -o UserKnownHostsFile=/dev/null \
    -o StrictHostKeyChecking=no astronaut@"$PUBLIC_EIP" \
    npm i -S twitter-autohooks

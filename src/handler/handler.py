#! /usr/bin/env python3
# -*- coding: utf-8 -*-


from twitterwebhoooks import TwitterWebhookAdapter
from flask import Flask

import json
import os


if (TWITTER_CONSUMER_SECRET := os.getenv('TWITTER_CONSUMER_SECRET')) is None:
    raise EnvironmentError('Must set SECRET_KEY environment variable.')

events_adapter = TwitterWebhookAdapter(TWITTER_CONSUMER_SECRET, "/webhooks/astronautcount")
app = Flask(__name__)


@events_adapter.on("favorite_events")
def favorite_events(event_data: dict) -> None:
    event = event_data['event']
    print(event)
    print(json.dumps(event_data, indent=4, sort_keys=True))


@events_adapter.on("tweet_create_events")
def handle_message(event_data: dict) -> None:
    event = event_data['event']
    print(event)
    print(json.dumps(event_data, indent=4, sort_keys=True))

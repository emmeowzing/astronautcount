"""
A Twitter bot that posts the number of astronauts in space every day.
"""

from typing import Dict, Any

import tweepy
import os
import requests


if API_KEY := os.getenv('API_KEY') is None:
    raise EnvironmentError('Must set API_KEY environment variable.')

if SECRET_KEY := os.getenv('SECRET_KEY') is None:
    raise EnvironmentError('Must set SECRET_KEY environment variable.')





def pull_astronaut_list(url: str ='http://api.open-notify.org/astros.json') -> Dict[str, Any]:
    """
    Pull a list of astronauts via API. Defaults to open-notify's API.

    Args:
        url: the URL to pull data from.

    Returns:
        A dict containing the astronaut count and names.
    """
    data = requests.get(url).json()

    return data


def tweet() -> None:
    """
    Tweet the number of astronauts and their names retrieved from the API.

    Returns:
        Nothing.
    """
    
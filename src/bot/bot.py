"""
A Twitter bot that posts the number of astronauts in space every day.
"""

from typing import Dict, Any, List

import tweepy
import os
import requests


TWITTER_CHARACTER_LIMIT = 280

# Authenticate tweepy.
if (TWITTER_API_KEY := os.getenv('TWITTER_API_KEY')) is None:
    raise EnvironmentError('Must set API_KEY environment variable.')
if (TWITTER_SECRET_KEY := os.getenv('TWITTER_SECRET_KEY')) is None:
    raise EnvironmentError('Must set SECRET_KEY environment variable.')
if (TWITTER_ACCESS_TOKEN := os.getenv('TWITTER_ACCESS_TOKEN')) is None:
    raise EnvironmentError('Must set TWITTER_ACCESS_TOKEN environment variable.')
if (TWITTER_ACCESS_TOKEN_SECRET := os.getenv('TWITTER_ACCESS_TOKEN_SECRET')) is None:
    raise EnvironmentError('Must set TWITTER_ACCESS_TOKEN_SECRET environment variable.')

auth = tweepy.OAuthHandler(TWITTER_API_KEY, TWITTER_SECRET_KEY)
auth.set_access_token(TWITTER_ACCESS_TOKEN, TWITTER_ACCESS_TOKEN_SECRET)
api = tweepy.API(auth)


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


def englishified_list(items: List[str]) -> str:
    """
    Create a nice-English list of items.
    """
    formatted_string = ''
    n_items = len(items) - 1
    for i, item in enumerate(items):
        if i == n_items and i != 0:
            formatted_string += f'and {item}'
        else:
            formatted_string += f'{item}, '
    return formatted_string


def parse_astronauts(astronaut_list: List[Dict[str, str]]) -> str:
    """
    Parse a list of astronauts and return a list of names grouped by craft they reside on.

    Args:
        astronaut_list: a list of dictionaries containing astronaut names and the spacecraft they're stationed on (e.g., ISS).

    Returns:
        A nicely-formatted string of these names and craft. Returned string looks like

        'Pyotr Dubrov, Thomas Pesquet, Megan McArthur on the ISS'
    """
    spacecraft = list()

    for person in astronaut_list:
        if person['craft'] not in spacecraft:
            spacecraft.append(person['craft'])

    transposed_astronaut_list: Dict[str, List[str]] = dict()

    for ship in spacecraft:
        transposed_astronaut_list[ship] = list()
        for person in astronaut_list:
            if person['craft'] == ship:
                transposed_astronaut_list[ship].append(person['name'])

    grouped_astronauts_string = ''
    for ship in transposed_astronaut_list:
        grouped_astronauts_string += englishified_list(transposed_astronaut_list[ship])
        grouped_astronauts_string += f' on the {ship}'

    print(grouped_astronauts_string)

    return grouped_astronauts_string


def tweet() -> None:
    """
    Tweet the number of astronauts and their names retrieved from the API.

    Returns:
        Nothing.
    """
    astronauts = pull_astronaut_list()
    tweet = ''

    if astronauts['message'] != 'success':
        raise ValueError(f'Unable to retrieve astronaut list from API: {astronauts}')

    number_of_astronauts = astronauts['number']

    if number_of_astronauts == 0:
        tweet = 'There are no people in space today!'
    elif number_of_astronauts == 1:
        grouped_astronauts = parse_astronauts(astronauts['people'])
        tweet = 'There is one person in space today, {grouped_astronauts}'
    elif number_of_astronauts > 1:
        grouped_astronauts = parse_astronauts(astronauts['people'])
        tweet = f'There are {number_of_astronauts} people in space today'

        # TODO: logically cut string until we're below the character threshold for better tweet content.
        if len(tweet) + len(f', including {grouped_astronauts}') <= TWITTER_CHARACTER_LIMIT:
            tweet += f', including {grouped_astronauts}'

    print(tweet)
    api.update_status(status=tweet)

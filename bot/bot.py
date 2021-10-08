import tweepy
import os
import dotenv


if API_KEY := os.getenv('API_KEY') is None:
    raise EnvironmentError('Must set API_KEY environment variable.')
if SECRET_KEY := os.getenv('SECRET_KEY') is None:
    raise EnvironmentError('Must set SECRET_KEY environment variable.')
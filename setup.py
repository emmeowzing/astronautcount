# For reference ~ https://github.com/pypa/sampleproject/blob/main/setup.py

import pathlib

from setuptools import setup, find_packages
from src import bot


here = pathlib.Path(__file__).parent.resolve()

# Get the long description from the README file
long_description = (here / 'README.md').read_text(encoding='utf-8')

setup(
    name='astronautcount',
    version=bot.__version__,
    description=bot.__doc__,
    long_description=long_description,
    long_description_content_type='text/markdown',
    author='Brandon Doyle',
    author_email='bjd2385.linux@gmail.com',
    keywords='Astronaut, NASA',
    package_dir={'': 'src'},
    packages=find_packages(where='src'),
    python_requires='>=3.9, <4',
    install_requires=[
        'requests>=2.26.0',
        'urllib3>=1.26.7',
        'tweepy>=4.1.0',
        'Flask>=2.0.2'
    ],
    entry_points={
        'console_scripts': [
            'astrobot=bot.bot:tweet',
        ],
    },
    project_urls={  # Optional
        'Bug Reports': 'https://github.com/bjd2385/astronautbot/issues',
        'Source': 'https://github.com/bjd2385/astronautbot'
    },
    include_package_data=True
)

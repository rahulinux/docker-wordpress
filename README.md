# docker-wordpress
[![GitPitch](https://gitpitch.com/assets/badge.svg)](https://gitpitch.com/lewebsimple/docker-wordpress/presentation?grs=github&t=white)

This repository contains everything you need to start enjoying [Docker](https://www.docker.com/) for local WordPress development, as I presented at [WordCamp Halifax 2017](https://2017.halifax.wordcamp.org/sessions/#wcorg-session-651). 

Slides for the presentation are available using [GitPitch](https://gitpitch.com/).

## Getting started

Make sure you have the latest versions of [Docker](https://www.docker.com/) and [Compose](https://docs.docker.com/compose/) installed.

Clone this repository:

```bash
git clone https://gitlab.lewebsimple.ca/docker/ledevsimple.git
```

Copy `env-sample` to `.env` and adjust the environment variables to your liking.
This file should never be checked into version control as it contains sensitive information.

Create and start the containers in the background:
```bash
docker-compose up -d
```

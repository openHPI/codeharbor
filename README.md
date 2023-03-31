# CodeHarbor
CodeHarbor is a repository system for automatically gradeable programming exercises and enables instructors to exchange of such exxercises via the [ProFormA XML](https://github.com/ProFormA/proformaxml) format across diverse code assessment systems.


## Current Status on `master`

[![Build Status](https://github.com/openHPI/codeharbor/workflows/CI/badge.svg)](https://github.com/openHPI/codeharbor/actions?query=workflow%3ACI)
[![Code Climate](https://codeclimate.com/github/openHPI/codeharbor/badges/gpa.svg)](https://codeclimate.com/github/openHPI/codeharbor)
[![Test Coverage](https://codeclimate.com/github/openHPI/codeharbor/badges/coverage.svg)](https://codeclimate.com/github/openHPI/codeharbor)
[![codecov](https://codecov.io/gh/openHPI/codeharbor/branch/master/graph/badge.svg?token=lUL0Fq7Uc9)](https://codecov.io/gh/openHPI/codeharbor)


## Server Setup and Deployment
Use [Capistrano](https://capistranorb.com/). Docker and Vagrant are for local development only.


## Development

Please refer to the [Local Setup Guide](docs/LOCAL_SETUP.md) for more details.

## Testing

Run all tests with `rspec .` or just one test by providing the file path.

You can find the coverage results in `coverage/index.html`.

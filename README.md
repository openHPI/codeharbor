# CodeHarbor
CodeHarbor is a repository system for automatically gradeable programming exercises and enables instructors to exchange of such exercises via the [ProFormA XML](https://github.com/ProFormA/proformaxml) format across diverse code assessment systems.


## Current Status on `master`

[![Build Status](https://github.com/openHPI/codeharbor/workflows/CI/badge.svg)](https://github.com/openHPI/codeharbor/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/openHPI/codeharbor/branch/master/graph/badge.svg?token=lUL0Fq7Uc9)](https://codecov.io/gh/openHPI/codeharbor)


## Server Setup and Deployment
Use [Capistrano](https://capistranorb.com/). Docker and Vagrant are for local development only.


## Development

Please refer to the [Local Setup Guide](docs/LOCAL_SETUP.md) for more details.

## Testing

Run all tests with `rspec .` or just one test by providing the file path.

You can find the coverage results in `coverage/index.html`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/openHPI/codeharbor. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/openHPI/codeharbor/blob/master/CODE_OF_CONDUCT.md).

## License

CodeHarbor is available as open source under the terms of the [BSD 3-Clause License](https://opensource.org/licenses/BSD-3-clause).

## Code of Conduct

Everyone interacting in this project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/openHPI/codeharbor/blob/master/CODE_OF_CONDUCT.md).

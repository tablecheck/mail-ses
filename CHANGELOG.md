# Changelog

### 1.0.5

- Pass-thru invalid email addresses.

### 1.0.4

- Fix missing method error related to message headers.

### 1.0.3

- Support UTF-8 chars in from, to, etc addresses.

### 1.0.2

- Fix labels in being stripped from email addresses.
- Support Reply-To address.

### 1.0.1

- Add compatibility with Mail gem 2.8.0.

### 1.0.0

- BREAKING CHANGE: Upgrade to AWS Ruby SDK v3 - SESv2 API ([@khrvi](https://github.com/khrvi))
- Drop support for Ruby 2.5 and earlier.
- Switch CI from Travis to Github Actions.
- Add Rubocop to CI.
- Refactor code.

### 0.1.2

- Fix: Add #settings method for conformity with other Mail delivery methods.

### 0.1.1

- Fix: Remove Base64 encoding from message body.

### 0.1.0

- Initial release of gem.
- Support for sending ActionMailer mails via AWS SDK v3.

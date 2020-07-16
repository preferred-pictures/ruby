# Preferred.pictures Ruby Client Library

The [Preferred.pictures](https://preferred.pictures) PHP library provides a convenient way to call the
[Preferred.pictures](https://preferred.pictures) API for applications written in Ruby

## Installation

```
gem install preferredpictures
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install preferredpictures

## Usage

```ruby

# Create a new client using an issued identity
# and a secret key
client = PreferredPictures::Client.new("testidentity", "secret123456")

# A simple example with just choices and the a tournament.
url = client.createChooseUrl(
    ['https://example.com/image-red.jpg',
    'https://example.com/image-green.jpg',
    'https://example.com/image-blue.jpg'],
    'test-tournament')

# A more involved example setting the ttl's and using
# a prefix and suffix applied to the choices for brevity
url = client.createChooseUrl(
    ['red', 'green', 'blue'],
    'test-tournament',
    600,
    3600,
    "https://example.com/image-",
    ".jpg")

# The url returned will appear to be something like:
#
# https://api.preferred.pictures/choose-url?choices=red%2Cgreen%2Cblue&tournament=testing&expiration=[EXPIRATION]&uid=[UNIQUEID]&ttl=600&prefix=https%3A%2F%2Fexample.com%2Fjacket-&suffix=.jpg&identity=test-identity&signature=[SIGNATURE]
#
# which should be placed where it is needed in your application or templates.
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/preferred-pictures/ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/preferred-pictures/ruby/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Preferredpictures project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/preferred-pictures/ruby/blob/master/CODE_OF_CONDUCT.md).

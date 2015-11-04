# TahiEpub

TahiEpub is a convenience gem for Tahi and iHat. It contains utility classes and converters that create and extract ePubs, removing the need to maintain multiple implementations of the functionality in two different codebases.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tahi_epub'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tahi_epub

## Usage

Look at `TahiEpub::Zip`, `TahiEpub::Tempfile`, and `TahiEpub::JSONParser`.

If you're using `TahiEpub::Storage`, please make sure the following environment variables are populated:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `S3_BUCKET`

## Contributing

1. Fork it ( https://github.com/[my-github-username]/tahi_epub/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

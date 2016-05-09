# SecurerRandomer

[![Build Status](https://travis-ci.org/mwpastore/securer_randomer.svg?branch=master)](https://travis-ci.org/mwpastore/securer_randomer)
[![Gem Version](https://badge.fury.io/rb/securer_randomer.svg)](https://badge.fury.io/rb/securer_randomer)

Ruby's SecureRandom prefers OpenSSL over other mechanisms (such as
`/dev/urandom` and `getrandom(2)`). This has recently garnered [some][1]
[criticism][2].

[RbNaCl][3] provides Ruby bindings to a portable crypto library
([libsodium][4]) that includes an alternative, OpenSSL-free pseudo-random
number generator (PRNG) implementation.

This gem monkeypatches RbNaCl into SecureRandom and aims to be "bug-for-bug"
compatible with the "stock" implementation of SecureRandom across Ruby
versions. It also provides a nice "do what I mean" random number method that
can be used instead of Kernel`.rand` and SecureRandom`.random_number`.

## History

This gem started out as a very simple monkeypatch to
SecureRandom`.random_bytes` and grew as I dug deeper. In newer Rubies, you need
to patch `.gen_random` instead of `.random_bytes`, and it has no default byte
size.

Generating random numbers proved to be rather tricky due to inconsistencies
between the implementations and functionality of Kernel`.rand` and
SecureRandom`.random_number` between Ruby versions. For example:

* `Kernel.rand(nil)` and `SecureRandom.random_number(nil)` both return a float
  such that `{ 0.0 <= n < 1.0 }` in Ruby 2.3; but
  `SecureRandom.random_number(nil)` throws an ArgumentError in Ruby 2.2
* Kernel`.rand` with an inverted range (e.g. `0..-10`) returns `nil` in Ruby
  2.2+, but SecureRandom`.random_number` throws an ArgumentError in Ruby 2.2
  and returns a float such that `{ 0.0 <= n < 1.0 }` in Ruby 2.3

Tests started to accumulate so I decided it was probably a good idea to gemify
this!

## Features

* SecureRandom`.gen_random` (or `.random_bytes`)

Monkeypatches SecureRandom such that its various formatter methods (`.uuid`,
`.hex`, `.base64`, `.urlsafe_base64`, and `.random_bytes`) use RbNaCl for random
byte generation instead of OpenSSL.

* SecureRandom`.random_number`

Monkeypatches SecureRandom such that it uses SecurerRandomer`.kernel_rand`
instead of OpenSSL (or Kernel`.rand`) to generate random numbers from numeric
types and ranges. It is bug-for-bug compatible with "stock" SecureRandom,
meaning it "chokes" on the same inputs and throws the same exception types.

* SecurerRandomer`.kernel_rand`

A bug-for-bug reimplementation of Kernel`.rand`&mdash;meaning it "chokes" on
the same inputs and throws the same exception types&mdash;that uses RbNaCl as
its source of entropy.

* SecurerRandomer`.rand`

An idealistic, "do what I mean" random number method that accepts a variety of
inputs and returns what you might expect. Whereas `Kernel.rand(-5.6)` returns
an integer such that `{ 0 <= n < 5 }` and `SecureRandom.random_number(-5.6)`
returns a float such that `{ 0.0 <= n < 1.0 }`, **`SecurerRandomer.rand(-5.6)`
returns a float such that `{ 0 >= n > -5.6 }`**. Whereas `Kernel.rand(10..0)`
returns `nil` and `SecureRandom.random_number(10..0)` returns a float such that
`{ 0.0 <= n < 1.0 }` (in Ruby 2.3), **`SecurerRandomer.rand(10..0)` returns an
integer such that `{ 10 >= n >= 0 }`**.

## Installation

Please review the installation instructions for [RbNaCl][3]. You will need to
install either [libsodium][4] or [rbnacl-libsodium][5] before installing this
gem.

Add this line to your application's Gemfile:

```ruby
gem 'securer_randomer', '~> 0.1.0'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install securer_randomer

## Compatibility

SecurerRandomer has been tested under MRI/YARV versions 1.9.3, 2.0, 2.1, 2.2,
and 2.3.

## DISCLAIMER

**Use at your own risk!**

I am neither a cryptologist nor a cryptographer. Although I'm fairly confident
in the test suite, serious bugs affecting compatibility, randomness, and
performance may be present. If you're cautious, I would recommend using the
monkeypatched SecureRandom formatter methods for random data and Kernel`.rand`
for random numbers. Bug reports are welcome.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mwpastore/securer_randomer.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[1]: https://bugs.ruby-lang.org/issues/9569
[2]: https://news.ycombinator.com/item?id=11624890
[3]: https://github.com/cryptosphere/rbnacl
[4]: https://github.com/jedisct1/libsodium
[5]: https://github.com/cryptosphere/rbnacl-libsodium

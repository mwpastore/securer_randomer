# frozen_string_literal: true

require 'rbnacl/sodium'
require 'rbnacl/util'
require 'rbnacl/random'

module SecureRandom
  # for Rubies < 2.2
  def self.random_bytes(n = nil)
    RbNaCl::Random.random_bytes(n ? n.to_i : 16)
  end

  # for Rubies >= 2.2
  def self.gen_random(n)
    RbNaCl::Random.random_bytes(n)
  end

  def self.random_number(n = 0)
    # mimic exceptions raised by "stock" SecureRandom
    raise ArgumentError, "comparison of Fixnum with #{n} failed" unless n.is_a?(Numeric)
    if n.is_a?(Float) && n > 0
      if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new(String.new('2.2.0'))
        raise TypeError, "Cannot convert into OpenSSL::BN"
      else
        raise ArgumentError, 'wrong number of arguments'
      end
    end

    Kernel.rand(n > 0 ? n : 0)
  end
end

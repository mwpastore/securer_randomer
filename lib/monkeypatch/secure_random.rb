# frozen_string_literal: true

require 'securerandom'

require 'rbnacl/sodium'
require 'rbnacl/util'
require 'rbnacl/random'

module SecureRandom
  def self.gen_random(n)
    RbNaCl::Random.random_bytes(n)
  end

  def self.random_number(n = 0)
    if n.is_a?(Range)
      raise TypeError, 'no implicit conversion of Range into Numeric' \
        unless n.begin.respond_to?(:-) and n.end.respond_to?(:-)

      float_wanted = n.begin.is_a?(Float) or n.end.is_a?(Float)
    else
      raise TypeError, 'no implicit conversion of #{n.class} into Numeric' \
        unless n.respond_to?(:-)

      unless n > 0
        i64 = gen_random(8).unpack('Q').first
        return Math.ldexp(i64 >> (64 - Float::MANT_DIG), -Float::MANT_DIG)
      end

      float_wanted = n.is_a?(Float)
      n = Range.new(0, n, true)
    end

    while true
      q = n.begin + if float_wanted
        random_number * (n.end - n.begin)
      else
        (random_number * ((n.end - n.begin) + 1)).to_i
      end

      break q unless n.exclude_end? and q == n.end
    end
  end
end

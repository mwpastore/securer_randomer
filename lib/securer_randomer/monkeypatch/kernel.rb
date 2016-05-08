# frozen_string_literal: true

require 'rbnacl/sodium'
require 'rbnacl/util'
require 'rbnacl/random'

module Kernel
  module_function

  def rand(n = 0)
    if n.is_a?(Range)
      raise TypeError, "no implicit conversion of Range into Fixnum" \
        unless n.begin.respond_to?(:-) and n.end.respond_to?(:-)

      float_wanted = n.begin.is_a?(Float) or n.end.is_a?(Float)
    else
      raise TypeError, "no implicit conversion of #{n.class} into Fixnum" \
        unless n.respond_to?(:-)

      if n.to_i.zero?
        i64 = RbNaCl::Random.random_bytes(8).unpack('Q').first
        return Math.ldexp(i64 >> (64 - Float::MANT_DIG), -Float::MANT_DIG)
      end

      n = Range.new(0, n.to_i.abs, true)
      float_wanted = false
    end

    while true
      q = n.begin + if float_wanted
        rand * (n.end - n.begin)
      else
        (rand * ((n.end - n.begin) + 1)).to_i
      end

      break q unless n.exclude_end? and q == n.end
    end
  end

  def srand(_number)
    raise NotImplementedError, 'RbNaCl implementation of Kernel[.#]rand is not seedable'
  end
end

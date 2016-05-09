# frozen_string_literal: true

require 'rbnacl/sodium'
require 'rbnacl/util'
require 'rbnacl/random'

module SecureRandom
  RUBY_VER_OBJ = Gem::Version.new(RUBY_VERSION.dup)
  RUBY_GE_2_2 = RUBY_VER_OBJ >= Gem::Version.new(String.new('2.2.0'))
  RUBY_GE_2_3 = RUBY_VER_OBJ >= Gem::Version.new(String.new('2.3.0'))

  if RUBY_GE_2_2
    def self.gen_random(n)
      RbNaCl::Random.random_bytes(n)
    end
  else
    def self.random_bytes(n = nil)
      RbNaCl::Random.random_bytes(n ? n.to_i : 16)
    end
  end

  if RUBY_GE_2_3
    def self.random_number(n = 0)
      case n
      when nil
        Kernel.rand
      when Range
        raise ArgumentError, "invalid argument - #{n}" \
          unless n.begin.is_a?(Numeric) and n.end.is_a?(Numeric)

        Kernel.rand(n)
      when Numeric
        Kernel.rand(n > 0 ? n : 0)
      else
        raise ArgumentError, "invalid argument - #{n}"
      end
    end
  else
    def self.random_number(n = 0)
      raise ArgumentError, "comparison of Fixnum with #{n} failed" unless n.is_a?(Numeric)
      if n.is_a?(Float) && n > 0
        if RUBY_GE_2_2
          raise TypeError, "Cannot convert into OpenSSL::BN"
        else
          raise ArgumentError, 'wrong number of arguments'
        end
      end

      Kernel.rand(n > 0 ? n : 0)
    end
  end
end

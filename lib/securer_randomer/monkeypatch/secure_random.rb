# frozen_string_literal: true

require 'securerandom'

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
      arg =
        case n
        when nil
          0
        when Range
          n.end < n.begin ? 0 : n
        when Numeric
          n > 0 ? n : 0
        end

      raise TypeError unless arg

      SecurerRandomer.rand(arg, true)
    rescue TypeError
      raise ArgumentError, "invalid argument - #{n}"
    end
  else
    def self.random_number(n = 0)
      raise ArgumentError, "comparison of Fixnum with #{n} failed" unless n.is_a?(Numeric)
      if n.is_a?(Float) and n > 0
        if RUBY_GE_2_2
          raise TypeError, 'Cannot convert into OpenSSL::BN'
        else
          raise ArgumentError, 'wrong number of arguments'
        end
      end

      SecurerRandomer.rand(n > 0 ? n : 0, true)
    end
  end
end

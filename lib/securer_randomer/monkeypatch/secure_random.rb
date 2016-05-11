# frozen_string_literal: true

require 'securerandom'

module SecureRandom
  if respond_to?(:gen_random)
    def self.gen_random(n)
      RbNaCl::Random.random_bytes(n)
    end
  else
    def self.random_bytes(n = nil)
      RbNaCl::Random.random_bytes(n ? n.to_i : 16)
    end
  end

  if (random_number(nil) rescue nil)
    def self.random_number(n = 0)
      arg =
        case n
        when nil
          0
        when Range
          if n.end < n.begin
            0
          elsif n.begin == n.end and n.exclude_end?
            0
          else
            n
          end
        when Numeric
          n > 0 ? n : 0
        end

      raise TypeError unless arg

      SecurerRandomer.rand(arg, true)
    rescue TypeError
      raise ArgumentError, "invalid argument - #{n}"
    end
  else
    FLOAT_ERROR = begin random_number(1.0); rescue => e; e end

    def self.random_number(n = 0)
      raise ArgumentError, "comparison of Fixnum with #{n} failed" unless n.is_a?(Numeric)
      raise FLOAT_ERROR if n.is_a?(Float) and n > 0

      SecurerRandomer.rand(n > 0 ? n : 0, true)
    end
  end
end

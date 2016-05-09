# frozen_string_literal: true

require 'rbnacl/sodium'
require 'rbnacl/util'
require 'rbnacl/random'

require 'securer_randomer/version'
require 'securer_randomer/monkeypatch/secure_random'

module SecurerRandomer
  def self.kernel_rand(max = 0)
    rand(max, true)
  end

  def self.rand(n = 0, emulate_kernel = false)
    if n.is_a?(Range)
      raise TypeError, 'no implicit conversion of Range into Fixnum' \
        unless n.begin.is_a?(Numeric) and n.end.is_a?(Numeric)

      if n.end < n.begin
        if emulate_kernel
          nil
        else
          m = Range.new(n.end, n.begin, false)

          while true # TODO: better way to do this than looping?
            q = _rand_range(m)

            break q unless n.exclude_end? and q == n.end
          end
        end
      else
        _rand_range(n)
      end
    else
      raise TypeError, "no implicit conversion of #{n.class} into Fixnum" \
        unless n.nil? or n.is_a?(Numeric)

      if n.nil? or n.zero?
        _randex
      elsif emulate_kernel
        _rand_range(Range.new(0, n.to_i.abs, true))
      else
        _rand_range(Range.new(0, n.abs, true)) * (n < 0 ? -1 : 1)
      end
    end
  end

  def self._randex
    i64 = RbNaCl::Random.random_bytes(8).unpack('Q').first
    Math.ldexp(i64 >> (64 - Float::MANT_DIG), -Float::MANT_DIG)
  end

  def self._randin
    _randex >= 0.5 ? 1 - _randex : _randex
  end

  def self._rand_range(n)
    n.begin + if n.end.is_a?(Float) or n.begin.is_a?(Float)
      (n.exclude_end? ? _randex : _randin) * (n.end - n.begin)
    else
      (_randex * (n.end - n.begin + (n.exclude_end? ? 0 : 1))).to_i
    end
  end

  private_class_method(:_randex, :_randin, :_rand_range) if respond_to?(:private_class_method)
end

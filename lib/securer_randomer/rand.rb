# frozen_string_literal: true

module SecurerRandomer
  def self.kernel_rand(max = 0)
    rand(max, true)
  end

  def self.rand(n = 0, emulate_kernel = false)
    if n.is_a?(Range)
      unless n.begin.is_a?(Numeric) and n.end.is_a?(Numeric)
        if emulate_kernel and defined?(JRUBY_VERSION)
          raise NoMethodError, "undefined method `-' for \"#{n.end}\""
        else
          raise TypeError, 'no implicit conversion of Range into Fixnum'
        end
      end

      if n.end < n.begin
        if emulate_kernel
          raise ArgumentError, "invalid argument - #{n}" if defined?(JRUBY_VERSION)

          nil
        else
          m = Range.new(n.end, n.begin, false)

          while true # TODO: better way to do this than looping?
            q = _rand_range(m)

            break q unless n.exclude_end? and q == n.end
          end
        end
      elsif n.begin == n.end and n.exclude_end?
        raise ArgumentError, "invalid argument - #{n}" if emulate_kernel and defined?(JRUBY_VERSION)

        nil
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

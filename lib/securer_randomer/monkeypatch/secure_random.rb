# frozen_string_literal: true

require 'rbnacl/sodium'
require 'rbnacl/util'
require 'rbnacl/random'

module SecureRandom
  def self.gen_random(n)
    RbNaCl::Random.random_bytes(n)
  end

  def self.random_number(n = 0)
    # mimic exceptions raised by "stock" SecureRandom
    raise ArgumentError, "comparison of Fixnum with #{n} failed" unless n.respond_to?(:>)
    raise TypeError, "Cannot convert into OpenSSL::BN" if n.is_a?(Float) && n > 0

    begin
      Kernel.rand(n > 0 ? n : 0)
    rescue TypeError => e
      raise ArgumentError.new(e)
    end
  end
end

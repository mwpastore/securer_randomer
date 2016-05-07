# frozen_string_literal: true

require_relative 'secure_random'

module Kernel
  alias_method :kernel_rand, :rand
  alias_method :kernel_srand, :srand

  def rand(max = 0)
    SecureRandom.random_number(max.is_a?(Range) ? max : max.to_i.abs)
  end

  def srand(_number)
    raise NotImplementedError, 'use Random or (preferably) SecureRandom'
  end
end

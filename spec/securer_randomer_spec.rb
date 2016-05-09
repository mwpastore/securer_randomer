require_relative 'spec_helper'

describe SecurerRandomer do
  context 'SecurerRandomer::VERSION' do
    Then { SecurerRandomer.const_defined?(:VERSION) }
    And { !SecurerRandomer::VERSION.nil? }
  end
end

describe SecurerRandomer do
  context '.rand' do
    context 'dwim with an inverted range' do
      When(:results) { Array.new(100) { described_class.rand(0...-10) } }

      Then { results.all? { |i| i.is_a?(Integer) } }
      And { results.all? { |i| i > -10 } }
      And { results.all? { |i| i <= 0 } }
    end

    context 'dwim with negative integers' do
      When(:results) { Array.new(100) { described_class.rand(-10) } }

      Then { results.all? { |i| i.is_a?(Integer) } }
      And { results.all? { |i| i > -10 } }
      And { results.all? { |i| i <= 0 } }
    end

    context 'dwim with negative floats' do
      When(:results) { Array.new(100) { described_class.rand(-9.6) } }

      Then { results.all? { |i| i.is_a?(Float) } }
      And { results.all? { |i| i > -9.6 } }
      And { results.all? { |i| i <= 0.0 } }
    end
  end if ENV.fetch('WITH_MONKEYPATCH', 'true') == 'true'

  context '.kernel_rand' do
    Given(:method) do
      if ENV.fetch('WITH_MONKEYPATCH', 'true') == 'true'
        proc { |arg| described_class.rand(arg, true) }
      else
        proc { |arg| Kernel.rand(arg) }
      end
    end

    context 'returns random positive integers when passed positive and negative integers' do
      When(:results) do
        Array.new(50) { method.call(10) }.concat \
          Array.new(50) { method.call(-10) }
      end

      Then { results.all? { |i| i.is_a?(Integer) } }
      And { results.all? { |i| i >= 0 } }
      And { results.all? { |i| i < 10 } }
    end

    context 'returns random integers in an inclusive range' do
      When(:results) { Array.new(100) { method.call(4..10) } }

      Then { results.all? { |i| i.is_a?(Integer) } }
      And { results.all? { |i| i >= 4 } }
      And { results.all? { |i| i <= 10 } }
    end

    context 'returns random integers in an exclusive range' do
      When(:results) { Array.new(100) { method.call(4...10) } }

      Then { results.all? { |i| i.is_a?(Integer) } }
      And { results.all? { |i| i >= 4 } }
      And { results.all? { |i| i < 10 } }
    end

    context 'returns random positive integers when passed positive and negative floats' do
      When(:results) do
        Array.new(50) { method.call(9.5) }.concat \
          Array.new(50) { method.call(-9.5) }
      end

      Then { results.all? { |f| f.is_a?(Integer) } }
      And { results.all? { |f| f >= 0 } }
      And { results.all? { |f| f < 9 } }
    end

    context 'returns random floats in an inclusive range' do
      When(:results) { Array.new(100) { method.call(3.5..9.6) } }

      Then { results.all? { |f| f.is_a?(Float) } }
      And { results.all? { |f| f >= 3.5 } }
      And { results.all? { |f| f <= 9.6 } }
    end

    context 'rejects weird input' do
      When(:result) { method.call('a') }

      Then { result == Failure(TypeError) }
    end

    context 'rejects weirder input' do
      When(:result) { method.call('a'..'b') }

      Then { result == Failure(TypeError) }
    end

    context 'rejects inverted ranges' do
      When(:result) { method.call(0..-1) }

      Then { result.nil? }
    end

    context 'has default behavior' do
      When(:floats) { Array.new(100) { method.call } }

      Then { floats.all? { |f| f.is_a?(Float) } }
      And { floats.all? { |f| f >= 0 } }
      And { floats.all? { |f| f < 1 } }
    end

    context 'supports ranges including negative integers' do
      When(:results) { Array.new(100) { method.call(-100..100) } }

      Then { results.all? { |i| i.is_a?(Integer) } }
      And { results.all? { |i| i >= -100 } }
      And { results.all? { |i| i <= 100 } }
      And { results.any? { |i| i < 0 } }
    end

    context 'supports ranges including negative floats' do
      When(:results) { Array.new(100) { method.call(-100.0..100.0) } }

      Then { results.all? { |f| f.is_a?(Float) } }
      And { results.all? { |f| f >= -100.0 } }
      And { results.all? { |f| f <= 100.0 } }
      And { results.any? { |f| f < 0.0 } }
    end
  end
end

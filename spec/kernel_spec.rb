require_relative 'spec_helper'

describe Kernel do
  context '.rand' do
    context 'is monkeypatched' do
      When(:source_location) { described_class.method(:rand).source_location }

      Then { source_location }
      And { source_location.first =~ %r{lib/securer_randomer/monkeypatch/kernel\.rb$} }
    end
  end

  context '#rand' do
    context 'is monkeypatched' do
      When(:source_location) { described_class.instance_method(:rand).source_location }

      Then { source_location }
      And { source_location.first =~ %r{lib/securer_randomer/monkeypatch/kernel\.rb$} }
    end

    context 'returns random positive integers when passed positive and negative integers' do
      When(:results) do
        Array.new(50) { described_class.rand(10) }.concat \
          Array.new(50) { described_class.rand(-10) }
      end

      Then { results.all? { |i| i.is_a?(Integer) } }
      And { results.all? { |i| i >= 0 } }
      And { results.all? { |i| i < 10 } }
    end

    context 'returns random integers in an inclusive range' do
      When(:results) { Array.new(100) { described_class.rand(4..10) } }

      Then { results.all? { |i| i.is_a?(Integer) } }
      And { results.all? { |i| i >= 4 } }
      And { results.all? { |i| i <= 10 } }
    end

    context 'returns random integers in an exclusive range' do
      When(:results) { Array.new(100) { described_class.rand(4...10) } }

      Then { results.all? { |i| i.is_a?(Integer) } }
      And { results.all? { |i| i >= 4 } }
      And { results.all? { |i| i < 10 } }
    end

    context 'returns random positive integers when passed positive and negative floats' do
      When(:results) do
        Array.new(50) { described_class.rand(9.5) }.concat \
          Array.new(50) { described_class.rand(-9.5) }
      end

      Then { results.all? { |f| f.is_a?(Integer) } }
      And { results.all? { |f| f >= 0 } }
      And { results.all? { |f| f < 9 } }
    end

    context 'returns random floats in an inclusive range' do
      When(:results) { Array.new(100) { described_class.rand(3.5..9.6) } }

      Then { results.all? { |f| f.is_a?(Float) } }
      And { results.all? { |f| f >= 3.5 } }
      And { results.all? { |f| f <= 9.6 } }
    end

    context 'rejects weird input' do
      When(:result) { described_class.rand('a') }

      Then { result == Failure(TypeError) }
    end

    context 'rejects weirder input' do
      When(:result) { described_class.rand('a'..'b') }

      Then { result == Failure(TypeError) }
    end

    context 'has default behavior' do
      When(:floats) { Array.new(100) { described_class.rand } }

      Then { floats.all? { |f| f.is_a?(Float) } }
      And { floats.all? { |f| f >= 0 } }
      And { floats.all? { |f| f < 1 } }
    end

    context 'supports ranges including negative integers' do
      When(:results) { Array.new(100) { described_class.rand(-100..100) } }

      Then { results.all? { |i| i.is_a?(Integer) } }
      And { results.all? { |i| i >= -100 } }
      And { results.all? { |i| i <= 100 } }
      And { results.any? { |i| i < 0 } }
    end

    context 'supports ranges including negative floats' do
      When(:results) { Array.new(100) { described_class.rand(-100.0..100.0) } }

      Then { results.all? { |f| f.is_a?(Float) } }
      And { results.all? { |f| f >= -100.0 } }
      And { results.all? { |f| f <= 100.0 } }
      And { results.any? { |f| f < 0.0 } }
    end
  end
end

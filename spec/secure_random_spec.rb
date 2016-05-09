require_relative 'spec_helper'

describe SecureRandom do
  context '.gen_random' do
    context 'is monkeypatched' do
      When(:source_location) { described_class.method(:gen_random).source_location }

      Then { source_location }
      And { source_location.first =~ %r{lib/securer_randomer/monkeypatch/secure_random\.rb$} }
    end

    context 'returns random bytes' do
      When(:forty_bytes) { described_class.gen_random(40) }
      When(:forty_other_bytes) { described_class.gen_random(40) }

      Then { forty_bytes.bytesize == 40 }
      And { forty_bytes != forty_other_bytes }
    end
  end

  context '.random_number' do
    context 'is monkeypatched' do
      When(:source_location) { described_class.method(:random_number).source_location }

      Then { source_location }
      And { source_location.first =~ %r{lib/securer_randomer/monkeypatch/secure_random\.rb$} }
    end

    context 'returns random integers up to but not including n' do
      When(:ints) { Array.new(100) { described_class.random_number(10) } }

      Then { ints.all? { |i| i.is_a?(Integer) } }
      And { ints.all? { |i| i >= 0 } }
      And { ints.all? { |i| i < 10 } }
    end

    context 'rejects positive floats' do
      When(:result) { described_class.random_number(0.1) }

      Then { result == Failure(TypeError) }
    end

    context 'rejects ranges' do
      When(:result) { described_class.random_number(0..1) }

      Then { result == Failure(ArgumentError) }
    end

    context 'rejects strings' do
      When(:result) { described_class.random_number('a') }

      Then { result == Failure(ArgumentError) }
    end

    context 'rejects nil' do
      When(:result) { described_class.random_number(nil) }

      Then { result == Failure(ArgumentError) }
    end

    context 'has default behavior' do
      When(:floats) { Array.new(100) { described_class.random_number } }

      Then { floats.all? { |f| f.is_a?(Float) } }
      And { floats.all? { |f| f >= 0 } }
      And { floats.all? { |f| f < 1 } }
    end

    context 'ignores zero and negative floats and integers' do
      Given(:samples) { [0, 0.0, -1, -100, -5.5] }

      When(:floats) { samples.map { |i| described_class.random_number(i) } }

      Then { floats.all? { |f| f.is_a?(Float) } }
      And { floats.all? { |f| f >= 0 } }
      And { floats.all? { |f| f < 1 } }
    end
  end

  context '.random_bytes' do
    context 'is monkeypatched' do
      When(:source_location) { described_class.method(:random_bytes).source_location }

      Then { source_location }
      And { source_location.first =~ %r{lib/securer_randomer/monkeypatch/secure_random\.rb$} }
    end

    context 'returns 16 bytes by default' do
      When(:sixteen_bytes) { described_class.gen_random(16) }
      When(:sixteen_other_bytes) { described_class.gen_random(16) }

      Then { sixteen_bytes.bytesize == 16 }
      And { sixteen_bytes != sixteen_other_bytes }
    end
  end
end

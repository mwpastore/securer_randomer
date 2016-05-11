require_relative 'spec_helper'

describe SecureRandom do
  context '.random_number' do
    context 'is monkeypatched' do
      When(:source_location) { described_class.method(:random_number).source_location }

      Then { source_location }
      And { source_location.first =~ %r{lib/securer_randomer/monkeypatch/secure_random\.rb$} }
    end if ENV.fetch('WITH_MONKEYPATCH', 'true') == 'true'

    context 'returns random integers up to but not including n' do
      When(:ints) { Array.new(100) { described_class.random_number(10) } }

      Then { ints.all? { |i| i.is_a?(Integer) } }
      And { ints.all? { |i| i >= 0 } }
      And { ints.all? { |i| i < 10 } }
    end

    context 'rejects positive floats' do
      When(:result) { described_class.random_number(0.1) }
      When(:error_class) do
        if defined?(JRUBY_VERSION)
          ArgumentError
        elsif Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new(String.new('2.2.0'))
          TypeError
        else
          ArgumentError
        end
      end

      Then { result == Failure(error_class) }
    end unless Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new(String.new('2.3.0'))

    context 'rejects ranges' do
      When(:result) { described_class.random_number(0..1) }

      Then { result == Failure(ArgumentError) }
    end unless Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new(String.new('2.3.0'))

    context 'rejects strings' do
      When(:result) { described_class.random_number('a') }

      Then { result == Failure(ArgumentError) }
    end

    context 'rejects nil' do
      When(:result) { described_class.random_number(nil) }

      Then { result == Failure(ArgumentError) }
    end unless Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new(String.new('2.3.0'))

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

    context 'in ruby 2.3+' do
      context 'ignores nil' do
        When(:result) { described_class.random_number(nil) }

        Then { result.is_a?(Float) }
        And { result >= 0 }
        And { result < 1 }
      end

      context 'returns random integers in an inclusive range' do
        When(:results) { Array.new(100) { described_class.random_number(4..10) } }

        Then { results.all? { |i| i.is_a?(Integer) } }
        And { results.all? { |i| i >= 4 } }
        And { results.all? { |i| i <= 10 } }
      end

      context 'returns random integers in an exclusive range' do
        When(:results) { Array.new(100) { described_class.random_number(4...10) } }

        Then { results.all? { |i| i.is_a?(Integer) } }
        And { results.all? { |i| i >= 4 } }
        And { results.all? { |i| i < 10 } }
      end

      context 'returns random floats in an inclusive range' do
        When(:results) { Array.new(100) { described_class.random_number(3.5..9.6) } }

        Then { results.all? { |f| f.is_a?(Float) } }
        And { results.all? { |f| f >= 3.5 } }
        And { results.all? { |f| f <= 9.6 } }
      end

      context 'supports ranges including negative integers' do
        When(:results) { Array.new(100) { described_class.random_number(-100..100) } }

        Then { results.all? { |i| i.is_a?(Integer) } }
        And { results.all? { |i| i >= -100 } }
        And { results.all? { |i| i <= 100 } }
        And { results.any? { |i| i < 0 } }
      end

      context 'supports ranges including negative floats' do
        When(:results) { Array.new(100) { described_class.random_number(-100.0..100.0) } }

        Then { results.all? { |f| f.is_a?(Float) } }
        And { results.all? { |f| f >= -100.0 } }
        And { results.all? { |f| f <= 100.0 } }
        And { results.any? { |f| f < 0.0 } }
      end

      context 'rejects weird ranges' do
        When(:result) { described_class.random_number('a'..'b') }

        Then { result == Failure(ArgumentError) }
      end

      context 'rejects inverted ranges' do
        When(:result) { described_class.random_number(0..-1) }

        Then { result.is_a?(Float) }
        And { result >= 0 }
        And { result < 1 }
      end

      context 'returns range.begin in inclusive noop range' do
        Given(:samples) { [0, 0.0, 1, 1.0, -1, -1.0] }

        When(:results) { samples.map { |i| [i, described_class.random_number(i..i)] } }

        Then { results.all? { |i| i.first.class == i.last.class } }
        And { results.all? { |i| i.first === i.last } }
      end

      context 'rejects noop ranges' do
        Given(:samples) { [0, 0.0, 1, 1.0, -1, -1.0] }

        When(:results) { samples.map { |i| described_class.random_number(i...i) } }

        Then { results.all? { |f| f.is_a?(Float) } }
        And { results.all? { |f| f >= 0 } }
        And { results.all? { |f| f < 1 } }
      end
    end if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new(String.new('2.3.0'))
  end

  context '.gen_random' do
    context 'is monkeypatched' do
      When(:source_location) { described_class.method(:gen_random).source_location }

      Then { source_location }
      And { source_location.first =~ %r{lib/securer_randomer/monkeypatch/secure_random\.rb$} }
    end if ENV.fetch('WITH_MONKEYPATCH', 'true') == 'true'

    context 'returns random bytes' do
      When(:forty_bytes) { described_class.gen_random(40) }
      When(:forty_other_bytes) { described_class.gen_random(40) }

      Then { forty_bytes.bytesize == 40 }
      And { forty_bytes != forty_other_bytes }
    end
  end if described_class.respond_to?(:gen_random)

  context '.random_bytes' do
    context 'is monkeypatched' do
      When(:source_location) { described_class.method(:random_bytes).source_location }

      Then { source_location }
      And { source_location.first =~ %r{lib/securer_randomer/monkeypatch/secure_random\.rb$} }
    end if ENV.fetch('WITH_MONKEYPATCH', 'true') == 'true'

    context 'returns 16 bytes by default' do
      When(:sixteen_bytes) { described_class.random_bytes(16) }
      When(:sixteen_other_bytes) { described_class.random_bytes(16) }

      Then { sixteen_bytes.bytesize == 16 }
      And { sixteen_bytes != sixteen_other_bytes }
    end
  end unless described_class.respond_to?(:gen_random)
end

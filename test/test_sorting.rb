# frozen_string_literal: true

require "test_helper"

class TestSorting < Minitest::Test
  def test_sorting_alphabetically
    gemfile = <<~GEMFILE
      gem "rubocop"
      gem "debug"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.write!
        gem "debug" # Debugging functionality for Ruby
        gem "rubocop" # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_sorting_dashed_underscored
    gemfile = <<~GEMFILE
      gem "something"
      gem "something_beta"
      gem "something-alpha"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      parser.stub(:find_external_gem_summary, nil) do
        assert_equal <<~GEMFILE, parser.write!
          gem "something"
          gem "something-alpha"
          gem "something_beta"
        GEMFILE
      end
    end
  end

  def test_sorting_with_group_in_between
    gemfile = <<~GEMFILE
      gem "debug"

      group :development do
        gem "rake"
      end

      gem "rubocop"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      parser.stub(:find_external_gem_summary, nil) do
        assert_equal <<~GEMFILE, parser.write!
          gem "debug" # Debugging functionality for Ruby
          gem "rubocop" # Automatic Ruby code style checking tool.

          group :development do
            gem "rake" # Rake is a Make-like program implemented in Ruby
          end
        GEMFILE
      end
    end
  end

  def test_sorting_with_two_equal_groups
    gemfile = <<~GEMFILE
      group :development do
        gem "rubocop"
      end

      group :development do
        gem "rake"
      end
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      parser.stub(:find_external_gem_summary, nil) do
        assert_equal <<~GEMFILE, parser.write!
          group :development do
            gem "rake" # Rake is a Make-like program implemented in Ruby
            gem "rubocop" # Automatic Ruby code style checking tool.
          end
        GEMFILE
      end
    end
  end
end

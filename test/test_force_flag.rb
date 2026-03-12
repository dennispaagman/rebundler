# frozen_string_literal: true

require "test_helper"

class TestForceFlag < Minitest::Test
  def test_force_overwrites_existing_comment
    gemfile = <<~GEMFILE
      gem "rubocop" # Style police
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format(overwrite_comments: true)
        gem "rubocop" # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_default_preserves_existing_comment
    gemfile = <<~GEMFILE
      gem "rubocop" # My custom comment
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop" # My custom comment
      GEMFILE
    end
  end

  def test_default_adds_summary_when_no_comment
    gemfile = <<~GEMFILE
      gem "rubocop"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop" # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_whitespace_only_comment_treated_as_no_comment
    gemfile = <<~GEMFILE
      gem "rubocop" #
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop" # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_force_overwrites_whitespace_comment
    gemfile = <<~GEMFILE
      gem "rubocop" #
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format(overwrite_comments: true)
        gem "rubocop" # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_preserves_comments_in_groups
    gemfile = <<~GEMFILE
      group :development do
        gem "rubocop" # Custom style checker
      end
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        group :development do
          gem "rubocop" # Custom style checker
        end
      GEMFILE
    end
  end

  def test_mixed_gems_some_with_comments
    gemfile = <<~GEMFILE
      gem "minitest" # Keep this
      gem "rubocop"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "minitest" # Keep this
        gem "rubocop" # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end
end

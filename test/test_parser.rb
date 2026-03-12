# frozen_string_literal: true

require "test_helper"

class TestParserInterface < Minitest::Test
  def test_from_file_raises_on_missing_file
    assert_raises(Rebundler::Error) do
      Rebundler::Parser.from_file("/nonexistent/path/Gemfile")
    end
  end

  def test_from_file_formats_gemfile
    Tempfile.create("Gemfile") do |f|
      f.write(<<~GEMFILE)
        gem "rubocop"
      GEMFILE
      f.flush

      parser = Rebundler::Parser.from_file(f.path)

      assert_equal <<~GEMFILE, parser.format
        gem "rubocop" # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_from_string_formats_gemfile
    parser = Rebundler::Parser.from_string(<<~GEMFILE)
      gem "rubocop"
    GEMFILE

    assert_equal <<~GEMFILE, parser.format
      gem "rubocop" # Automatic Ruby code style checking tool.
    GEMFILE
  end

  def test_format_callable_twice_with_different_overwrite_comments
    parser = Rebundler::Parser.from_string(<<~GEMFILE)
      gem "rubocop" # My custom comment
    GEMFILE

    # First call: preserve existing comment
    first = parser.format(overwrite_comments: false)

    assert_equal <<~GEMFILE, first
      gem "rubocop" # My custom comment
    GEMFILE

    # Second call: overwrite
    second = parser.format(overwrite_comments: true)

    assert_equal <<~GEMFILE, second
      gem "rubocop" # Automatic Ruby code style checking tool.
    GEMFILE
  end
end

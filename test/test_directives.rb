# frozen_string_literal: true

require "test_helper"

class TestDirectives < Minitest::Test
  def test_source_with_string
    gemfile = <<~GEMFILE
      source "https://rubygems.org"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.parse_and_write!
        source "https://rubygems.org"
      GEMFILE
    end
  end

  def test_ruby_version_with_string
    gemfile = <<~GEMFILE
      ruby "3.2.0"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.parse_and_write!
        ruby "3.2.0"
      GEMFILE
    end
  end

  def test_ruby_version_with_arguments
    gemfile = <<~GEMFILE
      ruby "3.2.0", engine: "ruby", engine_version: "3.2.0"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.parse_and_write!
        ruby "3.2.0", engine: "ruby", engine_version: "3.2.0"
      GEMFILE
    end
  end

  def test_ruby_with_file_argument
    gemfile = <<~GEMFILE
      ruby file: ".ruby-version"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.parse_and_write!
        ruby file: ".ruby-version"
      GEMFILE
    end
  end

  def test_gemspec
    gemfile = <<~GEMFILE
      gemspec
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.parse_and_write!
        gemspec
      GEMFILE
    end
  end

  def test_gemspec_with_arguments
    gemfile = <<~GEMFILE
      gemspec name: "my_gem", path: "../", development_group: :dev
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.parse_and_write!
        gemspec name: "my_gem", path: "../", development_group: :dev
      GEMFILE
    end
  end

  def test_frozen_string_literal
    gemfile = <<~GEMFILE
      # frozen_string_literal: true

      gem "rubocop"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.parse_and_write!
        # frozen_string_literal: true

        gem "rubocop" # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_git_source
    gemfile = <<~'GEMFILE'
      git_source(:bc) { |repo| "https://github.com/basecamp/#{repo}" }

      gem "rails"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~'GEMFILE', parser.parse_and_write!
        git_source(:bc) { |repo| "https://github.com/basecamp/#{repo}" }

        gem "rails" # Full-stack web application framework.
      GEMFILE
    end
  end

  # NOTE: the \t is explicit here, to prevent auto formatting from messing with the test.
  def test_group_with_tabs_instead_of_spaces
    gemfile = <<~GEMFILE
      group :development do
      \tgem "rubocop"
      end
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.parse_and_write!
        group :development do
        \tgem "rubocop" # Automatic Ruby code style checking tool.
        end
      GEMFILE
    end
  end
end

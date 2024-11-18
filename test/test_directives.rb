require "test_helper"

class TestDirectives < Minitest::Test
  def test_source_with_string
    gemfile = <<~GEMFILE
      source "https://rubygems.org"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.write!
        source "https://rubygems.org"
      GEMFILE
    end
  end

  def test_ruby_version_with_string
    gemfile = <<~GEMFILE
      ruby "3.2.0"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.write!
        ruby "3.2.0"
      GEMFILE
    end
  end

  def test_ruby_version_with_arguments
    gemfile = <<~GEMFILE
      ruby "3.2.0", engine: "ruby", engine_version: "3.2.0"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.write!
        ruby "3.2.0", engine: "ruby", engine_version: "3.2.0"
      GEMFILE
    end
  end

  def test_gemspec
    gemfile = <<~GEMFILE
      gemspec
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.write!
        gemspec
      GEMFILE
    end
  end

  def test_gemspec_with_arguments
    gemfile = <<~GEMFILE
      gemspec name: "my_gem", path: "../", development_group: :dev
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.write!
        gemspec name: "my_gem", path: "../", development_group: :dev
      GEMFILE
    end
  end
end

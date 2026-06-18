# frozen_string_literal: true

require "test_helper"

class TestParserGemVariants < Minitest::Test
  def test_gem_without_any_args
    gemfile = <<~GEMFILE
      gem "rubocop"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop" # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_require_boolean
    gemfile = <<~GEMFILE
      gem "rubocop", require: false
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", require: false # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_require_string
    gemfile = <<~GEMFILE
      gem "rubocop", require: "rubocop"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", require: "rubocop" # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_require_string_array
    gemfile = <<~GEMFILE
      gem "rubocop", require: ["rubocop", "rubocop/rspec"]
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", require: ["rubocop", "rubocop/rspec"] # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_source
    gemfile = <<~GEMFILE
      gem "rubocop", source: "https://rubygems.org"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", source: "https://rubygems.org" # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_git
    gemfile = <<~GEMFILE
      gem "rubocop", git: "https://github.com/rubocop/rubocop.git"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", git: "https://github.com/rubocop/rubocop.git" # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_git_with_branch
    gemfile = <<~GEMFILE
      gem "rubocop", git: "https://github.com/rubocop/rubocop.git", branch: "main"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", git: "https://github.com/rubocop/rubocop.git", branch: "main" # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_git_with_tag
    gemfile = <<~GEMFILE
      gem "rubocop", git: "https://github.com/rubocop/rubocop.git", tag: "v1.0.0"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", git: "https://github.com/rubocop/rubocop.git", tag: "v1.0.0" # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_git_with_ref
    gemfile = <<~GEMFILE
      gem "rubocop", git: "https://github.com/rubocop/rubocop.git", ref: "abc123"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", git: "https://github.com/rubocop/rubocop.git", ref: "abc123" # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_git_submodules
    gemfile = <<~GEMFILE
      gem "rubocop", git: "https://github.com/rubocop/rubocop.git", submodules: true
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", git: "https://github.com/rubocop/rubocop.git", submodules: true # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_github
    gemfile = <<~GEMFILE
      gem "rubocop", github: "rubocop/rubocop"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", github: "rubocop/rubocop" # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_gist
    gemfile = <<~GEMFILE
      gem "rubocop", gist: "e123456789abcdef0123456789abcdef"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", gist: "e123456789abcdef0123456789abcdef" # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_path
    gemfile = <<~GEMFILE
      gem "rubocop", path: "../rubocop"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", path: "../rubocop" # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_group
    gemfile = <<~GEMFILE
      gem "rubocop", group: :development
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", group: :development # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_groups
    gemfile = <<~GEMFILE
      gem "rubocop", groups: [:development, :test]
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", groups: [:development, :test] # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_platform
    gemfile = <<~GEMFILE
      gem "rubocop", platform: :jruby
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", platform: :jruby # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_platforms
    gemfile = <<~GEMFILE
      gem "rubocop", platforms: [:jruby, :mingw, :x64_mingw]
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", platforms: [:jruby, :mingw, :x64_mingw] # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_force_ruby_platform
    gemfile = <<~GEMFILE
      gem "rubocop", force_ruby_platform: true
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", force_ruby_platform: true # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_symbol_array_literal
    gemfile = <<~GEMFILE
      gem "rubocop", platforms: %i[jruby mingw x64_mingw]
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", platforms: %i[jruby mingw x64_mingw] # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_symbol_array_literal_with_different_delimiter
    gemfile = <<~GEMFILE
      gem "rubocop", platforms: %I(jruby mingw x64_mingw)
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", platforms: %I(jruby mingw x64_mingw) # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_gem_with_string_array_literal
    gemfile = <<~GEMFILE
      gem "rubocop", platforms: %w[jruby mingw x64_mingw]
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "rubocop", platforms: %w[jruby mingw x64_mingw] # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end

  def test_not_loaded_gem
    gemfile = <<~GEMFILE
      gem "phlex"
    GEMFILE

    with_parsed_gemfile(gemfile, summary: "Object-oriented views in Ruby.") do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "phlex" # Object-oriented views in Ruby.
      GEMFILE
    end
  end

  def test_non_existing_gem
    gemfile = <<~GEMFILE
      gem "schrodingers_gem"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        gem "schrodingers_gem"
      GEMFILE
    end
  end

  def test_plugin
    gemfile = <<~GEMFILE
      plugin "rubocop"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        plugin "rubocop" # Automatic Ruby code style checking tool.
      GEMFILE
    end
  end
end

# frozen_string_literal: true

require "test_helper"

class TestParserBlocks < Minitest::Test
  def test_gemfile_with_group_block
    gemfile = <<~GEMFILE
      group :development do
        gem "rubocop"
      end
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        group :development do
          gem "rubocop" # Automatic Ruby code style checking tool.
        end
      GEMFILE
    end
  end

  def test_gemfile_with_group_block_with_multiple
    gemfile = <<~GEMFILE
      group :development, :test do
        gem "rubocop"
      end
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        group :development, :test do
          gem "rubocop" # Automatic Ruby code style checking tool.
        end
      GEMFILE
    end
  end

  def test_gemfile_with_group_block_with_array
    gemfile = <<~GEMFILE
      group [:development, :test] do
        gem "rubocop"
      end
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        group [:development, :test] do
          gem "rubocop" # Automatic Ruby code style checking tool.
        end
      GEMFILE
    end
  end

  def test_gemfile_with_group_block_with_optional
    gemfile = <<~GEMFILE
      group :development, optional: true do
        gem "rubocop"
      end
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        group :development, optional: true do
          gem "rubocop" # Automatic Ruby code style checking tool.
        end
      GEMFILE
    end
  end

  def test_gemfile_with_source_block
    gemfile = <<~GEMFILE
      source "https://gems.example.org" do
        gem "rubocop"
      end
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        source "https://gems.example.org" do
          gem "rubocop" # Automatic Ruby code style checking tool.
        end
      GEMFILE
    end
  end

  def test_gemfile_with_git_block
    gemfile = <<~GEMFILE
      git "https://github.com/rubocop/rubocop.git" do
        gem "rubocop"
      end
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        git "https://github.com/rubocop/rubocop.git" do
          gem "rubocop" # Automatic Ruby code style checking tool.
        end
      GEMFILE
    end
  end

  def test_gemfile_with_git_block_with_branch
    gemfile = <<~GEMFILE
      git "https://github.com/rubocop/rubocop.git", branch: "main" do
        gem "rubocop"
      end
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        git "https://github.com/rubocop/rubocop.git", branch: "main" do
          gem "rubocop" # Automatic Ruby code style checking tool.
        end
      GEMFILE
    end
  end

  def test_gemfile_with_path_block
    gemfile = <<~GEMFILE
      path "../rubocop" do
        gem "rubocop"
      end
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        path "../rubocop" do
          gem "rubocop" # Automatic Ruby code style checking tool.
        end
      GEMFILE
    end
  end

  def test_gemfile_with_platform_block
    gemfile = <<~GEMFILE
      platforms :ruby do
        gem "rubocop"
      end
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        platforms :ruby do
          gem "rubocop" # Automatic Ruby code style checking tool.
        end
      GEMFILE
    end
  end

  def test_gemfile_with_bracketed_block
    gemfile = <<~GEMFILE
      group :development {
        gem "rubocop"
      }
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        group :development {
          gem "rubocop" # Automatic Ruby code style checking tool.
        }
      GEMFILE
    end
  end

  def test_ordering_groups_alpabetically
    gemfile = <<~GEMFILE
      group :test do
        gem "minitest"
      end

      group :development do
        gem "rubocop"
      end
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        group :development do
          gem "rubocop" # Automatic Ruby code style checking tool.
        end

        group :test do
          gem "minitest" # minitest provides a complete suite of testing facilities supporting TDD, BDD, and benchmarking
        end
      GEMFILE
    end
  end

  def test_ordering_combined_groups
    gemfile = <<~GEMFILE
      group :development, :test do
        gem "debug"
      end

      group :test do
        gem "minitest"
      end

      group :development do
        gem "rubocop"
      end
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.format
        group :development do
          gem "rubocop" # Automatic Ruby code style checking tool.
        end

        group :development, :test do
          gem "debug" # Debugging functionality for Ruby
        end

        group :test do
          gem "minitest" # minitest provides a complete suite of testing facilities supporting TDD, BDD, and benchmarking
        end
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
      assert_equal <<~GEMFILE, parser.format
        group :development do
        \tgem "rubocop" # Automatic Ruby code style checking tool.
        end
      GEMFILE
    end
  end
end

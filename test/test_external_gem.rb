# frozen_string_literal: true

class TestExternalGem < Minitest::Test
  def test_not_loaded_gem
    gemfile = <<~GEMFILE
      gem "phlex"
    GEMFILE

    with_parsed_gemfile(gemfile) do |parser|
      assert_equal <<~GEMFILE, parser.write!
        gem "phlex" # A fun framework for building views in Ruby.
      GEMFILE
    end
  end
end

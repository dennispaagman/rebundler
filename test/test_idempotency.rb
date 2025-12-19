# frozen_string_literal: true

require "test_helper"

class TestIdempotency < Minitest::Test
  def test_running_multiple_times_does_not_change_output
    gemfile = <<~GEMFILE
      gem "rubocop"
    GEMFILE

    parsed_gemfile = nil

    with_parsed_gemfile(gemfile) do |parser|
      parsed_gemfile = parser.parse_and_write!

      assert_equal <<~GEMFILE, parsed_gemfile
        gem "rubocop" # Automatic Ruby code style checking tool.
      GEMFILE
    end

    # Do another pass.
    with_parsed_gemfile(parsed_gemfile) do |parser|
      assert_equal parsed_gemfile, parser.parse_and_write!
    end
  end
end

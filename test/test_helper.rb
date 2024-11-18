# frozen_string_literal: true

require "debug"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rebundler"

require "minitest/autorun"

def with_temporary_gemfile(content, &)
  file = Tempfile.new("Gemfile")

  file.write(content)
  file.rewind

  begin
    yield file
  ensure
    file.close
    file.unlink
  end
end

def with_parsed_gemfile(content, &)
  with_temporary_gemfile(content) do |file|
    parser = Rebundler::Parser.new(file.path)
    parser.parse!

    yield parser
  end
end

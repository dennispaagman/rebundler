# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "rebundler"
require "minitest/autorun"
require "minitest/mock"

def with_parsed_gemfile(content, external_summary: nil, &)
  Rebundler::GemDeclaration.stub(:find_external_gem_summary, external_summary) do
    yield Rebundler::Parser.from_string(content)
  end
end

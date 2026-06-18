# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "rebundler"
require "minitest/autorun"
require "minitest/stub_any_instance"

def with_parsed_gemfile(content, summary: nil, description: nil, &)
  mocked_spec = Gem::Specification.new do |s|
    s.summary = summary if summary
    s.description = description if description
  end

  Rebundler::GemDeclaration.stub_any_instance(:find_external_gem, mocked_spec) do
    yield Rebundler::Parser.from_string(content)
  end
end

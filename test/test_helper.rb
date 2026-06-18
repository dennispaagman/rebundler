# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "rebundler"
require "minitest/autorun"
require "minitest/stub_any_instance"

def with_parsed_gemfile(content, &)
  Rebundler::GemDeclaration.stub_any_instance(:find_external_gem, nil) do
    yield Rebundler::Parser.from_string(content)
  end
end

def with_stubbed_gem(gem_name, **options, &)
  spec = Gem::Specification.new do |s|
    options.each { |attribute, value| s.public_send("#{attribute}=", value) }
  end

  Rebundler::GemDeclaration.stub_any_instance(
    :find_external_gem, -> { spec if name == gem_name.to_s }, &
  )
end

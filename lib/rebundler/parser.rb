# frozen_string_literal: true

require "prism"

module Rebundler
  class Parser
    attr_reader :file, :before, :sets, :frozen_string_literal

    def initialize(file)
      @file = file
      @frozen_string_literal = false
      @before = []
      @sets = []

      build_set(name: "") # all gems outside a specific block (group, source, etc) will end up here
    end

    def build_set(name:, node: nil)
      GemSet.build(name:, node:).tap do |set|
        @sets << set
      end
    end

    def write!
      parse!

      Writer.new(self).write!
    end

    def find_or_build_set(name:, node: nil)
      sets.find { |set| set.name == name } || build_set(name:, node:)
    end

    private

    def parse!
      parsed = Prism.parse(File.read(file))

      @frozen_string_literal = parsed.magic_comments.map(&:key).include?("frozen_string_literal")

      visitor = Visitor.new(self)
      parsed.value.accept(visitor)
    end
  end
end

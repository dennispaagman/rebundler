# frozen_string_literal: true

require "prism"

module Rebundler
  class Parser
    attr_reader :file, :preamble_nodes, :gem_sets, :frozen_string_literal

    def initialize(file)
      @file = file
      @frozen_string_literal = false
      @preamble_nodes = []
      @gem_sets = []

      build_set(name: "") # all gems outside a specific block (group, source, etc) will end up here
    end

    def build_set(name:, node: nil)
      GemSet.new(name:, node:).tap do |set|
        @gem_sets << set
      end
    end

    def parse!
      return if @parsed

      parsed = Prism.parse(File.read(file))

      @frozen_string_literal = parsed.magic_comments.map(&:key).include?("frozen_string_literal")

      visitor = Visitor.new(self)
      parsed.value.accept(visitor)

      @parsed = true
    end

    def parse_and_write!
      parse!
      Writer.new(self).write!
    end

    def find_or_build_set(name:, node: nil)
      gem_sets.find { |set| set.name == name } || build_set(name:, node:)
    end
  end
end

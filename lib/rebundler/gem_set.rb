# frozen_string_literal: true

module Rebundler
  class GemSet
    include Comparable

    attr_reader :name, :node, :plugins, :gems, :default

    def initialize(name: nil, node: nil, default: false)
      @name = name
      @node = node
      @default = default

      @plugins = []
      @gems = []
    end

    def <=>(other)
      return nil unless other.is_a?(GemSet)

      # Default first, then sort by name
      [default ? 0 : 1, name] <=> [other.default ? 0 : 1, other.name]
    end

    def ==(other)
      other.is_a?(GemSet) && other.name == name
    end
  end
end

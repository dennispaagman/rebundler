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
      unless other.is_a?(GemSet)
        raise ArgumentError,
              "comparison of GemSet with #{other.class} failed"
      end

      # Default first, then sort by name
      [default ? 0 : 1, name.to_s] <=> [other.default ? 0 : 1, other.name.to_s]
    end

    def ==(other)
      other.is_a?(GemSet) && other.name == name && other.default == default
    end
  end
end

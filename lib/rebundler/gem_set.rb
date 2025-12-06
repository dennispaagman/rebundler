# frozen_string_literal: true

module Rebundler
  class GemSet
    attr_reader :name, :node, :plugins, :gems

    def initialize(name: "", node: nil)
      @name = name
      @node = node
      @plugins = []
      @gems = []
    end

    def ==(other)
      other.is_a?(GemSet) && other.name == name
    end
  end
end

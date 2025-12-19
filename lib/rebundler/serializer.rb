# frozen_string_literal: true

module Rebundler
  class Serializer
    def self.node_to_s(node)
      lines = node.location.slice.lines

      # If a block is given, we replace the content of the node's block
      # with the content of the passed block.
      if node.block && block_given? && lines.size > 1
        depth = find_depth(node)
        tab_or_space = find_spacing_character(node)

        indented_content = yield.lines.map { |line| (tab_or_space * depth) + line }.join

        lines.first + indented_content + "\n" + lines.last
      else
        node.location.slice
      end
    end

    def self.find_depth(node)
      node.block.body.location.start_column
    end

    def self.find_spacing_character(node)
      # Assume it's formatted with tabs if there is ANY tab in the whole block of code.
      node.location.slice.include?("\t") ? "\t" : " "
    end
  end
end

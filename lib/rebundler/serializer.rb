# frozen_string_literal: true

module Rebundler
  class Serializer
    def self.node_to_s(node)
      return if node.nil?

      if node.block && block_given?
        indent = detect_indent(node)
        indented_content = yield.lines.map { |line| indent + line.lstrip }.join

        stripped_block = node.location.slice.gsub(node.block.body.location.slice, "BLOCK")
        stripped_block.gsub(/[#{WHITESPACE_CHARACTERS}]*BLOCK/, indented_content)
      else
        node.location.slice
      end
    end

    def self.detect_indent(node)
      return "" unless node

      second_line = node.location.slice.lines[1]
      second_line&.[](/\A */) || "  "
    end
  end
end

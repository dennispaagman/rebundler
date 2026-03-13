# frozen_string_literal: true

module Rebundler
  class Serializer
    def self.extract_comment(node, comments)
      # Find comments that are on the same line as the node
      node_line = node.location.end_line

      trailing_comment = comments.find do |comment|
        comment.location.start_line == node_line &&
          comment.location.start_offset > node.location.end_offset
      end

      return nil unless trailing_comment

      # Get the comment text (without the # prefix)
      comment_text = trailing_comment.location.slice.sub(/^#\s*/, "").strip
      comment_text.empty? ? nil : comment_text
    end

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
      # Assume it's formatted with tabs if ANY line starts with a tab.
      any_line_starts_with_tab = node.location.slice.split("\n").any? { |line| line.start_with?("\t") }

      any_line_starts_with_tab ? "\t" : " "
    end
  end
end

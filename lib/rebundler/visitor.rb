# frozen_string_literal: true

module Rebundler
  class Visitor < Prism::Visitor
    def initialize(parser)
      super()
      @parser = parser
      @current_set = @parser.gem_sets.find(&:default)
    end

    def visit_call_node(node)
      case node.name
      when :plugin
        @current_set.plugins << parse_gem_with_comment(node)
      when :gem
        @current_set.gems << parse_gem_with_comment(node)
      when :git_source
        @parser.preamble_nodes << node
      when *BLOCK_NODES
        if node.block
          # Use the full block declaration (e.g., "group :development do") as the unique name
          name = node.location.slice.lines.first.strip

          previous_set = @current_set
          @current_set = @parser.find_or_build_set(name:, node:)
          node.block.body&.accept(self)
          @current_set = previous_set
        else
          @parser.preamble_nodes << node
        end
      end
    end

    private

    def parse_gem_with_comment(node)
      existing_comment = Serializer.extract_comment(node, @parser.comments)

      # If there's an existing comment and we're not forcing, use it without fetching
      if existing_comment && !@parser.force
        gem_name = node.arguments.child_nodes[0].content

        return { name: gem_name, summary: existing_comment, node: }
      end

      # Otherwise, fetch the gem info (which includes summary)
      GemFetcher.parse_gem(node)
    end
  end
end

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
        # :git_source is a special case where it's a directive with a block that
        # we don't want to add it as a set, which would happen if it's parsed in
        # the condition for DIRECTIVE_AND_BLOCK_NODES below.
        @parser.directives << node
      when *DIRECTIVE_AND_BLOCK_NODES
        if node.block
          return unless node.block.body

          # Use the full block declaration (e.g., "group :development do") as the unique name
          name = node.location.slice.lines.first.strip

          previous_set = @current_set
          @current_set = find_or_build_set(name:, node:)
          node.block.body.accept(self)
          @current_set = previous_set
        else
          @parser.directives << node
        end
      end
    end

    private

    def find_or_build_set(name:, node: nil)
      @parser.gem_sets.find { |set| set.name == name } || build_set(name:, node:)
    end

    def build_set(name:, node: nil)
      GemSet.new(name:, node:).tap do |set|
        @parser.gem_sets << set
      end
    end

    def parse_gem_with_comment(node)
      name = node.arguments.child_nodes[0].content
      summary = Summarizer.summarize(name)

      GemDeclaration.new(name:, summary:, node:)
    end
  end
end

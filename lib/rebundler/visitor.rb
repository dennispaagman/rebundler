# frozen_string_literal: true

module Rebundler
  class Visitor < Prism::Visitor
    def initialize(parser)
      super()
      @parser = parser
      @current_set = @parser.gem_sets.first
    end

    def visit_call_node(node)
      case node.name
      when :plugin
        parsed_gem = GemFetcher.parse_gem(node)
        @current_set.plugins << parsed_gem if parsed_gem
      when :gem
        parsed_gem = GemFetcher.parse_gem(node)
        @current_set.gems << parsed_gem if parsed_gem
      when *BLOCK_NODES
        if node.block
          name = Serializer.node_to_s(node)

          previous_set = @current_set
          @current_set = @parser.find_or_build_set(name:, node:)
          node.block.body&.accept(self)
          @current_set = previous_set
        else
          @parser.preamble_nodes << node
        end
      end
    end
  end
end

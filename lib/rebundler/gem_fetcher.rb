# frozen_string_literal: true

module Rebundler
  class GemFetcher
    def self.parse_gem(node)
      return unless node.type == :call_node && SORTABLE_NODES.include?(node.name)

      gem_name = node.arguments.child_nodes[0].content

      find_gem(gem_name).merge(node:)
    end

    private_class_method def self.find_gem(name)
      summary = find_loaded_gem_summary(name) || find_external_gem_summary(name)

      { name:, summary: }
    end

    private_class_method def self.find_loaded_gem_summary(name)
      gem = Gem::Specification.find_by_name(name)

      gem.summary
    rescue Gem::MissingSpecError
      nil
    end

    private_class_method def self.find_external_gem_summary(name)
      spec = Gem::SpecFetcher.fetcher.spec_for_dependency Gem::Dependency.new(name)

      return unless spec
      return if spec == [[], []]

      spec.first.first.first.summary
    end
  end
end

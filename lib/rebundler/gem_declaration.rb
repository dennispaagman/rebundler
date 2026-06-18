# frozen_string_literal: true

module Rebundler
  class GemDeclaration
    include Comparable

    attr_reader :node

    def initialize(node: nil)
      @node = node
    end

    def name = @node.arguments.child_nodes[0].content
    def normalized_name = name.tr("-_", "").downcase

    def summary
      gem = find_loaded_gem || find_external_gem

      return if gem.nil?

      if gem.summary.nil? || gem.summary == ""
        gem.description
      else
        gem.summary
      end
    end

    def <=>(other)
      unless other.is_a?(GemDeclaration)
        raise ArgumentError,
              "comparison of GemDeclaration with #{other.class} failed"
      end

      normalized_name <=> other.normalized_name
    end

    private

    def find_loaded_gem
      Gem::Specification.find_by_name(name)
    rescue Gem::MissingSpecError
      nil
    end

    def find_external_gem
      spec = Gem::SpecFetcher.fetcher.spec_for_dependency(Gem::Dependency.new(name))

      return if spec.nil? || spec.first.empty?

      spec.first.first.first
    rescue SocketError, Errno::ECONNREFUSED, Errno::ETIMEDOUT, Timeout::Error => e
      raise Rebundler::Error, "Network error while fetching gem info for '#{name}': #{e.message}"
    end
  end
end

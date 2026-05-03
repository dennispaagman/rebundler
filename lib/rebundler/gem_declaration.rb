# frozen_string_literal: true

require "timeout"

module Rebundler
  class GemDeclaration < Data.define(:name, :node)
    include Comparable

    def initialize(name:, node:)
      @memo = {}
      super
    end

    def summary
      @memo[:summary] ||= self.class.find_loaded_gem_summary(name) || self.class.find_external_gem_summary(name)
    end

    def <=>(other)
      raise ArgumentError, "comparison of GemDeclaration with #{other.class} failed" unless other.is_a?(GemDeclaration)

      normalized_name <=> other.normalized_name
    end

    def normalized_name
      name.tr("-_", "").downcase
    end

    def self.find_loaded_gem_summary(name)
      gem = Gem::Specification.find_by_name(name)

      gem.summary
    rescue Gem::MissingSpecError
      nil
    end

    def self.find_external_gem_summary(name)
      spec = Gem::SpecFetcher.fetcher.spec_for_dependency Gem::Dependency.new(name)

      return if spec.nil? || spec.first.empty?

      spec.first.first.first.summary
    rescue SocketError, Errno::ECONNREFUSED, Errno::ETIMEDOUT, Timeout::Error => e
      raise Rebundler::Error, "Network error while fetching gem info for '#{name}': #{e.message}"
    end
  end
end

# frozen_string_literal: true

require "timeout"

module Rebundler
  class Summarizer
    class << self
      def summarize(name)
        find_loaded_gem_summary(name) || find_external_gem_summary(name)
      end

      private

      def find_loaded_gem_summary(name)
        gem = Gem::Specification.find_by_name(name)

        gem.summary
      rescue Gem::MissingSpecError
        nil
      end

      def find_external_gem_summary(name)
        spec = Gem::SpecFetcher.fetcher.spec_for_dependency Gem::Dependency.new(name)

        return if spec.nil? || spec.first.empty?

        spec.first.first.first.summary
      rescue SocketError, Errno::ECONNREFUSED, Errno::ETIMEDOUT, Timeout::Error => e
        raise Rebundler::Error, "Network error while fetching gem info for '#{name}': #{e.message}"
      end
    end
  end
end

# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/bundler")
loader.setup

module Rebundler
  class Error < StandardError; end

  WHITESPACE_CHARACTERS = " \t"

  SORTABLE_NODES = %i[plugin gem].freeze
  BLOCK_NODES = %i[gemspec git group path platforms ruby source].freeze
end

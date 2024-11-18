# frozen_string_literal: true

require_relative "rebundler/version"
require_relative "rebundler/parser"

require_relative "rebundler/railtie" if defined?(Rails)

module Rebundler
  class Error < StandardError; end
  # Your code goes here...
end

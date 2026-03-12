# frozen_string_literal: true

require "prism"

module Rebundler
  class Parser
    attr_reader :content, :frozen_string_literal, :directives, :gem_sets, :comments

    def self.from_file(path)
      raise Rebundler::Error, "File not found: #{path}" unless File.exist?(path)

      new(File.read(path))
    end

    def self.from_string(content)
      new(content)
    end

    def format(overwrite_comments: false)
      Formatter.new(self).format(overwrite_comments:)
    end

    private_class_method :new

    def initialize(content)
      @content = content
      @frozen_string_literal = false
      @directives = []
      @gem_sets = [GemSet.new(default: true)]
      @comments = []

      parse!
    end

    private

    def parse!
      parsed = Prism.parse(@content)

      @frozen_string_literal = parsed.magic_comments.map(&:key).include?("frozen_string_literal")
      @comments = parsed.comments

      visitor = Visitor.new(self)
      parsed.value.accept(visitor)
    end
  end
end

# frozen_string_literal: true

require "forwardable"

module Rebundler
  class Formatter
    extend Forwardable

    def_delegators :@parser, :directives, :gem_sets, :frozen_string_literal, :comments

    def initialize(parser)
      @parser = parser
    end

    def format(overwrite_comments: false)
      buffer = []

      buffer << "# frozen_string_literal: true" if frozen_string_literal

      directives.each do |node|
        buffer << Serializer.node_to_s(node)
      end

      gem_sets.sort.each do |set|
        gem_content = [set.plugins, set.gems].map do |nodes|
          nodes.sort.map do |gem|
            existing_comment = Serializer.extract_comment(gem.node, comments)
            comment = if existing_comment && !overwrite_comments
                        existing_comment
                      else
                        gem.summary
                      end

            line = +Serializer.node_to_s(gem.node)
            line << " # #{comment}" if comment
            line
          end.join("\n")
        end.reject(&:empty?).join("\n\n")

        buffer << if set.node
                    Serializer.node_to_s(set.node) { gem_content }
                  else
                    gem_content
                  end
      end

      buffer.reject(&:empty?).join("\n\n") + "\n"
    end
  end
end

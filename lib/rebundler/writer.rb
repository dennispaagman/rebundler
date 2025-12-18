# frozen_string_literal: true

module Rebundler
  class Writer
    def initialize(parser)
      @parser = parser
    end

    def write!
      buffer = []

      buffer << "# frozen_string_literal: true" if frozen_string_literal

      preamble_nodes.each do |node|
        buffer << Serializer.node_to_s(node)
      end

      gem_sets.sort.each do |set|
        gem_content = [set.plugins, set.gems].map do |nodes|
          sorted = nodes.sort_by { |node| node[:name].tr("-_", "").downcase }

          sorted.map do |gem|
            line = +Serializer.node_to_s(gem[:node])
            line << " # #{gem[:summary]}" if gem[:summary]
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

    private

    def preamble_nodes
      @parser.preamble_nodes
    end

    def gem_sets
      @parser.gem_sets
    end

    def frozen_string_literal
      @parser.frozen_string_literal
    end
  end
end

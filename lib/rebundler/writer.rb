# frozen_string_literal: true

module Rebundler
  class Writer
    def initialize(parser)
      @parser = parser
    end

    def write!
      buffer = []

      buffer << "# frozen_string_literal: true" if frozen_string_literal

      before.each do |node|
        buffer << Serializer.node_to_s(node)
      end

      sets.sort_by(&:name).each do |set|
        set_buffer = []

        set_buffer << [Serializer.node_to_s(set.node), set.node.block.opening].compact.join(" ") if set.node

        set_buffer << [set.plugins, set.gems].map do |nodes|
          sorted = nodes.sort_by { _1[:name].tr("-_", "").downcase }

          sorted.map do |gem|
            line = +""
            line << "  " if set.node
            line << Serializer.node_to_s(gem[:node])
            line << " # #{gem[:summary]}" if gem[:summary]

            line
          end.join("\n")
        end.reject(&:empty?).join("\n\n")

        set_buffer << set.node.block.closing if set.node&.block

        buffer << set_buffer.join("\n")
      end

      buffer.reject(&:empty?).join("\n\n") + "\n"
    end

    private

    def before = @parser.before
    def sets = @parser.sets
    def frozen_string_literal = @parser.frozen_string_literal
  end
end

# frozen_string_literal: true

require "prism"

module Rebundler
  class Parser
    attr_reader :file, :before, :blocks, :frozen_string_literal

    def initialize(file)
      @file = file
      @before = []
      @blocks = [
        { block: nil, gems: [] } # the gems without a specific block
      ]
      @frozen_string_literal = false
    end

    def parse!
      parsed = Prism.parse(File.read(file))

      @frozen_string_literal = true if parsed.magic_comments.map(&:key).include?("frozen_string_literal")

      parsed.value.compact_child_nodes[0].compact_child_nodes.each do |node|
        case node.type
        when :call_node
          case node.name
          when :gem
            @blocks[0][:gems] << parse_gem(node)
          when :gemspec, :ruby
            @before << node
          when :group, :source, :git, :platforms, :path
            if node.block
              block = { block: node, gems: [] }

              node.block.body.compact_child_nodes.each do |child|
                block[:gems] << parse_gem(child)
              end

              @blocks << block
            else
              @before << node
            end
          end
        end
      end
    end

    def write!
      chunks = []

      chunks << "# frozen_string_literal: true" if frozen_string_literal

      before.each do |node|
        chunks << node_to_s(node)
      end

      blocks.each do |block|
        block_node = block[:block]
        block_lines = []

        block_lines << "#{block_node.message} #{args_to_s(block_node.arguments)} do" if block_node

        block[:gems].sort_by { _1[:gem].name }.each do |gem|
          dep = gem[:gem]
          code = node_to_s(gem[:node])

          line = +""
          line << "  " if block_node
          line << "#{code} # #{dep.summary}"

          block_lines << line
        end

        block_lines << "end" if block_node

        chunks << block_lines.join("\n")
      end

      chunks.reject(&:empty?).join("\n\n") + "\n"
    end

    private

    def find_loaded_gem(gem)
      Gem.loaded_specs.find do |name, _|
        name == gem
      end&.last
    end

    def args_to_s(args)
      return if args.nil? || args.child_nodes.empty?

      args.child_nodes.map { node_to_s(_1) }.join(", ")
    end

    def node_to_s(node)
      case node.type
      when :call_node
        "#{node.name} #{args_to_s(node.arguments)}".strip
      when :keyword_hash_node
        node.elements.map do |element|
          key = node_to_s(element.key)
          value = node_to_s(element.value)

          "#{key} #{value}"
        end
      when :symbol_node
        "#{node.opening}#{node.value}#{node.closing}"
      when :string_node
        "#{node.opening}#{node.content}#{node.closing}"
      when :array_node
        separator = node.opening == "[" ? ", " : " "

        node.opening + node.elements.map do |element|
          node_to_s(element)
        end.join(separator) + node.closing
      when :true_node
        "true"
      when :false_node
        "false"
      else
        raise NotImplementedError, "Unknown node type: #{node.type}"
      end
    end

    def parse_gem(node)
      return unless node.type == :call_node && node.name == :gem

      gem_name = node.arguments.child_nodes[0].content

      { gem: find_loaded_gem(gem_name), node: }
    end
  end
end

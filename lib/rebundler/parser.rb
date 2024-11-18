# frozen_string_literal: true

require "prism"

module Rebundler
  class Parser
    attr_reader :blocks

    def initialize(file)
      @file = file
      @blocks = [
        { block: nil, gems: [] } # the gems without a specific block
      ]
    end

    def parse!
      parsed = Prism.parse(File.read(@file)).value

      parsed.compact_child_nodes[0].compact_child_nodes.each do |node|
        case node.type
        when :call_node
          case node.name
          when :gem
            @blocks[0][:gems] << parse_gem(node)
          when :group, :source, :git, :platforms, :path
            block = { block: node, gems: [] }

            node.block.body.compact_child_nodes.each do |child|
              block[:gems] << parse_gem(child)
            end

            @blocks << block
          end
        end
      end
    end

    def write!
      lines = []

      lines << @blocks.map do |block|
        bl = block[:block]
        block_lines = []

        block_lines << "#{bl.message} #{args_to_s(bl.arguments.child_nodes)} do" if bl

        block[:gems].sort_by { _1[:gem].name }.each do |gem|
          dep = gem[:gem]
          args = args_to_s(gem[:args])

          line = +""
          line << "  " if bl

          line << if args
                    "gem \"#{dep.name}\", #{args_to_s(gem[:args])} # #{dep.summary}"
                  else
                    "gem \"#{dep.name}\" # #{dep.summary}"
                  end

          block_lines << line
        end

        block_lines << "end" if bl

        block_lines.join("\n")
      end.reject(&:empty?).join("\n\n")

      lines.join + "\n"
    end

    private

    def find_loaded_gem(gem)
      Gem.loaded_specs.find do |name, _|
        name == gem
      end&.last
    end

    def args_to_s(args)
      return if args.empty?

      args.map do |arg|
        case arg.type
        when :keyword_hash_node
          arg.elements.map do |element|
            key = node_to_s(element.key)
            value = node_to_s(element.value)

            "#{key} #{value}"
          end
        when :string_node, :symbol_node, :array_node
          node_to_s(arg)
        else
          raise NotImplementedError, "Unknown argument type: #{arg.type}"
        end
      end.join(", ")
    end

    def node_to_s(node)
      case node.type
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

      { gem: find_loaded_gem(gem_name), args: node.arguments.child_nodes[1..] }
    end
  end
end

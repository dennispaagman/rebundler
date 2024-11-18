# frozen_string_literal: true

require "prism"

module Rebundler
  class Parser
    def initialize(file)
      @file = file
      @gems = []
    end

    def parse!
      queue = [Prism.parse(File.read(@file)).value]

      while (node = queue.shift)
        case node.type
        when :call_node
          if node.name == :gem
            gem_name = node.arguments.child_nodes[0].unescaped

            @gems << { gem: find_loaded_gem(gem_name), args: node.arguments.child_nodes[1..] }
          end
        end

        queue.concat(node.compact_child_nodes)
      end
    end

    def write!
      raise "UnparsedError" if @gems.empty?

      lines = []

      @gems.sort_by { _1[:gem].name }.each do |gem|
        dep = gem[:gem]

        lines << "gem \"#{dep.name}\"#{args_to_s(gem[:args])} # #{dep.summary}"
      end

      "#{lines.join("\n")}\n"
    end

    private

    def find_loaded_gem(gem)
      Gem.loaded_specs.find do |name, _|
        name == gem
      end&.last
    end

    def args_to_s(args)
      return if args.empty?

      ", " + args.map do |arg|
        case arg.type
        when :keyword_hash_node
          arg.elements.map do |element|
            key = node_to_s(element.key)
            value = node_to_s(element.value)

            "#{key} #{value}"
          end
        when :string_node
          node_to_s(arg)
        else
          raise NotImplementedError
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
        raise NotImplementedError
      end
    end
  end
end

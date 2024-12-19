# frozen_string_literal: true

require "prism"

module Rebundler
  class Parser
    attr_reader :blocks

    def initialize(file)
      @file = file
      @before = []
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

      @before.each do |node|
        case node.name
        when :source, :gemspec, :ruby
          chunks << if node.arguments.nil?
                      node.message
                    else
                      "#{node.message} #{args_to_s(node.arguments.child_nodes)}"
                    end
        end
      end

      @blocks.each do |block|
        block_node = block[:block]
        block_lines = []

        block_lines << "#{block_node.message} #{args_to_s(block_node.arguments.child_nodes)} do" if block_node

        # TODO: remove nil filter, add a fallback to grab data from rubygems.org for non loaded gems
        grouped = block[:gems].filter { !_1[:gem].nil? }.group_by do |gem|
          catalog.find do
            _2.include?(gem[:gem].name)
          end&.first
        end.sort_by { |key, _| key.nil? ? "zzzz" : key }.to_h # very ugly hack to put nil last

        grouped.each do |group, gems|
          if group
            if block_node
              block_lines << "  # #{group}"
            elsif group
              block_lines << "# #{group}"
            end
          end

          gems.sort_by { _1[:gem].name }.each do |gem|
            dep = gem[:gem]
            args = args_to_s(gem[:args])

            line = +""
            line << "  " if block_node

            line << if args
                      "gem \"#{dep.name}\", #{args} # #{dep.summary}"
                    else
                      "gem \"#{dep.name}\" # #{dep.summary}"
                    end

            block_lines << line
          end
          block_lines << "" if group
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
      return if args.empty?

      args.map { node_to_s(_1) }.join(", ")
    end

    def node_to_s(node)
      case node.type
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

      { gem: find_loaded_gem(gem_name), args: node.arguments.child_nodes[1..] }
    end

    def catalog
      @catalog ||= Catalogizer.new.catalog
    end
  end
end

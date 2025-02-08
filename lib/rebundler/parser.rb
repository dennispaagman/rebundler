# frozen_string_literal: true

require "prism"
require "gems"

module Rebundler
  class Parser
    attr_reader :file, :before, :sets, :frozen_string_literal

    def initialize(file)
      @file = file
      @frozen_string_literal = false
      @before = []
      @sets = [
        { node: nil, gems: [] } # all gems outside a specific block (group, source, etc) will end up here
      ]
    end

    def parse!
      parsed = Prism.parse(File.read(file))

      @frozen_string_literal = parsed.magic_comments.map(&:key).include?("frozen_string_literal")

      parsed.value.compact_child_nodes[0].compact_child_nodes.each do |node|
        case node.type
        when :call_node
          case node.name
          when :gem
            @sets[0][:gems] << parse_gem(node)
          when :gemspec, :ruby
            @before << node
          when :group, :source, :git, :platforms, :path
            if node.block
              @sets << {
                node:,
                gems: node.block.body.compact_child_nodes.map { parse_gem(_1) }
              }
            else
              @before << node
            end
          end
        end
      end
    end

    def write!
      buffer = []

      buffer << "# frozen_string_literal: true" if frozen_string_literal

      before.each do |node|
        buffer << node_to_s(node)
      end

      sets.each do |set|
        set_node = set[:node]
        set_lines = []

        set_lines << "#{set_node.message} #{args_to_s(set_node.arguments)} do" if set_node

        set[:gems].sort_by { _1[:name] }.each do |gem|
          line = +""
          line << "  " if set_node
          line << node_to_s(gem[:node])
          line << " # #{gem[:summary]}" if gem[:summary]

          set_lines << line
        end

        set_lines << "end" if set_node

        buffer << set_lines.join("\n")
      end

      buffer.reject(&:empty?).join("\n\n") + "\n"
    end

    private

    def find_gem(name)
      summary = find_loaded_gem_summary(name) || find_external_gem_summary(name)

      { name:, summary: }
    end

    def find_loaded_gem_summary(name)
      gem = Gem::Specification.find_by_name(name)

      gem.summary
    rescue Gem::MissingSpecError
      nil
    end

    def find_external_gem_summary(name)
      version = Gems.latest_version(name)["version"]

      return if version == "unknown"

      Gems::V2.info(name, version)["summary"]
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

      find_gem(gem_name).merge(node:)
    end
  end
end

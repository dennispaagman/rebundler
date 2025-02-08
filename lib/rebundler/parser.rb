# frozen_string_literal: true

require "prism"
require "gems"

module Rebundler
  class Parser
    SORTABLE_NODES = %i[plugin gem].freeze
    BLOCK_NODES = %i[gemspec git group path platforms ruby source].freeze

    attr_reader :file, :before, :sets, :frozen_string_literal

    def initialize(file)
      @file = file
      @frozen_string_literal = false
      @before = []
      @sets = [
        { node: nil, plugin: [], gem: [] } # all gems outside a specific block (group, source, etc) will end up here
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
            @sets[0][:gem] << parse_gem(node)
          when :plugin
            @sets[0][:plugin] << parse_gem(node)
          when *BLOCK_NODES
            if node.block
              children = node.block.body.compact_child_nodes

              @sets << {
                node:,
                plugin: children.filter { _1.name == :plugin }.map { parse_gem(_1) },
                gem: children.filter { _1.name == :gem }.map { parse_gem(_1) }
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

      sets.sort_by { node_to_s(_1[:node]) || "" }.each do |set|
        set_node = set[:node]
        set_buffer = []

        set_buffer << [node_to_s(set_node), set_node.block.opening].compact.join(" ") if set_node

        set_buffer << SORTABLE_NODES.map do |node_type|
          nodes = set[node_type].sort_by { _1[:name] }

          nodes.map do |gem|
            line = +""
            line << "  " if set_node
            line << node_to_s(gem[:node])
            line << " # #{gem[:summary]}" if gem[:summary]

            line
          end.join("\n")
        end.reject(&:empty?).join("\n\n")

        set_buffer << set_node.block.closing if set_node&.block

        buffer << set_buffer.join("\n")
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

    def node_to_s(node)
      return if node.nil?

      case node.type
      when :call_node
        [node.name, node_to_s(node.arguments)].compact.join(" ")
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
      when :arguments_node
        return if node.child_nodes.empty?

        node.child_nodes.map { node_to_s(_1) }.join(", ")
      else
        raise NotImplementedError, "Unknown node type: #{node.type}"
      end
    end

    def parse_gem(node)
      return unless node.type == :call_node && SORTABLE_NODES.include?(node.name)

      gem_name = node.arguments.child_nodes[0].content

      find_gem(gem_name).merge(node:)
    end
  end
end

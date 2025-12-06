# frozen_string_literal: true

module Rebundler
  class Serializer
    def self.node_to_s(node)
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

        node.child_nodes.map { |child| node_to_s(child) }.join(", ")
      else
        raise Rebundler::Error, "Unsupported node type: #{node.type}"
      end
    end
  end
end

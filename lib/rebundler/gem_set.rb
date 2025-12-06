# frozen_string_literal: true

module Rebundler
  GemSet = Data.define(:name, :node, :plugins, :gems) do
    def self.build(name: "", node: nil)
      new(name:, node:, plugins: [], gems: [])
    end
  end
end

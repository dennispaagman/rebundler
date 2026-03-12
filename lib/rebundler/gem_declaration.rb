# frozen_string_literal: true

module Rebundler
  GemDeclaration = Data.define(:name, :summary, :node) do
    def <=>(other)
      raise ArgumentError, "comparison of GemDeclaration with #{other.class} failed" unless other.is_a?(GemDeclaration)

      normalized_name <=> other.normalized_name
    end

    def normalized_name
      name.tr("-_", "").downcase
    end
  end
end

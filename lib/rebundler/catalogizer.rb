# frozen_string_literal: true

require "json"

module Rebundler
  class Catalogizer
    attr_reader :catalog

    def initialize
      @catalog = {}
      load_catalog!
    end

    private

    def load_catalog!
      file = JSON.parse(File.read(File.join(__dir__, "catalog.json")), symbolize_names: true)

      file[:category_groups].each do |group|
        group[:categories].each do |category|
          @catalog[group[:name]] ||= []
          @catalog[group[:name]].append(*category[:projects])
        end
      end
    end
  end
end

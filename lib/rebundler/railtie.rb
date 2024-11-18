# frozen_string_literal: true

# lib/railtie.rb
require "rebundler"
require "rails"

module Rebundler
  class Railtie < Rails::Railtie
    railtie_name :rebundler

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end
  end
end

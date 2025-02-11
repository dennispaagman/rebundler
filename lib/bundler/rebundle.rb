# frozen_string_literal: true

module Bundler
  class Rebundle < Bundler::Plugin::API
    hook "after-install-all" do
      parse_and_write_gemfile!
    end

    def self.parse_and_write_gemfile!
      Bundler.ui.info "Reordering and annotating Gemfile..."

      file = Bundler.root.to_s + "/Gemfile"

      begin
        # Load all gems in the Gemfile so we can use them to grab the summary instead of
        # having to hit rubygems.org
        Bundler.setup

        parser = ::Rebundler::Parser.new(file)
        parser.parse!
        File.write(file, parser.write!)
      rescue StandardError => e
        Bundler.ui.error "Error parsing Gemfile: #{e.message}"
        raise Bundler::PluginError, e
      end
    end
  end
end

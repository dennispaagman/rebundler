# frozen_string_literal: true

require "bundler"
require "tempfile"

module Bundler
  class Rebundle < Bundler::Plugin::API
    command "rebundle"

    hook "after-install-all" do
      parse_and_write_gemfile!
    end

    def exec(command, args)
      send command, args
    end

    def self.parse_and_write_gemfile!
      Bundler.ui.info "Reordering and annotating Gemfile..."

      file = Bundler.root.to_s + "/Gemfile"

      begin
        # Load all gems in the Gemfile so we can use them to grab the summary instead of
        # having to hit rubygems.org
        Bundler.setup

        parser = ::Rebundler::Parser.new(file)
        content = parser.parse_and_write!

        # Use atomic write to prevent corruption if write fails
        Tempfile.create("Gemfile", Bundler.root.to_s) do |tmp|
          tmp.write(content)
          tmp.flush
          tmp.close
          FileUtils.mv(tmp.path, file)
        end
      rescue StandardError => e
        Bundler.ui.error "Error parsing Gemfile: #{e.message}"
        raise Bundler::PluginError, e
      end
    end
  end
end

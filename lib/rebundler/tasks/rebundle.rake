# frozen_string_literal: true

require "rebundler"

desc "Rebundle"
task :rebundle, :file do |_t, args|
  file = args[:file] || (Dir.pwd + "/Gemfile")
  parser = Rebundler::Parser.new(file)

  parser.parse!

  File.write(file, parser.write!)
end

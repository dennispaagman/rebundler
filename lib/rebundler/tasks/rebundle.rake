# frozen_string_literal: true

require "rebundler"

desc "Rebundle"
task :rebundle, :file do |t, args|
  file = args[:file] || Dir.pwd + "/Gemfile"
  parser = Rebundler::Parser.new(file)

  parser.parse!

  puts parser.write!
end

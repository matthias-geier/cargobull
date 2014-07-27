gem 'minitest'

require 'cargobull'
require 'minitest/autorun'

path = File.dirname(__FILE__)
Dir.open(path).select{ |f| f =~ /spec/ }.each do |f|
  load path + '/' + f.to_s
end

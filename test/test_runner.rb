gem 'minitest'
require 'minitest/autorun'
require 'cargobull/test_helper'

path = File.dirname(__FILE__)
Dir.open(path).select{ |f| f =~ /spec.*\.rb$/ }.each do |f|
  load path + '/' + f.to_s
end

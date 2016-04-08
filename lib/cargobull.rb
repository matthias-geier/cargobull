require 'cargobull/extensions/string'
require 'cargobull/env'
require 'cargobull/service'
require 'cargobull/dispatch'
require 'cargobull/rackup'

module Cargobull
  def self.runner(cargoenv=env.get)
    ->(env) do
      cenv = cargoenv.dup
      cenv[:rackenv] = env
      cenv[:request_path] = env["REQUEST_PATH"]
      cenv[:request_method] = env["REQUEST_METHOD"]
      cenv.freeze
      Rackup.call(cenv)
    end
  end

  #def self.streamer(cargoenv=env.get)
  #  cargoenv[:session] = {}
  #  cargoenv.freeze
  #  Stream.call(cargoenv)
  #end
end

if File.exist?('./setup.rb')
  require 'cargobull/initialize'
  require './setup'
  Cargobull::Initialize.init_all
end

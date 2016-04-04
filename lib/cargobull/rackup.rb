
module Cargobull
  def self.runner(cargoenv=env.get)
    cargoenv.freeze
    ->(env){ Rackup.call(cargoenv, env) }
  end

  module Rackup
    def self.file(env)
      path = env["REQUEST_PATH"]
      path.gsub!(/\/\.+/, '')
      path.sub!(/^#{Cargobull.env.serve_url}\/?/i, '')
      if path.empty?
        path = Cargobull.env.default_files.detect do |f|
          File.file?("./files/#{f}")
        end
      end
      path = "./files/#{path}"
      if File.file?(path)
        return [200, {}, File.open(path, File::RDONLY)]
      elsif Cargobull.env.default_path
        return [200, {},
          File.open("./files/#{Cargobull.env.default_path}", File::RDONLY)]
      else
        return [404, {}, "Not found"]
      end
    end

    def self.dispatch(cargoenv, rackenv)
      req = Rack::Request.new(rackenv)
      action = rackenv["REQUEST_PATH"].sub(/^#{cargoenv[:dispatch_url]}\/?/, '')
      params = req.POST.merge(req.GET)
      return Dispatch.call(cargoenv, rackenv["REQUEST_METHOD"], action, params)
    end

    def self.routes(cargoenv)
      routes = [
        #[/^#{cargoenv[:serve_url]}\/?/i, :file],
        [/^#{cargoenv[:dispatch_url]}\/?/i, :dispatch]
      ]
      routes.reverse! if cargoenv[:serve_url] == '/'
      return routes.unshift([/^\/favicon/i, :file])
    end

    def self.call(cargoenv, rackenv)
      path = rackenv["REQUEST_PATH"]
      _, match_method = routes(cargoenv).detect{ |pattern, _| path =~ pattern }
      if match_method.nil?
        return [500, { "Content-Type" => cargoenv[:ctype] }, cargoenv[:e500] ]
      else
        return send(match_method, cargoenv, rackenv)
      end
    end
  end
end

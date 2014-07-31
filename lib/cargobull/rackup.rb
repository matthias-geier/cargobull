
module Cargobull
  class Rackup
    def file(env)
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
      else
        return [404, {}, "Not found"]
      end
    end

    def dispatch(env)
      req = Rack::Request.new(env)
      action = env["REQUEST_PATH"].sub(/^#{Cargobull.env.dispatch_url}\/?/, '').
        gsub(/\/[^\/]+/, '')
      params = req.POST.merge(req.GET)
      data = Cargobull::Dispatch.call(env["REQUEST_METHOD"], action, params)
      return [200, {}, data]
    rescue RuntimeError
      return [404, {}, "Not found"]
    end

    def self.routes
      routes = [
        [/^#{Cargobull.env.serve_url}\/?/i, :file],
        [/^#{Cargobull.env.dispatch_url}\/?/i, :dispatch]
      ]
      routes.reverse! if Cargobull.env.serve_url == '/'
      return routes.unshift([/^\/favicon/i, :file])
    end

    def call(env)
      path = env["REQUEST_PATH"]
      _, match_method = self.class.routes.detect{ |pattern, _| path =~ pattern }
      return self.send(match_method, env)
    end
  end
end

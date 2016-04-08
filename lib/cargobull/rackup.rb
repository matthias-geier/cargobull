
module Cargobull
  module Rackup
    def self.file(env)
      path = env[:request_path].gsub(/\/\.+/, '').
        sub(/^#{env[:serve_url]}\/?/i, '')
      if path.empty?
        path = env[:default_files].detect do |f|
          File.file?("./files/#{f}")
        end
      end
      path = "./files/#{path}"
      if File.file?(path)
        return [200, {}, File.open(path, File::RDONLY)]
      elsif env[:default_path]
        return [200, {}, File.open("./files/#{env[:default_path]}",
          File::RDONLY)]
      else
        return [404, { "Content-Type" => env[:ctype] }, env[:e404] ]
      end
    end

    def self.dispatch(env)
      req = Rack::Request.new(env[:rackenv])
      action = env[:request_path].sub(/^#{env[:dispatch_url]}\/?/, '')
      params = req.GET
      if req.content_type == "application/x-www-form-urlencoded"
        params.merge!(req.POST)
      else
        params[:body] = req.body
      end
      return Dispatch.call(env, env[:request_method], action, params)
    end

    def self.routes(env)
      routes = [:file, :dispatch].map do |type|
        [/^#{env["#{type}_url".to_sym]}\/?/i, type]
      end
      routes.reverse! if env[:file_url] == '/'
      return routes.unshift([/^\/favicon/i, :file])
    end

    def self.call(env)
      path = env[:request_path]
      _, match_method = routes(env).detect{ |pattern, _| path =~ pattern }
      if match_method.nil?
        return [500, { "Content-Type" => env[:ctype] }, env[:e500] ]
      else
        return send(match_method, env)
      end
    end
  end
end

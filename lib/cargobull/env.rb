
module Cargobull
  def self.env
    Env
  end

  module Env
    def self.get(*args)
      update(defaults, *args)
    end

    def self.update(env, *args)
      (args.first.is_a?(Hash) ? args.first : Hash[*args]).reduce(env) do
        |acc, (k, v)|

        acc[k.to_sym] = respond_to?(k) ? send(k, v) : v
        next acc
      end
    end

    def self.defaults
      {
        dispatch_url: "/api",
        serve_url: "/",
        default_files: ["index.html", "index.htm"],
        default_path: nil,
        ctype: "text/plain",
        e403: "Forbidden",
        e404: "Not found",
        e405: "Method not allowed",
        e500: "Internal error",
        transform_out: nil,
        transform_in: nil
      }
    end
  end
end

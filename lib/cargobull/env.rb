
module Cargobull
  def self.env
    return Env
  end

  class Env
    class << self
      attr_reader :dispatch_url, :serve_url, :transform_out, :transform_in
    end

    @dispatch_url = "/"
    @serve_url = "/files"

    def self.dispatch_url=(url)
      sanitized_url = (url || "").split('/').reject(&:empty?).first
      @dispatch_url = sanitized_url ? "/#{sanitized_url}" : "/"
      @serve_url = sanitized_url ? "/" : "/files"
    end

    def self.transform_out=(blk)
      @transform_out = blk
    end

    def self.transform_in=(blk)
      @transform_in = blk
    end
  end
end

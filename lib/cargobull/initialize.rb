
module Cargobull
  module Initialize
    @file_map = []

    def self.sanitize_file_name(file_name)
      return "./#{File.basename(file_name)}"
    end

    def self.dir(*args)
      sanitized_args = args.map{ |d| sanitize_file_name(d).sub(/\/$/, '') }.
        select{ |d| File.directory?(d) }

      sanitized_args.each do |dir|
        ruby_files = Dir["#{dir}/*.rb"]
        @file_map = ruby_files.reduce(@file_map) do |acc, f|
          camel_file = f.split("/").last.sub(/\.rb$/, '').camelize
          Object.autoload(camel_file, f)
          acc << f
        end
      end
    end

    def self.file(klass_str, file_name)
      file_name = sanitize_file_name(file_name)
      return unless File.file?(file_name)
      Object.autoload(klass_str, file_name)
      @file_map << file_name
    end

    def self.init_all
      @file_map.each{ |file| require file }
    end
  end
end

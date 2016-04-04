
module Cargobull
  module Initialize
    @file_map = []

    def self.sanitize_file_name(file_name)
      "./#{File.basename(file_name)}"
    end

    def self.dir(*args)
      sanitized_args = args.map{ |d| sanitize_file_name(d).sub(/\/$/, '') }.
        select{ |d| File.directory?(d) }

      sanitized_args.each do |dir|
        ruby_files = Dir["#{dir}/**/*.rb"]
        @file_map = ruby_files.each do |f|
          full_klass = f.sub(/^#{dir}\/?/, '').sub(/\.rb$/, '').camelize
          register_file(full_klass, f)
        end
      end
    end

    def self.file(klass_str, file_name)
      file_name = sanitize_file_name(file_name)
      return unless File.file?(file_name)
      register_file(klass_str, file_name)
    end

    def self.register_file(full_klass, fname)
      *mods, klass_name = full_klass.split('::')
      mod = mods.reduce(Object) do |acc, mod_str|
        unless acc.const_defined?(mod_str)
          acc.const_set(mod_str, Module.new)
        end
        next acc.const_get(mod_str)
      end

      mod.autoload(klass_name, fname)
      @file_map << fname
      Service.register(full_klass)
    end

    def self.init_all
      @file_map.each{ |file| require file }
    end
  end
end

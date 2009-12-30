module Kddev
  class Project
    class << self
      def list
        `ls #{ PATH }`
      end

      def find(name)
        project = new(name)
        project.exists? ? project : nil
      end

      def find!(name)
        project = find(name)

        raise "Unknown project #{ name }" if project.nil?

        project
      end
    end
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def path
      File.join(File.expand_path(PATH), name)
    end

    def exists?
      File.exists?(path)
    end

    def subpath(p)
      File.join(path, p)
    end

    def subpath?(p)
      File.exists?(subpath(p))
    end
  end
end

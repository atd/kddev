module Kddev
  class Session
    class << self
      # List of all konsole Session
      def konsole_sessions
        `qdbus org.kde.konsole`.each_line.select{ |l|
          l =~ /^\/Sessions\/\d+$/ }.map(&:chomp).map{ |name|
            new name
          }
      end

      # List of development sessions
      def all
        @all ||= konsole_sessions.select{ |w| w.dev? }
      end

      # The session from which the command has been called
      def current
        return @current unless @current.nil?

        if ENV["KONSOLE_DBUS_SESSION"].nil?
          raise "$KONSOLE_DBUS_SESSION is not defined"
        end
        @current = new(ENV["KONSOLE_DBUS_SESSION"])
      end
    end

    attr_reader :dbus_name

    def initialize(dbus_name)
      @dbus_name = dbus_name
    end

    def title
      `qdbus org.kde.konsole #{ dbus_name } org.kde.konsole.Session.title 1`.chomp
    end

    def dev?
      title =~ PREFIX
    end

    def station?
      title =~ STATION_PREFIX
    end

    def change(project)
      exec "cd #{ path(project) }"
    end

    def path(project)
      station? && project.subpath?(STATION_PATH) ?
        project.subpath(STATION_PATH) :
        project.path
    end

    def exec(text)
      silently do
        `qdbus org.kde.konsole #{ dbus_name } org.kde.konsole.Session.sendText "#{ text + "\n" }"`
      end
    end

    protected

    def silently
      system "stty -echo"
      yield
      system "stty echo"
    end

  end
end

require 'dbus'


class Dev
  def change(project)

  end

  def introspect
    puts windows.last.inspect
  end

  # Help message
  def help
    puts <<-EOS
Usage: dev <command> args"
  help: this message
EOS
  end

  private

  def session_bus
    @session_bus ||= DBus::SessionBus.instance
  end

  def konsole_bus
    @konsole_bus ||= session_bus.service("org.kde.konsole")
  end

  def main_windows
    dev_windows | Array(station_window)
  end

  def station_window
  end

  def windows
    return @windows unless @windows.nil?

    @windows = []

    puts system("qdbus org.kde.konsole")
    # Limits search to 50 windows
    [1].each do |i|
      puts "/konsole/MainWindow_#{ i }"
      win = DevWindow.new(konsole_bus.object("/konsole/MainWindow_#{ i }"))

      puts win.dbus.inspect
      puts win.dbus["org.freedesktop.DBus.Properties"].inspect
      puts win.present?

      @windows << win
    end

    @windows
  end
end

class DevWindow
  attr_reader :dbus

  def initialize(dbus_object)
    @dbus = dbus_object
  end

  def properties
    @properties_iface ||= dbus["org.freedesktop.DBus.Properties"]
  end

  def present?
    ! properties.nil?
  end
end

dev = Dev.new

if ARGV.size == 0
  dev.help
  exit
end

cmd = ARGV.shift.to_sym

unless dev.respond_to?(cmd)
  puts "Unknown command #{ cmd }"
  puts
  dev.help
  exit
end

dev.send(cmd, *ARGV)


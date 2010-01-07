module Kddev
  class Window
    attr_accessor :dbus_name

    class << self
      def main_windows_with_actions
        `qdbus org.kde.konsole`.each_line.select { |l|
          # At this time, /konsole/MainWindow_* instances remain
          # after you have closed them. So we are searching here
          # for /konsole/MainWindow_*/actions, that exists only
          # for present konsole windows.
          #
          # There's probably a better approach for this..
          l =~ /^\/konsole\/MainWindow_\d*\/actions$/
        }.map(&:chomp)
      end
    end

    def initialize
      initial_windows = self.class.main_windows_with_actions

      # Create new window instance
      `qdbus org.kde.konsole /MainApplication org.kde.KUniqueApplication.newInstance`

      diff_windows = self.class.main_windows_with_actions - initial_windows
      if diff_windows.count != 1
        raise "Main windows differ in #{ diff_windows.count } instead of 1"
      end

      @dbus_name = diff_windows.first.gsub("/actions", "")
    end
  end
end

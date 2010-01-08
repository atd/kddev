%w(project session window).each do |file|
  require File.join(File.dirname(__FILE__), file)
end

module Kddev
  class Command
    def init
      puts Window.new.dbus_name
    end

    def projects
      puts Project.list
    end

    # See if there are missing jobs in all windows
    def jobs
      Session.all.each{ |s| s.exec("jobs") }
    end

    # Change all dev sessions to project
    def change(project)
      Session.all.each{ |r| r.change(Project.find!(project)) }
    end

    # Change current session to project
    def switch(project)
      Session.current.change(Project.find!(project))
    end

    # Help message
    def help
      puts <<-EOS
  Usage: dev <command> args

  Available commands:
  - change <project> - change all sessions to <project>
  - help             - this message
  - jobs             - show if there are background jobs in all sessions
  - switch <project> - change current session to <project>
  EOS
    end
  end
end

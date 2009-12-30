%w(project session window).each do |file|
  require File.join(File.dirname(__FILE__), file)
end

module Kddev
  class Command
    def projects
      puts Project.list
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
  - switch <project> - change current session to <project>
  EOS
    end
  end
end

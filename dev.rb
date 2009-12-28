# Konsole DBus Development Environment
#
# Installation
# - executable /usr/local/bin/dev with
#   #!/usr/bin/ruby1.8
#   load "path/to/dev.rb"
#
# - completion in .bash_completion
#   TODO: `dev __bash_completion__`
class Dev
  PATH = "~/dev"
  STATION_PATH = "vendor/plugins/station"

  def projects
    puts project_list
  end

  # Change all dev sessions to project
  def change(project)
    ensure_project_exists(project)

    dev_sessions.each{ |r| r.change(project) }
  end

  # Help message
  def help
    puts <<-EOS
Usage: dev <command> args

help: this message
EOS
  end

  private

  def project_list
    `ls #{ PATH }`
  end

  def ensure_project_exists(project)
    unless project_list =~ /^#{ project }$/
      puts "Unknown project #{ project }"
      exit
    end
  end

  # List of all konsole DevSession
  def all_sessions
    `qdbus org.kde.konsole`.each_line.select{ |l|
      l =~ /^\/Sessions\/\d+$/ }.map(&:chomp).map{ |name|
        DevSession.new name
      }
  end

  # List of development sessions
  def dev_sessions
    @dev_sessions ||= all_sessions.select{ |w| w.dev? }
  end
end

class DevSession
  DEV_PREFIX     = /^dev-\d+/
  STATION_PREFIX = /^dev-2/

  attr_reader :dbus_name

  def initialize(dbus_name)
    @dbus_name = dbus_name
  end

  def title
    `qdbus org.kde.konsole #{ dbus_name } org.kde.konsole.Session.title 1`.chomp
  end

  def dev?
    title =~ DEV_PREFIX
  end

  def station?
    title =~ STATION_PREFIX
  end

  def change(project)
    exec "cd #{ path(project) }"
  end

  def path(project)
    project_path = File.join(File.expand_path(Dev::PATH), project)

    if station?
      station_path = File.join(project_path, Dev::STATION_PATH)
      if File.exists?(station_path)
        project_path = station_path
      end
    end

    project_path
  end

  private

  def exec(text)
    `qdbus org.kde.konsole #{ dbus_name } org.kde.konsole.Session.sendText "#{ text + "\n" }"`
  end
end

dev = Dev.new

if ARGV.size == 0
  dev.help
  exit
end

cmd = ARGV.shift

case cmd
when '__bash_complete__'
  case ARGV.first
  when "dev"
    puts (dev.public_methods - Object.new.public_methods).join(" ")
  when "change"
    dev.projects
  else
    puts
  end
when '__bash_completion__'
  #TODO
  puts <<-EOS
function _dev_completion()
{
  local cur prev opts\n
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts=`dev __bash_complete__ ${prev}`

  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
  return 0
}

complete -F _dev_completion dev
EOS
else
  unless dev.respond_to?(cmd)
    puts "Unknown command #{ cmd }"
    puts
    dev_help
    exit
  end

  dev.send(cmd, *ARGV)
end

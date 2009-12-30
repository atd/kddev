# Konsole DBus Development Framework
module Kddev
  #TODO: this should be in a config file
  
  PATH = "~/dev"
  PREFIX = /^dev-\d+/

  STATION_PATH = "vendor/plugins/station"
  STATION_PREFIX = /^dev-2/
end

require File.join(File.dirname(__FILE__), 'kddev', 'command')

dev = Kddev::Command.new

if ARGV.size == 0
  dev.help
  exit(1)
end

cmd = ARGV.shift

case cmd
when '__bash_complete__'
  case ARGV.first
  when "dev"
    puts (dev.public_methods - Object.new.public_methods).join(" ")
  when "change", "switch"
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
    dev.help
    exit(1)
  end

  dev.send(cmd, *ARGV)
end

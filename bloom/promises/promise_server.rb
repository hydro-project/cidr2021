require 'bud'
require_relative 'promises_api'

class PServer 
  include Bud
  include PromiseServer

  def initialize(server, opts={})
    @server = server
  super opts
end
end

server = ARGV[0]
ip, port = server.split(":")
puts "Server address: #{server}"
program = PServer.new(server, :ip=>ip, :port=>port)
program.run_fg

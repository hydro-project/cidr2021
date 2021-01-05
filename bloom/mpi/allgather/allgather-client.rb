require 'rubygems'
require 'backports'
require 'bud'
require_relative 'allgather-test'

class Client
  include Bud
  include AllGatherTest

  def initialize(server, sender, num_receivers, id, opts={})
    @server = server
    $sender = sender.to_i
    $idx = id.to_i
    @num_receivers = num_receivers.to_i
    super opts
  end
end

server = ARGV[0]
sender = ARGV[1]
num_receivers = ARGV[2]
id = ARGV[3]
ip, port = server.split(":")
puts "Server address: #{server}"
program = Client.new(server, sender, num_receivers, id, :ip=>ip, :port=>port, :stdin => $stdin)
program.run_fg

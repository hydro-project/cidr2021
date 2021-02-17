require 'bud'
require_relative 'promises_api'
require 'securerandom'

class PClient 
  include Bud
  include PromiseClient

  def initialize(server, opts={})
    @server = server
    super opts
  end

  state do
    scratch :all_results, results.schema
  end
  bloom do :after_waiting
    all_results <= (results*done).pairs {|r, d| r }
    temp :the_sum <= all_results.group([], sum(all_results.result))
    stdio <~ the_sum {|s| ["All futures complete. Sum is #{s[0]}"]}
  end
end

server = ARGV[0]
ip, port = server.split(":")
puts "Server address: #{server}"
c = PClient.new(server)
c.tick
c.sync_do{
  c.promises <+ (1..4).to_a.map {|i| [server, c.ip_port, SecureRandom.uuid, 'lambda{|x| x**2}', i, c.budtime]}
}

c.run_fg
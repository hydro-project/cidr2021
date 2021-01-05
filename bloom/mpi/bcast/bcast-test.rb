require_relative 'bcast'

module BcastTest
  import Bcast => :s

  state do
    table :tmp
  end

  bootstrap do
    tmp <= [[0, "Broadcast"]]
    s.ips_bcast <+ [[0, "127.0.0.1:12346"], [1, "127.0.0.1:12347"], [2, "127.0.0.1:12348"]]
    s.sender <+ [[$sender]]
  end

  bloom do
    s.data_bcast <= tmp
    stdio <~ s.received_bcast.inspected
  end
end
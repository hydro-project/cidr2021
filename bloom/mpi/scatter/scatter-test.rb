require_relative 'scatter'

module ScatterTest
  import Scatter => :s

  state do
    table :tmp
  end

  bootstrap do
    tmp <= [[0, [2, 3, 4, 6, 7, 8, 4, 234, 65, 2, -3, 4]]]
    s.ips_scatter <+ [[0, "127.0.0.1:12346"], [1, "127.0.0.1:12347"], [2, "127.0.0.1:12348"]]
    s.sender <+ [[$sender]]
  end

  bloom do
    s.data_scatter <= tmp
    stdio <~ s.received_scatter.inspected
  end
end
require_relative 'allreduce'

module AllReduceTest
  import AllReduce => :s

  state do
    table :tmp
  end

  bootstrap do
    tmp <= [[0, [2, 3, 4, 6, 7]]]
    s.ips_reduce <+ [[0, "127.0.0.1:12345"], [1, "127.0.0.1:12346"], [2, "127.0.0.1:12347"], [3, "127.0.0.1:12348"]]
    s.ip_main <+ [[0, "127.0.0.1:12345"]]
    s.sender <+ [[$sender]]
    s.each_len <+ [[0, 5]]
    s.total_senders <+ [[3]]
    s.idx <+ [[$idx]]
  end

  bloom do
    s.data_reduce <= tmp
    stdio <~ s.received_reduce.inspected
  end
end
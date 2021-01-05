module Scatter
  state do
    table :loc_sender
    table :loc_ips_scatter
    table :loc_data_scatter

    table :ips_len
    interface input, :data_scatter
    interface input, :sender
    interface input, :ips_scatter
    interface output, :received_scatter
    channel :message_func_scatter, [:@addr, :id] => [:val]
    periodic :timer, 1
  end

  bootstrap do

  end

  bloom do
      loc_sender <= sender
      loc_ips_scatter <= ips_scatter
      loc_data_scatter <= data_scatter

      ips_len <= ips_scatter.group([], count())
      message_func_scatter <~ (loc_ips_scatter * ips_len * loc_data_scatter * loc_sender * timer).combos {|i, l, d, s, t| [i.val, d.key, d.val[(d.val.length()/l.key)*i.key..(d.val.length()/l.key)*(i.key + 1)-1]] if s.key > 0}
      received_scatter <= message_func_scatter {|m| [m.id, m.val]}
  end
end
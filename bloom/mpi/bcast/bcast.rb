module Bcast
  state do
    table :loc_sender
    table :loc_ips_bcast
    table :loc_data_bcast

    interface input, :data_bcast
    interface input, :sender
    interface input, :ips_bcast
    interface output, :received_bcast
    channel :message_func_bcast, [:@addr, :id] => [:val]
    periodic :timer, 1
  end

  bootstrap do

  end

  bloom do
      loc_sender <= sender
      loc_ips_bcast <= ips_bcast
      loc_data_bcast <= data_bcast

      message_func_bcast <~ (loc_ips_bcast * loc_data_bcast * loc_sender * timer).combos {|i, d, s, t| [i.val, d.key, d.val] if s.key > 0}
      received_bcast <= message_func_bcast {|m| [m.id, m.val]}
  end
end
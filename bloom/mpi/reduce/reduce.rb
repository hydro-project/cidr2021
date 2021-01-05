module Reduce
  state do
    table :loc_sender
    table :loc_ips_reduce
    table :loc_data_reduce
    table :loc_each_len
    table :loc_total_senders
    table :loc_idx
    scratch :sink

    table :ips_len
    interface input, :data_reduce
    interface input, :sender
    interface input, :ips_reduce
    interface input, :each_len
    interface input, :total_senders
    interface input, :idx

    interface output, :received_reduce
    table :received_buffer
    channel :message_func_reduce, [:@addr, :id, :idx] => [:val]
    periodic :timer, 20
  end

  bloom do
      loc_sender <= sender
      loc_ips_reduce <= ips_reduce
      loc_data_reduce <= data_reduce
      loc_each_len <= each_len
      loc_total_senders <= total_senders
      loc_idx <= idx
      received_buffer <= (loc_each_len * loc_total_senders).pairs {|e, t| [e.key, [Array.new(e.val, 0), 0]]}

      message_func_reduce <~ (loc_ips_reduce * loc_each_len * loc_data_reduce * loc_sender * loc_idx * timer).combos {|i, l, d, s, idx, t| [i.val, d.key, idx.key, d.val] if (s.key > 0 and l.key == d.key) }
      sink <+ (received_buffer * message_func_reduce * loc_each_len).combos {|r, m, l| [r.key, modify_val(r.val, m.idx, l.val, m.val)] if l.key == m.id and r.key == l.key}

      received_reduce <= (received_buffer * loc_total_senders * sink).pairs {|r, t, s| [r.key, r.val[0]] if r.val[1] == t.key}
  end

  def modify_val(arr, idx, l, arr_to_add)
    arr[0] = [arr[0], arr_to_add].transpose.map {|x| x.reduce(:+)}
    arr[1] += 1
    return arr
  end

  def set_range(arr, idx, l, arr_to_add)
    arr[(idx*l)..((idx+1)*l-1)] = arr_to_add
    return arr
  end
end
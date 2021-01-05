module AllReduce
  state do
    table :loc_sender
    table :loc_ips_reduce
    table :loc_ip_main
    table :loc_data_reduce
    table :loc_each_len
    table :loc_total_senders
    table :loc_idx
    scratch :sink

    table :ips_len
    interface input, :data_reduce
    interface input, :sender
    interface input, :ips_reduce
    interface input, :ip_main
    interface input, :each_len
    interface input, :total_senders
    interface input, :idx

    interface output, :received_reduce
    table :received_buffer
    channel :message_func_reduce, [:@addr, :id, :idx] => [:val]
    scratch :broadcast_result_self, [:id] => [:val]
    channel :broadcast_result, [:@addr, :id] => [:val]
    periodic :timer, 2
  end

  bloom do
      loc_sender <= sender
      loc_ips_reduce <= ips_reduce
      loc_ip_main <= ip_main
      loc_data_reduce <= data_reduce
      loc_each_len <= each_len
      loc_total_senders <= total_senders
      loc_idx <= idx
      received_buffer <= (loc_each_len * loc_total_senders).pairs {|e, t| [e.key, [Array.new(e.val, 0), 0]]}

      message_func_reduce <~ (loc_ip_main * loc_each_len * loc_data_reduce * loc_sender * loc_idx * timer).combos {|i, l, d, s, idx, t| [i.val, d.key, idx.key, d.val] if (s.key > 0 and l.key == d.key) }
      sink <+ (received_buffer * message_func_reduce * loc_each_len * loc_total_senders).combos {|r, m, l, s| [r.key, 1] if l.key == m.id and r.key == l.key and modify_val(r.val, m.idx, l.val, m.val, s.key) }

      broadcast_result <~ (received_buffer * loc_total_senders * sink * loc_ips_reduce).pairs { |r, t, s, i| [i.val, r.key, r.val[0]] }
      received_reduce <= broadcast_result {|b| [b.id, b.val]}
  end

  def modify_val(arr, idx, l, arr_to_add, senders)
    arr[0] = [arr[0], arr_to_add].transpose.map {|x| x.reduce(:+)}
    arr[1] += 1
    if (arr[1] == senders)
      arr[1] += 1 # prevent issues
      return true
    end
    return false
  end

  def val_done(arr)
    arr[1] += 1
    return true
  end

  def set_range(arr, idx, l, arr_to_add)
    arr[(idx*l)..((idx+1)*l-1)] = arr_to_add
    return arr
  end
end
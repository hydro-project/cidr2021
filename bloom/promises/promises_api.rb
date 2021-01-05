require 'securerandom'

module PromiseServerAPI
  state do
    channel :promise_in,  [:@addr, :from, :handle, :func, :args, :timestamp]
    channel :promise_out, [:@addr, :handle, :result, :timestamp]
  end
end

module PromiseServer
  include PromiseServerAPI

  state do
    table :buf, [:addr, :from, :handle] => [:func, :args, :timestamp, :countdown]
    periodic :timer, 0.1
  end

  bloom do
    buf <= promise_in{|p| p + [rand(4)]}
    stdio <~ promise_in {|p| ["received " + p.to_s]}
    promise_out <~ buf { |p| 
      if p.countdown == 0 then
        f = eval(p.func)
        [p.from, p.handle, f.call(p.args), p.timestamp]
      end
    }
    buf <+- (timer*buf).pairs{|p, b| [b.addr, b.from, b.handle, b.func, b.args, b.timestamp, b.countdown - 1]}
  end
end

module PromiseClient
  include PromiseServerAPI

  state do
    interface input, :promises, promise_in.schema
    table :vars
    table :futures, [:handle, :timestamp]
    table :results, promise_out.schema
    scratch :done, [:flag]
  end

  bootstrap do
    vars <+ [[:waiting, false]]
  end

  bloom do
    futures <= promises{|p| [p.handle, budtime()]}
    vars <+- promises{|p| [:waiting, true]}
    promise_in <~ promises{|p| p}
    results <= promise_out

    done <= promise_out {|p| [true] if results.length == futures.length}
    vars <+- done {|d| [:waiting, false] }
    stdio <~ (results*done).pairs {|r,d| [r.to_s] }
    futures <- (futures*done).pairs {|f, d| f }
    results <- (results*done).pairs {|r, d| r }
  end
end
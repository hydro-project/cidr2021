require 'bud'
require_relative 'actor_api'

class MidMethodActorClass
    include Bud
    include MidMethodActor

  	def m_pre(msg)
		fiber = Fiber.new do
	  		x = 1*2*3
	  		y = "Product of first 6 primes is: "
	  		Fiber.yield x
     		x = x * 5 * 7 * 11
	  		"#{y}#{x}"
		end
		fiber.resume # run until the first yield
		fiber
	end

	def m_post(m_state, newmsg)
		finish = m_state.resume # run from the yield onwards
		"#{newmsg}: #{finish}" 
	end
end

m = MidMethodActorClass.new
m.sync_do{ m.mymethod <+ [[0, 'msg']]}
m.sync_do{ m.mybox <+ [[0, 1, 'Success']]}
require 'bud'

module MidMethodActor
	state do
		table :actors, [:actor_id] => [:state, :waiting]
		interface input, :mymethod, [:actor_id, :from, :msg]
		interface input, :mybox, [:actor_id, :from, :msg]
		interface output, :result, [:val]
	end

	bloom do :mymethod_handler
		actors <+- mymethod{|m| [m.actor_id, m_pre(m.msg), true]}
	end

	bloom do :mybox_handler
		result <= (mybox*actors).pairs(:actor_id => :actor_id){|m,a| [m_post(a.state, m.msg)]}
		actors <- (mybox*actors).pairs(:actor_id => :actor_id){|m,a| a}
		stdio <~ result.inspected
	end
end

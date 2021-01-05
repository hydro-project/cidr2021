require 'bud'
require_relative 'example_api'

def to_lbool(b) 
  return b if b.is_a?(Bud::BoolLattice)
  Bud::BoolLattice.new(b) 
end

def to_lset(s)
  return s if s.is_a?(Bud::SetLattice)
  Bud::SetLattice.new(s) 
end

class CIDR21Example
  include Bud
  include CIDR21ExampleAPI

  state do 
    table :people, [:pid] => [:country, :contacts, :covid, :vaccinated] 
    scratch :people_alert, people.schema()
    table :vars
    scratch :nested_pairs, [:origin, :pid] => [:country, :contacts, :covid, :vaccinated]
    scratch :tr_in, [:origin]
    scratch :transitive, [:origin, :pid]
  end

  bootstrap do
    vars <+ [[:covid_vaccine, 0]]
  end

  require_relative './covid_model'
  bloom do :handlers
    # add_person
    people <= add_person_in{|a| 
      [a.pid, a.country, a.contacts, a.covid, a.vaccinated]
    }
    add_person_out <= add_person_in{|a| [a.rid]}
    
    # add_contact
    people <= (add_contact_in*people).pairs(:from=>:pid) {|a,p| 
      [p.pid, p.country, to_lset([a.to]), p.covid, p.vaccinated]
    }
    people <= (add_contact_in*people).pairs(:to=>:pid) {|a,p| 
      [p.pid, p.country, to_lset([a.from]), p.covid, p.vaccinated]
    }
    add_contact_out <= add_contact_in{|a| [a.rid]}

    # trace / transitive
    tr_in <= trace_in{|t| [t.pid]}
    nested_pairs <= (tr_in*people).pairs(:origin=>:pid){|t,p| 
      [t.origin] + p
    }
    nested_pairs <= (transitive*people).pairs(:pid=>:pid){|t,p| 
      [t.origin] + p
    }
    transitive <= nested_pairs.flat_map{|tp| 
      tp.contacts.reveal().map{|s| [tp.origin, s]}
    }
    trace_out <= (trace_in*transitive).pairs{|i,o| [i.rid] + o}

    # diagnosed
    people <= (diagnosed_in*people).pairs(:pid=>:pid){|d,p| 
      [p.pid, p.country, p.contacts, to_lbool(true), p.vaccinated]
    }
    people_alert <= (diagnosed_in*people).pairs(:pid=>:pid){|d,p| 
      [p.pid, p.country, p.contacts, to_lbool(true), p.vaccinated]
    }
    diagnosed_out <= diagnosed_in{|p| [p.rid]}
    alert <= people_alert.inspected()

    # likelihood
    likelihood_out <= (likelihood_in*people).pairs(:pid=>:pid) {|l,p| 
      [l.rid, covid_xmission_model(p.contacts)]
    }

    # vaccinate
    people <= (vax_in*people).pairs(:pid=>:pid){|v,p| 
      [p.pid, p.country, p.contacts, p.covid, to_lbool(true)]
    }
    vars <+- (vax_in*vars).pairs{|i,v| 
      [v.key, v.val-1] if v.key == :covid_vaccine
    }
    vax_out <= vax_in{|v|[v.rid]}
  end
end

 module CIDR21ExampleAPI
  state do
    interface :in, :add_person_in, [:rid] => [:pid, :country, :contacts, :covid, :vaccinated]
    interface :out, :add_person_out, [:rid]
    interface :in, :diagnosed_in, [:rid] => [:pid]
    interface :in, :diagnosed_out, [:rid]
    interface :in, :add_contact_in, [:rid] => [:from, :to]
    interface :in, :add_contact_out, [:rid]
    interface :in, :likelihood_in, [:rid] => [:pid]
    interface :out, :likelihood_out, [:rid] => [:likelihood]
    interface :in, :trace_in, [:rid] => [:pid]
    interface :out, :trace_out, [:rid, :from, :to]
    interface :in, :vax_in, [:rid] => [:pid]
    interface :out, :vax_out, [:rid]
    interface :out, :alert
  end
end

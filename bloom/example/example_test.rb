require_relative './example'

c = CIDR21Example.new
c.sync_do{
    c.people <+ [[1, 'USA', to_lset([2,3]), to_lbool(true), to_lbool(false)],
                 [2, 'USA', to_lset([1,4]), to_lbool(false), to_lbool(false)],
                 [3, 'USA', to_lset([1,4]), to_lbool(false), to_lbool(false)],
                 [4, 'USA', to_lset([2,3]), to_lbool(false), to_lbool(false)],
                 [5, 'FR', to_lset([6]), to_lbool(false), to_lbool(false)],
                 [6, 'FR', to_lset([5]), to_lbool(false), to_lbool(false)]]
}
c.sync_do {
  puts c.people.inspected
}
c.sync_do{
  c.add_person_in <+ [['apin1', 7, 'FR', Bud::SetLattice.new, to_lbool(false), to_lbool(false)]]
}
c.sync_do{
  c.add_contact_in <+ [['acin1', 7, 5]]
}
c.sync_do{
  puts c.people.inspected
}
c.sync_do{
  c.diagnosed_in <+[['din1', 7]]
}
c.sync_do{
  c.likelihood_in <+ [['lin1', 2]]
}
c.sync_do{
  puts c.likelihood_out.inspected
}
c.sync_do{
  c.trace_in <+ [['tin1', 1]] 
}
c.sync_do{
  puts c.trace_out.inspected
}
c.sync_do {
  c.vars <+- [[:covid_vaccine, 100]]
}
c.sync_do{
  c.vars{|v| puts v.to_s if v[0] == :covid_vaccine}
}
c.sync_do{
  c.vax_in <+ [['vaxin1', 1]]
}
c.tick
c.sync_do{
  c.vars{|v| puts v.to_s if v[0] == :covid_vaccine}
}
c.tick
c.sync_do{
  puts c.people.inspected
  puts c.vars.inspected
}
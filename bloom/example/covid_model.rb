  def covid_xmission_model(contacts)
    s = people.sum {|p| 
      (contacts.reveal.include?(p.pid) and p.covid.reveal) ? 1 : 0
    }
    return s/contacts.reveal.length
  end
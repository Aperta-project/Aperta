class AdminJournalPage < Page
  def logo
    dtdds = all('dt, dd').to_a.in_groups_of(2)
    _, dd = dtdds.detect { |dtdd| dtdd.first.text == 'Logo' }
    dd.find('img')['src']
  end
end

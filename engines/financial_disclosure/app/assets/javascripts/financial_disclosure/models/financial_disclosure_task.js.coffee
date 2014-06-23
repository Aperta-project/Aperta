ETahi.FinancialDisclosureTask = ETahi.Task.extend
  funders: DS.hasMany('funder')
  authors: (->
    @get('store').all('author').filter (author) =>
      author.get('authorGroup.paper.id') == @get('litePaper.id')
  ).property('paper')

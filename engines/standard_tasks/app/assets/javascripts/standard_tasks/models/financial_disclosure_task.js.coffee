ETahi.FinancialDisclosureTask = ETahi.Task.extend
  funders: DS.hasMany('funder')
  authors: (->
    @get('store').all('author').filter (author) =>
      author.get('authorGroup.paper.id') == @get('litePaper.id')
  ).property('litePaper')
  authorsTask: (->
    @get('store').all('authors-task').filter((task) =>
      task.get('litePaper.id') == @get('litePaper.id')
    ).get('firstObject')
  ).property('litePaper')

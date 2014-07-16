a = DS.attr
ETahi.LitePaper = DS.Model.extend
  paper: DS.belongsTo('paper')
  flow: DS.belongsTo('flow')

  title: a('string')
  shortTitle: a('string')
  submitted: a('boolean')
  role: a('string')
  displayTitle: (->
    @get('title') || @get('shortTitle')
  ).property 'title', 'shortTitle'

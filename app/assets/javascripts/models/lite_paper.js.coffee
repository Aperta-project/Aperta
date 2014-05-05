a = DS.attr
ETahi.LitePaper = DS.Model.extend
  paper: DS.belongsTo('paper')
  title: a('string')
  shortTitle: a('string')
  flow: DS.belongsTo('flow')
  submitted: a('boolean')
  displayTitle: (->
    @get('title') || @get('shortTitle')
  ).property 'title', 'shortTitle'

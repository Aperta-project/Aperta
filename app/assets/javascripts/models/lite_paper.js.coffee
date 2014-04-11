a = DS.attr
ETahi.LitePaper = DS.Model.extend
  paper: DS.belongsTo('paper')
  title: a('string')
  shortTitle: a('string')
  flow: DS.belongsTo('flow')
  displayTitle: (->
    @get('title') || @get('shortTitle')
  ).property 'title', 'shortTitle'

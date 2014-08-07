a = DS.attr
ETahi.LitePaper = DS.Model.extend
  paper: DS.belongsTo('paper')
  flow: DS.belongsTo('flow')

  title: a('string')
  shortTitle: a('string')
  submitted: a('boolean')
  roles: a()

  displayTitle: (->
    @get('title') || @get('shortTitle')
  ).property 'title', 'shortTitle'

  roleList: (->
    @get('roles').sort().join(', ')
  ).property('roles.@each', 'roles.[]')

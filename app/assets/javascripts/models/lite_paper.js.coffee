a = DS.attr
ETahi.LitePaper = DS.Model.extend
  flow: DS.belongsTo('flow')
  paper: DS.belongsTo('paper')

  title: a('string')
  shortTitle: a('string')
  submitted: a('boolean')
  relatedAtDate: a('date')
  roles: a()
  unreadCommentsCount: a('number')

  displayTitle: (->
    @get('title') || @get('shortTitle')
  ).property 'title', 'shortTitle'

  roleList: (->
    @get('roles').sort().join(', ')
  ).property('roles.@each', 'roles.[]')

a = DS.attr
ETahi.LitePaper = DS.Model.extend
  flow: DS.belongsTo('flow')

  title: a('string')
  shortTitle: a('string')
  submitted: a('boolean')
  relatedAtDate: a('date')
  roles: a()
  unreadCommentsCount: a('number')
  editable: a('boolean')

  displayTitle: (->
    @get('title') || @get('shortTitle')
  ).property 'title', 'shortTitle'

  roleList: (->
    @get('roles').sort().join(', ')
  ).property('roles.@each', 'roles.[]')

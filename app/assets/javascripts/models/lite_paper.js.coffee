a = DS.attr
ETahi.LitePaper = DS.Model.extend
  title: a('string')
  shortTitle: a('string')
  submitted: a('boolean')
  relatedAtDate: a('date')
  roles: a()

  displayTitle: (->
    @get('title') || @get('shortTitle')
  ).property 'title', 'shortTitle'

  roleList: (->
    @get('roles').sort().join(', ')
  ).property('roles.@each', 'roles.[]')

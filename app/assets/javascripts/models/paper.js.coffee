a = DS.attr
ETahi.Paper = DS.Model.extend
  shortTitle: a('string')
  title: a('string')
  assignees: DS.hasMany('assignee')
  phases: DS.hasMany('phase')
  declarations: DS.hasMany('declaration')
  displayTitle: (->
    if @get('title.length') > 0
      @get('title')
    else
      @get 'shortTitle'
  ).property 'title', 'shortTitle'

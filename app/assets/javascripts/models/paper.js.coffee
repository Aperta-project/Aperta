a = DS.attr
ETahi.Paper = DS.Model.extend
  shortTitle: a('string')
  title: a('string')
  assignees: DS.hasMany('assignee')
  phases: DS.hasMany('phase')

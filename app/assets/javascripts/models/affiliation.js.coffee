a = DS.attr
ETahi.Affiliation = DS.Model.extend
  user: DS.belongsTo('user')
  name: a('string')
  endDate: a('string')
  startDate: a('string')

a = DS.attr
ETahi.Affiliation = DS.Model.extend
  user: DS.belongsTo('user')
  name: a('string')
  endDate: a('string')
  startDate: a('string')
  email: a('string')

  isCurrent: ( ->
    Ember.isBlank(@get('endDate'))
  ).property('endDate')

  displayEndDate: (->
    @get('endDate') || "Current"
  ).property('endDate')

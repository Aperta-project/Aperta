a = DS.attr
ETahi.User = DS.Model.extend
  imageUrl: a('string')
  fullName: a('string')

ETahi.Assignee = ETahi.User.extend()

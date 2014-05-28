a = DS.attr
ETahi.Survey = DS.Model.extend
  declarationTask: DS.belongsTo('declarationTask')
  answer: a('string')
  question: a('string')

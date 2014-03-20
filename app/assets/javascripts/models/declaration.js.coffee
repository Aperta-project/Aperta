a = DS.attr
ETahi.Declaration = DS.Model.extend
  paper: DS.belongsTo('paper')
  question: a('string')
  answer: a('string')

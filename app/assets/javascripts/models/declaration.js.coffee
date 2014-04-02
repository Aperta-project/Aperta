a = DS.attr
ETahi.Declaration = DS.Model.extend
  paper: DS.belongsTo('paper')
  answer: a('string')
  question: a('string')

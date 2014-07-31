a = DS.attr
ETahi.QuestionAttachment = DS.Model.extend
  question: DS.belongsTo('question')
  title: a('string')
  status: a('string')
  filename: a('string')
  src: a('string')

import DS from 'ember-data';

export default DS.Model.extend({
  attachments: DS.hasMany('question-attachment', { async: false, inverse: 'nestedQuestionAnswer' }),
});

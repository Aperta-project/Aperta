import DS from 'ember-data';

export default DS.Model.extend({
  attachment: DS.belongsTo('question-attachment', { async: false, inverse: 'nestedQuestionAnswer' })
});

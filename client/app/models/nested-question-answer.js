import DS from 'ember-data';

export default DS.Model.extend({
  owner: DS.belongsTo('nested-question-owner', {
    polymorphic: true,
    async: false,
    inverse: 'nestedQuestionAnswers'
  }),
  nestedQuestion: DS.belongsTo('nested-question', { async: false, inverse: 'answers' }),
  value: DS.attr(),
  additionalData: DS.attr(),
  createdAt: DS.attr('date'),
  updatedAt: DS.attr('date'),
});

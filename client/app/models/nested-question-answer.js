import DS from 'ember-data';
import QuestionAttachmentOwner from 'tahi/models/question-attachment-owner';

export default QuestionAttachmentOwner.extend({
  owner: DS.belongsTo('nested-question-owner', {
    polymorphic: true,
    async: false,
    inverse: 'nestedQuestionAnswers'
  }),
  nestedQuestion: DS.belongsTo('nested-question', { async: false, inverse: 'answers' }),
  value: DS.attr(),
  additionalData: DS.attr(),
  url: DS.attr('string'),
  createdAt: DS.attr('date'),
  updatedAt: DS.attr('date')
});

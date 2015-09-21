import DS from 'ember-data';
import QuestionAttachmentOwner from 'tahi/models/question-attachment-owner';

export default QuestionAttachmentOwner.extend({
  decision: DS.belongsTo('decision', { async: false }),
  task: DS.belongsTo('task', {
    polymorphic: true,
    inverse: 'questions',
    async: false
  }),

  additionalData: DS.attr(),
  answer: DS.attr('string'),
  createdAt: DS.attr('date'),
  ident: DS.attr('string'),
  question: DS.attr('string'),
  updatedAt: DS.attr('date'),
  url: DS.attr('string')
});

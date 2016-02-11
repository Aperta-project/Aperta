import Ember from 'ember';
import DS from 'ember-data';
import QuestionAttachmentOwner from 'tahi/models/question-attachment-owner';

export default QuestionAttachmentOwner.extend({
  decision: DS.belongsTo('decision', { async: true }),
  owner: DS.belongsTo('nested-question-owner', {
    polymorphic: true,
    async: true,
    inverse: 'nestedQuestionAnswers'
  }),
  nestedQuestion: DS.belongsTo('nested-question', {
    async: true,
    inverse: 'answers'
  }),
  value: DS.attr(),
  additionalData: DS.attr(),
  createdAt: DS.attr('date'),
  updatedAt: DS.attr('date'),

  wasAnswered: Ember.computed('value', function(){
    return Ember.isPresent(this.get('value')) || this.get('value') === false;
  })
});

import Ember from 'ember';
import DS from 'ember-data';
import QuestionAttachmentOwner from 'tahi/models/question-attachment-owner';

export default QuestionAttachmentOwner.extend({
  wasAnswered: Ember.computed(function(){
    let value = this.get("value");
    return value || value === false;
  }),
  owner: DS.belongsTo('nested-question-owner', {
    polymorphic: true,
    async: false,
    inverse: 'nestedQuestionAnswers'
  }),
  nestedQuestion: DS.belongsTo('nested-question', { async: false, inverse: 'answers' }),
  value: DS.attr(),
  valueType: DS.attr("string"),
  additionalData: DS.attr(),
  createdAt: DS.attr('date'),
  updatedAt: DS.attr('date'),

  isBoolean: Ember.computed("valueType", function(){
    return this.get("valueType") === "boolean";
  })
});

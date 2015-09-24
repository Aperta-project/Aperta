import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  owner: DS.belongsTo('nested-question-owner', {
    polymorphic: true,
    async: false,
    inverse: 'nestedQuestions'
  }),

  task: Ember.computed("owner", function(){
    return this.get("owner");
  }),

  ident: DS.attr('string'),
  position: DS.attr('number'),
  value_type: DS.attr('string'),
  createdAt: DS.attr('date'),
  updatedAt: DS.attr('date'),

  text: DS.attr('string'),
  children: DS.hasMany('nested-question', { async: false, inverse: 'parent' }),
  parent: DS.belongsTo('nested-question', { async: false }),
  answers: DS.hasMany('nested-question-answer', { async: false , inverse: 'nestedQuestion'}),

  answerForOwner: function(owner){
    let ownerId = owner.get("id");
    let answer = this.get('answers').findBy('owner.id', ownerId);

    if(!answer){
      answer = this.store.createRecord('nested-question-answer', {
        nestedQuestion: this,
        owner: owner
      });
      this.get('answers').addObject(answer);
    }

    return answer;
  }

});

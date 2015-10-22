import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  owner: Ember.computed("owner", function(){
    return this.get("owner");
  }),

  ident: DS.attr('string'),
  position: DS.attr('number'),
  value_type: DS.attr('string'),
  createdAt: DS.attr('date'),
  updatedAt: DS.attr('date'),
  additional_data: DS.attr('string'),

  text: DS.attr('string'),
  children: DS.hasMany('nested-question', { async: false, inverse: 'parent' }),
  parent: DS.belongsTo('nested-question', { async: false }),
  answers: DS.hasMany('nested-question-answer', { async: false , inverse: 'nestedQuestion'}),

  answerForOwner: function(owner, decision){
    let ownerId = owner.get("id");
    let answer = this.get("answers").toArray().find(function(answer){
      let answerOwnerId = answer.get("owner.id") || answer.get("data.owner.id");
      let matched = Ember.isEqual(parseInt(answerOwnerId), parseInt(ownerId));
      if(decision){
        matched = matched && Ember.isEqual(parseInt(answer.get("decision.id")), parseInt(decision.get("id")));
      }

      matched = matched && !answer.get("isDeleted");
      return matched;
    });

    if(!answer){
      answer = this.store.createRecord('nested-question-answer', {
        nestedQuestion: this,
        owner: owner,
        decision: decision
      });
    }

    return answer;
  },

  clearAnswerForOwner: function(owner){
    let answer = this.answerForOwner(owner);
    if(answer){
      answer.rollback();
    }
  }

});

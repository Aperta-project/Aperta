import Ember from 'ember';

export default Ember.ObjectProxy.extend({
  init: function(){
    let nestedQuestion = this.get("nestedQuestion");

    if(this.constructor === nestedQuestion.constructor){
      nestedQuestion = nestedQuestion.get("content");
      this.set("nestedQuestion", nestedQuestion);
    }

    Ember.assert("Must have provided nestedQuestion when creating this object", nestedQuestion);
    Ember.assert("Must have provided owner when creating this object", this.get('owner'));
    this.set('content', nestedQuestion);
  },

  answer: Ember.computed('nestedQuestion', 'owner', function(){
    let nestedQuestion = this.get("nestedQuestion");
    let owner = this.get("owner");
    let decision = this.get("decision");

    if(nestedQuestion){
      return nestedQuestion.answerForOwner(owner, decision);
    }
  })
});

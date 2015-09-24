import Ember from 'ember';

export default Ember.ObjectProxy.extend({
  init: function(){
    Ember.assert("Must have provided nestedQuestion when creating this object", this.get('nestedQuestion'));
    Ember.assert("Must have provided owner when creating this object", this.get('owner'));
    this.set('content', this.get('nestedQuestion'));
  },

  answer: Ember.computed('nestedQuestion', 'owner', function(){
    let nestedQuestion = this.get("nestedQuestion");
    let owner = this.get("owner");
    return nestedQuestion.answerForOwner(owner);
  })
});

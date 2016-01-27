import Ember from 'ember';

export default Ember.ObjectProxy.extend({
  nestedQuestion: null,
  owner: null,
  decision: null,

  init: function(){
    Ember.assert(
      'Must have provided nestedQuestion when creating this object',
      this.get('nestedQuestion')
    );
    Ember.assert(
      'Must have provided owner when creating this object',
      this.get('owner')
    );

    this.set('content', this.get('nestedQuestion'));
    this.set('answer', this._loadAnswer());
  },

  refreshAnswer: Ember.observer('answer.isDeleted', function(){
    const answer = this.get('answer');
    if(answer && answer.get('isDeleted')){
      this.set('answer', this._loadAnswer());
    }
  }),

  _loadAnswer: function(){
    const nestedQuestion = this.get('nestedQuestion');
    const owner = this.get('owner');

    // decision may be null, that's okay
    const decision = this.get('decision');

    return nestedQuestion.answerForOwner(owner, decision);
  }
});

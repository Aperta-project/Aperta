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

    // get 'answer.isDeleted' in order to have it be properly observed.
    // https://guides.emberjs.com/v2.10.0/object-model/observers/#toc_unconsumed-computed-properties-do-not-trigger-observers
    // this may be a subtlety with http://emberjs.com/blog/2015/09/02/ember-data-2-0-released.html#toc_unsaved-deleted-records,
    // whereby records that are marked deleted are no longer automatically removed from DS.model relationships.
    // it's possible that previously `.isDeleted` was consumed internally by those mechanics, but as of now that property on the
    // answer is never consumed anywhere else so we have to do it here.
    this.get('answer.isDeleted');
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

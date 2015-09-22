import Ember from 'ember';

export default Ember.Controller.extend({
  selectBoxSelection: null,
  actions: {
    clearSelectBoxSelection() {
     this.set('selectBoxSelection', null);
    },
    selectSelectBoxSelection(selection) {
      this.set('selectBoxSelection', selection);
    }
  },

  nestedQuestionOwner: Ember.computed(function(){
    let owner = this.store.createRecord('nested-question-owner');
    let fooQuestion = this.store.createRecord('nested-question', {
      ident: 'foo',
      value_type: 'text',
      text: "What's your name?"
    });
    let booleanQuestion = this.store.createRecord('nested-question', {
      ident: 'booleanFoo',
      value_type: 'boolean',
      text: 'Yes or no?'
    });

    owner.get('nestedQuestions').pushObject(fooQuestion);
    owner.get('nestedQuestions').pushObject(booleanQuestion);
    return owner;
  }),

  fooQuestion: Ember.computed(function(){
    return this.get('nestedQuestionOwner').findQuestion('foo');
  })
});

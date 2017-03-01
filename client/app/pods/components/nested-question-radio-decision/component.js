import CardContentQuestion from
  'tahi/pods/components/card-content-question/component';

export default CardContentQuestion.extend({
  helpText: null,
  unwrappedHelpText: null,

  namePrefix: Ember.computed(function(){
    return `${this.elementId}-${this.get('ident')}`;
  }),

  actions: {
    setAnswer(decision) {
      this.set('answer.value', decision);
    }
  }
});

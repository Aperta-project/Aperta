import CardContentQuestion from
  'tahi/pods/components/card-content-question/component';
import Ember from 'ember';

export default CardContentQuestion.extend({
  helpText: null,
  unwrappedHelpText: null,
  displayContent: true,
  inputClassNames: ['form-control'],

  input() {
    this.save();
  },

  change() {
    return false; // no-op to override parent's behavior
  },

  clearHiddenQuestions: Ember.observer('displayContent', 'disabled', function() {
    if (!this.get('disabled') && !this.get('displayContent')) {
      this.set('answer.value', '');
      this.get('answer').save();
    }
  })
});

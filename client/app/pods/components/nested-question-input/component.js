import Ember from 'ember';
import CardContentQuestion from
  'tahi/pods/components/card-content-question/component';

export default CardContentQuestion.extend({
  defaultAnswer: null,
  setAnswer: Ember.on('init',
      function() {
        if (this.get('defaultAnswer')) {
          this.set('answer.value', this.get('defaultAnswer'));
        }
      }),
  classNameBindings: [
    ':nested-question',
    'errorPresent:error' // errorPresent defined in NestedQuestionComponent
  ],
  displayContent: true,
  formatted: false,
  inputClassNames: ['form-control tall-text-field'],
  type: 'text',
  clearHiddenQuestions: Ember.observer('displayContent', function() {
    if (!this.get('displayContent')) {
      this.set('answer.value', '');
      this.get('answer').save();
    }
  }),

  init() {
    const allowedTypes = ['text', 'number'];
    const type = this.get('type');
    // restrict type due to the input event. Ironically, it seems that not all inputs emit it.
    Ember.assert(`nested-question-input doesn't support type "${type}"`, allowedTypes.includes(type));
    return this._super(...arguments);
  },

  input() {
    this.save();
  },

  change() {
    return false; // no-op to override parent's behavior
  }
});

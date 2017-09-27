import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

let childAt = function(key, position) {
  return Ember.computed(`${key}.[]`, function() {
    return this.get(key).objectAt(position);
  });
};

export default Ember.Component.extend({

  propTypes: {
    answer: PropTypes.EmberObject.isRequired,
    content: PropTypes.EmberObject.isRequired,
    owner: PropTypes.EmberObject.isRequired,
    repetition: PropTypes.EmberObject.isRequired,
    answerChanged: PropTypes.any.isRequired
  },

  classNames: ['card-content', 'card-content-sendback-reason'],

  shouldHide: Ember.observer('checkboxAnswer.value', function() {
    Ember.run.once(this, 'revertChildrenAnswers');
  }),

  revertChildrenAnswers() {
    if (!this.get('checkboxAnswer.value')) {
      this.get('textareaAnswer').set('value', this.get('textarea.defaultAnswerValue'));
    }
  },

  checkboxAnswer: Ember.computed('checkbox', 'owner', 'repetition', function(){
    return this.get('checkbox').answerForOwner(this.get('owner'), this.get('repetition'));
  }),

  pencilAnswer: Ember.computed('pencil', 'owner', 'repetition', function(){
    return this.get('pencil').answerForOwner(this.get('owner'), this.get('repetition'));
  }),

  textareaAnswer: Ember.computed('textarea', 'owner', 'repetition', function(){
    return this.get('textarea').answerForOwner(this.get('owner'), this.get('repetition'));
  }),

  checkbox: childAt('content.children', 0),
  pencil: childAt('content.children', 1),
  textarea: childAt('content.children', 2),
  showText: Ember.computed(
    'checkboxAnswer.value',
    'pencilAnswer.value',
    function() {
      return this.get('checkboxAnswer.value') && this.get('pencilAnswer.value');
    }
  ),
  actions: {
    toggleAnswer(answer) {
      answer.toggleProperty('value');
      if (this.get('preview')) {return Ember.RSVP.resolve();}
      return answer.save();
    }
  }

});

import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-tech-check'],
  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    answer: PropTypes.EmberObject.isRequired,
    preview: PropTypes.bool
  },

  clearSendbacks() {
    let sendbackAnswers = this.get('content.children').map((sendbackContent) => {
      let checkbox = sendbackContent.get('children.firstObject');
      return checkbox.answerForOwner(this.get('owner'));
    });

    sendbackAnswers.setEach('value', false);
    if (!this.get('preview')) {
      //TODO: filter to only save changed answers
      sendbackAnswers.invoke('save');
    }
  },

  actions: {
    sendbackChanged(sendbackAnswer) {
      let techCheckAnswer = this.get('answer');
      if (sendbackAnswer.get('value') === true) {
        techCheckAnswer.set('value', false);
      }
    },
    saveAnswer(newVal) {
      let action = this.get('valueChanged');
      if (action) {
        action(newVal);
      }

      if (newVal) {//if the check has 'passed' manually
        this.clearSendbacks();
      }
    }
  }
});

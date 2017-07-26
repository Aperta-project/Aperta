import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-tech-check'],
  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    answer: PropTypes.EmberObject.isRequired
  },

  actions: {
    sendbackChanged(sendbackAnswer) {
      let techCheckAnswer = this.get('answer');
      if (sendbackAnswer.get('value') === true) {
        techCheckAnswer.set('value', false);
      }
    },
    saveAnswer(newVal) {
      //# TODO: do stuff to switch all sendback checkboxes here
      let action = this.get('valueChanged');
      if (action) {
        action(newVal);
      }
    }
  }
});

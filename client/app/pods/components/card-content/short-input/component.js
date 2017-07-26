import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-short-input'],
  classNameBindings: ['answer.hasErrors:has-error'],

  propTypes: {
    answer: PropTypes.EmberObject.isRequired,
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool
  },

  //short-input renders a standard {{input}} component, which doesn't bind aria attributes
  didInsertElement() {
    if (this.get('content.isRequired') === true) {
      this.$('input').attr({'aria-required': 'true'});
    }
  },

  actions: {
    valueChanged(e) {
      let action = this.get('valueChanged');
      if (action) {
        action(e.target.value);
      }
    }
  }
});

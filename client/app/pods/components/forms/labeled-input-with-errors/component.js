import Ember from 'ember';
import {PropTypes} from 'ember-prop-types';

export default Ember.Component.extend({
  propTypes: {
    value: PropTypes.string,
    placeholder: PropTypes.string,
    label: PropTypes.string,
    errors: PropTypes.array,
    enter: PropTypes.func
  },

  classNames: ['labeled-input-with-errors'],

  errorPresent: Ember.computed.notEmpty('errors'),

  actions: {
    // Called when user hits enter while focused on the input
    enter() {
      const passedInEnterAction = this.get('enter');
      if (passedInEnterAction) passedInEnterAction();
    }
  }
});

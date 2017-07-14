import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-short-input'],
  attributeBindings: ['isRequired:required', 'aria-required'],
  'aria-required': Ember.computed.reads('isRequiredString'),

  hasErrors: Ember.computed.notEmpty('answer.readyIssuesArray.[]'),
  classNameBindings: ['hasErrors:has-error'],

  propTypes: {
    answer: PropTypes.EmberObject.isRequired,
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool
  },

  isRequiredString: Ember.computed('isRequired', function() {
    return this.get('isRequired') === true ? 'true' : 'false';
  }),

  actions: {
    valueChanged(e) {
      let action = this.get('valueChanged');
      if (action) {
        action(e.target.value);
      }
    }
  }
});

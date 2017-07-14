import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-check-box'],
  attributeBindings: ['isRequired:required', 'aria-required'],
  'aria-required': Ember.computed.reads('isRequiredString'),

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    answer: PropTypes.EmberObject.isRequired
  },

  name: Ember.computed('content.ident', function() {
    let ident = this.get('content.ident') || Ember.guidFor(this);

    return `check-box-${ident}`;
  }),

  isRequiredString: Ember.computed('isRequired', function() {
    return this.get('isRequired') === true ? 'true' : 'false';
  }),

  actions: {
    valueChanged(newVal) {
      let action = this.get('valueChanged');
      if (action) {
        action(newVal.checked);
      }
    }
  }
});

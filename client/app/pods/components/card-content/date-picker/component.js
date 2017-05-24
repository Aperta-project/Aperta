import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-date-picker'],

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    preview: PropTypes.bool
  },

  name: Ember.computed('content.ident', function() {
    let ident = this.get('content.ident') || Ember.guidFor(this);
    return `date-picker-${ident}`;
  }),

  actions: {
    valueChanged(newVal) {
      let action = this.get('valueChanged');
      if (action) {
        action(newVal);
      }
    }
  }
});

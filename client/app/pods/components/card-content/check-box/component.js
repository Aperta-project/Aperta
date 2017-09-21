import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-check-box', 'checkbox'],

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    answer: PropTypes.EmberObject.isRequired
  },

  // This is used for a workaround regarding content.text being
  // the text used for version diffing (content.label will not show
  // in the diffing view as the question text).  Eventually, we'll
  // do a real fix for this in APERTA-11249 and/or APERTA-11224
  textOnly: Ember.computed('content.text', 'content.label', function() {
    return this.get('content.text') && Ember.isEmpty(this.get('content.label'));
  }),

  name: Ember.computed('content.ident', function() {
    let ident = this.get('content.ident') || Ember.guidFor(this);
    return `check-box-${ident}`;
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

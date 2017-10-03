import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content', 'card-content-check-box'],

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    repetition: PropTypes.oneOfType([PropTypes.null, PropTypes.EmberObject]).isRequired,
    answer: PropTypes.EmberObject.isRequired
  },

  // This is used for a workaround regarding content.text being
  // the text used for version diffing (content.label will not show
  // in the diffing view as the question text).  Eventually, we'll
  // do a real fix for this in APERTA-11249 and/or APERTA-11224
  showTextAndLabel: Ember.computed('content.{text,label}', function() {
    return Ember.isPresent(this.get('content.label')) && Ember.isPresent(this.get('content.text'));
  }),

  labelOnly: Ember.computed('content.{text,label}', function() {
    return Ember.isPresent(this.get('content.label')) && Ember.isEmpty(this.get('content.text'));
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

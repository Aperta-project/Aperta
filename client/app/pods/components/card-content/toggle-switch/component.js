import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-toggle-switch'],
  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    labelText: PropTypes.string,
    answer: PropTypes.EmberObject.isRequired,
    size: PropTypes.string // 'small', 'medium', or 'large'
  },

  getDefaultProps() {
    return {
      size: 'medium'
    };
  },

  name: Ember.computed('content.ident', function() {
    let ident = this.get('content.ident') || Ember.guidFor(this);

    return `toggle-switch-${ident}`;
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
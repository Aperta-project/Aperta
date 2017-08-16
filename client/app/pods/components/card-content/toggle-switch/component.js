import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-toggle-switch'],
  propTypes: {
    content: PropTypes.object.isRequired,
    disabled: PropTypes.bool,
    labelText: PropTypes.string,
    answer: PropTypes.object.isRequired,
    size: PropTypes.string, // 'small', 'medium', or 'large'
    color: PropTypes.string // 'green', 'blue'
  },

  getDefaultProps() {
    return {
      size: 'medium',
      color: 'green'
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

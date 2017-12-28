import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content', 'card-content-toggle-switch'],
  propTypes: {
    content: PropTypes.oneOfType([PropTypes.object, PropTypes.EmberObject]).isRequired,
    disabled: PropTypes.bool,
    labelText: PropTypes.string,
    interiorText: PropTypes.string,
    answer: PropTypes.oneOfType([PropTypes.object, PropTypes.EmberObject]).isRequired,
    size: PropTypes.string, // 'smaller', small', 'medium', or 'large'
    color: PropTypes.string // 'green', 'blue'
  },

  getDefaultProps() {
    return {
      size: 'medium',
      color: 'green'
    };
  },

  // Note that card-content/toggle switch only consumes the 'ident'
  // on its content
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

import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-check-box'],
  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    answer: PropTypes.EmberObject.isRequired
  },

  name: Ember.computed('content.ident', function() {
    let ident = this.get('content.ident') || Ember.guidFor(this);

    return `check-box-${ident}`;
  }),

  toggleableHideEnabled: Ember.computed.and('content.toggleableHide', 'answerChecked'),
  answerChecked: Ember.computed.equal('answer.value', true),

  actions: {
    valueChanged(newVal) {
      let action = this.get('valueChanged');
      if (action) {
        action(newVal.checked);
      }
    },

    toggleHide() {
      this.toggleProperty('answer.toggleableHideValue');
    }
  }
});

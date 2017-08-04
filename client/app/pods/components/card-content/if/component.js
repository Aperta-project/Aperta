import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-if'],

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    owner: PropTypes.EmberObject.isRequired,
    preview: PropTypes.bool
  },

  condition: Ember.computed('content.condition', function () {
    window.console.log(this.get('content.condition'));
    return !this.get('content.condition');
  }),

  init() {
    this._super(...arguments);
  },

  actions: {
    previewToggleChanged(args) {
      window.console.log(args);
    }
  }

});

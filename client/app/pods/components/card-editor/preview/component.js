import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';


export default Ember.Component.extend({
  propTypes: {
    card: PropTypes.EmberObject
  },

  classNames: ['card-editor-preview'],
  sidebar: false,

  actions: {
    showFullscreen() {
      this.set('sidebar', false);
    },

    showSidebar() {
      this.set('sidebar', true);
    }
  }
});

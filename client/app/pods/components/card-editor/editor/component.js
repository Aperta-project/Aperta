import Ember from 'ember';
import {PropTypes} from 'ember-prop-types';

export default Ember.Component.extend({
  propTypes: {
    card: PropTypes.EmberObject
  },

  classNames: ['card-editor-editor'],

  actions: {
    saveCard() {
      this.get('card').save().then((r)=>r.reload());
    }
  }
});

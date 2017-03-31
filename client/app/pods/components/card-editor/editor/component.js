import Ember from 'ember';
import {PropTypes} from 'ember-prop-types';

export default Ember.Component.extend({
  propTypes: {
    card: PropTypes.EmberObject
  },

  errors: null,

  classNames: ['card-editor-editor'],

  actions: {
    saveCard() {
      this.get('card').save().then((r)=> {
        this.set('errors', null);
        r.reload();
      }).catch((e)=> {
        this.set('errors', e.errors);
      });
    }
  }
});

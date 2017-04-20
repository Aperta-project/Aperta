import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import { task } from 'ember-concurrency';

export default Ember.Component.extend({
  propTypes: {
    card: PropTypes.EmberObject
  },

  errors: null,

  classNames: ['card-editor-editor'],

  saveCard: task(function * () {
    try {
      let r = yield this.get('card').save();
      yield r.reload();
      this.clearErrors();
    } catch (e) {
      this.set('errors', e.errors);
    }
  }),

  publishCard: task(function * () {
    try {
      let r = yield this.get('card').publish();
      yield r.reload();
      this.clearErrors();
    } catch (e) {
      this.set('errors', e.errors);
    }
  })
});

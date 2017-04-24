import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import { task } from 'ember-concurrency';

export default Ember.Component.extend({
  propTypes: {
    card: PropTypes.EmberObject
  },

  xmlDirty: Ember.computed('card.xml', 'card.hasDirtyAttributes', function() {
    let card = this.get('card');

    return card.get('hasDirtyAttributes') && card.changedAttributes()['xml'];
  }),

  errors: null,
  showPublishOverlay: false,

  classNames: ['card-editor-editor'],

  saveCard: task(function*() {
    try {
      let r = yield this.get('card').save();
      yield r.reload();
      this.set('errors', []);
    } catch (e) {
      this.set('errors', e.errors);
    }
  }),

  publishCard: task(function*() {
    let card = this.get('card');
    try {
      yield card.publish();
      yield card.reload();
      this.set('showPublishOverlay', false);
      this.set('errors', []);
    } catch (e) {
      this.set('errors', e.errors);
    }
  }),

  actions: {
    confirmPublish() {
      this.set('showPublishOverlay', true);
    }
  }
});

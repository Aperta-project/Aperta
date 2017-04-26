import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import { task } from 'ember-concurrency';

export default Ember.Component.extend({
  routing: Ember.inject.service('-routing'),
  propTypes: {
    card: PropTypes.EmberObject
  },

  xmlDirty: Ember.computed('card.xml', 'card.hasDirtyAttributes', function() {
    let card = this.get('card');

    return card.get('hasDirtyAttributes') && card.changedAttributes()['xml'];
  }),

  errors: null,
  showPublishOverlay: false,
  showArchiveOverlay: false,

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

  archiveCard: task(function*() {
    let card = this.get('card');

    try {
      yield card.archive();
      this.set('errors', []);
      let journalID = yield card.get('journal.id');
      this.get('routing').transitionTo('admin.cc.journals.cards', null, {
        journalID
      });
    } catch (e) {
      this.set('errors', e.errors);
    }
  }),

  actions: {
    confirmPublish() {
      this.set('showPublishOverlay', true);
    },

    confirmArchive() {
      this.set('showArchiveOverlay', true);
    }
  }
});

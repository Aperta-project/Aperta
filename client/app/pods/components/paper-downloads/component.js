import Ember from 'ember';
import { task } from 'ember-concurrency';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['sheet', 'sheet--visible'],

  propTypes: {
    // actions:
    toggle: PropTypes.func.isRequired
  },

  init() {
    this._super(...arguments);
    this.fetchVersions.perform();
  },

  pdfDownloadLink: Ember.computed('paperid', function() {
    return '/papers/' + this.get('paper.id') + '/download.pdf';
  }),

  versions: [],
  fetchVersions: task(function * () {
    const versions = yield this.get('paper.versionedTexts');
    this.set('versions', versions);
  }),

  actions: {
    toggle() {
      this.get('toggle')();
    }
  }
});

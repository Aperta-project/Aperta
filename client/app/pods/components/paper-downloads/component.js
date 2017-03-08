import Ember from 'ember';
import { task } from 'ember-concurrency';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: [
    'paper-downloads-component',
    'sheet',
    'sheet--visible'
  ],

  propTypes: {
    // actions:
    toggle: PropTypes.func.isRequired
  },

  init() {
    this._super(...arguments);
  },

  pdfDownloadLink: Ember.computed('paperid', function() {
    return '/papers/' + this.get('paper.id') + '/download.pdf';
  }),

  versions: [],
  fetchVersions: task(function * () {
    const versions = yield this.get('paper.versionedTexts');
    // TMP: APERTA-9385: Displaying only the latest version
    let version = versions.findBy('isDraft', true);
    if (!version) {
      version = versions.toArray().sortBy('majorVersion', 'minorVersion')[versions.length - 1];
    }
    this.set('versions', [version]);
  }),

  actions: {
    toggle() {
      this.get('toggle')();
    }
  }
});

import Ember from 'ember';
import PaperBase from 'tahi/mixins/controllers/paper-base';

export default Ember.Component.extend(PaperBase, {
  elementId: 'versioning-bar',
  classNames: ['versions', 'active'],
  versionedTexts: Ember.computed('paper.versionedTexts.[]]', function() {
    return this.get('paper.versionedTexts').forEach(versionedText => {
      versionedText.set(
        'dropdownString',
        `v${versionedText.get('majorVersion')}.${versionedText.get('minorVersion')} ` +
        `${versionedText.get('versionString').replace(/^R\d.\d\s/, '')}`
      );
    });
  }),

  actions: {
    setViewingVersion(version) {
      this.set('viewingVersion', version);
      this.set(
        'selectedVersion1',
        `${version.get('majorVersion')}.${version.get('minorVersion')}`);

      this.attrs.setQueryParam(
        'selectedVersion1', this.get('selectedVersion1')
      );
    },

    setComparisonVersion(version) {
      this.set('comparisonVersion', version);
      this.set(
        'selectedVersion2',
        `${version.get('majorVersion')}.${version.get('minorVersion')}`);
      let action = this.get('setQueryParam');
      action('selectedVersion2', this.get('selectedVersion2'));
    }
  }
});

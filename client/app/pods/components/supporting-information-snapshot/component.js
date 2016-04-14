import Ember from 'ember';
import namedComputedProperty from 'tahi/mixins/components/snapshot-named-computed-property';

export default Ember.Component.extend({
  snapshot1: null,
  snapshot2: null,
  classNames: ['supporting-information-file-snapshot'],

  siFile1: Ember.computed(
    'snapshot1.children.[]',
    function() {
      return SIFileSnapshot({snapshot: this.get('snapshot1')});
    }
  ),

  siFile2: Ember.computed(
    'snapshot2.children.[]',
    function() {
      return SIFileSnapshot({snapshot: this.get('snapshot2')});
    }
  ),

  fileHashChanged: Ember.computed('siFile1.fileHash', 'siFile2.fileHash', function() {
    return this.get('siFile1.fileHash') != this.get('siFile2.fileHash');
  }),
})

var SIFileSnapshot = Ember.Object.extend({
  snapshot: null,
  file: namedComputedProperty('file'),
  title: namedComputedProperty('title'),
  caption: namedComputedProperty('caption'),
  strikingImage: namedComputedProperty('striking_image'),
  publishable: namedComputedProperty('publishable'),
  fileHash: namedComputedProperty('file_hash'),
});

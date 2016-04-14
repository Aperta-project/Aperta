import Ember from 'ember';
import namedComputedProperty from 'tahi/mixins/components/snapshot-named-computed-property';

export default Ember.Component.extend({
  snapshot1: null,
  snapshot2: null,
  classNames: ['supporting-information-file-snapshot'],

  file1: namedComputedProperty('file', 'snapshot1'),
  file2: namedComputedProperty('file', 'snapshot2'),

  title1: namedComputedProperty('title', 'snapshot1'),
  title2: namedComputedProperty('title', 'snapshot2'),

  caption1: namedComputedProperty('caption', 'snapshot1'),
  caption2: namedComputedProperty('caption', 'snapshot2'),

  publishable1: namedComputedProperty('publishable', 'snapshot1'),
  publishable2: namedComputedProperty('publishable', 'snapshot2'),

  strikingImage1: namedComputedProperty('striking_image', 'snapshot1'),
  strikingImage2: namedComputedProperty('striking_image', 'snapshot2'),

  fileHash1: namedComputedProperty('file_hash', 'snapshot1'),
  fileHash2: namedComputedProperty('file_hash', 'snapshot2'),

  fileHashChanged: Ember.computed('fileHash1', 'fileHash2', function() {
    return this.get('fileHash1') != this.get('fileHash2');
  }),
})

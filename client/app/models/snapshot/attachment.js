import Ember from 'ember';
import {
  namedComputedProperty
} from 'tahi/lib/snapshots/snapshot-named-computed-property';

export default Ember.Object.extend({
  attachment: null,

  id: namedComputedProperty('attachment', 'id'),
  caption: namedComputedProperty('attachment', 'caption'),
  category: namedComputedProperty('attachment', 'category'),
  file: namedComputedProperty('attachment', 'file'),
  fileHash: namedComputedProperty('attachment', 'file_hash'),
  label: namedComputedProperty('attachment', 'label'),
  publishable: namedComputedProperty('attachment', 'publishable'),
  status: namedComputedProperty('attachment', 'status'),
  strikingImage: namedComputedProperty('attachment', 'striking_image'),
  title: namedComputedProperty('attachment', 'title'),
  url: namedComputedProperty('attachment', 'url'),
  isImage: Ember.computed('file', function() {
    return (/\.(gif|jpg|jpeg|tiff|png)$/i).test(this.get('file'));
  }),
  previewUrl: Ember.computed('url', function() {
    return this.get('url') + '/preview';
  })
});

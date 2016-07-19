import Ember from 'ember';
import { 
  namedComputedProperty,
} from 'tahi/lib/snapshots/snapshot-named-computed-property';
import namedComputedAttachmentProperty
from 'tahi/lib/snapshots/named-computed-attachment-property';

export default Ember.Component.extend({
  snapshot1: null,
  snapshot2: null,
  classNames: ['cover-letter-snapshot'],

  attachment1: namedComputedAttachmentProperty('snapshot1', 'cover_letter--attachment'),
  attachment2: namedComputedAttachmentProperty('snapshot2', 'cover_letter--attachment'), 

  text1: namedComputedProperty('snapshot1', 'cover_letter--text'),
  text2: namedComputedProperty('snapshot2', 'cover_letter--text'),

});

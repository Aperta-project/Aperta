import Ember from 'ember';
import relativeTime from 'tahi/lib/relative-time';

export default Ember.Component.extend({
  tagName: 'span',

  /**
   * @property time
   * @type Date
   * @default null
   */
  time: null,

  formatedTime: Ember.computed('time', function() {
    return relativeTime(this.get('time'));
  })
});

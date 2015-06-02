import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'span',

  /**
   * @property time
   * @type Date
   * @default null
   */
  time: null,

  formatedTime: function() {
    if(Ember.isEmpty(this.get('time'))) { return ''; }
    return moment(this.get('time').toISOString()).fromNow();
  }.property('time')
});

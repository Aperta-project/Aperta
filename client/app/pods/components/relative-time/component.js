import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'span',

  time: null,

  formatedTime: function() {
    if(Ember.isEmpty(this.get('time'))) { return ''; }
    return moment(this.get('time').toISOString()).fromNow();
  }.property('time')
});

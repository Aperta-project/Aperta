import Ember from 'ember';

export default Ember.Component.extend({
  reply: null, // required

  classNames: ['message-comment'],

  resetTooltip: Ember.observer('reply.body', function() {
    return Ember.run.schedule('afterRender', this, function() {
      this.$('a[title]').tooltip({ placement: 'top' });
    });
  }).on('didInsertElement')
});

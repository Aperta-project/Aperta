import Ember from 'ember';

export default Ember.Component.extend({
  onDidInsertElement: Ember.on('didInsertElement', function() {
    console.log('3 didInsertElement');
  })
});

import Ember from 'ember';
import Select2Component from 'tahi/pods/components/select-2/component';

export default Select2Component.extend({
  setRemoteSource: (function() {
    this.set('selectedData', null);
    this.repaint();
  }).observes('remoteSource'),

  setSelectedData: (function() {
    this.$().select2('val', this.get('selectedData'));
  }).observes('selectedData'),

  initSelection: function(el, callback) {
    (new Ember.RSVP.Promise((function(_this) {
      return function(resolve) {
        return resolve(_this.get('selectedData'));
      };
    })(this))).then(callback);
  }
});

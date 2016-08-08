import Ember from 'ember';
import Select2Component from 'tahi/pods/components/select-2/component';

export default Select2Component.extend({
  multiSelect: true,
  setSelectedData: Ember.observer('selectedData', function() {
    this.$().select2('val', (this.get('selectedData') || []).mapBy('id'));
  })
});


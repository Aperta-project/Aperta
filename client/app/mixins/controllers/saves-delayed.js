import Ember from 'ember';

export default Ember.Mixin.create({
  application: Ember.inject.controller(),
  delayedSave: Ember.computed.alias('application.delayedSave'),

  saveDelayed() {
    this.set('delayedSave', true);
    return Ember.run.debounce(this, this.saveModel, 500);
  },

  saveModel() {
    if (this.get('saveInFlight')) { return; }

    this.set('saveInFlight', true);

    return this.get('model').save().finally(()=> {
      this.set('saveInFlight', false);
      this.set('delayedSave', false);
    });
  },

  actions: {
    saveModel() {
      this.saveDelayed();
    }
  }
});

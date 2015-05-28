import Ember from 'ember';

export default Ember.Mixin.create({
  needs: ['application'],
  delayedSave: Ember.computed.alias('controllers.application.delayedSave'),

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

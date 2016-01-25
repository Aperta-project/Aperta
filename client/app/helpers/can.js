import Ember from 'ember';

export default Ember.Helper.extend({
  can: Ember.inject.service('can'),

  compute([name, resource]){
    const service = this.get('can');
    if (!this.ability){
      this.ability = service.build(name, resource);
    }

    this.ability.addObserver('can', this, 'recompute');
    return this.ability.get('can');
  },

  destroy() {
    this.ability.removeObserver('can', this, 'recompute');
    return this._super();
  }
});

import Ember from 'ember';

export default {
  name: 'macros',
  initialize() {
    Ember.computed['concat'] = function(string, dependentKey) {
      return Ember.computed(dependentKey, function(){
        let value = Ember.get(this, dependentKey);

        if(Ember.isEmpty(value)) { return null; }
        return string + Ember.get(this, dependentKey);
      });
    };
  }
};

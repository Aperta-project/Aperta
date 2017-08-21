import Ember from 'ember';

export default Ember.Helper.helper(function([obj, suffix]) {
  return [Ember.guidFor(obj), suffix].join('-');
});

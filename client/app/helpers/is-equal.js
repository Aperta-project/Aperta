import Ember from 'ember';

export default Ember.Helper.helper(function([leftSide, rightSide]) {
  return Ember.isEqual(leftSide, rightSide);
});

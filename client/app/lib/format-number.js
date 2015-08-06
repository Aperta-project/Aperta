import Ember from 'ember';

export default function(number) {
  if(Ember.isEmpty(number)) { return '0'; }
  return number.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1,');
}

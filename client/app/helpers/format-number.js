import Ember from 'ember';

export default Ember.Handlebars.makeBoundHelper(function(number) {
  if (number) {
    return number.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, '$1,');
  } else {
    return 0;
  }
});

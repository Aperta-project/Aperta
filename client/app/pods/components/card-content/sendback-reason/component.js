import Ember from 'ember';

let childAt = function(key, position) {
  return Ember.computed(`${key}.[]`, function() {
    return this.get(key).objectAt(position);
  });
};

export default Ember.Component.extend({
  checkbox: childAt('content.children', 0),
  pencil: childAt('content.children', 1),
  textarea: childAt('content.children', 2),
  showText: Ember.computed(
    'checkbox.answer.value',
    'pencil.answer.value',
    function() {
      let checkboxAnswer = this.get('checkbox.answer.value');
      let pencilAnswer = this.get('pencil.answer.value');

      return checkboxAnswer && pencilAnswer;
    }
  )
});

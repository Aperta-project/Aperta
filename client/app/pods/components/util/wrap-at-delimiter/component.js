// Split long words containing symbols (e.g., TahiStandardTasks::Blah) after
// symbols, for better word-wrapping than breaking in the middle of of a word.
import Ember from 'ember';

export default Ember.Component.extend({
  chunks: Ember.computed('input', function() {
    let input = this.get('input');
    if (Ember.isEmpty(input)) return [input];

    return input.match(/.+?([\W_]+|$)/g);
  })
});

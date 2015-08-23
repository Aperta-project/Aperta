import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'select',

  // possible passed-in values with their defaults:
  content: null,
  prompt: null,
  optionValuePath: 'id',
  optionLabelPath: 'title',
  action: Ember.K, // action to fire on change

  // shadow the passed-in `selection` to avoid
  // leaking changes to it via a 2-way binding
  _selection: Ember.computed.reads('selection'),

  init() {
    this._super(...arguments);
    if (!this.get('content')) {
      this.set('content', []);
    }
  },

  change() {
    const selectEl = this.$()[0];
    const selectedIndex = selectEl.selectedIndex;
    const content = this.get('content');

    // decrement index by 1 if we have a prompt
    const hasPrompt = !!this.get('prompt');
    const contentIndex = hasPrompt ? selectedIndex - 1 : selectedIndex;

    const selection = content[contentIndex];

    // set the local, shadowed selection to avoid leaking
    // changes to `selection` out via 2-way binding
    this.set('_selection', selection);

    const changeCallback = this.get('action');
    changeCallback(selection);
  }
});

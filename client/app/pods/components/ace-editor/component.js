import Ember from 'ember';
import LazyLoader from 'ember-cli-lazyloader/lib/lazy-loader';

export default Ember.Component.extend({
  aceInstance: null,
  value: null,
  language: 'latex',
  theme: 'chrome',

  loadAceScripts: function() {
    var scripts = [
      '/ace/ace.js',
      `/ace/mode-${this.get('language')}.js`,
      `/ace/theme-${this.get('theme')}.js`
    ];

    return LazyLoader.loadScripts(scripts);
  },

  aceEditorSetup: function() {
    this.loadAceScripts().then(()=> {
      var editor = ace.edit(this.$().get(0));
          editor.setTheme('ace/theme/' + this.get('theme'));
          editor.getSession().setMode('ace/mode/' + this.get('language'));

      this.set('aceInstance', editor);
    });
  }.on('didInsertElement'),

  aceEditorTeardown: function() {
    this.get('aceInstance').destroy();
  }.on('willDestroyElement')
});

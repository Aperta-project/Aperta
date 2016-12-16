import Ember from 'ember';
import bowser from 'ember-bowser';

export default Ember.Service.extend({
  init() {
    if (!this.get('msie')) { this.set('msie', bowser.msie); }
    if (!this.get('version')) { this.set('version', bowser.version); }
  },

  isIE11OrLess: Ember.computed('name', 'version', function() {
    const lessThan12 = (bowser.compareVersions([this.get('version'), '12']) === -1);
    return (lessThan12 && this.get('msie'));
  })
});

import Ember from 'ember';

export default Ember.Component.extend({
  attributeBindings: ['toggle:data-toggle', 'placement:data-placement', 'title'],
  toggle: 'tooltip',

  placement: 'top',
  title: 'tooltip title',
  enabled: true,

  _tooltipExists: false,

  didRender() {
    this._super(...arguments);
    if (this.get('enabled') && !this.get('_tooltipExists')) {
      this.$().tooltip();
      this.set('_tooltipExists', true);
    }

    if (!this.get('enabled') && this.get('_tooltipExists')) {
      this.$().tooltip('destroy');
      this.set('_tooltipExists', false);
    }
  },
});

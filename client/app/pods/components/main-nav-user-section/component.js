import Component from 'ember-component';

export default Component.extend({
  classNameBindings: [
    ':main-nav-user-section',
    ':main-navigation-item',
    'active'
  ],

  active: false,

  didInsertElement() {
    this._super(...arguments);

    this.$().on('click', (event)=> {
      this.toggleProperty('active');
      event.stopPropagation();
      this.listenForBodyClick();
    });
  },

  listenForBodyClick() {
    const that = this;
    $('body')
      .off('click.mainnav')
      .on('click.mainnav', function() {
        if($(this).closest('.main-nav-user-section').length) {
          return;
        }

        $('body').off('click.mainnav');
        that.set('active', false);
      });
  }
});

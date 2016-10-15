import Component from 'ember-component';

let userNavClicked = false;

export default Component.extend({
  classNameBindings: [
    ':main-nav-user-section',
    ':main-navigation-item',
    'active'
  ],

  active: false,

  didInsertElement() {
    this._super(...arguments);

    this.$().on('click', ()=> {
      userNavClicked = true;
      this.toggleProperty('active');
      this.listenForBodyClick();
    });
  },

  listenForBodyClick() {
    const that = this;
    $('body')
      .off('click.mainnav')
      .on('click.mainnav', function() {
        if($(this).closest('.main-nav-user-section').length || userNavClicked) {
          userNavClicked = false;
          return;
        }

        userNavClicked = false;
        $('body').off('click.mainnav');
        that.set('active', false);
      });
  }
});

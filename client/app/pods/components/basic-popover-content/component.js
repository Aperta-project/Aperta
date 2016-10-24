import BasicDropdownContent from 'ember-basic-dropdown/components/basic-dropdown/content';

export default BasicDropdownContent.extend({
  class: 'popover-menu',

  init() {
    this._super(...arguments);
    const self = this;
    $('body').on('click.basic-popover-content', function(e) {
      self.handleContentClick(e);
    });
  },

  handleContentClick(e) {
    const clickedInPopover = $(e.target).closest('.ember-basic-dropdown-content');
    if(clickedInPopover.length) {
      this.get('dropdown').actions.close();
    }
  },

  willDestroyElement() {
    this._super(...arguments);
    $('body').off('click.basic-popover-content');
  }
});

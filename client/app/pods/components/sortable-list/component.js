 import Ember from 'ember';

export default Ember.Component.extend({
  list: null, // passed-in
  items: null, // passed-in
  classNames: ['sortable'],
  classNameBindings: ['sortableNoCards'],
  sortableNoCards: Ember.computed.empty('items'),
  tasks: Ember.computed.alias('list.tasks'),
  changedWithinPhase: null,

  initSortable: Ember.on('didInsertElement', function() {
    Ember.run.schedule('afterRender', this, 'setupSortable');
  }),

  destroySortable: Ember.on('willDestroyElement', function() {
    this.$().sortable('destroy');
  }),

  setupSortable() {
    const self = this;

    this.$().sortable({
      items: '.card',
      scroll: false,
      containment: '.columns',
      connectWith: '.sortable',

      start(event, ui) {

        ui.item.__source__ = self;
        ui.item.data('oldIndex', ui.item.index());
        self.set('changedWithinPhase', true);

        $(ui.item).addClass('card--dragging')
                  .closest('.column-content')
                  .addClass('column-content--dragging');
      },

      update(event, ui) {
        if (ui.item.closest('.sortable').attr('id') === self.get('elementId')) {

          if (self.get('changedWithinPhase')) {
            self.move(ui.item.data('oldIndex'), ui.item.index());
            console.log('update');
          }
        }
      },

      receive(event, ui) {
        const oldIndex = ui.item.data('oldIndex');
        const newIndex = ui.item.index();
        const originalSource = ui.item.__source__;
        self.set('changedWithinPhase', false);
        const item = originalSource.get('items').objectAt(oldIndex);
        originalSource.get('items').removeAt(oldIndex);
        self.get('items').insertAt(newIndex, item);
      },

      stop(event, ui) {
        ui.item.removeData('oldIndex');
        self.set('changedWithinPhase', true);

        $(ui.item).removeClass('card--dragging')
                  .closest('.column-content')
                  .removeClass('column-content--dragging');
      }
    });
  },

  move(oldIndex, newIndex) {
    const item = this.get('items').objectAt(oldIndex);
    this.get('items').removeAt(oldIndex);
    this.get('items').insertAt(newIndex, item);
    this.updatePositions();
  },

  updatePositions() {
    this.get('items').forEach((item, index) => {
      item.set('position', index + 1);
    });
  }

});

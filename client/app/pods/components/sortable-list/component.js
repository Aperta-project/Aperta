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
        var _id = ui.item.closest('.sortable').attr('id');
        if ((_id === self.get('elementId')) && self.get('changedWithinPhase')) {
          const oldIndex = ui.item.data('oldIndex');
          const newIndex = ui.item.index();
          let itemList   = self.get('items');

          const item = itemList.objectAt(oldIndex);
          itemList.removeAt(oldIndex);
          itemList.insertAt(newIndex, item);
          self.updatePositions(itemList);

          self.attrs.itemWasMoved(item, oldIndex, newIndex);
        }
      },

      receive(event, ui) {
        const oldIndex = ui.item.data('oldIndex');
        const newIndex = ui.item.index();
        let itemList   = self.get('items');
        let originalItemList = ui.item.__source__.get('items');

        self.set('changedWithinPhase', false);

        const item = originalItemList.objectAt(oldIndex);
        originalItemList.removeAt(oldIndex);
        itemList.insertAt(newIndex, item);
        item.set('phase',self.get('list'));

        self.updatePositions(originalItemList);
        self.updatePositions(itemList);

        self.attrs.itemWasMoved(item, oldIndex, newIndex);
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

  updatePositions(itemList) {
    this.beginPropertyChanges();
    itemList.forEach((item, index) => {
      item.set('position', index + 1);
    });
    this.endPropertyChanges();
  }
});

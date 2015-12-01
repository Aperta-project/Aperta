 import Ember from 'ember';

export default Ember.Component.extend({
  list: null, // passed-in
  items: null, // passed-in
  classNames: ['sortable'],
  classNameBindings: ['sortableNoCards'],
  sortableNoCards: Ember.computed.empty('items'),
  changedWithinList: null,

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
        self.set('changedWithinList', true);

        self.attrs.startDragging($(ui.item), self.$());
      },

      update(event, ui) {
        var _id = ui.item.closest('.sortable').attr('id');
        if ((_id === self.get('elementId')) && self.get('changedWithinList')) {
          const oldIndex = ui.item.data('oldIndex');
          const newIndex = ui.item.index();
          const items    = self.get('items');
          const item     = items.objectAt(oldIndex);
          self.attrs.itemMovedWithinList(item, oldIndex, newIndex, items);
        }
      },

      receive(event, ui) {
        self.set('changedWithinList', false);

        const oldIndex    = ui.item.data('oldIndex');
        const newIndex    = ui.item.index();
        const newList     = self.get('list');
        const sourceItems = ui.item.__source__.get('items');
        const newItems    = self.get('items');
        const item        = sourceItems.objectAt(oldIndex);

        self.attrs.itemMovedBetweenList(item, oldIndex, newIndex, newList, sourceItems, newItems);
      },

      stop(event, ui) {
        ui.item.removeData('oldIndex');
        self.set('changedWithinList', true);
        self.attrs.stopDragging($(ui.item), ui.item.__source__.$());
      }
    });
  }
});

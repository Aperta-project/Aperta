import Ember from 'ember';

export default Ember.Component.extend({
  phase: null, // passed-in
  classNames: ['sortable'],
  classNameBindings: ['sortableNoCards'],
  attributeBindings: ['dataPhaseId:data-phase-id'],
  dataPhaseId: Ember.computed.alias('phase.id'),
  taskTemplates: Ember.computed.alias('phase.taskTemplates'),
  sortableNoCards: Ember.computed.empty('taskTemplates'),

  didInsertElement() {
    this._super();
    Ember.run.schedule("afterRender", this, "setupSortable");
  },

  updateSortOrder(updatedOrder) {
    this.beginPropertyChanges();
    this.get('taskTemplates').forEach(function(task) {
      task.set('position', updatedOrder[task.get('id')]);
    });
    this.endPropertyChanges();
    // this.get('taskTemplates').invoke('save');
  },

  getTaskByID(taskId) {
    return this.get('taskTemplates').find(function(t) {
      return t.get('id') === taskId.toString();
    });
  },


  setupSortable() {
    const self = this;

    this.$().sortable({
      items: '.card',
      scroll: false,
      containment: '.columns',
      connectWith: '.sortable',

      update(event, ui) {
        let updatedOrder      = {};
        const senderPhaseId   = self.get('phase.id');
        const receiverPhaseId = ui.item.parent().data('phase-id') + '';
        const task = self.getTaskByID(ui.item.find('.card-content').data('id'));

        if(senderPhaseId !== receiverPhaseId) {
          self.sendAction('changePhaseForTask', task, receiverPhaseId);
          Ember.run.scheduleOnce('afterRender', self, function() {
            ui.item.remove();
          });
        }

        $(this).find('.card-content').each(function(index) {
          updatedOrder[$(this).data('id')] = index + 1;
        });

        self.updateSortOrder(updatedOrder);
      },

      start(event, ui) {
        // class added to set overflow: visible;
        $(ui.item).addClass('card--dragging')
                  .closest('.column-content')
                  .addClass('column-content--dragging');
      },

      stop(event, ui) {
        $(ui.item).removeClass('card--dragging')
                  .closest('.column-content')
                  .removeClass('column-content--dragging');
      }
    });
  }

});

import Ember from 'ember';

export default Ember.Component.extend({
  phase: null, // passed-in
  classNames: ['sortable'],
  classNameBindings: ['sortableNoCards'],
  taskTemplates: Ember.computed.alias('phase.taskTemplates'),
  sortableNoCards: Ember.computed.empty('taskTemplates'),
  phaseChanged: false,
  domChanged: false,

  didInsertElement() {
    this._super();
    Ember.run.schedule("afterRender", this, "setupSortable");
  },

  willDestroyElement() {
    this.$().sortable('destroy');
  },

  changedWithinPhase: Ember.computed('phaseChanged', 'domChanged', function() {
    if (this.get('domChanged') === true && this.get('phaseChanged') === false) {
      return true;
    } else {
      return false;
    }
  }),

  sortTaskTemplate(oldIndex, newIndex) {
    let taskTemplate = this.get('taskTemplates').objectAt(oldIndex);
    this.get('taskTemplates').removeAt(oldIndex);
    this.get('taskTemplates').insertAt(newIndex, taskTemplate);
    this.updateTaskPositions();
  },

  updateTaskPositions() {
    this.get('taskTemplates').forEach((task, index) => {
      task.set('position', index + 1);
    });
  },

  setupSortable() {
    const self = this;

    this.$().sortable({
      items: '.card',
      scroll: false,
      containment: '.columns',
      connectWith: '.sortable',

      start(event, ui) {

        ui.item.__source__ = self;
        ui.item.data('old-index', ui.item.index());

        $(ui.item).addClass('card--dragging')
                  .closest('.column-content')
                  .addClass('column-content--dragging');
      },

      update() {
        self.set("domChanged", true);
      },

      receive(event, ui) {
        ui.item.__source__.set("phaseChanged", true);
        let sourcePhase = ui.item.__source__.get("phase");
        let newPhase = self.get("phase");
        let oldIndex = ui.item.data('old-index');
        let newIndex = ui.item.index();
        let taskTemplate = sourcePhase.get("taskTemplates").objectAt(oldIndex);
        sourcePhase.get("taskTemplates").removeAt(oldIndex);
        newPhase.get("taskTemplates").insertAt(newIndex, taskTemplate);

        self.updateTaskPositions();

        self.sendAction('itemUpdated');
      },

      stop(event, ui) {

        if (self.get("changedWithinPhase")) {
          self.sortTaskTemplate(ui.item.data('old-index'), ui.item.index());
          self.sendAction('itemUpdated');
        }

        ui.item.removeData('old-index');
        self.setProperties({phaseChanged: false, domChanged: false});

        $(ui.item).removeClass('card--dragging')
                  .closest('.column-content')
                  .removeClass('column-content--dragging');
      }
    });
  }
});

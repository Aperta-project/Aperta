import Ember from 'ember';

export default Ember.Component.extend({
  model: null,

  viewableDiff: Ember.computed('model', function(){
    let diffResults = this.get('model.diff');

    this.buildHTML(diffResults);

    return this.buildHTML(diffResults);
  }),

  buildHTML: function(diffResults){
    let html = "";

    _.each(diffResults, function(element){
      if(_.isArray(element)){
        html += this.buildHTML(element);
      } else if(element.added) {
          html += ` <span class="added">${element.value}</span> `;
      } else if(element.removed) {
        html += ` <span class="removed">${element.value}</span> `;
      } else {
        html += ` <span class="unchanged">${element.value}</span> `;
      }
    }, this);

    return html;
  }
});

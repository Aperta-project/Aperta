import Ember from 'ember';

export default Ember.Component.extend({
  model: null,

  viewableDiff: Ember.computed('model', function(){
    let diffResults = this.get('model.diff');

    this.buildHTML(diffResults);

    return this.buildHTML(diffResults);
  }),

  buildHTML: function(diffResults, levels){
    let html = "";
    levels = levels || 0;

    if(levels == 0){
      html += `<div class='diffing-${diffResults[0].name}'>`;
    }

    _.each(diffResults, function(element){
      if(element.type === "propertiesDiff"){
        html +=  `<div class="diff-child">
            <h3>${element.name}</h3>
            ${this.buildHTML(element.diffs, levels+1)
          }</div>`;
      } else if(element.type === "propertyDiff"){
        html += `<div class="property"> <label>${element.name}:</label> `;

        _.each(element.diffs, function(e){
          if(e.added) {
              html += ` <span class="added">${e.value}</span> `;
          } else if(e.removed) {
            html += ` <span class="removed">${e.value}</span> `;
          } else {
            html += ` <span class="unchanged">${e.value}</span> `;
          }
        });
        html += "</div>";
      }
    }, this);

    if(levels == 0){
      html += "</div'>";
    }


    return html;
  }
});

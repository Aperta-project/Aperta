import Ember from 'ember';

export default Ember.Component.extend({
  model: null,

  viewableDiff: Ember.computed('model', function(){
    let diffResults = this.get('model.diff');

    this.buildHTML(diffResults);

    return this.buildHTML(diffResults);
  }),

  buildHTML: function(diffResults, levels, insideList){
    let html = "";
    levels = levels || 0;

    if(levels === 0){
      html += `<div class='diffing-${diffResults[0].name}'>`;
    }

    _.each(diffResults, function(element){
      if(element.type === "propertiesDiff" || element.type === "question"){
        console.log("A: ", element);
        if(insideList){
          html += "<li>";
        }
        html +=  `
          <h3>${element.name}</h3>
          <ol class="diff-child diff-${element.type}">
            ${this.buildHTML(element.diffs, levels+1, true)
          }</ol>`;
        if(insideList){
          html += "</li>";
        }

      } else {
        html += `<li class="property ${element.type}"> <label>${element.name}:</label> `;

        _.each(element.diffs, function(e){
          console.log("B:", e);
          if(e.added) {
            html += ` <span class="added">${e.value}</span> `;
          } else if(e.removed) {
            html += ` <span class="removed">${e.value}</span> `;
          } else {
            html += ` <span class="unchanged">${e.value}</span> `;
          }
        });
        html += "</li>";
      }
    }, this);

    if(levels === 0){
      html += "</div'>";
    }

    return html;
  }
});

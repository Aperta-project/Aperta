import Ember from 'ember';

export default Ember.Handlebars.makeBoundHelper(function(chunk) {

  function makeDiffSpan(chunk) {
    if (chunk.added) {
      return "<span class='added'>";
    } else if (chunk.removed) {
      return "<span class='removed'>";
    } else {
      return "<span>";
    }
  };

  let replacement = "</span>" + "$&" + makeDiffSpan(chunk);

  return (makeDiffSpan(chunk) +
          chunk.value.replace(/<.*?>/g, replacement) +
          "</span>");

});

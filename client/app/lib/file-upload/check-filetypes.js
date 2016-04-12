import Ember from 'ember';

// turns a comma separated list of filetypes into a regex that matches them all
// ".js,.hbs,.txt" => /(js|hbs|txt)$/i
function filetypeRegex(list){
  let types = list.replace(/\./g, '').replace(/,/g, '|');
  return new RegExp("(" + types + ")$", 'i');
}

export default function(fileName, acceptString) {
  if (Ember.isPresent(acceptString)) {
    if (fileName.length && !filetypeRegex(acceptString).test(fileName)) {
      let types = acceptString.split(',').join(' or ');
      return {error: true, msg: `Sorry! '${fileName}' is not of an accepted file type (${types})`};
    }
  }
  return {error: false, msg: null};
}

import Ember from 'ember';

// turns a comma separated list of filetypes into a regex that matches them all
// ".js,.hbs,.txt" => /(js|hbs|txt)$/i
export function filetypeRegex(list){
  let types = list.replace(/\s+|\./g, '').replace(/,/g, '|');
  return new RegExp("\.(" + types + ")$", 'i');
}

export default function(fileName, acceptString) {
  if (Ember.isPresent(acceptString)) {
    let fileTypeMatches = fileName.toLowerCase().match(filetypeRegex(acceptString));
    if (fileName.length && !filetypeRegex(acceptString).test(fileName)) {
      let types = acceptString.split(',').join(' or ');
      return {error: true, msg: `We're sorry, '${fileName}' is not a valid file type. Please upload an acceptable file (${types}).`};
    }
    return {acceptedFileType: fileTypeMatches[0].substr(1), error: false, msg: `'${fileName}' is an accepted file type`};
  }
}

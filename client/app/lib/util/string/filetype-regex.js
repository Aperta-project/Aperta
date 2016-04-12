// turns a comma separated list of filetypes into a regex that matches them all
// ".js,.hbs,.txt" => /(js|hbs|txt)$/i
export default function(list){
  let types = list.replace(/\./g, '').replace(/,/g, '|');
  return new RegExp("(" + types + ")$", 'i');
}

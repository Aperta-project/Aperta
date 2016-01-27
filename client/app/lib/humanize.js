export default function(str) {
  if (str == undefined) return '';
  
  return str.replace(/_/g, ' ').
    replace(/^\w/g, function(character){
      return character.toUpperCase();
    });
}

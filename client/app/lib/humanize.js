export default function(str) {
  return str.replace(/_/g, ' ').
    replace(/^\w/g, function(character){
      return character.toUpperCase();
    });
}

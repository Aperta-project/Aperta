  // The Task payload has a key of `type`. This is the full
  // Ruby class name. Example: "ApertaThings::ImportantTask"
  // The Ember side is only interested in the last half.
export default function(typeString) {
  const taskTypeNames = typeString.split('::');

  if (taskTypeNames.length === 1) {
    return typeString;
  } else {
    return taskTypeNames[taskTypeNames.length - 1];
  }
}

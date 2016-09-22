  // The Task payload has a key of `type`. This is the full
  // Ruby class name. Example: "ApertaThings::ImportantTask"
  // The Ember side is only interested in the last half.
export default function(typeString) {
  const taskTypeNames = typeString.split('::');

  if (taskTypeNames.length === 1) {
    return typeString;
  }

  if (taskTypeNames[0] !== 'Task' ||
      taskTypeNames[0] !== 'AdHocTask') {
    return taskTypeNames[taskTypeNames.length - 1];
  }

  throw new Error('The task type: "' + typeString + '" is not qualified.');
}

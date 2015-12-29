export default function(typeString) {
  const taskTypeNames = typeString.split('::');

  if (taskTypeNames.length === 1) {
    return typeString;
  }

  if (taskTypeNames[0] !== 'Task') {
    return taskTypeNames[taskTypeNames.length - 1];
  }

  throw new Error('The task type: "' + typeString + '" is not qualified.');
}

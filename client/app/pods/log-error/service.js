export default function(error) {
  console.log('error!', error);
  console.log('\n' + error.message + '\n');
  console.log('\n' + error.stack   + '\n');
}

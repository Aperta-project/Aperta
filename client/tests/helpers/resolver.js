import Resolver from 'tahi/resolver';
import config from 'tahi/config/environment';

const resolver = Resolver.create();

resolver.namespace = {
  modulePrefix: config.modulePrefix,
  podModulePrefix: config.podModulePrefix
};

resolver.pluralizedTypes.ability = 'abilities';

export default resolver;

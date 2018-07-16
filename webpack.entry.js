var exported = {
  'fbp-spec': require('./src/index'),
  'chai': require('chai'),
  'js-yaml': require('js-yaml'),
};

if (window) {
  window.require = function (moduleName) {
    if (exported[moduleName]) {
      return exported[moduleName];
    }
    throw new Error('Module ' + moduleName + ' not available');
  };
}



const { evaluate } = require('./src/engine/opaRunner');

(async () => {
  const resource = {
    resource_type: 'azurerm_storage_account',
    properties: {
      enable_blob_encryption: false
    }
  };

  const violations = await evaluate(resource);
  console.log('Violations trouvées :', violations);
})();

const fs = require('fs');
const path = require('path');
const opaWasm = require('@open-policy-agent/opa-wasm');

const BUNDLE_PATH = path.join(__dirname, '../../bundle.tar.gz');

async function loadOpaBundle() {
  const bundleData = fs.readFileSync(BUNDLE_PATH);
  const policy = await opaWasm.loadBundle(bundleData);
  await policy.setData({});
  return policy;
}

async function evaluate(input) {
  const opa = await loadOpaBundle();
  const result = await opa.evaluate({ input });

  if (result.length === 0) return [];
  return result
    .flatMap(r => r.result.deny || [])
    .filter(msg => typeof msg === 'string');
}

module.exports = {
  evaluate
};

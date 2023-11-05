"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;

var _reactNative = require("react-native");

const {
  WalletManager
} = _reactNative.NativeModules;
var _default = {
  canAddPasses: async () => {
    if (_reactNative.Platform.OS === 'android') {
      throw new Error('canAddPasses method not available on Android');
    }

    return await WalletManager.canAddPasses();
  },
  addPassFromUrl: _reactNative.Platform.OS === 'ios' ? WalletManager.addPassFromUrl : url => _reactNative.Linking.openURL(url),
  hasPass: async (cardIdentifier, serialNumber) => {
    if (_reactNative.Platform.OS === 'android') {
      throw new Error('hasPass method not available on Android');
    }

    return await WalletManager.hasPass(cardIdentifier, serialNumber != null ? serialNumber : null);
  },
  removePass: async (cardIdentifier, serialNumber) => {
    if (_reactNative.Platform.OS === 'android') {
      throw new Error('removePass method not available on Android');
    }

    return await WalletManager.removePass(cardIdentifier, serialNumber != null ? serialNumber : null);
  },
  viewInWallet: async (cardIdentifier, serialNumber) => {
    if (_reactNative.Platform.OS === 'android') {
      throw new Error('viewInWallet method not available on Android');
    }

    return await WalletManager.viewInWallet(cardIdentifier, serialNumber != null ? serialNumber : null);
  }
}; // Platform.OS === 'ios'
// ? WalletManager.removePass
// : new Promise((_, reject) => {
//     return reject('removePass method not available on Android');
//   }),

exports.default = _default;
//# sourceMappingURL=index.js.map
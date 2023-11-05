import { NativeModules, Platform, Linking } from 'react-native';
const {
  WalletManager
} = NativeModules;
export default {
  canAddPasses: async () => {
    if (Platform.OS === 'android') {
      throw new Error('canAddPasses method not available on Android');
    }

    return await WalletManager.canAddPasses();
  },
  addPassFromUrl: Platform.OS === 'ios' ? WalletManager.addPassFromUrl : url => Linking.openURL(url),
  hasPass: async (cardIdentifier, serialNumber) => {
    if (Platform.OS === 'android') {
      throw new Error('hasPass method not available on Android');
    }

    return await WalletManager.hasPass(cardIdentifier, serialNumber != null ? serialNumber : null);
  },
  removePass: async (cardIdentifier, serialNumber) => {
    if (Platform.OS === 'android') {
      throw new Error('removePass method not available on Android');
    }

    return await WalletManager.removePass(cardIdentifier, serialNumber != null ? serialNumber : null);
  },
  viewInWallet: async (cardIdentifier, serialNumber) => {
    if (Platform.OS === 'android') {
      throw new Error('viewInWallet method not available on Android');
    }

    return await WalletManager.viewInWallet(cardIdentifier, serialNumber != null ? serialNumber : null);
  }
}; // Platform.OS === 'ios'
// ? WalletManager.removePass
// : new Promise((_, reject) => {
//     return reject('removePass method not available on Android');
//   }),
//# sourceMappingURL=index.js.map
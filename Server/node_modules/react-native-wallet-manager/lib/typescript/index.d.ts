declare type WalletManagerType = {
    canAddPasses(): Promise<boolean>;
    addPassFromUrl(url: string): Promise<boolean>;
    hasPass(cardIdentifier: string, serialNumber?: string): Promise<boolean>;
    removePass(cardIdentifier: string, serialNumber?: string): Promise<boolean>;
    viewInWallet(cardIdentifier: string, serialNumber?: string): Promise<boolean>;
};
declare const _default: WalletManagerType;
export default _default;

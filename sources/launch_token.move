
module launch::launch_token {
    use sui::coin::{Self, TreasuryCap};
    use sui::url;
    use sui::tx_context::TxContext;

    /// One-time witness for the coin
    struct LAUNCH has drop {}

    /// Total supply: 100M tokens with 9 decimals
    const TOTAL_SUPPLY: u64 = 100_000_000_000_000_000;

    /// Initialize the LAUNCH token
    fun init(witness: LAUNCH, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<LAUNCH>(
            witness,
            9,
            b"LAUNCH",
            b"LAUNCH Token",
            b"Utility token for SUI launches",
            url::new_unsafe_from_bytes(b"https://example.com/logo.png"),
            ctx
        );

        // Mint total supply and transfer to deployer
        let supply = coin::mint(&mut treasury_cap, TOTAL_SUPPLY, ctx);
        transfer::public_transfer(supply, tx_context::sender(ctx));
        
        // Transfer treasury cap and metadata to deployer
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
    }
}

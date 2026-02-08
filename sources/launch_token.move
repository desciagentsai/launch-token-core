module launch::launch {
    use sui::coin;
    use sui::url;

    /// One-time witness for the coin (Must be uppercase to match module name)
    public struct LAUNCH has drop {}

    /// Total supply: 100M tokens with 9 decimals
    const TOTAL_SUPPLY: u64 = 100_000_000_000_000_000;

    /// Initialize the LAUNCH token
    fun init(witness: LAUNCH, ctx: &mut TxContext) {
        let (mut treasury_cap, metadata) = coin::create_currency(
            witness,
            9,
            b"LAUNCH",       // The Ticker (Symbol) - All caps looks best
            b"Launch",       // The Full Name - Title case looks professional
            b"Utility token for DeSci Launch -- Launchpad for Decentralized Science assets on the SUI blockchain",
            option::some(url::new_unsafe_from_bytes(b"https://pbs.twimg.com")),
            ctx
        );

        // Mint total supply and transfer to you (the deployer)
        let supply = coin::mint(&mut treasury_cap, TOTAL_SUPPLY, ctx);
        transfer::public_transfer(supply, ctx.sender());
        
        // Lock the metadata (Name/Symbol/Logo) so it's decentralized
        transfer::public_freeze_object(metadata);
        
        // Transfer the Minting Key (TreasuryCap) to you
        transfer::public_transfer(treasury_cap, ctx.sender());
    }
}

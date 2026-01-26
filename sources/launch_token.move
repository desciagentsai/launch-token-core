
module launch::launch_token {
    use sui::coin::{Self, Coin};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct LAUNCH has drop {}

    const TOTAL_SUPPLY: u64 = 100_000_000_000_000_000;

    public entry fun init(ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<LAUNCH>(
            LAUNCH {},
            9,
            b"LAUNCH",
            b"LAUNCH",
            b"Utility token for SUI launches",
            option::none(),
            ctx
        );

        let supply = coin::mint<LAUNCH>(TOTAL_SUPPLY, &treasury_cap, ctx);
        transfer::public_transfer(supply, tx_context::sender(ctx));
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
        transfer::public_transfer(metadata, tx_context::sender(ctx));
    }
}

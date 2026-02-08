
module launch::slashing {
    use sui::coin::{Self, Coin};
    use sui::tx_context::TxContext;
    use sui::transfer;
    use launch::launch_token::LAUNCH;

    /// Error codes
    const E_INSUFFICIENT_STAKE: u64 = 0;

    /// Slash tokens and send to treasury
    public entry fun slash_to_treasury(
        stake: &mut Coin<LAUNCH>,
        slash_amount: u64,
        treasury: address,
        ctx: &mut TxContext
    ) {
        assert!(coin::value(stake) >= slash_amount, E_INSUFFICIENT_STAKE);
        
        let slashed = coin::split(stake, slash_amount, ctx);
        transfer::public_transfer(slashed, treasury);
    }

    /// Split stake between treasury and penalty address
    public entry fun slash_and_split(
        stake: &mut Coin<LAUNCH>,
        slash_amount: u64,
        treasury: address,
        penalty_recipient: address,
        ctx: &mut TxContext
    ) {
        assert!(coin::value(stake) >= slash_amount, E_INSUFFICIENT_STAKE);
        
        let slashed = coin::split(stake, slash_amount, ctx);
        let treasury_amount = slash_amount / 2;
        
        let treasury_coin = coin::split(&mut slashed, treasury_amount, ctx);
        transfer::public_transfer(treasury_coin, treasury);
        transfer::public_transfer(slashed, penalty_recipient);
    }
}

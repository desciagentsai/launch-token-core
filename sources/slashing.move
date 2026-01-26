
module launch::slashing {
    use sui::coin::Coin;
    use sui::tx_context::TxContext;
    use sui::transfer;
    use launch::launch_token::LAUNCH;

    public entry fun slash_and_burn(
        mut stake: Coin<LAUNCH>,
        slash_amount: u64,
        treasury: address,
        ctx: &mut TxContext
    ) {
        let slashed = Coin::split(&mut stake, slash_amount);
        let burn_amount = slash_amount / 2;
        let treasury_amount = slash_amount - burn_amount;

        let burn_coin = Coin::split(&mut slashed, burn_amount);
        Coin::destroy_zero(burn_coin);

        let treasury_coin = Coin::split(&mut slashed, treasury_amount);
        transfer::public_transfer(treasury_coin, treasury);
    }
}

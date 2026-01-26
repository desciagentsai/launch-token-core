
module launch::vesting {
    use sui::coin::Coin;
    use sui::clock::{Self, Clock};
    use sui::tx_context::TxContext;
    use sui::transfer;
    use launch::launch_token::LAUNCH;

    const SECONDS_PER_MONTH: u64 = 30 * 24 * 60 * 60;

    struct VestingVault has key {
        beneficiary: address,
        total_amount: u64,
        claimed_amount: u64,
        start_time: u64,
        cliff_seconds: u64,
        duration_seconds: u64,
        balance: Coin<LAUNCH>
    }

    public entry fun create_vesting(
        beneficiary: address,
        total_amount: u64,
        cliff_months: u64,
        vesting_months: u64,
        balance: Coin<LAUNCH>,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        let vault = VestingVault {
            beneficiary,
            total_amount,
            claimed_amount: 0,
            start_time: clock::now(clock),
            cliff_seconds: cliff_months * SECONDS_PER_MONTH,
            duration_seconds: vesting_months * SECONDS_PER_MONTH,
            balance
        };
        transfer::share_object(vault);
    }

    public entry fun claim(vault: &mut VestingVault, clock: &Clock, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == vault.beneficiary, 0);
        let now = clock::now(clock);
        let elapsed =
            if (now <= vault.start_time + vault.cliff_seconds) {
                0
            } else {
                now - vault.start_time - vault.cliff_seconds
            };

        let vested =
            if (elapsed >= vault.duration_seconds) {
                vault.total_amount
            } else {
                vault.total_amount * elapsed / vault.duration_seconds
            };

        let claimable = vested - vault.claimed_amount;
        assert!(claimable > 0, 1);

        let payout = Coin::split(&mut vault.balance, claimable);
        vault.claimed_amount = vault.claimed_amount + claimable;
        transfer::public_transfer(payout, vault.beneficiary);
    }
}

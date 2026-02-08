
module launch::vesting {
    use sui::coin::{Self, Coin};
    use sui::clock::Clock;
    use launch::launch_token::LAUNCH_TOKEN;

    const SECONDS_PER_MONTH: u64 = 30 * 24 * 60 * 60 * 1000; // milliseconds

    /// Error codes
    const E_NOT_BENEFICIARY: u64 = 0;
    const E_NOTHING_TO_CLAIM: u64 = 1;

    /// Vesting vault structure
    public struct VestingVault has key {
        id: UID,
        beneficiary: address,
        total_amount: u64,
        claimed_amount: u64,
        start_time: u64,
        cliff_seconds: u64,
        duration_seconds: u64,
        balance: Coin<LAUNCH_TOKEN>
    }

    /// Create a vesting schedule
    public fun create_vesting(
        beneficiary: address,
        total_amount: u64,
        cliff_months: u64,
        vesting_months: u64,
        balance: Coin<LAUNCH_TOKEN>,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        let vault = VestingVault {
            id: object::new(ctx),
            beneficiary,
            total_amount,
            claimed_amount: 0,
            start_time: clock.timestamp_ms(),
            cliff_seconds: cliff_months * SECONDS_PER_MONTH,
            duration_seconds: vesting_months * SECONDS_PER_MONTH,
            balance
        };
        transfer::share_object(vault);
    }

    /// Claim vested tokens
    public fun claim(vault: &mut VestingVault, clock: &Clock, ctx: &mut TxContext) {
        assert!(ctx.sender() == vault.beneficiary, E_NOT_BENEFICIARY);
        
        let now = clock.timestamp_ms();
        let elapsed = if (now <= vault.start_time + vault.cliff_seconds) {
            0
        } else {
            now - vault.start_time - vault.cliff_seconds
        };

        let vested = if (elapsed >= vault.duration_seconds) {
            vault.total_amount
        } else {
            vault.total_amount * elapsed / vault.duration_seconds
        };

        let claimable = vested - vault.claimed_amount;
        assert!(claimable > 0, E_NOTHING_TO_CLAIM);

        let payout = coin::split(&mut vault.balance, claimable, ctx);
        vault.claimed_amount = vault.claimed_amount + claimable;
        transfer::public_transfer(payout, vault.beneficiary);
    }
}

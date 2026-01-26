
module launch::dao {
    use sui::clock::{Self, Clock};
    use sui::tx_context::TxContext;

    struct Proposal has key {
        id: u64,
        creator: address,
        start_time: u64,
        end_time: u64,
        for_votes: u64,
        against_votes: u64,
        executed: bool
    }

    public entry fun vote(
        proposal: &mut Proposal,
        voting_power: u64,
        support: bool,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        let now = clock::now(clock);
        assert!(now >= proposal.start_time && now <= proposal.end_time, 0);

        if (support) {
            proposal.for_votes = proposal.for_votes + voting_power;
        } else {
            proposal.against_votes = proposal.against_votes + voting_power;
        }
    }
}

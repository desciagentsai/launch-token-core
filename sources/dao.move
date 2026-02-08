
module launch::dao {
    use sui::clock::{Self, Clock};
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    /// Proposal structure for DAO governance
    struct Proposal has key, store {
        id: UID,
        creator: address,
        start_time: u64,
        end_time: u64,
        for_votes: u64,
        against_votes: u64,
        executed: bool
    }

    /// Error codes
    const E_VOTING_NOT_ACTIVE: u64 = 0;
    const E_ALREADY_EXECUTED: u64 = 1;

    /// Create a new proposal
    public entry fun create_proposal(
        start_time: u64,
        end_time: u64,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        let proposal = Proposal {
            id: object::new(ctx),
            creator: tx_context::sender(ctx),
            start_time,
            end_time,
            for_votes: 0,
            against_votes: 0,
            executed: false
        };
        transfer::share_object(proposal);
    }

    /// Vote on a proposal
    public entry fun vote(
        proposal: &mut Proposal,
        voting_power: u64,
        support: bool,
        clock: &Clock,
        _ctx: &mut TxContext
    ) {
        let now = clock::timestamp_ms(clock);
        assert!(now >= proposal.start_time && now <= proposal.end_time, E_VOTING_NOT_ACTIVE);

        if (support) {
            proposal.for_votes = proposal.for_votes + voting_power;
        } else {
            proposal.against_votes = proposal.against_votes + voting_power;
        }
    }

    /// Execute a proposal
    public entry fun execute(
        proposal: &mut Proposal,
        clock: &Clock,
        _ctx: &mut TxContext
    ) {
        let now = clock::timestamp_ms(clock);
        assert!(now > proposal.end_time, E_VOTING_NOT_ACTIVE);
        assert!(!proposal.executed, E_ALREADY_EXECUTED);
        
        proposal.executed = true;
    }
}

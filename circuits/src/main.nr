use dep::std;

global N_EVENTS = 10;

fn simple_hash(inputs: [Field]) -> Field { 
    let mut hash = 0;
    for i in 0..std::array::len(inputs) {
        hash = hash + inputs[i];
    };
    hash
}

// An Noir RTS game.
fn simulate_rts(
    eventFactions : [Field; N_EVENTS],   // The faction of each event
    eventTicks : [Field; N_EVENTS],      // The tick of each event
    eventSelected : [Field; N_EVENTS],        // The selected unit of each event
    newGoalsX : [Field; N_EVENTS],       // The goal x of the selected unit of each event
    newGoalsY : [Field; N_EVENTS],       // The goal y of the selected unit of each event
    ) -> [Field; 2] {   

    let mut eventHash = 0;
    for i in 0..N_EVENTS {
        eventHash = simple_hash([eventHash, eventFactions[i], eventTicks[i], eventSelected[i], newGoalsX[i], newGoalsY[i]]);
    };

    // player 0 wins for now
    [eventHash, 0]
}

fn main(eventFaction : [Field; N_EVENTS]) -> pub [Field; 2] {
    // Default values to mimic player input
    let eventTick : [Field; N_EVENTS] = [0; 10];
    let eventSelected : [Field; N_EVENTS] = [0; 10];
    let newGoalsX : [Field; N_EVENTS] = [0; 10];
    let newGoalsY : [Field; N_EVENTS] = [0; 10];

    simulate_rts(eventFaction, eventTick, eventSelected, newGoalsX, newGoalsY)
}

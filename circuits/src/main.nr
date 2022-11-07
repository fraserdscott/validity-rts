use dep::std;

global nEvents = 3;
global nPlayers = 2;
global nUnits = 10;
global nTicks = 10;
global SIZE = 5;
global DAMAGE = 1;

// Non-euclidean geometries are easier to prove :)
fn manhattan_distance(x1: Field, x2: Field, y1: Field, y2: Field) -> Field {
    let xDiff = if x1 > x2 {x1 - x2} else {x2 - x1};
    let yDiff = if y1 > y2 {y1 - y2} else {y2 - y1};

    xDiff + yDiff
}

fn out_range(x: Field, y: Field, xs: [Field], ys: [Field]) -> bool {
    let mut found = false;
    for i in 0..std::array::len(xs) {
        if manhattan_distance(x, xs[i], y, ys[i]) < SIZE {
            found = true;
        }
    };
    !found
}

fn find_max_index(l: [Field]) -> Field {
    let mut maxIndex = 0;
    let mut maxValue = 0;
    for i in 0..std::array::len(l) {
        if l[i] > maxValue {
            maxIndex = i;
            maxValue = l[i];
        }
    };
    maxIndex
}

// TODO: make this recursive?

// An Noir RTS game.
// Each tick: 
// - units move towards their respective "goal" position, at a rate of `SPEED`.
// - units with nonzero health (ie. alive), damage every unit that is not in their faction and within `RANGE` of them.
// - the player sets a new goal position for exactly one unit.
//
// Movement based on https://gamedev.stackexchange.com/questions/50978/moving-a-sprite-towards-an-x-and-y-coordinate
fn simulate_rts(
    factions : [Field; nUnits],         // The faction of each unit
    initialXs : [Field; nUnits],        // The starting x for each unit
    initialYs : [Field; nUnits],        // The starting y for each unit
    initialHealths : [Field; nUnits],   // The initial health of each unit
    ranges : [Field; nUnits],           // The attack range of each unit
    speeds : [Field; nUnits],           // The movement speed of each unit
    eventFactions : [Field; nEvents],   // The faction of each event
    eventTicks : [Field; nEvents],      // The tick of each event
    selected : [Field; nEvents],        // The selected unit of each event
    newGoalsX : [Field; nEvents],       // The goal x of the selected unit of each event
    newGoalsY : [Field; nEvents],       // The goal y of the selected unit of each event
    ) -> [Field; 2] {

    // Mutable unit traits
    let mut healths : [Field; nUnits] = [0; 10];
    let mut xs : [Field; nUnits] = [0; 10];
    let mut ys : [Field; nUnits] = [0; 10];
    let mut xGoals : [Field; nUnits] = [0; 10];
    let mut yGoals : [Field; nUnits] = [0; 10];

    for i in 0..nUnits {
        healths[i] = initialHealths[i];
        xs[i] = initialXs[i];
        ys[i] = initialYs[i];
    };

    for i in 0..nTicks {
        // First, process any events
        for j in 0..nEvents {
            for k in 0..nUnits {
                // If this event took place in this tick and the player owns this unit and selected this unit, update its goal position
                if (eventTicks[j] == i) & (eventFactions[j] == factions[k]) & (selected[j] == k) {
                    xGoals[k] = newGoalsX[j];
                    yGoals[k] = newGoalsY[j];
                }
            }
        };

        // Then, process unit ticking
        for j in 0..nUnits {
            // Calculate move towards its goal position
            let run = xGoals[j] - xs[j];
            let rise = yGoals[j] - ys[j];
            let length = run + rise;

            if length != 0 {
                // TODO: add back division operator
                let newX = xs[j] + ((run * speeds[j])); // / length);
                let newY = ys[j] + ((rise * speeds[j])); // / length);

                // Check if the new position collides with any another unit
                // TODO: exclude self
                if out_range(newX, newY, xs, ys) {
                    xs[j] = newX;
                    ys[j] = newY;
                }
            }

            // If this unit is alive, damage all enemy entities within range
            for k in 0..nUnits {
                if (healths[j] > 0) & (factions[j] != factions[k]) & (manhattan_distance(xs[j], xs[k], ys[j], ys[k]) < ranges[j]) {
                    healths[k] = healths[k] - DAMAGE;
                }
            }
        }
    };

    // Whichever faction has most overall unit health wins
    let mut points : [Field; nPlayers] = [0 ; 2];
    for i in 0..nUnits {
        let mut faction = 0;
        for j in 0..nPlayers {
            if j == factions[i] {
                faction = j;
            }
        };
        points[faction] = points[faction] + healths[i];
    };

    let mut eventHash = 0;
    for i in 0..nEvents {
        eventHash = std::hash::pedersen([eventHash, eventFactions[i], eventTicks[i], selected[i], newGoalsX[i], newGoalsY[i]])[0];
    };

    [eventHash, find_max_index(points)]
}

fn setup_and_sim(
    eventFactions : [Field; nEvents],
    ticks : [Field; nEvents],
    selected : [Field; nEvents], 
    newGoalsX : [Field; nEvents], 
    newGoalsY : [Field; nEvents]
    ) -> [Field; 2] {

    // The match configuration; immutable unit traits
    let factions : [Field; nUnits] = [0; 10];
    let initialHealths : [Field; nUnits] = [200; 10];
    let ranges : [Field; nUnits] = [10; 10];
    let speeds : [Field; nUnits] = [2; 10];
    let mut initialXs : [Field; nUnits] = [0; 10];
    let initialYs : [Field; nUnits] = [0; 10];

    // Spawn entities in a line along the bottom of the map
    for i in 0..nUnits {
        initialXs[i] = i * 100;
    };

    simulate_rts(factions, initialXs, initialYs, initialHealths, ranges, speeds, eventFactions, ticks, selected, newGoalsX, newGoalsY)
}

// TODO: add [Field; nPlayers] which says the address for each faction. This will be given by contract.
fn main(eventFaction : [Field; nEvents]) -> pub [Field; 2] {
    // Default values to mimic player input
    let eventTick : [Field; nEvents] = [0; 3];
    let eventSelected : [Field; nEvents] = [0; 3];
    let newGoalsX : [Field; nEvents] = [0; 3];
    let newGoalsY : [Field; nEvents] = [0; 3];

    setup_and_sim(eventFaction, eventTick, eventSelected, newGoalsX, newGoalsY)
}

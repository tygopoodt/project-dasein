# 01 — Swarm Size Trade Study

**Status:** Proposed — awaiting decision (see [ADR-0001](../decisions/0001-swarm-size.md))
**Script:** [`simulation/matlab/swarm_size_tradeoff.m`](../../simulation/matlab/swarm_size_tradeoff.m)

## The question

How many drones should Project Dasein have — 10? 20? more?

There is no universally "right" number. Swarm size is a trade between **what the swarm
must accomplish** (more drones = faster coverage, more redundancy) and **what it costs to
coordinate** (radio airtime, computation, money, test space, regulation). This document
puts numbers on those trades so the choice is defensible.

## Assumptions (illustrative — refine once the mission is fixed)

| Parameter | Value | Why |
|-----------|-------|-----|
| Drone class | Sub-250 g micro-quad, ~15 cm motor-to-motor | EU C0 class; smallest real-world regulatory burden; cheap |
| Endurance | ~12 min | Typical for 1S–2S sub-250 g designs |
| Cruise speed | 5 m/s | Conservative for coordinated flight |
| Sensor swath | 20 m | Downward camera at ~15 m altitude |
| Example mission area | 0.5 km² | Search/mapping benchmark |
| State broadcast | 20 Hz per drone, 0.5 ms TDMA slot each | Position/velocity sharing for formation + collision avoidance |
| Per-sortie failure prob. | 5 % per drone | Battery, motor, link loss, etc. |
| BOM per drone | ~€90 | Custom PCB + motors + battery + frame |
| Shared infrastructure | ~€300 | Ground station radio, UWB anchors, chargers |

## Results

| N | Coverage time (0.5 km²) | Radio channel use (TDMA) | All-to-all pairs | P(≥80 % of swarm healthy) | Est. cost |
|--:|------------------------:|-------------------------:|-----------------:|--------------------------:|----------:|
|  5 | 16.7 min ❌ exceeds endurance | 5 %  | 10   | 97.7 % | €750 |
| 10 |  8.3 min ✅ | 10 % | 45   | 98.9 % | €1,200 |
| 15 |  5.6 min ✅ | 15 % | 105  | 99.5 % | €1,650 |
| 20 |  4.2 min ✅ | 20 % | 190  | 99.7 % | €2,100 |
| 30 |  2.8 min ✅ | 30 % | 435  | 99.9 % | €3,000 |
| 50 |  1.7 min ✅ | 50 % ⚠️ | 1,225 | >99.9 % | €4,800 |

## What the numbers say

1. **Below ~8 drones it isn't really a swarm.** Coverage doesn't fit in one battery, and
   emergent behaviours (flocking, distributed task allocation) are barely observable.
2. **Coverage gains flatten fast.** Going 10 → 20 saves ~4 minutes; 20 → 50 saves only ~2.5
   more while cost more than doubles. Diminishing returns.
3. **Radio is the real scaling wall.** With one shared channel, airtime grows linearly with
   N. Past ~50 % utilisation, latency and packet loss climb sharply. Anything above ~40
   drones needs multiple channels or local-neighbour-only communication.
4. **All-to-all doesn't scale; k-nearest-neighbours does.** Pairwise interactions grow as
   N². If each drone only reasons about its k ≈ 6 nearest neighbours, per-drone compute
   stays constant regardless of swarm size. **This is the architectural decision that
   matters more than N itself.**
5. **Redundancy is already good at 10.** Going from 10 to 20 only improves the
   "≥80 % healthy" probability from 98.9 % to 99.7 %.
6. **Real-world practicality.** 10 micro-drones can be tested in a ~6×6×3 m indoor space
   with UWB positioning. 20+ realistically needs a sports hall or outdoor permit. In the EU,
   flying a swarm requires a *Specific* category operational authorisation (SORA) regardless
   of size — so the design should include Remote ID and geo-awareness from day one.

## Recommendation

> **Design a swarm of 10 drones as the reference ("Dasein-10"), but architect everything
> to be size-independent, and validate in simulation at N = 10, 20 and 50.**

Concretely:
- Hardware (PCB, frame, battery) is designed and costed for **10 units**.
- Swarm algorithms use **local neighbour interactions only** (no hard-coded N, no
  all-to-all dependency).
- Radio protocol uses **TDMA with a configurable slot count**, supporting at least 32 nodes
  on one channel.
- The MATLAB swarm sim must show stable behaviour at **N = 50** before the design is
  considered done. A design that only works at 10 is fragile.

## Open questions (needed before this becomes final)

- **What is the mission?** Search & rescue mapping, light show, environmental sensing,
  formation research? This changes the area, payload, and endurance numbers above.
- **Indoor, outdoor, or both?** Drives positioning (UWB vs GNSS/RTK) and the frame/IP rating.
- **Payload?** A camera vs. just an LED vs. a gas sensor changes the mass budget, and
  therefore the motors, the frame load cases for topology optimisation, and the PCB.

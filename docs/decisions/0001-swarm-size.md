# ADR-0001: Swarm size

**Status:** Proposed
**Date:** 2026-10-22

## Context

Swarm size drives the radio protocol, the swarm algorithms, the per-drone budget and the
test environment. It must be fixed before airframe and PCB design start. The full
analysis is in [01-swarm-size-trade-study.md](../requirements/01-swarm-size-trade-study.md).

## Decision (proposed)

- Reference swarm: **10 drones**.
- Architecture must be **size-independent** (local neighbour interactions, configurable TDMA).
- Simulation must validate behaviour at **N = 10, 20, 50**.

## Alternatives considered

- **5 drones** — cheaper, but coverage exceeds one battery and swarm behaviour is barely visible.
- **20 drones as reference** — viable; roughly double the cost for ~4 min faster coverage
  and marginal redundancy gain. Kept as a simulation target.
- **50+ drones** — requires multi-channel radio; out of scope for the reference design.

## Consequences

- PCB/BOM costing targets 10 units.
- Firmware and sim code must never assume a fixed N.

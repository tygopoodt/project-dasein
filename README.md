# Project Dasein

An open-source, fully digital design of a small autonomous drone swarm — engineered
so that every part of it *could* be built and flown in real life.

Nothing here is physically manufactured by the project. But every decision is made as
if it will be: real components with real datasheets, real manufacturing constraints,
real radio budgets, real regulations. If someone downloads this repository, they should
be able to order the PCBs, print the frames, flash the firmware, and fly the swarm.

## Design philosophy

1. **Small details first.** System-level numbers (swarm size, mass, endurance, radio
   budget) are fixed before any CAD or schematics. Everything downstream inherits them.
2. **Real-world feasible.** Only off-the-shelf, purchasable parts. Manufacturable by
   common services (JLCPCB/PCBWay, consumer 3D printers, CNC).
3. **Simulation before hardware.** Every claim is backed by a model — MATLAB/Simulink,
   Python, FEM — that lives in this repo and can be re-run.
4. **Decisions are written down.** Every major choice is recorded in
   [`docs/decisions/`](docs/decisions/) with its reasoning and the alternatives rejected.

## Roadmap

| Phase | Focus | Key outputs | Status |
|------:|-------|-------------|--------|
| 0 | Repository & project setup | Repo structure, license, conventions | ✅ Done |
| 1 | **System requirements** | Mission, swarm size, per-drone mass/endurance/payload budget | 🟡 In progress |
| 2 | Swarm simulation (abstract) | Point-mass swarm sim in MATLAB: formation, collision avoidance, comms model | ⏳ |
| 3 | Drone airframe | Propulsion sizing, topology-optimized frame, FEM validation | ⏳ |
| 4 | Electronics | Custom flight controller PCB (KiCad): MCU, IMU, radio, power | ⏳ |
| 5 | Firmware | Flight control, state estimation, swarm networking | ⏳ |
| 6 | Integrated simulation | Full 6-DOF dynamics + firmware-in-the-loop for the whole swarm | ⏳ |
| 7 | Build package | BOM, Gerbers, print files, assembly guide | ⏳ |

## Repository layout

```
docs/
  requirements/     System requirements and trade studies (start here)
  decisions/        Architecture Decision Records (ADRs)
simulation/
  matlab/           MATLAB scripts & Simulink models
  python/           Python tooling / alternative sims
mechanical/
  topology-optimization/   Load cases, design spaces, optimization runs
  cad/              Final airframe CAD (STEP + native)
electronics/
  pcb/              KiCad projects
  datasheets/       Links/notes on selected components (not the PDFs themselves)
firmware/           Flight controller & swarm firmware
tools/              Helper scripts
```

## Where we are now

Phase 1 — deciding **how many drones** the swarm has and what each one must do.
See [docs/requirements/01-swarm-size-trade-study.md](docs/requirements/01-swarm-size-trade-study.md)
and the accompanying script [simulation/matlab/swarm_size_tradeoff.m](simulation/matlab/swarm_size_tradeoff.m).

## Tools

- MATLAB (+ Simulink, Optimization / PDE toolboxes) for simulation and topology optimization
- KiCad for PCB design
- FreeCAD / Fusion 360 for CAD
- Git + GitHub for everything

## License

[MIT](LICENSE). Hardware files may move to CERN-OHL-P later if that suits the
project better — any such change will be recorded as an ADR.

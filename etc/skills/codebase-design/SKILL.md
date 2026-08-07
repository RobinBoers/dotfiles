---
name: codebase-design
description: Design or assess modules, interfaces, and seams for depth, locality, and testability.
---

# Codebase design

Design deep modules: substantial behavior behind a small interface at a clean seam.

## Vocabulary

- **Module:** anything with an interface and implementation, from a function to a subsystem.
- **Interface:** everything callers must know: operations, invariants, ordering, errors, configuration, and performance constraints.
- **Implementation:** behavior hidden inside a module.
- **Depth:** behavior and leverage provided per unit of interface complexity. A shallow module exposes nearly as much complexity as it contains.
- **Seam:** a place where behavior can vary without editing the caller.
- **Adapter:** an implementation selected at a seam.
- **Leverage:** one implementation benefits many callers or tests.
- **Locality:** related knowledge, changes, bugs, and verification stay together.

Use this vocabulary consistently when it makes the design clearer. Do not police harmless wording.

## Core tests

- **Deletion test:** if deleting a module makes complexity disappear, it was probably pass-through code. A useful module's complexity would spread into its callers.
- **Interface test:** callers and tests should cross the same seam. Tests reaching through the interface often expose the wrong module shape.
- **Variation test:** one adapter is a hypothetical seam. Two justified adapters make it real. Do not abstract imagined variation.

Depth belongs to the interface, not file size. A deep module may contain small internal modules and private test seams without exposing them to callers.

## Place dependencies

Classify dependencies before choosing a seam:

1. **In-process:** merge related computation and test through the new interface. No adapter is needed.
2. **Local substitute:** use a realistic local implementation such as an in-memory filesystem or embedded database. Keep that seam internal.
3. **Remote but owned:** define a port at the network seam. Use production and in-memory adapters while keeping policy in the deep module.
4. **External:** inject a narrow port around the third-party behavior the module needs. Tests use a controlled adapter.

Accept dependencies where behavior genuinely varies. Do not expose internal composition merely to make tests easier.

## Deepen safely

- Move policy, sequencing, invariants, and integration details behind the interface.
- Reduce what callers know. Do not merely move functions into another file.
- Keep strongly related behavior together, even when splitting it would make smaller files.
- Prefer observable results over hidden side effects where practical.
- Replace old shallow-module tests with tests at the deepened interface. Do not layer both suites indefinitely.
- Assert observable behavior, not internal state. Good tests survive internal restructuring.

## Design it twice

For an expensive or hard-to-reverse interface, compare at least two materially different designs. For difficult cases, explore three:

- minimum interface and maximum leverage
- flexibility across known use cases
- the simplest default path for the common caller

For each, show the interface, one usage example, hidden behavior, dependency strategy, and trade-offs. Compare depth, locality, seam placement, and migration cost. Recommend one or a deliberate hybrid. Do not hand the user an unranked menu.

Judge the result by simpler callers, concentrated change, and meaningful tests. Do not judge it by layer count, abstraction count, or file size.

# ADR-0001 — Godot as the Single Client and Rendering Runtime

**Status:** Accepted  
**Date:** 2026-09-30  
**Decision authority:** Mememom Engineering Constitution v1.0.0

## Context

The initial Mememom product foundation proposed a split architecture:

- Godot for duels;
- Three.js + React for the Forge, card previews and collection/binder presentation.

That split was based primarily on development familiarity and perceived convenience for browser 3D presentation.

The project now has stronger practical capability in Godot. The original reason for maintaining a second renderer is no longer sufficient to justify duplicated UI/rendering pipelines.

## Decision

Mememom V1 will use **Godot 4.x as the single client and rendering runtime**.

Godot owns:
- duel scenes;
- Forge UI;
- card previews;
- collection/binder;
- card animations and 3D/2D presentation;
- desktop/mobile targets;
- browser target through Godot Web export when needed.

Three.js is removed from the active V1 architecture.

Backend services remain technology-agnostic and may use a separate appropriate stack.

## Consequences

### Positive

- one rendering stack;
- one asset pipeline;
- less duplicated interaction code;
- simpler debugging and testing;
- consistent visual behavior across duel, Forge and collection;
- more direct reuse of Godot scenes/resources/shaders;
- smaller architectural surface for V1.

### Trade-offs

- browser-specific UI ergonomics must be solved inside Godot/Web export rather than a React/Three.js app;
- some web-native integration may require Godot/JavaScript bridge work;
- if a future product requirement proves materially better served by another client/runtime, the constitution must be explicitly amended.

## Superseded direction

Any prior statement assigning Forge, collection, binder, preview, foil or reveal presentation to Three.js/React is superseded by this ADR and Mememom Engineering Constitution v1.0.0.

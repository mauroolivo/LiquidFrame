# LiquidFrame

LiquidFrame is a SwiftUI showcase project that explores Liquid Glass as a design system for content-heavy interfaces, not just a visual effect.

It focuses on one practical question:

> When should an app trust system-owned navigation and chrome, and when is a custom glass control actually justified?

## Companion article

Read the full write-up here:

- https://uimatters.io/articles/liquid-glass-swiftui

If you want the source version, see `LIQUIDFRAME_ARTICLE.md` in this repository.

## What’s in the project

- System-first navigation with custom contextual glass where needed
- One floating command cluster with a DEBUG-only A/B implementation toggle
- Deterministic background stress conditions for repeatable evaluation
- Explicit accessibility handling for custom translucent surfaces

## Why this repo exists

LiquidFrame is intentionally small in scope so the design and engineering trade-offs stay visible. The repository is built for experimentation, capture, and article writing rather than as a general-purpose app template.

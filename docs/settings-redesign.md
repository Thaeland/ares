# Settings redesign

Implementation contract: separate explicit Classic and NextGen settings contexts, nine real categories, shared live components and existing stores. Merely opening a category or search result cannot write the layout preference. Only the explicit interface switch does so.

Category navigation uses normal routes with predictable back behavior. Content is constrained on desktop, scrollable at narrow widths and inherits the experience theme, including Material dialogs and sheets. NextGen uses its existing Material theme bridge and Ng tokens; imported palettes remain owned by the existing presentation host. Existing owner-bound controllers and platform gates are retained.

Verification and remaining work will be recorded at the final checkpoint.

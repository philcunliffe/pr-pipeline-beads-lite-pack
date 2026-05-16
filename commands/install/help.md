Install the bundled PR pipeline formulas into this city's beads-lite stores.

Examples:

    gc pr-pipeline install
    gc pr-pipeline install --no-rigs

The command copies `formulas/*.formula.toml` into the city `.beads/formulas`
directory and, by default, every registered rig `.beads/formulas` directory.
Run it after first importing this pack, and again after updating formula files.

The wrapper commands route work to `<rig>/gastown-beads-lite.polecat` by
default. Override with `--agent <configured-agent>` or
`GC_PR_PIPELINE_AGENT=<configured-agent>` when needed.

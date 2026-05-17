#!/bin/sh
# gc <binding> pr dual-review — sling a coding agent the
# mol-pr-dual-review formula to run Codex + Claude reviewers in parallel
# and compose a risk capstone via mol-pr-blast-radius.
#
# Usage:
#   gc <binding> pr dual-review <pr-number-or-url> [--rig <name>] [--agent <name>]
#
# Environment (set by gc):
#   GC_CITY_PATH   absolute city root
#   GC_PACK_DIR    absolute pack directory
#   GC_PACK_NAME   pack name ("pr-pipeline")
#   GC_CITY_NAME   city workspace name
#   GC_RIG         current rig (when running inside a rig session)

set -eu

if [ -z "${GC_PACK_DIR:-}" ]; then
    echo "gc pr-pipeline pr dual-review: missing Gas City pack context" >&2
    exit 1
fi

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ] || [ -z "${1:-}" ]; then
    cat "$GC_PACK_DIR/commands/pr/dual-review/help.md"
    [ -z "${1:-}" ] && exit 2 || exit 0
fi

PR="$1"
shift

# Accept bare integer or full URL of the form https://github.com/<owner>/<repo>/pull/<integer>.
case "$PR" in
    https://github.com/*/pull/*)
        # Verify the segment after /pull/ is a positive integer (strip any
        # trailing /files, ?query, or #fragment).
        PR_NUM="${PR##*/pull/}"
        PR_NUM="${PR_NUM%%/*}"
        PR_NUM="${PR_NUM%%\?*}"
        PR_NUM="${PR_NUM%%#*}"
        case "$PR_NUM" in
            ''|*[!0-9]*)
                echo "gc pr-pipeline pr dual-review: PR URL must end in /pull/<integer> (got: $PR)" >&2
                exit 2
                ;;
        esac
        ;;
    *[!0-9]*)
        echo "gc pr-pipeline pr dual-review: <pr> must be a positive integer or a GitHub PR URL (got: $PR)" >&2
        exit 2
        ;;
esac

RIG=""
AGENT="${GC_PR_PIPELINE_AGENT:-gastown-beads-lite.polecat}"

while [ $# -gt 0 ]; do
    case "$1" in
        --rig)        RIG="$2"; shift 2 ;;
        --rig=*)      RIG="${1#--rig=}"; shift ;;
        --agent)      AGENT="$2"; shift 2 ;;
        --agent=*)    AGENT="${1#--agent=}"; shift ;;
        *)
            echo "gc pr-pipeline pr dual-review: unknown argument: $1" >&2
            exit 2
            ;;
    esac
done

if [ -z "$RIG" ]; then
    RIG="${GC_RIG:-}"
fi

if [ -z "$RIG" ]; then
    echo "gc pr-pipeline pr dual-review: --rig <name> required (or set GC_RIG)" >&2
    exit 2
fi

if ! command -v gc >/dev/null 2>&1; then
    echo "gc pr-pipeline pr dual-review: gc binary not in PATH" >&2
    exit 1
fi

exec gc sling "$RIG/$AGENT" mol-pr-dual-review --formula --var "pr=$PR"

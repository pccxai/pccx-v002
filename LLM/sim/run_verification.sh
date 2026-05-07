#!/usr/bin/env bash
# Unified verification runner for the pccx-v002 LLM package.
#
# Runs every known testbench in deterministic order and reports a one-line
# summary plus the path to the emitted .pccx traces so pccx-lab can
# visualise them.
#
# Intentionally idempotent: each tb writes to its own work dir under
# LLM/sim/work/<tb_name>/ so concurrent / repeated runs don't stomp.
#
# Usage:
#   LLM/sim/run_verification.sh
#   LLM/sim/run_verification.sh --list
#   LLM/sim/run_verification.sh --tb tb_shape_const_ram

set -euo pipefail

LLM_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PKG_DIR="$(cd "$LLM_DIR/.." && pwd)"
SIM_DIR="$LLM_DIR/sim"
WORK_ROOT="$SIM_DIR/work"
PCCX_LAB_DIR="${PCCX_LAB_DIR:-$PKG_DIR/../pccx-lab}"
PCCX_CLI_BIN="$PCCX_LAB_DIR/target/release/from_xsim_log"
SMOKE_PROGRAM_TOOL="${PCCX_SMOKE_PROGRAM_TOOL:-}"
VIVADO_ROOT="${XILINX_VIVADO:-}"
GLBL_V="${VIVADO_ROOT:+$VIVADO_ROOT/ids_lite/ISE/verilog/src/glbl.v}"

# ─── Per-testbench RTL dependency map ───────────────────────────────────────
# Each entry lists the .sv modules xvlog must pick up, relative to the package root.
declare -A TB_DEPS=(
    [tb_shape_const_ram]="LLM/rtl/packages/isa/isa_pkg.sv LLM/rtl/core/memory/Constant_Memory/shape_const_ram.sv"
    [tb_mem_dispatcher_shape_lookup]="LLM/rtl/packages/isa/isa_pkg.sv common/rtl/packages/perf_counter_pkg.sv common/rtl/interfaces/npu_interfaces.svh LLM/rtl/core/memory/Constant_Memory/shape_const_ram.sv LLM/rtl/core/memory/mem_u_operation_queue.sv LLM/rtl/core/memory/mem_BUFFER.sv LLM/rtl/core/memory/mem_L2_cache_fmap.sv LLM/rtl/core/memory/mem_GLOBAL_cache.sv LLM/rtl/core/memory/mem_CVO_stream_bridge.sv LLM/rtl/core/memory/mem_dispatcher.sv"
    [tb_GEMM_dsp_packer_sign_recovery]="LLM/rtl/core/mat/GEMM_dsp_packer.sv LLM/rtl/core/mat/GEMM_sign_recovery.sv"
    [tb_mat_result_normalizer]="common/rtl/packages/dtype_pkg.sv LLM/rtl/core/mat/mat_result_normalizer.sv"
    [tb_GEMM_weight_dispatcher]="LLM/rtl/core/mat/GEMM_weight_dispatcher.sv"
    [tb_FROM_mat_result_packer]="LLM/rtl/core/mat/FROM_mat_result_packer.sv"
    [tb_barrel_shifter_BF16]="common/rtl/wrappers/barrel_shifter_BF16.sv"
    [tb_ctrl_npu_decoder]="LLM/rtl/packages/isa/isa_pkg.sv LLM/rtl/core/controller/ctrl_npu_decoder.sv"
    [tb_mem_u_operation_queue]="common/rtl/packages/perf_counter_pkg.sv LLM/rtl/packages/isa/isa_pkg.sv LLM/rtl/core/memory/mem_u_operation_queue.sv"
    [tb_GEMM_fmap_staggered_delay]="LLM/rtl/core/mat/GEMM_fmap_staggered_delay.sv"
    [tb_v002_runtime_smoke_program]="LLM/rtl/packages/isa/isa_pkg.sv LLM/rtl/core/controller/ctrl_npu_decoder.sv LLM/rtl/core/controller/Global_Scheduler.sv"
)

# Core-id assigned to a tb's emitted pccx trace. Kept contiguous so the UI
# Timeline shows one lane per testbench when the traces are composed.
declare -A TB_CORE=(
    [tb_shape_const_ram]=0
    [tb_mem_dispatcher_shape_lookup]=1
    [tb_GEMM_dsp_packer_sign_recovery]=2
    [tb_mat_result_normalizer]=3
    [tb_GEMM_weight_dispatcher]=4
    [tb_FROM_mat_result_packer]=5
    [tb_barrel_shifter_BF16]=6
    [tb_ctrl_npu_decoder]=7
    [tb_mem_u_operation_queue]=8
    [tb_GEMM_fmap_staggered_delay]=9
    [tb_v002_runtime_smoke_program]=10
)

TB_LIST=(
    tb_shape_const_ram
    tb_mem_dispatcher_shape_lookup
    tb_GEMM_dsp_packer_sign_recovery
    tb_mat_result_normalizer
    tb_GEMM_weight_dispatcher
    tb_FROM_mat_result_packer
    tb_barrel_shifter_BF16
    tb_ctrl_npu_decoder
    tb_mem_u_operation_queue
    tb_GEMM_fmap_staggered_delay
    tb_v002_runtime_smoke_program
)

QUICK_TB_LIST=(
    tb_shape_const_ram
    tb_mem_dispatcher_shape_lookup
    tb_v002_runtime_smoke_program
)

usage() {
    cat <<'USAGE'
usage: LLM/sim/run_verification.sh [--list] [--quick] [--full] [--tb <testbench>]

Options:
  --list          print known testbenches and exit
  --quick         run the stable local smoke subset
  --full          run all known testbenches (default)
  --tb <name>     run one known testbench
  -h, --help      print this help
USAGE
}

SELECTED_TBS=("${TB_LIST[@]}")
while (($#)); do
    case "$1" in
        --list)
            printf '%s\n' "${TB_LIST[@]}"
            exit 0
            ;;
        --quick)
            SELECTED_TBS=("${QUICK_TB_LIST[@]}")
            shift
            ;;
        --full)
            SELECTED_TBS=("${TB_LIST[@]}")
            shift
            ;;
        --tb)
            if (($# < 2)); then
                echo "error: --tb requires a testbench name" >&2
                usage >&2
                exit 2
            fi
            if [[ ! -v "TB_DEPS[$2]" ]]; then
                echo "error: unknown testbench: $2" >&2
                usage >&2
                exit 2
            fi
            SELECTED_TBS=("$2")
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "error: unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

mkdir -p "$WORK_ROOT"

# Build the pccx-lab bridge binary if stale / missing.
if [[ ! -x "$PCCX_CLI_BIN" ]]; then
    echo "==> Building from_xsim_log (one-time setup)"
    (cd "$PCCX_LAB_DIR" && cargo build --release --bin from_xsim_log)
fi

run_tb() {
    local tb="$1"
    local work="$WORK_ROOT/$tb"
    mkdir -p "$work"

    local -a rtl_args=()
    for rel in ${TB_DEPS[$tb]}; do
        rtl_args+=("$PKG_DIR/$rel")
    done
    local -a glbl_src_args=()
    local -a glbl_top_args=()
    if [[ -n "$GLBL_V" && -f "$GLBL_V" ]]; then
        glbl_src_args=("$GLBL_V")
        glbl_top_args=(glbl)
    fi

    local tool_status=0
    (
        set -euo pipefail
        cd "$work"
        if [[ "$tb" == "tb_v002_runtime_smoke_program" ]]; then
            if [[ -z "$SMOKE_PROGRAM_TOOL" ]]; then
                echo "error: set PCCX_SMOKE_PROGRAM_TOOL for tb_v002_runtime_smoke_program" >&2
                exit 2
            fi
            echo "  [program]"
            python3 "$SMOKE_PROGRAM_TOOL" \
                --preset tiny-shape-lookup \
                --out "$work/program.json" \
                --memh "$work/v002_runtime_smoke.memh" \
                >program_emit.log 2>&1
        fi

        echo "  [xvlog]"
        xvlog -sv \
            -i "$PKG_DIR/common/rtl/packages/legacy" \
            -i "$PKG_DIR/common/rtl/packages" \
            -i "$PKG_DIR/common/rtl/interfaces" \
            -i "$LLM_DIR/rtl/packages/isa" \
            -i "$LLM_DIR/rtl/packages/controller" \
            -i "$LLM_DIR/rtl/core/mat" \
            -i "$LLM_DIR/rtl/core/vec" \
            -i "$LLM_DIR/rtl/interfaces" \
            "${rtl_args[@]}" \
            "$LLM_DIR/tb/$tb.sv" \
            "${glbl_src_args[@]}" \
            >xvlog.log 2>&1

        echo "  [xelab]"
        # -L xpm: needed for TBs that compile xpm_fifo_sync (e.g. the
        # mem_u_operation_queue queue smoke). No-op for TBs that don't.
        # glbl: needed for XPM async CDC models used by dispatcher-level TBs.
        xelab -L xpm -debug typical "$tb" "${glbl_top_args[@]}" -s snap >xelab.log 2>&1

        echo "  [xsim]"
        xsim snap -R >xsim.log 2>&1

        "$PCCX_CLI_BIN" \
            --log    "$work/xsim.log" \
            --output "$work/$tb.pccx" \
            --testbench "$tb" \
            --core-id "${TB_CORE[$tb]:-0}" \
            >"$work/from_xsim_log.log" 2>&1
    ) || tool_status=$?

    if (( tool_status != 0 )); then
        printf '%-50s  TOOL FAIL: see %s\n' "$tb" "$work"
        return 1
    fi

    local verdict
    verdict="$(awk '/^(PASS|FAIL):/ { print; exit }' "$work/xsim.log")"
    if [[ -z "$verdict" ]]; then
        verdict="FAIL: no PASS/FAIL verdict in $work/xsim.log"
    fi
    printf '%-50s  %s\n' "$tb" "$verdict"

    [[ "$verdict" == PASS:* ]]
}

# ─── Main ───────────────────────────────────────────────────────────────────
echo "==> Running pccx-v002 LLM testbench suite"
echo ""
printf '%-50s  %s\n' "TESTBENCH" "RESULT"
printf '%-50s  %s\n' "---------" "------"
overall_status=0
pass_count=0
fail_count=0
for tb in "${SELECTED_TBS[@]}"; do
    if ! run_tb "$tb"; then
        overall_status=1
        fail_count=$((fail_count + 1))
    else
        pass_count=$((pass_count + 1))
    fi
done

echo ""
echo "==> Summary: ${pass_count} passed, ${fail_count} failed"

echo ""
echo "==> Emitted .pccx traces:"
for tb in "${SELECTED_TBS[@]}"; do
    find "$WORK_ROOT/$tb" -name '*.pccx' -print
done

echo ""
echo "==> Synthesis status (from existing build/reports):"
if [[ -f "$PKG_DIR/build/reports/timing_summary_post_synth.rpt" ]]; then
    grep -E 'Timing constraints are (not )?met' \
        "$PKG_DIR/build/reports/timing_summary_post_synth.rpt" \
        | head -1 \
        || echo "  (no verdict line in timing report)"
else
    echo "  No synth report — run the package synthesis flow first."
fi

exit "$overall_status"

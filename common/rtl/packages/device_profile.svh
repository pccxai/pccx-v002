// ===| Device Profile Hardware Parameters |=====================================
// Physical hardware constants for the active implementation profile.
// To target a different device profile, replace or override this file only.
//
// Target: Bare-metal, 400MHz core clock
// ===============================================================================

`ifndef DEVICE_PROFILE_SVH
`define DEVICE_PROFILE_SVH

// ===| AXI HP Ports |============================================================
// Device profile exposes 4 HP ports, each 128-bit wide (max AXI4 stream bandwidth)
`define DEVICE_HP_PORT_CNT          4
`define DEVICE_HP_SINGLE_WIDTH_BIT  128

// ===| AXI HPC / ACP Ports |=====================================================
// ACP: Accelerator Coherency Port — used for FMap in / Result out (128-bit)
`define DEVICE_ACP_WIDTH_BIT        128

// ===| DSP48E2 Resource |=========================================================
// Xilinx UltraScale+ DSP48E2 specifications
// A-port:  30-bit  (signed)  → used for BF16 fixed-point mantissa (27-bit)
// B-port:  18-bit  (signed)  → used for INT4 weight (4-bit, packed)
// P-port:  48-bit  (signed)  → accumulator output
`define DEVICE_DSP_A_WIDTH          30
`define DEVICE_DSP_B_WIDTH          18
`define DEVICE_DSP_P_WIDTH          48

// ===| XPM FIFO Macros |=========================================================
// Xilinx Parameterized Macro (XPM) FIFO default depths
// Elastic buffers on all AXI stream ports to absorb jitter at 400MHz
`define DEVICE_XPM_FIFO_DEPTH       512
`define DEVICE_XPM_FIFO_DEPTH_TINY  16

// ===| BRAM / URAM |=============================================================
// These are design-level capacity choices, but they are technology-bounded
// by the selected resource profile. Listed here for portability awareness.
`define DEVICE_BRAM_WIDTH           36864   // bits per BRAM36
`define DEVICE_URAM_WIDTH           294912  // bits per URAM

`endif // DEVICE_PROFILE_SVH

# BTT SKR V1.3 — grblHAL Pin Map & Configuration Reference

> Board-level documentation for the BTT SKR V1.3 running grblHAL with dual-axis auto-squaring.  
> Last updated: 2026-02-08

---

## Board & MCU

| Parameter | Value |
|-----------|-------|
| Board | BigTreeTech SKR V1.3 |
| MCU | NXP LPC1768 (Cortex-M3, 100 MHz) |
| Flash | 512 KB (first 16 KB = bootloader, last 32 KB = flash NVS) |
| RAM | 32 KB local + 32 KB AHB |
| Communication | USB CDC (native USB, not UART-bridge) |
| Board Map | `btt_skr_1.3_map.h` |
| Board Define | `BOARD_BTT_SKR_13` |

---

## Motor / Driver Slot Mapping

This build uses **5 motors** (X, Y1, Y2, Z1, Z2) across the 5 driver slots on the SKR V1.3.

| Axis | Driver Slot | Step Pin | Dir Pin | Enable Pin | UART Pin | Limit Pin |
|------|-------------|----------|---------|------------|----------|-----------|
| X | X (slot 1) | P2.2 | P2.6 | P2.1 | P1.17 | P1.29 (X_MIN) |
| Y1 | Y (slot 2) | P0.19 | P0.20 | P2.8 | P1.15 | P1.27 (Y_MIN) |
| Y2 (ganged) | E0 / M3 (slot 4) | P2.13 | P0.11 | P2.12 | P1.8 | P1.26 (Y_MAX) |
| Z1 | Z (slot 3) | P0.22 | P2.11 | P0.21 | P1.10 | P1.25 (Z_MIN) |
| Z2 (ganged) | E1 / M4 (slot 5) | P0.1 | P0.0 | P0.10 | P1.1 | P1.24 (Z_MAX) |

### Auto-Squaring Notes

- **Y-axis:** Y2 uses the **E0 driver slot** (M3 in grblHAL). Its limit switch is on the **Y_MAX header** (P1.26).
- **Z-axis:** Z2 uses the **E1 driver slot** (M4 in grblHAL). Its limit switch is on the **Z_MAX header** (P1.24).
- `LIMIT_MAX_ENABLE` is **disabled** because the MAX limit pins are repurposed for ganged motor homing.
- During homing, each ganged motor pair homes independently to its respective limit switch, then the firmware squares the axis.

---

## Auxiliary Output Pins

| AuxOutput | Pin | SKR Header | Function |
|-----------|-----|------------|----------|
| AUXOUTPUT0 | P2.4 | MOSFET3 | Spindle PWM (laser power) |
| AUXOUTPUT1 | P1.21 | — | Spindle direction |
| AUXOUTPUT2 | P1.23 | — | Spindle enable |
| AUXOUTPUT3 | P3.25 | — | Coolant flood |
| AUXOUTPUT4 | P3.26 | — | Coolant mist |

> Spindle PWM channel: `PWM1_CH5` (P2.4) or `PWM1_CH6` (P2.5/BED MOSFET) depending on `SPINDLE_PWM_PIN_2_4`.

---

## Auxiliary Input Pins

| AuxInput | Pin | SKR Header | Function |
|----------|-----|------------|----------|
| AUXINPUT0 | P2.0 | Servos | MPG mode / general aux |
| AUXINPUT1 | P0.17 | EXP2-1 | Probe input (when `PROBE_ENABLE` active) |
| AUXINPUT2 | P0.18 | EXP2-6 | Reset / E-Stop (`CONTROL_HALT`) |
| AUXINPUT3 | P0.16 | EXP2-4 | Feed hold |
| AUXINPUT4 | P0.15 | EXP2-2 | Cycle start |

---

## Control Signals

Configured in `my_machine.h`:
```c
#define CONTROL_ENABLE (CONTROL_HALT | CONTROL_FEED_HOLD | CONTROL_CYCLE_START)
```

| Signal | Pin | Header |
|--------|-----|--------|
| Halt (Reset/E-Stop) | P0.18 | EXP2-6 |
| Feed Hold | P0.16 | EXP2-4 |
| Cycle Start | P0.15 | EXP2-2 |

---

## Trinamic TMC2209 UART

All 5 driver slots have single-wire UART for TMC2209 configuration:

| Motor | UART Pin |
|-------|----------|
| X | P1.17 |
| Y | P1.15 |
| Z | P1.10 |
| M3 (Y2) | P1.8 |
| M4 (Z2) | P1.1 |

---

## Enabled Plugins (`my_machine.h`)

| Plugin | Define | Value | Status |
|--------|--------|-------|--------|
| USB CDC | `USB_SERIAL_CDC` | 1 | **Enabled** |
| Trinamic | `TRINAMIC_ENABLE` | 2209 | **Enabled** |
| Trinamic Extended | `TRINAMIC_EXTENDED_SETTINGS` | 1 | **Enabled** |
| Laser PPI | `PPI_ENABLE` | 1 | **Enabled** |
| LightBurn Clusters | `LB_CLUSTERS_ENABLE` | 1 | **Enabled** |
| CO2 Overdrive | `LASER_OVD_ENABLE` | 1 | **Enabled** |
| Y Ganged + Auto-Square | `Y_GANGED` / `Y_AUTO_SQUARE` | 1 | **Enabled** |
| Z Ganged + Auto-Square | `Z_GANGED` / `Z_AUTO_SQUARE` | 1 | **Enabled** |

### Disabled (available but commented out)

| Plugin | Define | Notes |
|--------|--------|-------|
| Probe | `PROBE_ENABLE` | Pin assigned (P0.17) but not enabled |
| EEPROM | `EEPROM_ENABLE` | **Blocked by board map** — SKR V1.3 has no I2C |
| Laser Coolant | `LASER_COOLANT_ENABLE` | Uses aux port 0 (P2.0) |
| SD Card | `SDCARD_ENABLE` | Onboard SD used only by bootloader |
| E-Stop | `ESTOP_ENABLE` | Using `CONTROL_HALT` instead |
| Safety Door | `SAFETY_DOOR_ENABLE` | Not wired |
| Limit Max | `LIMIT_MAX_ENABLE` | Pins used for auto-squaring |

---

## Hardware Limitations (SKR V1.3)

1. **No I2C:** P0.27/P0.28 are dedicated I2C pins without pull-up/down — the board map blocks I2C with `#error`.
2. **No EEPROM/FRAM:** Directly follows from no I2C. Settings use flash NVS in the last 32 KB.
3. **Port 1 not interrupt-capable:** Limit switches on Port 1 use polling (`LIMITS_POLL_PORT`), not IRQ.
4. **USB pins shared:** P0.29/P0.30 must match USB direction — cannot be used for other I/O.
5. **Max 2 ABC motors:** Board map enforces `N_ABC_MOTORS <= 2`.

---

## Memory Layout

```
0x00000000  ┌─────────────────────────┐
            │   Bootloader (16 KB)    │
0x00004000  ├─────────────────────────┤
            │   Firmware              │  ← VTOR = 0x4000
            │   (up to 464 KB)        │
0x00078000  ├─────────────────────────┤
            │   Flash NVS (32 KB)     │  ← Settings storage
0x00080000  └─────────────────────────┘
```

See [USB_FIX_NOTES.md](../../USB_FIX_NOTES.md) for full details on the linker script and USB fix.

---

## Build Process

```bash
cd LPC176x/Debug
make clean && make all -j4
arm-none-eabi-objcopy -O binary "GRBL Driver LPC176x.axf" firmware.bin
cp firmware.bin D:/firmware.bin   # Copy to SD card
```

1. Place `firmware.bin` on SD card root
2. Power cycle the SKR V1.3
3. Bootloader flashes firmware automatically (creates `FIRMWARE.CUR`)
4. Board resets and runs grblHAL over USB CDC

---

## EXP2 Header Wiring Reference

| EXP2 Pin | LPC Pin | Function |
|-----------|---------|----------|
| EXP2-1 | P0.17 | Probe (AUXINPUT1) |
| EXP2-2 | P0.15 | Cycle Start (AUXINPUT4) |
| EXP2-4 | P0.16 | Feed Hold (AUXINPUT3) |
| EXP2-6 | P0.18 | Reset/Halt (AUXINPUT2) |

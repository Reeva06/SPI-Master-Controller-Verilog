# FSM-Based SPI Master Controller (SPI Mode 0)

## Overview
This repository contains the RTL implementation and verification environment for an **SPI (Serial Peripheral Interface) Master Controller** designed in Verilog HDL. The module is configured for **SPI Mode 0 (CPOL=0, CPHA=0)** and provides synchronous serial communication designed to interface with serial Flash and EEPROM devices.

## Architectural Features
- **Protocol Mode:** SPI Mode 0 (Clock idles low, data captured on rising edge and shifted on falling edge).
- **FSM-Driven Architecture:** Finite State Machine with clear `IDLE`, `TRANSFER`, and `DONE` states.
- **Clock Division:** Internal clock divider generates the serialized `sclk` from the system clock (`clk`).
- **Full-Duplex Support:** Transmits data on `mosi` while simultaneously sampling input on `miso`.
- **Status Reporting:** Provides active-low chip select (`cs_n`) and transaction status flag (`busy`).

## State Machine Overview
1. **IDLE:** Controller waits for `start` assertion. `cs_n` is held high.
2. **TRANSFER:** `cs_n` pulled low. Data bits are shifted out MSB-first on `mosi` on falling edges of `sclk` and sampled from `miso` on rising edges.
3. **DONE:** Transaction completes; byte is latched into `rx_data`, and `cs_n` returns high.

## Simulation Waveform
Verification was carried out via loopback testing on EDA Playground using Icarus Verilog and analyzed on EPWave.

![SPI Simulation Waveform](spi_waveform.png)

## Verification Highlights
- **Loopback Validation:** Successfully verified byte transmission (`0xA5` and `0x3C`) with zero bit corruption.
- **Protocol Timing:** Verified accurate setup/hold alignment between `sclk`, `mosi`, and `miso`.

## How to Simulate
1. Load `spi_master.v` and `spi_master_tb.v` onto [EDA Playground](https://www.edaplayground.com/).
2. Select **Icarus Verilog** and check **Open EPWave after run**.
3. Click **Run** to execute the loopback testbench.

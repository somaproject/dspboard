#!/bin/bash
coregen -b ../../../vhdl/fiberencode8b10b.xco
coregen -b ../../../vhdl/fiberdecode8b10b.xco
coregen -b ../../../vhdl/serial-deviceio/vhdl/encode8b10b.xco
coregen -b ../../../vhdl/serial-deviceio/vhdl/decode8b10b.xco

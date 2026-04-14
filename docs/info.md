## How it works

This is a parameterizable implementation of a successive approximation (SAR) finite state machine (FSM) for an ADC, as required for operation in a SAR ADC as shown in the following figure:

<a title="White Flye, CC BY-SA 2.5 &lt;https://creativecommons.org/licenses/by-sa/2.5&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:SA_ADC_block_diagram.png"><img width="960" alt="SA ADC block diagram" src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/61/SA_ADC_block_diagram.png/960px-SA_ADC_block_diagram.png"></a>

## How to test

## How to test

The design can be tested with the TinyTapeout DevKit.

* Apply a sequence of four bits to pin `ui_in[0]`, synchronized to the clock.
  * After five clock cycles, the serialized sequence should appear in parallel on pins `uo_out[3:0]`.
  * On pins `uio_out[3:0]`, each bit is set from MSB down to LSB on each clock cycle.
  * Depending on `ui_in[0]`, the current bit remains set or is cleared on the next clock cycle.


## External hardware

The design can be tested with the TinyTapeout DevKit.

Alternatively, the design can be tested using a 4-bit DAC setup and a comparator, as shown in the figure above.

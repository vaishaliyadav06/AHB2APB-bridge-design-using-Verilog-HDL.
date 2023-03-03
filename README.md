# AHB2APB-bridge-design-using-Verilog-HDL.
The AHB2APB bridge design is implemented in Verilog HDL for read, write, read burst, write burst and write transfers, and all these designs are simulated using the Xilinx Vivado software. By implementing the timeout concept, data loss can be minimized, and the design can become more extensible.
The mission of AMBA is to assist embedded system designers in overcoming issues such as low power design, facilitating rightfirst-time development of Embedded Microcontroller Products with one or more CPUs or signal processors, being technologyindependent, and encouraging modular systems. To reduce the amount of silicon infrastructure needed to support efficient onchip and off-chip connectivity for both operation and manufacturing test.
The focus of this research paper is on the synthesis and simulation of an AMBA-based AHB2APB Bridge. AHB2APB Bridge is
a bridge that connects the AHB and APB buses. The communication gap between low bandwidth peripherals on APB and high
bandwidth ARM Processors and/or other high-speed devices on AHB must be bridged. This is to ensure that no data is lost during
data transfers from AHB to APB or APB to AHB.
The RTL (Register Transfer Level) code was designed using Verilog HDL (Hardware Description Language). Xilinx Vivado are used for synthesis and simulation.
#  Design of AHB2APB Bridge
The AHB2APB Bridge uses HCLK, while the APB access sub module uses PCLK. The AHB response and control transfer are
referred to as the AHB interface, whereas the APB access is referred to as the APB interface. We use three internal signals in the
bridge module to assure the accurate creation of appropriate control signals and addresses: PENDWR (Pending Write), PENDRD
(Pending Read), and PDONE (Peripheral operation done). When HREADY, HTRANS, and HSEL are valid, the address and
control are captured for Write or Read operations. There is a necessity for linking these clock domains because the sub modules
run on distinct clock domains, namely HCLK and PCLK. At the interface's boundary, the design becomes asynchronous, resulting
in setup and hold time violations, metastability, and faulty data transfers. As a result, we'll need to seek for design and interface
strategies. If we need to transfer data in this situation, there are just a few options, including
• Handshake signalling method
• Asynchronous FIFO
Both have their own set of benefits and drawbacks. We employed the Handshake Signalling Method in our study. Based on the
handshake signals PENDWR (or PENDRD) and PDONE, the AHB interface delivers data to the APB interface using the
Handshake signalling mechanism. The protocol for this is based on the same handshake signals Request and Acknowledge as the
8155-chip used with the 8085.
The PENDWR (or PENDRD) signal is asserted by the AHB interface, instructing the APB interface to receive or send data on
the data bus. The PDONE signal is asserted by the APB interface, indicating that it has accepted or transferred the data. This
method is simple, but it has flaws: when the APB interface samples the AHB interface's PENDWR (or PENDRD) line and the
AHB interface samples the APB interface's PDONE line, they do so use their internal clocks, causing setup and hold time
violations. To avoid this, we use two stage synchronizers, which are rather resistant to metastability.

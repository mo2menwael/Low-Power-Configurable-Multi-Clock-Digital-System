# RTL to GDS Implementation of Low Power Configurable Multi Clock Digital System
It is responsible for receiving commands through the UART receiver to perform different system functions, such as reading/writing register files or processing data using the ALU block. It then sends the result to the UART transmitter through an asynchronous FIFO to handle different clock rates and avoid data loss.

## Overview
### The UART RX block receives multiple UART frames in each operation, the first frame determines which operation will be executed, the system supports 4 different commands:
1. Register File Write command
2. Register File Read command
3. ALU Operation with operands command
4. ALU Operation without operands command
   
**The UART RX parallel data goes to a Double Flip Flop synchronizer before being sent to the System Controller due to having 2 different clock domains.**
**The System Controller operates on a 50 MHz REF CLK, while the UART RX on a 3.6864 MHz clock.**

When the System Controller receives the data, it determines the required operation and configures the necessary control signals. Here's how the System Controller manages different operations:
1. **Register File Write Operation (0xAA):**

<p align="center">
  <img src="https://github.com/user-attachments/assets/9744c005-e3d4-4cba-b194-d8ed7d39a431"/>
</p>

   - It enables the `WrEn` signal of the Register File, indicating a write operation.
   
   - The desired `Address` for writing is specified.
  
2. **Register File Read Operation (0xBB):**

<p align="center">
  <img src="https://github.com/user-attachments/assets/298b7294-8046-493b-b5ce-9335899073bf"/>
</p>

   - It enables the `RdEn` signal of the Register File, indicating a read operation.

   - The desired `Address` for reading is specified.

   - The data is retrieved from the Register File and sent to the UART TX.

> **However, the UART TX operates on a different clock frequency, specifically 115.2 KHz. To prevent data loss due to clock domain crossing (CDC), a `FIFO` (First-In-First-Out) is placed just before the UART TX. To ensure proper transmission of data without loss or corruption.**

3. **ALU Operation With Operands (0xCC):**

<p align="center">
  <img src="https://github.com/user-attachments/assets/d24d1f9b-03d1-4299-962e-fbc7ee970cad"/>
</p>

   - It enables the `WrEn` signal of the Register File, indicating a write operation of the two operands.
   
   - It activates the `ALU_EN` signal of the ALU, signaling the start of an ALU operation.

   - The `CLK GATE` is enabled to activate the `ALU CLK`.

   - The operands required for the operation are obtained from the Register File at the predefined addresses.

   - The desired function for the ALU operation is taken from the `ALU_FUN` signal.

   - The result of the ALU operation (`ALU_OUT`) is passed to the System Controller.

   - From there, it is sent to the FIFO and, after that to the UART TX.

4. **ALU Operation Without Operands (0xDD):** 

<p align="center">
  <img src="https://github.com/user-attachments/assets/a1512f12-fbdb-428f-a6a7-f5f8ab778506"/>
</p>

   - This configuration allows the ALU to operate without changing the operands previously defined in the Register File.

## System Architecture

The system contains 10 blocks. Let's break down these blocks:

<p align="center">
  <img src="https://github.com/user-attachments/assets/5f2946d0-c2d1-4113-923c-d86d35131ea7"/>
</p>

## Clock Domain 1 (REF_CLK)

1. **RegFile (Register File)**

The RegFile block is a data storage unit, used for data storage and retrieval operations.

2. **ALU (Arithmetic Logic Unit)**

The ALU is the computational block of the system, capable of executing multiple operations:
- Arithmetic: Addition, Subtraction, Multiplication, Division
- Logical: AND, OR, NAND, NOR, XOR, XNOR
- Comparisons: Equality (A = B), Greater than (A > B), Less than (A < B)
- Shifts: Left and Right by 1 bit

3. **Clock Gating**

The Clock Gating block optimizes power consumption by controlling clock signals during idle periods, reducing dynamic power consumption.

4. **SYS_CTRL (System Controller)**

SYS_CTRL acts as the finite state machine of the system. It receives multiple frames and acts according to these frames.

## Clock Domain 2 (UART_CLK)

5. **UART_TX (UART Transmitter)**

UART_TX is responsible for transmitting data to an external device or master via UART communication.

6. **UART_RX (UART Receiver)**

UART_RX receives incoming data and commands from external sources and sends them to the system controller if there are no errors in the frames.

7. **PULSE_GEN (Pulse Generator)**

PULSE_GEN generates a pulse signal, converting the `Busy` signal High time (11 clock cycles of UART_TX clock period) into just one pulse to the `RD_INC` signal.

8. **Clock Dividers**

Clock Dividers are essential for generating clocks with different frequencies and ratios.

## Data Synchronizers

9. **RST Synchronizer**

The RST Synchronizer ensures synchronization of the de-assertion of asynchronous reset active low signals, so as not to violate recovery time, and to make sure flip flops don't enter a metastability state.

10. **Data Synchronizer**

The Data Synchronizer employs a unique synchronization scheme to address Clock Domain Crossing challenges, ensuring reliable data transfer between different clock domains.

## Reserved Registers

The system includes reserved registers, each serving specific functions:

1. **REG0 (Address: 0x0) - ALU Operand A**
2. **REG1 (Address: 0x1) - ALU Operand B**
3. **REG2 (Address: 0x2) - UART Configuration**
   - Bit 0: Parity Enable (Default: 1)
   - Bit 1: Parity Type (Default: 0 -> Even Parity)
   - Bits 7-2: Prescale (Default: 32)
4. **REG3 (Address: 0x3) - Divisor Ratio**
   - Bits 7-0: Division ratio (Default: 32)

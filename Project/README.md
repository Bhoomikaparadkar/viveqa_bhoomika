UART-Based SHA-256 Password Authentication System

Target Board: AT-STLN-ARTIX7-001 (XC7A35T) | System Clock: 24 MHz | HDL: Verilog

Submitted by: Bhoomika Paradkar
Part A — Project Overview
1. What This System Does

This project implements a secure password authentication system entirely on an FPGA using a hardware implementation of the SHA-256 cryptographic hash algorithm.

Instead of storing the password itself, the FPGA stores only the SHA-256 hash of the correct password. When a user enters a password through a serial terminal (PuTTY) over UART, the FPGA receives the characters, computes their SHA-256 hash in hardware, and compares the generated hash with the stored reference hash.

The authentication result is displayed through UART messages and the onboard LEDs.

This demonstrates how cryptographic authentication can be implemented completely in RTL without using any processor.

2. Working Principle

The authentication process consists of the following steps.

Step 1 – System Initialization

After power-up or reset:

UART Receiver is initialized.
Password buffer is cleared.
SHA-256 core waits in idle state.
FPGA sends
Enter Password:

to the serial terminal.

Step 2 – Password Reception

The user types a password in PuTTY.

Example

password123

Each ASCII character is received through UART and stored sequentially inside the Password Buffer.

The buffer continues accepting characters until the Enter key is pressed.

Step 3 – Password Buffer

The Password Buffer

stores all received bytes
counts password length
detects Enter key
generates a one-clock hashing trigger

After Enter,

the password is locked and transferred to the SHA-256 core.

Step 4 – SHA-256 Hash Computation

The SHA-256 hardware module

pads the message
expands message words
performs all 64 SHA-256 compression rounds
generates a 256-bit digest

No software is involved during hashing.

Step 5 – Hash Comparison

The generated digest is compared with a pre-stored golden SHA-256 hash.

If both hashes match,

Authentication Successful

Otherwise,

Authentication Failed

is transmitted over UART.

Step 6 – LED Indication

Since the FPGA board contains only 8 LEDs, they are used as status indicators.

LED Pattern	Meaning
11111111	Access Granted
00000000	Access Denied
10101010	SHA-256 Processing
01010101	Waiting for Password
Part B — System Architecture
                +----------------------+
                |      PuTTY / PC      |
                +----------+-----------+
                           |
                      UART Serial
                           |
                           v
                  +------------------+
                  |    UART Receiver |
                  +------------------+
                           |
                           v
                  +------------------+
                  | Password Buffer  |
                  +------------------+
                           |
                     Start Hashing
                           |
                           v
                  +------------------+
                  |   SHA-256 Core   |
                  +------------------+
                           |
                    256-bit Digest
                           |
                           v
                 +-------------------+
                 | Hash Comparator   |
                 +-------------------+
                           |
                 Match / No Match
                           |
          +----------------+----------------+
          |                                 |
          v                                 v
    UART Message                      LED Status
Part C — RTL Modules
Module	Description
top.v	Top-level module integrating all submodules
uart_rx.v	Receives serial UART data
uart_tx.v	Transmits authentication result
password_buffer.v	Stores received password characters
sha256.v	Top SHA-256 wrapper
sha256_core.v	SHA-256 compression engine
sha256_w_mem.v	Message schedule memory
sha256_k_constants.v	SHA-256 round constants
padding.v	Pads message to 512 bits
controller_fsm.v	Controls authentication flow
hash_compare.v	Compares generated hash with stored hash
Part D — Data Flow
PC
 ↓
UART RX
 ↓
Password Buffer
 ↓
Padding
 ↓
SHA-256 Core
 ↓
Hash Comparator
 ↓
Authentication Result
 ↓
UART TX + LEDs
Part E — Build Instructions
Software
Xilinx Vivado
PuTTY / TeraTerm
USB-UART Driver
Steps
Create RTL Project in Vivado.
Add all Verilog source files.
Add XDC constraints.
Set top.v as Top Module.
Run Synthesis.
Run Implementation.
Generate Bitstream.
Program FPGA.
Part F — Running the Project
Open PuTTY.
Configure
Baud Rate : 9600
Data Bits : 8
Parity    : None
Stop Bits : 1
Press Reset.

Terminal displays

Enter Password:
Type the password.
Press Enter.

FPGA computes SHA-256.

Terminal displays either

Authentication Successful

or

Authentication Failed
Part G — Testing
Test Case 1

Input

password123

Output

Authentication Successful

LED Pattern

11111111
Test Case 2

Input

hello123

Output

Authentication Failed

LED Pattern

00000000
Part H — Applications
Secure FPGA login systems
Hardware authentication
Secure boot systems
Embedded security
Cryptographic accelerators
Password verification hardware
Part I — Future Improvements
Multiple user accounts
Salted password hashing
BRAM-based credential storage
OLED/LCD display support
UART menu interface
AES + SHA combined security
SPI Flash password database
Ethernet/Wi-Fi authentication
Repository Structure
SHA256_UART_Authenticator/
│
├── rtl/
│   ├── top.v
│   ├── uart_rx.v
│   ├── uart_tx.v
│   ├── password_buffer.v
│   ├── controller_fsm.v
│   ├── padding.v
│   ├── hash_compare.v
│   ├── sha256.v
│   ├── sha256_core.v
│   ├── sha256_w_mem.v
│   └── sha256_k_constants.v
│
├── constraints/
│   └── top.xdc
│
├── simulation/
│   └── tb_top.v
│
├── images/
│   ├── block_diagram.png
│   ├── terminal_output.png
│   └── hardware_setup.jpg
│
├── docs/
│   └── PROJECT_DOCUMENTATION.md
│
└── README.md

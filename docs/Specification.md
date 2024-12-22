# Specification of Lightweight RISC-V RV32I Subset
# For Light - CPU Project


## 1. 概述

本手册基于 RV32I 基础整数指令集，定义了精简的最小子集，目标包括：

1. **简洁性**：涵盖最基本的功能与最常用的操作，便于在 FPGA/模拟器中快速实现。  
2. **可用性**：确保具备基本的算术、逻辑、内存读写、跳转、分支等功能，能够编写小型程序并运行。  
3. **相对兼容性**：采用与标准 RISC-V 指令集兼容的编码格式（R-type, I-type, B-type, U-type, J-type），方便后续扩展到完整 RV32I。  

该子集**不**追求包含所有 RV32I 指令，而是选取了一套足以实现一般性功能、同时指令总数较少的集合。  

---

## 2. 寄存器组

- **通用寄存器**：32 个 32 位寄存器，命名为 x0, x1, x2, …, x31。  
  - **x0**：硬连到常数 0，所有写入 x0 的操作都会被忽略，读出时返回 0。  
  - 其他寄存器（x1 ~ x31）为通用可读写寄存器。  

- **程序计数器（PC）**：用于存储当前指令的地址。执行完成后通常自动加 4 递增到下一条指令（对于绝大部分指令而言），但遇到跳转或分支时则会被修改为新的目标地址。  

---

## 3. 指令编码格式

本子集采用与 RV32I 相同的 5 种基本指令编码格式：

1. **R-type**（寄存器类型）  
   $$
   \underbrace{31:25}_{funct7} \,\underbrace{24:20}_{rs2} \,\underbrace{19:15}_{rs1} \,\underbrace{14:12}_{funct3} \,\underbrace{11:7}_{rd} \,\underbrace{6:0}_{opcode}
   $$

2. **I-type**（立即数类型）  
   $$
   \underbrace{31:20}_{imm[11:0]} \,\underbrace{19:15}_{rs1} \,\underbrace{14:12}_{funct3} \,\underbrace{11:7}_{rd} \,\underbrace{6:0}_{opcode}
   $$

3. **B-type**（分支类型）  
   $$
   \underbrace{31}_{imm[12]} \,\underbrace{30:25}_{imm[10:5]} \,\underbrace{24:20}_{rs2} \,\underbrace{19:15}_{rs1} \,\underbrace{14:12}_{funct3} \,\underbrace{11:8}_{imm[4:1]} \,\underbrace{7}_{imm[11]} \,\underbrace{6:0}_{opcode}
   $$

4. **U-type**（上半立即数类型）  
   $$
   \underbrace{31:12}_{imm[31:12]} \,\underbrace{11:7}_{rd} \,\underbrace{6:0}_{opcode}
   $$

5. **J-type**（跳转类型）  
   $$
   \underbrace{31}_{imm[20]} \,\underbrace{30:21}_{imm[10:1]} \,\underbrace{20}_{imm[11]} \,\underbrace{19:12}_{imm[19:12]} \,\underbrace{11:7}_{rd} \,\underbrace{6:0}_{opcode}
   $$

6. **S-type**（存储类型）  
   $$
   \underbrace{31:25}_{imm[11:5]} \,\underbrace{24:20}_{rs2} \,\underbrace{19:15}_{rs1} \,\underbrace{14:12}_{funct3} \,\underbrace{11:7}_{imm[4:0]} \,\underbrace{6:0}_{opcode}

---

## 4. 指令集一览

本子集的指令可以分为以下几类：

1. **算术与逻辑**  
2. **立即数操作**  
3. **分支与跳转**  
4. **内存读写**  
5. **上半立即数（装载地址高位）**

### 4.1 算术与逻辑指令（R-type）

| 指令 | 语义 | 格式 | funct3 | funct7 | 描述 |
|-----|-----|-----|-------|-------|-----|
| ADD  | rd ← rs1 + rs2 | R-type | 000 | 0000000 | 32 位有符号加法 |
| SUB  | rd ← rs1 - rs2 | R-type | 000 | 0100000 | 32 位有符号减法 |
| AND  | rd ← rs1 AND rs2 | R-type | 111 | 0000000 | 按位与 |
| OR   | rd ← rs1 OR rs2  | R-type | 110 | 0000000 | 按位或 |
| XOR  | rd ← rs1 XOR rs2 | R-type | 100 | 0000000 | 按位异或 |
| SLT  | rd ← (rs1 < rs2)? 1 : 0 | R-type | 010 | 0000000 | 有符号比较，小于置 1 |

> **说明**：  
> - ADD/SUB/AND/OR/XOR/SLL/SRL/SRA/SLT 均为 R-type，寄存器-寄存器操作。  
> - SLT 默认是有符号比较。  

### 4.2 立即数操作指令（I-type）

| 指令 | 语义 | 格式 | funct3 | 描述 |
|-----|-----|-----|-------|-----|
| ADDI  | rd ← rs1 + imm(12位符号扩展) | I-type | 000 | 32 位有符号加法（寄存器 + 立即数） |

> **说明**：  
> - 本子集仅保留最常用的 ADDI（加法立即数），可用于计算偏移、做简单的数值运算等。  
> - 立即数为 12 位带符号，可正可负，范围 -2048 ~ 2047。  

### 4.3 分支与跳转指令

#### 4.3.1 分支指令（B-type）

| 指令 | 条件 | 格式 | funct3 | 描述 |
|-----|-----|-----|-------|-----|
| BEQ  | rs1 == rs2 跳转 | B-type | 000 | 相等时跳转 |

> **说明**：  
> - B-type 指令中的跳转目标地址 = PC + offset，其中 offset 由指令的立即数域经过一定拼接和左移 1 位获得，能跳转 ±4KB 范围内的目标。  

#### 4.3.2 跳转指令（J-type / I-type）

| 指令 | 语义 | 格式 | 描述 |
|-----|-----|-----|-----|
| JAL  | rd ← PC+4; PC ← PC + offset | J-type | 无条件跳转并将返回地址写入 rd |


> **说明**：  
> - **JAL** 采用 J-type，常用于调用函数或做全局跳转，跳转范围可达 ±1MB 左右。  
 
> - `rd` 可选地存储返回地址，如果不需要存储返回地址，可将 rd 指定为 x0。  

### 4.4 内存读写指令（I-type for load, S-type for store）

> 虽然 RISC-V 将 Store 分为 S-type，但本子集说明中放在一起介绍。

| 指令 | 语义 | 格式 | funct3 | 描述 |
|-----|-----|-----|-------|-----|
| LW   | rd ← Mem(rs1 + imm) | I-type | 010 | 从内存加载 32 位数据到 rd |
| SW   | Mem(rs1 + imm) ← rs2 | S-type | 010 | 将 rs2 里 32 位数据存入内存 |

> **说明**：  
> - 本子集只保留字（32 位）读写指令 `LW` 和 `SW`。  
> - 地址对齐：本实现要求 `LW` / `SW` 的地址应当是 4 字节对齐，否则行为未定义或抛出对齐异常（具体实现可自定）。  
> - 立即数为 12 位带符号。对于 `LW` 是 I-type；对于 `SW` 是 S-type，它在编码上与 B-type 有相似之处，但 funct3 相同字段不同意义。  

### 4.5 上半立即数指令（U-type）

| 指令 | 语义 | 格式 | 描述 |
|-----|-----|-----|-----|
| LUI  | rd ← imm << 12 | U-type | 将 20 位立即数加载到 rd 的高 20 位，其余 12 位清零 |

> **说明**：  
> - `LUI` 常用于配合 `ADDI` 拼出 32 位常量或地址。  
> - 例如：要得到 0x12345000，可先 `LUI x1, 0x12345`，则 x1 = 0x12345000。若需要再加上一点偏移，可后接 `ADDI x1, x1, 0x??`。  

---

## 5. 详细指令描述

本节对各指令的操作数、结果、以及影响（如写回寄存器、修改 PC）作简要说明。  

1. **ADD rd, rs1, rs2**  
   - 功能：$\text{rd} \leftarrow \text{rs1} + \text{rs2}$（有符号 32 位加法，忽略溢出）  
   - 寄存器读：rs1, rs2  
   - 寄存器写：rd  
   - PC 更新：PC ← PC + 4  

2. **SUB rd, rs1, rs2**  
   - 功能：$\text{rd} \leftarrow \text{rs1} - \text{rs2}$  
   - 寄存器读：rs1, rs2  
   - 寄存器写：rd  
   - PC 更新：PC ← PC + 4  

3. **AND rd, rs1, rs2**  
   - 功能：$\text{rd} \leftarrow \text{rs1} \,\mathrm{AND}\, \text{rs2}$  
   - 寄存器读：rs1, rs2  
   - 寄存器写：rd  
   - PC 更新：PC ← PC + 4  

4. **OR rd, rs1, rs2**  
   - 功能：$\text{rd} \leftarrow \text{rs1} \,\mathrm{OR}\, \text{rs2}$  
   - 寄存器读：rs1, rs2  
   - 寄存器写：rd  
   - PC 更新：PC ← PC + 4  

5. **XOR rd, rs1, rs2**  
   - 功能：$\text{rd} \leftarrow \text{rs1} \,\mathrm{XOR}\, \text{rs2}$  
   - 寄存器读：rs1, rs2  
   - 寄存器写：rd  
   - PC 更新：PC ← PC + 4  

6. **SLT rd, rs1, rs2**  
   - 功能：若 $\text{rs1} < \text{rs2}$（有符号比较），则 rd = 1，否则 rd = 0。  
   - 寄存器读：rs1, rs2  
   - 寄存器写：rd  
   - PC 更新：PC ← PC + 4  

7. **ADDI rd, rs1, imm**  
    - 功能：$\text{rd} \leftarrow \text{rs1} + \text{imm}$（12 位有符号立即数）  
    - 寄存器读：rs1  
    - 寄存器写：rd  
    - PC 更新：PC ← PC + 4  

8. **BEQ rs1, rs2, offset**  
    - 功能：若 rs1 == rs2，则 PC ← PC + offset，否则 PC ← PC + 4。  
    - 寄存器读：rs1, rs2  
    - PC 更新：条件满足时跳转  

10. **JAL rd, offset**  
    - 功能：rd ← PC + 4; PC ← PC + offset  
    - 寄存器写：rd（保存返回地址）  
    - PC 更新：PC ← PC + offset  

11. **LW rd, imm(rs1)**  
    - 功能：rd ← Mem(rs1 + imm)  
    - 寄存器读：rs1  
    - 寄存器写：rd  
    - PC 更新：PC ← PC + 4  

12. **SW rs2, imm(rs1)**  
    - 功能：Mem(rs1 + imm) ← rs2  
    - 寄存器读：rs1, rs2  
    - PC 更新：PC ← PC + 4  

13. **LUI rd, imm**  
    - 功能：rd ← imm << 12  
    - 寄存器写：rd  
    - PC 更新：PC ← PC + 4  

---

## 6. 内存模型与对齐

- **对齐要求**：对于本子集中出现的 `LW` 和 `SW`，地址必须是 4 字节对齐，否则行为未定义或抛出异常（由具体实现决定）。  
- **内存访问大小**：本子集仅支持 32 位整字读写，不支持字节/半字（LB, LH 等）指令。  
- **地址空间**：可依据实现环境决定大小，一般仿真器或 FPGA 上不会超过 4 GiB。  

---

## 7. 系统约定（可选）

在纯硬件实验环境或教学场景下，可以先忽略系统调用相关指令（如 `ECALL` 等），也可以自行约定简单的 I/O 机制。若需要与标准 RISC-V Linux 生态兼容，需要进一步添加 `LB/LH/LBU/LHU`、`SB/SH`、`EBREAK/ECALL` 等指令，并遵循 ABI (Application Binary Interface) 等规范。本最小子集暂不涉及此内容。  

---

## 8. 伪指令（可选）

在汇编层面，可以引入一些常见的“伪指令”（Assembler Pseudoinstruction）简化编程。例如：

- **NOP**： `ADDI x0, x0, 0` （不做任何操作）  
- **LI rd, 立即数**： 编译器往往会拆分为：  
  - `LUI rd, high20(立即数)`  
  - `ADDI rd, rd, low12(立即数)`  
- **MV rd, rs**： `ADDI rd, rs, 0`  

这些伪指令不会增加硬件实现复杂度，因为硬件仍然只需要支持前述的真实指令即可。

---

## 9. 总结

以上即为一个精简的 RISC-V 32 位指令子集（可称为 “RV32I-minimal”）。它具备：

- **算术/逻辑**：`ADD, SUB, AND, OR, XOR, SLT, ADDI`  
- **跳转/分支**：`JAL, BEQ`  
- **加载/存储**：`LW, SW`  
- **上半立即数**：`LUI`  

通过这组指令，已经可以完成大多数初级的功能：  
- 使用 `ADD`/`SUB`/`ADDI` 做加减运算或地址计算；  
- 使用 `AND`/`OR`/`XOR`/`SLT` 等实现逻辑与简单比较；  
- 使用 `LW`/`SW` 存取 32 位数据；  
- 使用 `BEQ` 进行条件分支；  
- 使用 `JAL` 进行函数调用与返回；  
- 使用 `LUI + ADDI` 组合得到大于 12 位的常量或地址。  

---

## 10. 指令二进制编码

以下表格给出本子集指令的关键编码位（opcode / funct3 / funct7），寄存器与立即数位段请根据具体指令格式填入：

| 指令 | opcode   | funct3 | funct7  | 备注                    |
|-----|----------|--------|---------|-------------------------|
| ADD | 0110011  | 000    | 0000000 | R-type: rd ← rs1 + rs2  |
| SUB | 0110011  | 000    | 0100000 | R-type: rd ← rs1 - rs2  |
| AND | 0110011  | 111    | 0000000 | R-type: rd ← rs1 AND rs2|
| OR  | 0110011  | 110    | 0000000 | R-type: rd ← rs1 OR rs2 |
| XOR | 0110011  | 100    | 0000000 | R-type: rd ← rs1 XOR rs2|
| SLT | 0110011  | 010    | 0000000 | R-type: 有符号比较小于置 1|
| ADDI| 0010011  | 000    | -       | I-type: 12 位立即数     |
| BEQ | 1100011  | 000    | -       | B-type: rs1 == rs2 跳转 |
| JAL | 1101111  | -      | -       | J-type: rd ← PC+4; 跳转  |
| LW  | 0000011  | 010    | -       | I-type: rd ← Mem(...)   |
| SW  | 0100011  | 010    | -       | S-type: Mem(...) ← rs2  |
| LUI | 0110111  | -      | -       | U-type: rd ← imm<<12    |

---
### 参考资料

- The RISC-V Instruction Set Manual Volume I: Unprivileged ISA  - RISC-V 组织官方网站 <https://riscv.org/>
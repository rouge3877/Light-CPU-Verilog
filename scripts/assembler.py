#!/usr/bin/python3
import sys

# 根据 specification 中给出的指令(opcode, funct3, funct7)
INSTR_INFO = {
    "ADD":  ("0110011", "000", "0000000", "R"),
    "SUB":  ("0110011", "000", "0100000", "R"),
    "AND":  ("0110011", "111", "0000000", "R"),
    "OR":   ("0110011", "110", "0000000", "R"),
    "XOR":  ("0110011", "100", "0000000", "R"),
    "SLT":  ("0110011", "010", "0000000", "R"),
    "ADDI": ("0010011", "000", None,      "I"),
    "BEQ":  ("1100011", "000", None,      "B"),
    "JAL":  ("1101111", None,  None,      "J"),
    "LW":   ("0000011", "010", None,      "I"),
    "SW":   ("0100011", "010", None,      "S"),
    "LUI":  ("0110111", None,  None,      "U"),
}

def reg_num(r):
    # 简化：假设 x0, x1, x2... 直接取后面的数字
    return int(r.strip().lower().replace('x',''))

def imm_12(imm_str):
    val = int(imm_str)
    return ((val & 0xFFF) if val >= 0 else (0x1000 + (val & 0xFFF)))

def compile_line(line):
    parts = line.replace(',', ' ').split()
    if not parts:
        return None
    instr = parts[0].upper()
    if instr not in INSTR_INFO:
        return None
    opcode, funct3, funct7, ftype = INSTR_INFO[instr]

    if ftype == "R":
        # e.g. ADD rd, rs1, rs2
        # R-type: [funct7(7 bits) | rs2(5) | rs1(5) | funct3(3) | rd(5) | opcode(7)]
        rd, rs1, rs2 = parts[1:4]
        r_rd = reg_num(rd)
        r_rs1 = reg_num(rs1)
        r_rs2 = reg_num(rs2)
        machine = (
            f"{funct7}"
            f"{r_rs2:05b}"
            f"{r_rs1:05b}"
            f"{funct3}"
            f"{r_rd:05b}"
            f"{opcode}"
        )
        return machine

    elif ftype == "I":
        # e.g. ADDI rd, rs1, imm / LW rd, offset(rs1)
        # I-type: [imm(12) | rs1(5) | funct3(3) | rd(5) | opcode(7)]
        if instr == "LW":
            # LW rd, imm(rs1)
            # e.g. LW x2, 8(x1)
            rd = parts[1]
            offset, rs1 = parts[2].split('(')
            rs1 = rs1.strip(')')
            r_rd = reg_num(rd)
            r_rs1 = reg_num(rs1)
            imm_val = imm_12(offset)
        else:
            # e.g. ADDI x1, x2, 123
            rd = parts[1]
            rs1 = parts[2]
            imm_val = imm_12(parts[3])
            r_rd = reg_num(rd)
            r_rs1 = reg_num(rs1)
        imm_bin = f"{imm_val:012b}"
        machine = (
            f"{imm_bin}"
            f"{r_rs1:05b}"
            f"{funct3 if funct3 else '000'}"
            f"{r_rd:05b}"
            f"{opcode}"
        )
        return machine

    elif ftype == "S":
        # e.g. SW rs2, imm(rs1)
        # S-type: [imm(7) | rs2(5) | rs1(5) | funct3(3) | imm(5) | opcode(7)]
        rs2 = parts[1]
        offset, rs1 = parts[2].split('(')
        rs1 = rs1.strip(')')
        r_rs2 = reg_num(rs2)
        r_rs1 = reg_num(rs1)
        val = int(offset)
        imm_high = (val >> 5) & 0x7F
        imm_low  = val & 0x1F
        machine = (
            f"{imm_high:07b}"
            f"{r_rs2:05b}"
            f"{r_rs1:05b}"
            f"{funct3 if funct3 else '000'}"
            f"{imm_low:05b}"
            f"{opcode}"
        )
        return machine

    elif ftype == "B":
        # e.g. BEQ rs1, rs2, offset
        # B-type: [imm[12|10:5] | rs2(5) | rs1(5) | funct3(3) | imm[4:1|11] | opcode(7)]
        rs1 = parts[1]
        rs2 = parts[2]
        offset = int(parts[3])
        r_rs1 = reg_num(rs1)
        r_rs2 = reg_num(rs2)
        imm_12_val = (offset >> 12) & 0x1
        imm_10_5 = (offset >> 5) & 0x3F
        imm_4_1 = (offset >> 1) & 0xF
        imm_11 = (offset >> 11) & 0x1
        machine = (
            f"{imm_12_val:01b}"
            f"{imm_10_5:06b}"
            f"{r_rs2:05b}"
            f"{r_rs1:05b}"
            f"{funct3 if funct3 else '000'}"
            f"{imm_4_1:04b}"
            f"{imm_11:01b}"
            f"{opcode}"
        )
        return machine

    elif ftype == "J":
        # e.g. JAL rd, offset
        # J-type: [imm[20|10:1|11|19:12] | rd(5) | opcode(7)]
        rd = parts[1]
        offset = int(parts[2])
        r_rd = reg_num(rd)
        imm_20 = (offset >> 20) & 0x1
        imm_10_1 = (offset >> 1) & 0x3FF
        imm_11 = (offset >> 11) & 0x1
        imm_19_12 = (offset >> 12) & 0xFF
        machine = (
            f"{imm_20:01b}"
            f"{imm_10_1:010b}"
            f"{imm_11:01b}"
            f"{imm_19_12:08b}"
            f"{r_rd:05b}"
            f"{opcode}"
        )
        return machine

    elif ftype == "U":
        # e.g. LUI rd, imm
        # U-type: [imm(20) | rd(5) | opcode(7)]
        rd = parts[1]
        imm_val = int(parts[2]) & 0xFFFFF
        r_rd = reg_num(rd)
        machine = (
            f"{imm_val:020b}"
            f"{r_rd:05b}"
            f"{opcode}"
        )
        return machine

    return None

def main():
    for line in sys.stdin:
        if not line.strip():
            continue
        mc = compile_line(line)
        if mc:
            # 将二进制字符串转换为整数
            machine_int = int(mc, 2)
            # 转换为4个字节的小端序
            machine_bytes = machine_int.to_bytes(4, byteorder='little')
            # 逐字节以16进制格式输出，每个字节占一行
            for b in machine_bytes:
                print(f"{b:02X}")
        else:
            print(f"无法编译: {line.strip()}")

if __name__ == "__main__":
    main()

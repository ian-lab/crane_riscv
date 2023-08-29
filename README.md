# crane_riscv
make a sample riscv core

## 1、简介

crane_risc core具有三级流水线，取指-译码-执行-访存-写回，顺序执行，实现RV32I指令集

## 2、riscv指令集

RISC-V包括三种基本的指令集：RV32I，RV32E 以及 RV64I。RV32I 是32位地址空间标准的指令集，RV32E 是 RV32I 的变种，寄存器的数量更少，面向一些深度定制的简单嵌入式系统。RV64I 是64位地址空间标准的指令集。

RV32I 是基本的32位整数指令集，包含47种指令。RV32I足以提供给现代操作系统足够的基本支持以及作为编译器的编译目标。指令集中有 8 个指令用于系统指令，可以被实现为单一的陷阱指令。剩下的指令可以分为运算指令、控制指令以及内存交互指令三种。

RISC-V基于加载-存储结构，算术指令只能在寄存器上操作，内存中的数据只能读取和加载。

RV32I有31个通用整型寄存器，命名为 x1 - x31，每个的位宽为32位。x0被命名为常数0，它也可以被作为目标寄存器来舍弃指令执行的结果。PC是寄存器x32。整个寄存器的组织如下：

<img src="https://raw.githubusercontent.com/ian-lab/typorapic/master/RV32I-register-file-model.jpg" alt="img" style="zoom:67%;" />

RV32I的指令长度为32位，并且需要在内存中对齐存储，并且是小端存储。一共有6种指令格式：R、I、S、U以及变种 SB、UJ，如下所示：

![img](https://raw.githubusercontent.com/ian-lab/typorapic/master/RV32I-instruction-formats.jpg)

### R  TYPE

<img src="https://img-blog.csdnimg.cn/61944c4e98ed4016afe3f1d04e72d2d1.png" alt="在这里插入图片描述" style="zoom:150%;" />

```c
ADD  rd, rs1, rs2   // x[rd] = x[rs1] + x[rs2]
SUB  rd, rs1, rs2   // x[rd] = x[rs1] - x[rs2]
SLL  rd, rs1, rs2   // x[rd] = x[rs1] << x[rs2]
SLT  rd, rs1, rs2   // x[rd] = signed x[rs1] < x[rs2]
SLTU rd, rs1, rs2   // x[rd] = unsigned x[rs1] < x[rs2]
XOR  rd, rs1, rs2   // x[rd] = x[rs1] ^ x[rs2]
SRL  rd, rs1, rs2   // x[rd] = x[rs1] >> x[rs2]
SRA  rd, rs1, rs2   // x[rd] = x[rs1] >>> x[rs2]
OR   rd, rs1, rs2   // x[rd] = x[rs1] | x[rs2]
AND  rd, rs1, rs2   // x[rd] = x[rs1] & x[rs2]
```
### I  TYPE
<img src="https://img-blog.csdnimg.cn/c35e981fa3ad4380a0989ee34e11ad2f.png" alt="在这里插入图片描述" style="zoom:150%;" />

```c
ADDI  rd, rs1, immediate  // x[rd] = x[rs1] + x[rs2]
SLT   rd, rs1, immediate  // x[rd] = signed x[rs1] < x[rs2]
SLTIU rd, rs1, immediate  // x[rd] = unsigned x[rs1] < x[rs2]
XORI  rd, rs1, immediate  // x[rd] = x[rs1] ^ x[rs2]
ORI   rd, rs1, immediate  // x[rd] = x[rs1] | x[rs2]
ANDI  rd, rs1, immediate  // x[rd] = x[rs1] & x[rs2]
SLLI  rd, rs1, shamt      // x[rd] = x[rs1] << shamt
SRLI  rd, rs1, shamt      // x[rd] = x[rs1] >> shamt
SRAI  rd, rs1, shamt      // x[rd] = x[rs1] >>> shamt
```
### I_L  TYPE
<img src="https://img-blog.csdnimg.cn/0440e5fdb44a45f0aed305fa8a31ea04.png" alt="在这里插入图片描述" style="zoom:150%;" />

```C
// 该指令是从有效地址中读取一个字节(byte)，经符号位扩展后写入rd寄存器。
LB rd, immediate(rs1) // x[rd] = Mem[rs1 + immediate][31:0]
// 该指令是从有效地址中读取两个字节(halfword)，经符号位扩展后写入rd寄存器。
LH rd, immediate(rs1) // x[rd] = Mem[rs1 + immediate][31:0] 
// 该指令是从有效地址中读取四个字节(word)，经符号位扩展后写入rd寄存器。
LW rd, immediate(rs1) // x[rd] = Mem[rs1 + immediate][31:0]
// 该指令是从有效地址中读取一个字节(byte)，经零扩展后写入rd寄存器。
LBU rd, immediate(rs1) // x[rd] = Mem[rs1 + immediate][31:0]
// 该指令是从有效地址中读取两个字节(halfword)，经零扩展后写入rd寄存器。
LHU rd, immediate(rs1) // x[rd] = Mem[rs1 + immediate][31:0]
```
### S  TYPE
<img src="https://img-blog.csdnimg.cn/e2c80f3622854a1da6a9a0141dfc0876.png" alt="在这里插入图片描述" style="zoom:150%;" />

```c
SB rs2, immediate(rs1) //Mem[rs1 + immediate] = rs2[ 7:0]
SH rs2, immediate(rs1) //Mem[rs1 + immediate] = rs2[15:0]
SW rs2, immediate(rs1) //Mem[rs1 + immediate] = rs2[31:0]
```
### B/SB  TYPE
![在这里插入图片描述](https://img-blog.csdnimg.cn/3c5e7110b8644623821df637dd4f7914.png)

```C
BEQ rs1，rs2，immediate  // if (rs1 == rs2)   pc += sext(immediate )
BNE rs1，rs2，immediate  // if (rs1 != rs2)   pc += sext(immediate )
BLT rs1，rs2，immediate  // if (rs1 <  rs2)   pc += sext(immediate )
BGE rs1，rs2，immediate  // if (rs1 >= rs2)   pc += sext(immediate )
BLTU rs1，rs2，immediate // if (unsigned rs1 <  unsigned rs2)   pc += sext(immediate )
BGEU rs1，rs2，immediate // if (unsigned rs1 >= unsigned rs2)   pc += sext(immediate )
```
### J/UJ  TYPE
<img src="https://img-blog.csdnimg.cn/1acfd1ee84764caba39e8c5a5e738870.png" alt="在这里插入图片描述" style="zoom:150%;" />

```c
JAL rd, immediate        // x[rd] = pc+4; pc += sext(immediate)
JALR rd, immediate(rs1)  // t = pc + 4;  pc = (x[rs1]+sext(immediate)) & 0xffff_fffe;  x[rd]=t 
```
### U  TYPE
<img src="https://img-blog.csdnimg.cn/59a3bfcb2338486784abed8077d3eb31.png" alt="在这里插入图片描述" style="zoom:150%;" />

```c
LUI rd，immediate   // x[rd] = sext(immediate[31:12] << 12)
AUIPC rd，immediate // x[rd] = pc + sext(immediate[31:12] << 12)
```
## 硬件架构


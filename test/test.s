.section .text
.global _start

_start:
    li a0, 5       # a0 = 5
    li a1, 10      # a1 = 10
    li a2, 20      # a2 = 20

    add a0, a0, a1 # a0 = a0 + a1 (5 + 10)
    add a0, a0, a2 # a0 = a0 + a2 (15 + 20)

    # 将结果转换为字符串并打印
    addi sp, sp, -16  # 分配栈空间
    sw a0, 0(sp)      # 存储结果
    li a7, 34         # syscall: print integer
    ecall

    # 退出程序
    li a7, 93  # syscall: exit
    li a0, 0   # 退出码 0
    ecall

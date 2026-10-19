
.data
pitches:     .word 64, 64, 65, 67, 67, 65, 64, 62, 60, 60, 62, 64, 64, 62, 62
durations:   .word  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  3,  1,  4
num_notes:   .word 15

# Tham so ca nhan: a = 5, b = 2
param_a:     .word 5
unit_ms:     .word 170   # 150 + 10*2
instrument:  .word 40    # b % 4 = 2 -> instrument 40 (Violin)
volume:      .word 100

space:       .asciiz " "
newline:     .asciiz "\n"
str_exp:     .asciiz "Tong du kien (ms): "
str_meas:    .asciiz "Thoi gian do duoc (ms): "

.text
.globl main

main:
    # Do thoi gian bat dau
    li $v0, 30
    syscall
    move $s6, $a0

    li $s0, 0            # i = 0
    lw $s1, num_notes    # N = 15
    li $s7, 0            # sum_expected_ms = 0

    la $s2, pitches
    la $s3, durations
    lw $s4, param_a
    lw $s5, unit_ms

note_loop:
    beq $s0, $s1, note_done

    sll $t0, $s0, 2
    addu $t1, $s2, $t0
    lw $t2, 0($t1)
    add $a0, $t2, $s4    # Pitch thuc = pitch + a

    addu $t1, $s3, $t0
    lw $t3, 0($t1)
    mul $a1, $t3, $s5    

    add $s7, $s7, $a1    # Tich luy thoi gian du kien

    lw $a2, instrument
    lw $a3, volume

    move $t6, $a0
    move $t7, $a1

    # In: <cao do> <ms>
    li $v0, 1
    syscall

    la $a0, space
    li $v0, 4
    syscall

    move $a0, $t7
    li $v0, 1
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    move $a0, $t6
    move $a1, $t7

    # Syscall 33 (phat va cho)
    li $v0, 33
    syscall

    addi $s0, $s0, 1
    j note_loop

note_done:
    # Do thoi gian ket thuc
    li $v0, 30
    syscall
    sub $s5, $a0, $s6    # t_measured = t_end - t_start

    # In Tong du kien
    la $a0, str_exp
    li $v0, 4
    syscall
    move $a0, $s7
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall

    # In Thoi gian do duoc
    la $a0, str_meas
    li $v0, 4
    syscall
    move $a0, $s5
    li $v0, 1
    syscall
    la $a0, newline
    li $v0, 4
    syscall

    li $v0, 10
    syscall

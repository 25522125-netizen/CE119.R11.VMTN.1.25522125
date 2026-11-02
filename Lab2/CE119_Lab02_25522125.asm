.data
    # 1. DU LIEU TN2

    S:          .word 0, 8, 2, 3, 7, 10, 1, 7, 0, 3, 9, 8
    S_len:      .word 12
    grade_tab:  .byte 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3
    hist:       .word 0, 0, 0, 0

    str_min:    .asciiz "min="
    str_max:    .asciiz " max="
    str_g0:     .asciiz "g0="
    str_g1:     .asciiz " g1="
    str_g2:     .asciiz " g2="
    str_g3:     .asciiz " g3="
    str_nl:     .asciiz "\n"

    # Nhan cho thu tuc draw_hist
    str_dh0:    .asciiz "g0: "
    str_dh1:    .asciiz "g1: "
    str_dh2:    .asciiz "g2: "
    str_dh3:    .asciiz "g3: "

    # 2. DU LIEU TN3 (Chuoi ngoac ca nhan P voi k = 8)

    str_testP:  .asciiz "([{([{([])}])}])"
    str_res_v0: .asciiz "TN3 Result -> v0 (Index) = "
    str_res_v1: .asciiz ", v1 (Code) = "

.text
.globl main

main:

    # PHAN 1: CHAY THU NGHIEM TN2

    # 1.1 Goi stats(S, 12)
    la   $a0, S
    lw   $a1, S_len
    jal  stats
    move $s0, $v0
    move $s1, $v1

    # In min, max
    la   $a0, str_min
    li   $v0, 4
    syscall
    move $a0, $s0
    li   $v0, 1
    syscall
    la   $a0, str_max
    li   $v0, 4
    syscall
    move $a0, $s1
    li   $v0, 1
    syscall
    la   $a0, str_nl
    li   $v0, 4
    syscall

    # 1.2 Goi histogram(S, 12, grade_tab, hist)
    la   $a0, S
    lw   $a1, S_len
    la   $a2, grade_tab
    la   $a3, hist
    jal  histogram

    # In histogram dang so (g0, g1, g2, g3)
    la   $t0, hist
    la   $a0, str_g0
    li   $v0, 4
    syscall
    lw   $a0, 0($t0)
    li   $v0, 1
    syscall

    la   $a0, str_g1
    li   $v0, 4
    syscall
    lw   $a0, 4($t0)
    li   $v0, 1
    syscall

    la   $a0, str_g2
    li   $v0, 4
    syscall
    lw   $a0, 8($t0)
    li   $v0, 1
    syscall

    la   $a0, str_g3
    li   $v0, 4
    syscall
    lw   $a0, 12($t0)
    li   $v0, 1
    syscall

    la   $a0, str_nl
    li   $v0, 4
    syscall

    # PHAN MO RONG: GOI DRAW_HIST VE BIEU DO COT NGANG

    la   $a0, hist
    li   $a1, 4
    jal  draw_hist

    # PHAN 2: CHAY THU NGHIEM TN3 (KIEM TRA NGOAC CAN BANG)

    la   $a0, str_testP
    jal  check_brackets
    move $s2, $v0               # Luu vi tri loi v0
    move $s3, $v1               # Luu ma loi v1

    # In ket qua TN3
    la   $a0, str_res_v0
    li   $v0, 4
    syscall
    move $a0, $s2
    li   $v0, 1
    syscall

    la   $a0, str_res_v1
    li   $v0, 4
    syscall
    move $a0, $s3
    li   $v0, 1
    syscall

    la   $a0, str_nl
    li   $v0, 4
    syscall

    # Thoat chuong trinh
    li   $v0, 10
    syscall


# THU TUC STATS (TN2)

stats:
    lw   $v0, 0($a0)
    lw   $v1, 0($a0)
    move $t0, $a0
    move $t1, $a1
stats_loop:
    beq  $t1, $zero, stats_done
    lw   $t2, 0($t0)
    bge  $t2, $v0, check_max
    move $v0, $t2
check_max:
    ble  $t2, $v1, stats_next
    move $v1, $t2
stats_next:
    addi $t0, $t0, 4
    addi $t1, $t1, -1
    j    stats_loop
stats_done:
    jr   $ra


# THU TUC HISTOGRAM (TN2)

histogram:
    move $t0, $a0
    move $t1, $a1
hist_loop:
    beq  $t1, $zero, hist_done
    lw   $t2, 0($t0)
    add  $t3, $a2, $t2
    lbu  $t4, 0($t3)
    sll  $t5, $t4, 2
    add  $t5, $a3, $t5
    lw   $t6, 0($t5)
    addi $t6, $t6, 1
    sw   $t6, 0($t5)
    addi $t0, $t0, 4
    addi $t1, $t1, -1
    j    hist_loop
hist_done:
    jr   $ra


# THU TUC CHECK_BRACKETS (TN3)

check_brackets:
    move $t9, $sp               # Luu $sp ban dau
    move $t0, $a0
    li   $t1, 0                 # Bien dem vi tri ky tu

cb_loop:
    lb   $t2, 0($t0)
    beq  $t2, $zero, cb_eos
    addi $t1, $t1, 1

    # Ngoac mo: push vao stack
    li   $t3, 40                # '('
    beq  $t2, $t3, cb_push
    li   $t3, 91                # '['
    beq  $t2, $t3, cb_push
    li   $t3, 123               # '{'
    beq  $t2, $t3, cb_push

    # Ngoac dong: kiem tra va pop
    li   $t3, 41                # ')'
    beq  $t2, $t3, cb_close
    li   $t3, 93                # ']'
    beq  $t2, $t3, cb_close
    li   $t3, 125               # '}'
    beq  $t2, $t3, cb_close

    j    cb_next

cb_push:
    addi $sp, $sp, -4
    sw   $t2, 0($sp)
    j    cb_next

cb_close:
    beq  $sp, $t9, cb_err2      # Stack rong nhung gap ngoac dong -> Loi 2
    lw   $t4, 0($sp)
    addi $sp, $sp, 4

    # Kiem tra loai ngoac co khop khong
    li   $t3, 41
    beq  $t2, $t3, m_paren
    li   $t3, 93
    beq  $t2, $t3, m_brack
    li   $t3, 125
    beq  $t2, $t3, m_brace

m_paren:
    li   $t3, 40
    bne  $t4, $t3, cb_err1
    j    cb_next
m_brack:
    li   $t3, 91
    bne  $t4, $t3, cb_err1
    j    cb_next
m_brace:
    li   $t3, 123
    bne  $t4, $t3, cb_err1
    j    cb_next

cb_next:
    addi $t0, $t0, 1
    j    cb_loop

cb_eos:
    bne  $sp, $t9, cb_err3      # Het chuoi nhung stack con ngoac mo -> Loi 3
    li   $v0, 0
    li   $v1, 0
    jr   $ra

cb_err1:
    move $sp, $t9
    move $v0, $t1
    li   $v1, 1
    jr   $ra
cb_err2:
    move $sp, $t9
    move $v0, $t1
    li   $v1, 2
    jr   $ra
cb_err3:
    move $sp, $t9
    move $v0, $t1
    li   $v1, 3
    jr   $ra


# THU TUC DRAW_HIST (PHAN MO RONG)

draw_hist:
    addi $sp, $sp, -16
    sw   $s0, 0($sp)
    sw   $s1, 4($sp)
    sw   $s2, 8($sp)
    sw   $s3, 12($sp)

    move $s0, $a0               # Dia chi mang hist
    move $s1, $a1               # So nhom (4)
    li   $s2, 0                 # i = 0

dh_group_loop:
    beq  $s2, $s1, dh_done

    la   $a0, str_dh0
    beq  $s2, 0, print_label
    la   $a0, str_dh1
    beq  $s2, 1, print_label
    la   $a0, str_dh2
    beq  $s2, 2, print_label
    la   $a0, str_dh3

print_label:
    li   $v0, 4
    syscall

    sll  $t0, $s2, 2            # offset = i * 4
    add  $t0, $s0, $t0
    lw   $s3, 0($t0)            # $s3 = hist[i]

dh_char_loop:
    beq  $s3, $zero, dh_next_group
    li   $a0, 124               # Ky tu '|' (ASCII 124)
    li   $v0, 11
    syscall
    addi $s3, $s3, -1
    j    dh_char_loop

dh_next_group:
    la   $a0, str_nl            # Xuong dong
    li   $v0, 4
    syscall
    addi $s2, $s2, 1
    j    dh_group_loop

dh_done:
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    addi $sp, $sp, 16
    jr   $ra

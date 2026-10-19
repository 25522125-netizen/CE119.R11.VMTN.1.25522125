.data
prompt:      .asciiz "Nhap so kWh (0..9999): "
err_msg:     .asciiz "Gia tri khong hop le, nhap lai.\n"
res_prefix:  .asciiz "Tien dien: "
res_suffix:  .asciiz " dong\n"


limits:      .word 50, 100, 200, 300, 400, 9999
rates:       .word 1700, 1760, 2050, 2600, 2950, 3100

.text
.globl main

main:
input_loop:
    la $a0, prompt
    li $v0, 4
    syscall

    li $v0, 5
    syscall
    move $s0, $v0        # $s0 = x

    
    sltiu $t0, $s0, 10000
    bnez $t0, valid_input

    la $a0, err_msg
    li $v0, 4
    syscall
    j input_loop

valid_input:
    li $s1, 0            # sum = 0
    li $s2, 0            # i = 0
    li $s3, 0            # prev_limit = 0
    la $s4, limits
    la $s5, rates

calc_loop:
    sll $t0, $s2, 2      # offset = i * 4
    
    addu $t1, $s4, $t0
    lw $t2, 0($t1)       # $t2 = limits[i]
    
    addu $t1, $s5, $t0
    lw $t3, 0($t1)       # $t3 = rates[i]

    ble $s0, $t2, last_tier

   
    sub $t4, $t2, $s3    # kwh_tier = limits[i] - prev_limit
    mul $t5, $t4, $t3    # cost = kwh_tier * rates[i]
    add $s1, $s1, $t5    # sum += cost
    move $s3, $t2        # prev_limit = limits[i]

    addi $s2, $s2, 1
    j calc_loop

last_tier:
  
    sub $t4, $s0, $s3    # kwh_tier = x - prev_limit
    mul $t5, $t4, $t3    # cost = kwh_tier * rates[i]
    add $s1, $s1, $t5    # sum += cost

print_result:
    la $a0, res_prefix
    li $v0, 4
    syscall

    move $a0, $s1
    li $v0, 1
    syscall

    la $a0, res_suffix
    li $v0, 4
    syscall

    li $v0, 10
    syscall

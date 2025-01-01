.data
displayBuffer:  .space 0x40000
errorBuffer:    .space 0x40000
templateBuffer: .space 0x100
imageFileName:    .asciiz "banner.raw" 
templateFileName: .asciiz "waldo.raw"
# struct bufferInfo { int *buffer, int width, int height, char* filename }
imageBufferInfo:    .word displayBuffer  512 128  imageFileName
errorBufferInfo:    .word errorBuffer    512 128  0
templateBufferInfo: .word templateBuffer 8   8    templateFileName

.text
main:	la $a0, imageBufferInfo
	jal loadImage
	la $a0, templateBufferInfo
	jal loadImage
	la $a0, imageBufferInfo
	la $a1, templateBufferInfo
	la $a2, errorBufferInfo
	jal matchTemplate
	la $a0, errorBufferInfo
	jal findBest
	la $a0, imageBufferInfo
	move $a1, $v0
	jal highlight
	la $a0, errorBufferInfo	
	jal processError
	li $v0, 10		# exit
	syscall
	

##########################################################
# matchTemplate( bufferInfo imageBufferInfo, bufferInfo templateBufferInfo, bufferInfo errorBufferInfo )
matchTemplate:

    addi $sp, $sp, -32
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    sw $s5, 24($sp)
    sw $s6, 28($sp)

    lw $t0, 0($a0)
    lw $t1, 4($a0)
    lw $t2, 8($a0)
    lw $t3, 0($a1)
    lw $t4, 0($a2)

    addi $s1, $t1, -8
    addi $s2, $t2, -8

    li $s3, 0
outer_y_loop:
    bgt $s3, $s2, end_matchTemplate

    li $s4, 0
middle_x_loop:
    bgt $s4, $s1, next_y

    mul $t5, $s3, $t1
    add $t5, $t5, $s4
    sll $t5, $t5, 2
    add $s0, $t4, $t5
    sw $zero, 0($s0)

    li $s5, 0
inner_j_loop:
    bge $s5, 8, middle_x_next

    li $s6, 0
inner_i_loop:
    bge $s6, 8, next_j 

    add $t6, $s3, $s5
    mul $t6, $t6, $t1
    add $t6, $t6, $s4 
    add $t6, $t6, $s6
    sll $t6, $t6, 2  
    add $t6, $t0, $t6

    mul $t7, $s5, 8
    add $t7, $t7, $s6
    sll $t7, $t7, 2
    add $t7, $t3, $t7

    lbu $t8, 0($t6)
    lbu $t9, 0($t7)

    sub $t8, $t8, $t9
    bltz $t8, abs_diff
    j skip_abs
abs_diff:
    neg $t8, $t8
skip_abs:

    lw $t9, 0($s0)
    add $t9, $t9, $t8
    sw $t9, 0($s0)

    addi $s6, $s6, 1
    j inner_i_loop

next_j:
    addi $s5, $s5, 1
    j inner_j_loop

middle_x_next:
    addi $s4, $s4, 1
    j middle_x_loop

next_y:
    addi $s3, $s3, 1
    j outer_y_loop

end_matchTemplate:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    lw $s6, 28($sp)
    addi $sp, $sp, 32
    jr $ra


	
##########################################################
# matchTemplateFast( bufferInfo imageBufferInfo, bufferInfo templateBufferInfo, bufferInfo errorBufferInfo )
matchTemplateFast:	
	
    addi $sp, $sp, -68
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    sw $s5, 24($sp)
    sw $s6, 28($sp)
    sw $s7, 32($sp)

    lw $s0, 0($a0)
    lw $s1, 0($a1)
    lw $s2, 0($a2)
    lw $s3, 4($a0)
    lw $s4, 8($a0)

    li $s7, 0
outer_j_loop:
    bge $s7, 8, end_matchTemplateFast
    
    mul $t0, $s7, 8
    sll $t0, $t0, 2
    add $t0, $s1, $t0
    lbu $t1, 0($t0)          
    sb $t1, 36($sp)
    
    addi $t0, $t0, 4
    lbu $t1, 0($t0)          
    sb $t1, 40($sp)
    
    addi $t0, $t0, 4
    lbu $t1, 0($t0)          
    sb $t1, 44($sp)
    
    addi $t0, $t0, 4
    lbu $t1, 0($t0)          
    sb $t1, 48($sp)
    
    addi $t0, $t0, 4
    lbu $t1, 0($t0)          
    sb $t1, 52($sp)
    
    addi $t0, $t0, 4
    lbu $t1, 0($t0)          
    sb $t1, 56($sp)
    
    addi $t0, $t0, 4
    lbu $t1, 0($t0)          
    sb $t1, 60($sp)
    
    addi $t0, $t0, 4
    lbu $t1, 0($t0)          
    sb $t1, 64($sp)
    
    li $s5, 0
middle_y_loop:
    subi $t0, $s4, 8
    bgt $s5, $t0, next_j_2
    
    li $s6, 0
inner_x_loop:
    subi $t1, $s3, 8
    bgt $s6, $t1, next_y_2
    
    li $t2, 0
    
    mul $t3, $s5, $s3
    add $t3, $t3, $s6
    sll $t3, $t3, 2
    add $t9, $s2, $t3
    
    bgt $s7, $zero, sum_abs_2
    sw $zero, 0($t9)

sum_abs_2:
    
    add $t8, $s5, $s7
    mul $t8, $t8, $s3
    add $t8, $t8, $s6
    subi $t8, $t8, 1
    
    addi $t3, $sp, 32
    
    addi $t8, $t8, 1
    sll $t4, $t8, 2  
    add $t4, $s0, $t4
    lbu $t5, 0($t4)
    
    addi $t3, $t3, 4
    lbu $t6, 0($t3)
    
    sub $t7, $t5, $t6
    abs $t7, $t7             
    add $t2, $t2, $t7

    addi $t8, $t8, 1
    sll $t4, $t8, 2  
    add $t4, $s0, $t4
    lbu $t5, 0($t4)
    
    addi $t3, $t3, 4
    lbu $t6, 0($t3)
    
    sub $t7, $t5, $t6
    abs $t7, $t7             
    add $t2, $t2, $t7
    
    addi $t8, $t8, 1
    sll $t4, $t8, 2  
    add $t4, $s0, $t4
    lbu $t5, 0($t4)
    
    addi $t3, $t3, 4
    lbu $t6, 0($t3)
    
    sub $t7, $t5, $t6
    abs $t7, $t7             
    add $t2, $t2, $t7
    
    addi $t8, $t8, 1
    sll $t4, $t8, 2  
    add $t4, $s0, $t4
    lbu $t5, 0($t4)
    
    addi $t3, $t3, 4
    lbu $t6, 0($t3)
    
    sub $t7, $t5, $t6
    abs $t7, $t7             
    add $t2, $t2, $t7
    
    addi $t8, $t8, 1
    sll $t4, $t8, 2  
    add $t4, $s0, $t4
    lbu $t5, 0($t4)
    
    addi $t3, $t3, 4
    lbu $t6, 0($t3)
    
    sub $t7, $t5, $t6
    abs $t7, $t7             
    add $t2, $t2, $t7
    
    addi $t8, $t8, 1
    sll $t4, $t8, 2  
    add $t4, $s0, $t4
    lbu $t5, 0($t4)
    
    addi $t3, $t3, 4
    lbu $t6, 0($t3)
    
    sub $t7, $t5, $t6
    abs $t7, $t7             
    add $t2, $t2, $t7
    
    addi $t8, $t8, 1
    sll $t4, $t8, 2  
    add $t4, $s0, $t4
    lbu $t5, 0($t4)
    
    addi $t3, $t3, 4
    lbu $t6, 0($t3)
    
    sub $t7, $t5, $t6
    abs $t7, $t7             
    add $t2, $t2, $t7
    
    addi $t8, $t8, 1
    sll $t4, $t8, 2  
    add $t4, $s0, $t4
    lbu $t5, 0($t4)
    
    addi $t3, $t3, 4
    lbu $t6, 0($t3)
    
    sub $t7, $t5, $t6
    abs $t7, $t7             
    add $t2, $t2, $t7
    
    lw $t8, 0($t9)
    add $t8, $t8, $t2
    sw $t8, 0($t9)
    
    addi $s6, $s6, 1
    j inner_x_loop
    
next_y_2:
    addi $s5, $s5, 1
    j middle_y_loop
    
next_j_2:
    addi $s7, $s7, 1
    j outer_j_loop
    

end_matchTemplateFast:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    lw $s6, 28($sp)
    lw $s7, 32($sp)
    addi $sp, $sp, 68
    jr $ra
	
	
###############################################################
# loadImage( bufferInfo* imageBufferInfo )
loadImage:	lw $a3, 0($a0)
		lw $a1, 4($a0)
		lw $a2, 8($a0)
		lw $a0, 12($a0)
		mul $t0, $a1, $a2
		sll $t0, $t0, 2
		li $a1, 0
		li $a2, 0
		li $v0, 13
		syscall
		move $a0, $v0
  		move $a1, $a3
		move $a2, $t0
		li  $v0, 14
		syscall
		move $t0, $a3
		add $t1, $a3, $a2
loadloop:	lw $t2, ($t0)
		sw $t2, ($t0)
		addi $t0, $t0, 4
		bne $t0, $t1, loadloop
		jr $ra
		
		
#####################################################
findBest:	lw $t0, 0($a0)	
		lw $t2, 4($a0)
		lw $t3, 8($a0)
		addi $t3, $t3, -7
		mul $t1, $t2, $t3
		sll $t1, $t1, 2
		add $t1, $t0, $t1
		li $v0, 0
		li $v1, 0xffffffff
		lw $a1, 4($a0)
        addi $a1, $a1, -7
fbLoop:	lw $t9, 0($t0)
		sltu $t8, $t9, $v1
		beq $t8, $zero, notBest
		move $v0, $t0
		move $v1, $t9
notBest: addi $a1, $a1, -1
		bne $a1, $0, fbNotEOL
		lw $a1, 4($a0)
        addi $a1, $a1, -7
        addi $t0, $t0, 28
fbNotEOL: add $t0, $t0, 4
		bne $t0, $t1, fbLoop
		lw $t0, 0($a0)
		sub $v0, $v0, $t0
		jr $ra
		

#####################################################
highlight:	lw $t0, 0($a0)
		add $a1, $a1, $t0
		lw $t0, 4($a0)
		sll $t0, $t0, 2	
		li $a2, 0xff00
		li $t9, 8
highlightLoop:	lw $t3, 0($a1)
		and $t3, $t3, $a2
		sw $t3, 0($a1)
		lw $t3, 4($a1)
		and $t3, $t3, $a2
		sw $t3, 4($a1)
		lw $t3, 8($a1)
		and $t3, $t3, $a2
		sw $t3, 8($a1)
		lw $t3, 12($a1)
		and $t3, $t3, $a2
		sw $t3, 12($a1)
		lw $t3, 16($a1)
		and $t3, $t3, $a2
		sw $t3, 16($a1)
		lw $t3, 20($a1)
		and $t3, $t3, $a2
		sw $t3, 20($a1)
		lw $t3, 24($a1)
		and $t3, $t3, $a2
		sw $t3, 24($a1)
		lw $t3, 28($a1)
		and $t3, $t3, $a2
		sw $t3, 28($a1)
		add $a1, $a1, $t0
		add $t9, $t9, -1
		bne $t9, $zero, highlightLoop
		jr $ra

######################################################
processError:	lw $t0, 0($a0)
		lw $t2, 4($a0)
		lw $t3, 8($a0)
		addi $t3, $t3, -7
		mul $t1, $t2, $t3
		sll $t1, $t1, 2
		add $t1, $t0, $t1
		lw $a1, 4($a0)
        addi $a1, $a1, -7
pebLoop: lw $v0, 0($t0)
		srl $v0, $v0, 5
		slti $t2, $v0, 0x100
		bne  $t2, $zero, skipClamp
		li $v0, 0xff
skipClamp: li $t2, 0xff
		sub $v0, $t2, $v0
		sll $v0, $v0, 8
		sw $v0, 0($t0)
		addi $a1, $a1, -1
		bne $a1, $0, pebNotEOL
		lw $a1, 4($a0)
        addi $a1, $a1, -7
        addi $t0, $t0, 28
pebNotEOL: add $t0, $t0, 4
		bne $t0, $t1, pebLoop
		jr $ra

	# standard Decaf preamble 
	  .text
	  .align 2
	  .globl main
  main:
	# BeginFunc 56
	  subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	  sw $fp, 8($sp)	# save fp
	  sw $ra, 4($sp)	# save ra
	  addiu $fp, $sp, 8	# set up new fp
	  subu $sp, $sp, 56	# decrement sp to make space for locals/temps
	# _tmp0 = 8
	  li $t0, 8		# load constant value 8 into $t0
	# _tmp1 = 4
	  li $t1, 4		# load constant value 4 into $t1
	# _tmp2 = _tmp1 + _tmp0
	  add $t2, $t1, $t0	
	# PushParam _tmp2
	  subu $sp, $sp, 4	# decrement sp to make space for param
	  sw $t2, 4($sp)	# copy param value to stack
	# _tmp3 = LCall _Alloc
	# (save modified registers before flow of control change)
	  sw $t0, -12($fp)	# spill _tmp0 from $t0 to $fp-12
	  sw $t1, -16($fp)	# spill _tmp1 from $t1 to $fp-16
	  sw $t2, -20($fp)	# spill _tmp2 from $t2 to $fp-20
	  jal _Alloc         	# jump to function
	  move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	  add $sp, $sp, 4	# pop params off stack
	# _tmp4 = Cow
	  la $t1, Cow	# load label
	# *(_tmp3) = _tmp4
	  sw $t1, 0($t0) 	# store with offset
	# betsy = _tmp3
	  move $t2, $t0		# copy value
	# _tmp5 = 100
	  li $t3, 100		# load constant value 100 into $t3
	# _tmp6 = 122
	  li $t4, 122		# load constant value 122 into $t4
	# PushParam _tmp6
	  subu $sp, $sp, 4	# decrement sp to make space for param
	  sw $t4, 4($sp)	# copy param value to stack
	# PushParam _tmp5
	  subu $sp, $sp, 4	# decrement sp to make space for param
	  sw $t3, 4($sp)	# copy param value to stack
	# PushParam betsy
	  subu $sp, $sp, 4	# decrement sp to make space for param
	  sw $t2, 4($sp)	# copy param value to stack
	# _tmp7 = *(betsy)
	  lw $t5, 0($t2) 	# load with offset
	# _tmp8 = *(_tmp7)
	  lw $t6, 0($t5) 	# load with offset
	# ACall _tmp8
	# (save modified registers before flow of control change)
	  sw $t0, -24($fp)	# spill _tmp3 from $t0 to $fp-24
	  sw $t1, -28($fp)	# spill _tmp4 from $t1 to $fp-28
	  sw $t2, -8($fp)	# spill betsy from $t2 to $fp-8
	  sw $t3, -32($fp)	# spill _tmp5 from $t3 to $fp-32
	  sw $t4, -36($fp)	# spill _tmp6 from $t4 to $fp-36
	  sw $t5, -40($fp)	# spill _tmp7 from $t5 to $fp-40
	  sw $t6, -44($fp)	# spill _tmp8 from $t6 to $fp-44
	  jalr $t6            	# jump to function
	# PopParams 12
	  add $sp, $sp, 12	# pop params off stack
	# PushParam betsy
	  subu $sp, $sp, 4	# decrement sp to make space for param
	  lw $t0, -8($fp)	# load betsy from $fp-8 into $t0
	  sw $t0, 4($sp)	# copy param value to stack
	# _tmp9 = *(betsy)
	  lw $t1, 0($t0) 	# load with offset
	# _tmp10 = *(_tmp9 + 4)
	  lw $t2, 4($t1) 	# load with offset
	# ACall _tmp10
	# (save modified registers before flow of control change)
	  sw $t1, -48($fp)	# spill _tmp9 from $t1 to $fp-48
	  sw $t2, -52($fp)	# spill _tmp10 from $t2 to $fp-52
	  jalr $t2            	# jump to function
	# PopParams 4
	  add $sp, $sp, 4	# pop params off stack
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	  move $sp, $fp		# pop callee frame off stack
	  lw $ra, -4($fp)	# restore saved ra
	  lw $fp, 0($fp)	# restore saved fp
	  jr $ra		# return from function
  Cow.____Init:
	# BeginFunc 0
	  subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	  sw $fp, 8($sp)	# save fp
	  sw $ra, 4($sp)	# save ra
	  addiu $fp, $sp, 8	# set up new fp
	# *(this + 8) = w
	  lw $t0, 8($fp)	# load w from $fp+8 into $t0
	  lw $t1, 4($fp)	# load this from $fp+4 into $t1
	  sw $t0, 8($t1) 	# store with offset
	# *(this + 4) = h
	  lw $t2, 12($fp)	# load h from $fp+12 into $t2
	  sw $t2, 4($t1) 	# store with offset
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	  move $sp, $fp		# pop callee frame off stack
	  lw $ra, -4($fp)	# restore saved ra
	  lw $fp, 0($fp)	# restore saved fp
	  jr $ra		# return from function
  Cow.____Moo:
	# BeginFunc 16
	  subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	  sw $fp, 8($sp)	# save fp
	  sw $ra, 4($sp)	# save ra
	  addiu $fp, $sp, 8	# set up new fp
	  subu $sp, $sp, 16	# decrement sp to make space for locals/temps
	# _tmp11 = *(this + 4)
	  lw $t0, 4($fp)	# load this from $fp+4 into $t0
	  lw $t1, 4($t0) 	# load with offset
	# PushParam _tmp11
	  subu $sp, $sp, 4	# decrement sp to make space for param
	  sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	# (save modified registers before flow of control change)
	  sw $t1, -8($fp)	# spill _tmp11 from $t1 to $fp-8
	  jal _PrintInt      	# jump to function
	# PopParams 4
	  add $sp, $sp, 4	# pop params off stack
	# _tmp12 = " "
	  .data			# create string constant marked with label
	  _string1: .asciiz " "
	  .text
	  la $t0, _string1	# load label
	# PushParam _tmp12
	  subu $sp, $sp, 4	# decrement sp to make space for param
	  sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	  sw $t0, -12($fp)	# spill _tmp12 from $t0 to $fp-12
	  jal _PrintString   	# jump to function
	# PopParams 4
	  add $sp, $sp, 4	# pop params off stack
	# _tmp13 = *(this + 8)
	  lw $t0, 4($fp)	# load this from $fp+4 into $t0
	  lw $t1, 8($t0) 	# load with offset
	# PushParam _tmp13
	  subu $sp, $sp, 4	# decrement sp to make space for param
	  sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	# (save modified registers before flow of control change)
	  sw $t1, -16($fp)	# spill _tmp13 from $t1 to $fp-16
	  jal _PrintInt      	# jump to function
	# PopParams 4
	  add $sp, $sp, 4	# pop params off stack
	# _tmp14 = "\n"
	  .data			# create string constant marked with label
	  _string2: .asciiz "\n"
	  .text
	  la $t0, _string2	# load label
	# PushParam _tmp14
	  subu $sp, $sp, 4	# decrement sp to make space for param
	  sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	  sw $t0, -20($fp)	# spill _tmp14 from $t0 to $fp-20
	  jal _PrintString   	# jump to function
	# PopParams 4
	  add $sp, $sp, 4	# pop params off stack
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	  move $sp, $fp		# pop callee frame off stack
	  lw $ra, -4($fp)	# restore saved ra
	  lw $fp, 0($fp)	# restore saved fp
	  jr $ra		# return from function
	# VTable for class Cow
	  .data
	  .align 2
	  Cow:		# label for class Cow vtable
	  .word Cow.____Init
	  .word Cow.____Moo
	  .text
_PrintInt:
    subu $sp, $sp, 8
    sw $fp, 8($sp)
sw $ra, 4($sp)
    addiu $fp, $sp, 8
    li   $v0, 1
lw   $a0, 4($fp)
    syscall
    move $sp, $fp
    lw $ra, -4($fp)
lw $fp, 0($fp)
    jr $ra

    _PrintString:
    subu $sp, $sp, 8
    sw $fp, 8($sp)
sw $ra, 4($sp)
    addiu $fp, $sp, 8
    li   $v0, 4
lw $a0, 4($fp)
    syscall
    move $sp, $fp
    lw $ra, -4($fp)
lw $fp, 0($fp)
    jr $ra

    _PrintBool:
    subu $sp, $sp, 8
    sw $fp, 8($sp)
sw $ra, 4($sp)
    addiu $fp, $sp, 8
lw $t1, 4($fp)
    blez $t1, fbr
    li   $v0, 4     # system call for print_str
    la   $a0, TRUE      # address of str to print
    syscall         
    b end
    fbr:    li   $v0, 4     # system call for print_str
    la   $a0, FALSE     # address of str to print
    syscall             
    end:    move $sp, $fp
    lw $ra, -4($fp)
lw $fp, 0($fp)
    jr $ra

    _Alloc:
    subu $sp, $sp, 8
    sw $fp, 8($sp)
sw $ra, 4($sp)
    addiu $fp, $sp, 8
    li   $v0, 9
lw $a0, 4($fp)
    syscall
    move $sp, $fp
    lw $ra, -4($fp)
lw $fp, 0($fp) 
    jr $ra


    _StringEqual:
    subu $sp, $sp, 8      # decrement sp to make space to save ra, fp
    sw $fp, 8($sp)        # save fp
    sw $ra, 4($sp)        # save ra
    addiu $fp, $sp, 8     # set up new fp
    subu $sp, $sp, 4      # decrement sp to make space for locals/temps

    li $v0,0

#Determine length string 1
lw $t0, 4($fp)       
    li $t3,0
    bloop1: 
lb $t5, ($t0) 
    beqz $t5, eloop1    
    addi $t0, 1
    addi $t3, 1
    b bloop1
    eloop1:

#Determine length string 2
lw $t1, 8($fp)
    li $t4,0
    bloop2: 
lb $t5, ($t1) 
    beqz $t5, eloop2    
    addi $t1, 1
    addi $t4, 1
    b bloop2
    eloop2:
    bne $t3,$t4,end1       #Check String Lengths Same

    lw $t0, 4($fp)  
lw $t1, 8($fp)
    li $t3, 0           
    bloop3: 
    lb $t5, ($t0) 
lb $t6, ($t1) 
    bne $t5, $t6, end1
    beqz $t5, eloop3       # if zero, then we hit the end of both strings
    addi $t3, 1
    addi $t0, 1
    addi $t1, 1
#bne $t3,$t4,bloop3
    b bloop3
    eloop3: li $v0,1

    end1:   move $sp, $fp         # pop callee frame off stack
    lw $ra, -4($fp)       # restore saved ra
    lw $fp, 0($fp)        # restore saved fp
    jr $ra                # return from function

    _Halt:
    li $v0, 10
    syscall

    _ReadInteger:
    subu $sp, $sp, 8      # decrement sp to make space to save ra, fp
    sw $fp, 8($sp)        # save fp
    sw $ra, 4($sp)        # save ra
    addiu $fp, $sp, 8     # set up new fp
    subu $sp, $sp, 4      # decrement sp to make space for locals/temps
    li $v0, 5
    syscall
    move $sp, $fp         # pop callee frame off stack
    lw $ra, -4($fp)       # restore saved ra
    lw $fp, 0($fp)        # restore saved fp
    jr $ra


    _ReadLine:
    subu $sp, $sp, 8      # decrement sp to make space to save ra, fp
    sw $fp, 8($sp)        # save fp
    sw $ra, 4($sp)        # save ra
    addiu $fp, $sp, 8     # set up new fp
    subu $sp, $sp, 4      # decrement sp to make space for locals/temps
# allocate space to store memory
    li $a0, 128           # request 128 bytes
    li $v0, 9         # syscall "sbrk" for memory allocation
    syscall               # do the system call
# read in the new line
    li $a1, 128       # size of the buffer
#la $a0, SPACE        
    move $a0, $v0         # location of the buffer  
    li $v0, 8 
    syscall

#la $t1, SPACE  
    move $t1, $a0
    bloop4: 
lb $t5, ($t1) 
    beqz $t5, eloop4    
    addi $t1, 1
    b bloop4
    eloop4:
    addi $t1,-1
    li $t6,0
sb $t6, ($t1)

#la $v0, SPACE
    move $v0, $a0         # save buffer location to v0 as return value  
    move $sp, $fp         # pop callee frame off stack
    lw $ra, -4($fp)       # restore saved ra
    lw $fp, 0($fp)        # restore saved fp
    jr $ra


    .data
    TRUE:.asciiz "true"
    FALSE:.asciiz "false"
    SPACE:.asciiz "Making Space For Inputed Values Is Fun."
    SPACE2:.asciiz "AAA.\n"

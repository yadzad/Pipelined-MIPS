lui $1, 0x1000
ori $1, 0x1008		# $1 = 0x10001008
sw  $1, 0($0)	
lui $1, 0x1000
ori $1, 0x1002		# $1 = 0x10001002
sw  $1, 4($0)
lui $1, 0x8000
ori $1, 0x1001		# $1 = 0x80001001
sw  $1, 8($0)
lui $1, 0x1000
ori $1, 0x1005		# $1 = 0x10001005
sw  $1, 12($0)
lui $1, 0x8000
ori $1, 0x1000		# $1 = 0x80001000
sw  $1, 16($0)

ori $1, $0, 0	# $1 = 0
ori $7, $0, 16
ori $5, $0, 1
ori $6, $0, 5
sort_f:
	ori $1, $0, 0
	addi $6, $6, -1
sort:
	lw $2, 0($1)
	addi $1, $1, 4
	lw $3, 0($1)
	
	slt $4, $3, $2		# if $2 > $3, $4 = 1
	
	beq $4, $5, swap	# so swap($2, $3)
return:
	beq $6, $0, exit
	beq $1, $7, sort_f
	beq $0,$0, sort
	
swap:
	addi $1, $1, -4
	sw $3, 0($1)
	addi $1, $1, 4
	sw $2, 0($1)
	beq $6, $0, exit
	beq $0,$0, return
	
exit:
	

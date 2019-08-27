add $1,$2,$3
beq $1,$4,L1
L1:
addi $10,$10,0
addi $10,$10,0
addi $10,$10,0
addi $10,$10,0
addi $10,$10,0

lw $1,2($3)
beq $1,$4,L2

L2:
addi $10,$10,0
addi $10,$10,0
addi $10,$10,0
addi $10,$10,0
addi $10,$10,0

lw $1,2($3)
add $5,$1,$2
beq $1,$4,L3

L3:
addi $10,$10,0
addi $10,$10,0
addi $10,$10,0
addi $10,$10,0
addi $10,$10,0
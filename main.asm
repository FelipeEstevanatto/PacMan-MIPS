.set macro 		            #To include an external file
.include "menuInicial.asm"
.include "clearScreen.asm"

.data
.text
main:
jal colors		
jal background_def

menu() 		        #To call a function located in another file - associated with the .set macro

.set nomacro 		#Marks the end of the external file inclusion
colors:
addi $s2, $0, 0x00A8FF  # Light Blue
addi $s3, $0, 0x00FF00  # Green
addi $s4, $0, 0x000000	# Black
addi $s5, $0, 0x4169E1	# Blue
addi $s6, $0, 0xFFFF00	# Yellow
addi $s7, $0, 0xCFBA95 	# Score color
addi $t8, $0, 0xDC143C  # Crimson
addi $t9, $0, 0xFF007F  # Pink
addi $k0, $0, 0xFFA500  # Orange
addi $k1, $0, 0xFF6600  # Dark Orange
# addi $gp, $0, 0xFF0000  # Red Game Over
# addi $fp, $0, 0xFFFFFF  # White

jr $ra

background_def:
addi $t1, $0, 8192	# Background size
add $t2, $0, $t1		# Initial position
lui $t2, 0x1001		# Set the first pixel
jr $ra


; main.s
       AREA    |.text|, CODE, READONLY, ALIGN=2
       EXPORT  Start
	;;IEEE to TNS conversion
Start  BL   trans
       ADR  r0, TNS
	   LDR  r0, [r0]
	   CMP  r0, r3
	   B    .
	
trans  ADR	r0, IEEE        ; r0 := address of IEEE
	   LDR	r1,[r0]	        ; r1 := IEEE word
sign   MOV  r6, #0x1 
	   AND  r3,r1,r6,ROR #1 ; r3 = sign of the IEEE
exp	   ADR  r7,expMask      ; r7 = address of Exponent mask of IEEE
	   LDR  r7,[r7]         ; load the mask in r7
	   AND  r7,r1,r7        ; get the IEEE exponent in r7
	   ROR  r7, #23
	   SUB  r7, r7, #127    ; get unbiased
	   ADD  r7, r7, #256    ; convert to TNS bias
;	   ROR  r7, #24         ; shift to the correct location for TNS
	   MOV  r5, r7          ; Currently: r3: sign bit, r5: exponent
fra	   ADR  r7, fracMask
	   LDR  r7, [r7]        ; r7 = fraction mask
	   AND  r7, r7, r1      ; r7 = unpacked exponent
	   MOV  r4, r7, LSL #8  ; shift to correct location
comb   ORR  r3, r4
       ORR  r3, r5
	   BX   lr

;-----------------------------------DATA--------------------------------------
IEEE          DCD 0x41640000  ; IEEE Representation of 14.25(10),41640000 (16)
TNS           DCD 0x64000103  ; TNS  Representation of 14.25(10),64000103(16)
expMask       DCD 0x7F800000  ; mask to get the IEEE exponent bits
fracMask      DCD 0x007FFFFE  ; mask to get the IEEE fraction bits 
	                          ; (w/o least sig)
	  ALIGN
      END
           
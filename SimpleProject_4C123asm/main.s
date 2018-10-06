; main.s
; 
; ===========================================
; IEEE to TNS Conversion (32 bit, big endian)
; ===========================================
; :author: Michael Newman
; :class: CS2400 Computer Organization 2
; :assignment: HW5
; :date: 10/4/18
;
; Designed to convert a IEEE single-persision floating point number to TNS
; single-persision floating point.
;
; Builds the TNS number by loading:
;   r3 := sign
;   r4 := fraction
;   r5 := exponent
; And then packing the values into r3.
; ----------------------------------------------------------------------------

       AREA    |.text|, CODE, READONLY, ALIGN=2
       EXPORT  Start

Start  BL   IEEEtoTNS ; branch to caluclate the TNS value
       BL   TNStoIEEE ; branch to calculate the IEEE value
	   ADR  r0, TNS
	   LDR  r0, [r0]
	   CMP  r9, r0    ; check if IEEE to TNS worked
	   ADR  r0, IEEE
	   LDR  r0, [r0]
	   CMP  r8, r0    ; check if the TNS to IEEE worked   
	   B    .
	
IEEEtoTNS  ADR	r0, IEEE  ; r0 := address of IEEE
	       LDR	r1,[r0]	  ; r1 := IEEE word
	   
sign   MOV  r6, #0x1            ; sign mask
	   AND  r3, r1, r6, ROR #1  ; r3 := TNS sign
	   
exp	   ADR  r7, IEEEexpMask   ; r7 := address of exponent mask
	   LDR  r7, [r7]          ; r7 := exponent mask
	   AND  r7, r1, r7        ; r7 := unpacked exponent
	   ROR  r7, #23           ; shift exponent to TNS location
	   SUB  r7, r7, #127      ; remove bias 127
	   ADD  r7, r7, #256      ; add bias 256
	   MOV  r5, r7            ; r5 := TNS exponent

fra	   ADR  r7, IEEEfracMask  ; r7 := adddress of the fraction mask
	   LDR  r7, [r7]          ; r7 := fraction mask
	   AND  r7, r7, r1        ; r7 := unpacked exponent
	   MOV  r4, r7, LSL #8    ; r4 := TNS fraction

comb   ORR  r3, r4  ; pack
       ORR  r3, r5
	   MOV  r9, r3
	   BX   lr

;--------------------------------TNS TO IEEE----------------------------------
TNStoIEEE  ADR r0, TNS
           LDR r0, [r0]
		   
sign2      MOV r1, #0x1
           AND r3, r1, ROR #1
		   
exp2       ADR r7, TNSexpMask  ; address of the mask
           LDR r7, [r7]        ; actual mask content
		   AND r4, r7, r0      ; extract exponent bits
		   CMP r4, #254        ; test if exponent can be put into IEEE form
	       BGE error           ; if exponent is too big, branch to error
		   LSL r4, #21         ; shift exponent bits to the right location
		   
fra2       ADR r7, TNSfracMask
           LDR r7, [r7]
		   AND r5, r0, r7       ; extract fraction bits
		   ROR r5, #8

comb2      ORR r3, r4
           ORR r3, r5
		   MOV r8, r3
		   BX  lr
		   
		   

;---------------------------------HELPER--------------------------------------
error      SWI 1
           B   .

;-----------------------------------DATA--------------------------------------
IEEE              DCD 0x41640000  ; IEEE Representation of 14.25(10)
TNS               DCD 0x64000103  ; TNS  Representation of 14.25(10)
IEEEexpMask       DCD 0x7F800000  ; mask to get the IEEE exponent bits
IEEEfracMask      DCD 0x007FFFFE  ; mask to get the IEEE fraction bits 
	                              ; (w/o least sig)
TNSexpMask        DCD 0x000001FF  ; mask to get the TNS exponent bits
TNSfracMask       DCD 0x7FFFFE00  ; mask to get the TNS fraction bits
	  ALIGN
      END
           
; main.s
; 
; ===========================================
; IEEE to TNS Conversion (32 bit, big endian)
; ===========================================
; - Michael Newman
; - CS2400 Computer Organization 2
; - HW5
; - 10/4/18
;
; Designed to convert a IEEE single-persision floating point number to TNS
; single-persision floating point.
;
; Builds the TNS number by loading:
;   
       AREA    |.text|, CODE, READONLY, ALIGN=2
       EXPORT  Start
	;;IEEE to TNS conversion
Start  BL   trans  
       ADR  r0, TNS   ; Load address of TNS test
	   LDR  r0, [r0]  ; Load TNS test
	   CMP  r0, r3    ; Compare TNS tests & calculated TNS output
	   B    .
	
trans  ADR	r0, IEEE  ; r0 := address of IEEE
	   LDR	r1,[r0]	  ; r1 := IEEE word
	   
sign   MOV  r6, #0x1            ; sign mask
	   AND  r3, r1, r6, ROR #1  ; r3 = sign of the IEEE
	   
exp	   ADR  r7, expMask   ; r7 = address of Exponent mask of IEEE
	   LDR  r7, [r7]      ; load the mask in r7
	   AND  r7, r1, r7    ; get the IEEE exponent in r7
	   ROR  r7, #23       ; shift exponent to TNS location
	   SUB  r7, r7, #127  ; get unbiased exponent
	   ADD  r7, r7, #256  ; convert to TNS bias
	   MOV  r5, r7        
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
           
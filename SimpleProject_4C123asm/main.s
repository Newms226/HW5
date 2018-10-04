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

Start  BL   begin     ; Branch to caluclate TNS value
cmp    ADR  r0, TNS   ; Load address of TNS test
	   LDR  r0, [r0]  ; Load TNS test
	   CMP  r0, r3    ; Compare TNS tests & calculated TNS output
	   B    .
	
begin  ADR	r0, IEEE  ; r0 := address of IEEE
	   LDR	r1,[r0]	  ; r1 := IEEE word
	   
sign   MOV  r6, #0x1            ; sign mask
	   AND  r3, r1, r6, ROR #1  ; r3 := TNS sign
	   
exp	   ADR  r7, expMask   ; r7 := address of exponent mask
	   LDR  r7, [r7]      ; r7 := exponent mask
	   AND  r7, r1, r7    ; r7 := unpacked exponent
	   ROR  r7, #23       ; shift exponent to TNS location
	   SUB  r7, r7, #127  ; remove bias 127
	   ADD  r7, r7, #256  ; add bias 256
	   MOV  r5, r7        ; r5 := TNS exponent

fra	   ADR  r7, fracMask    ; r7 := adddress of the fraction mask
	   LDR  r7, [r7]        ; r7 := fraction mask
	   AND  r7, r7, r1      ; r7 := unpacked exponent
	   MOV  r4, r7, LSL #8  ; r4 := TNS fraction

comb   ORR  r3, r4  ; pack
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
           
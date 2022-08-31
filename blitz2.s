
;**************************************************;
;                                                  ;
; Source code to BLITZ BASIC ][                    ;
;      (Chocolate Edition)                         ;
;                                                  ;
;           You dudes out there had better         ;
;        like this, or I'm gonna start doing       ; 
;         something drastic with my life...        ;
;                like... GET A JOB!                ;
;                                                  ;
;**************************************************;


demo	equ	0
release	equ	-1
	;
cripple	equ	0	;set to -1 to make crippled
final	equ	-1	;set to -1 to make final version
version	equ	215	;version number

;**************************************************;
;
;	     Modifications
;
;V0.98 - change date on startup requester
;V0.00 - clear 'inerr' flag at start of compile
;V1.00 - max object size fixed to over 128
;     - pop next changed to pop for
;V1.10 - blitz2:deflibs - blitz2:blitzopts#?
;V1.20 - .info ignored on libs and opts
;V1.30 - square brackets bug fixed
;V1.40 - .info lock fixed, & exec Flush cache used
;V1.50 - optimizer removed! debugger added -
;       directtrap added - runtime errors majorly
;       overhauled! cont removed - ignore installed
;
;V1.60 - vbr handled
;v1.70 - runerrson & runerrsoff added, label runerrs removed
;v1.80 - separate strings out with clr.b (a3)+ in 'sbtolong'
;       fixed \a="Hello","goodbye"
;       removed 'library not found' error for maximum not found
;       flushc installed in direct mode (directtrap)
;
;v1.90 - attempting to add [] checking...
;
;v1.90 - run prog does a 'createproc' so user can do a PANIC!
;       Blitz2 loads debugger now instead of dhandlerlib
;
;v1.90 - added asmexit...checked for func ret outside of func.
;
;v1.95 - added 'proc not found' to functions
;
;**************************************************;

;Notes:

;This version includes a line 'MOVE.L #4000,D2'. This is
;coz AmigaDros APPEARS to pass the stack size in D2, but
;genam doesn't. God knows what WB sticks in D2.
;More research is required!

;Also, the section 'OPTSPNTS' has some rem'ed out bits
;which will have to be included in the final version.
;This will have to wait, as it'll fuck up all my .xtra
;files

	include	myoffs
;
;	First, a whole lot of Library equates
;
;	lib - 65533: wbstartuplib
;
wbstart	equ	$bf00
;
;	lib - 65534: varslib
;
allocvars	equ	65534
;
;	lib - 65530: memlib
;
localloc	equ	$c000
locfree	equ	$c001
globalloc	equ	$c002
globfree	equ	$c003
newmem	equ	$c004
freelast	equ	$c005
;
;	lib - 65520: intlib
;
setint	equ	$c100
clrint	equ	$c101
newint	equ	$c102
oldint	equ	$c103
intvwait	equ	$c104
intcleanup	equ	$c105
intgoblitz	equ	$c106
intgoamiga	equ	$c107
;
;	lib - 65510: switchlib
;
goblitz	equ	$c200
goamiga	equ	$c201
goqamiga	equ	$c202
ownblit	equ	$c203
disownblit	equ	$c204
;
;	lib - runerrlib
;
runerrlib	equ	65500
	;
finalscheck	equ	$c300
remline	equ	$c301
;
contjmp	equ	$c304
chkret	equ	$c305
snxtchk	equ	$c306
lnxtchk	equ	$c307
stchk	equ	$c308
arrerr	equ	$c309
maxerr	equ	$c30a
gosup	equ	$c30b
gouse	equ	$c30c
eschk	equ	$c30d
sachk	equ	$c30e
arrchk	equ	$c30f
datachk	equ	$c310
inblitz	equ	$c311
inamiga	equ	$c312
casechkw	equ	$c313
casechkl	equ	$c314
currentchk	equ	$c315
ltobover	equ	$c316
wtobover	equ	$c317
ltowover	equ	$c318
qtobover	equ	$c319
ftobover	equ	$c31a
ftowover	equ	$c31b
ftolover	equ	$c31c
;
;	lib - 65434: arrayslib
;
newarr	equ	$c400
newlocarr	equ	$c401
arrmult	equ	$c402
;
;	lib - 65335: staticslib
;
alstat	equ	$c500
localstat	equ	$c501
;
;	lib - 65235: stringslib1
;
copstring	equ	$c600
workstart	equ	$c601
;
;	lib - 65135: stringslib2
;
lastring	equ	$c700
astring	equ	$c701
;
;	lib - 65035: exitslib
;
endjmp	equ	$c800
;
;	lib - 64935: ffplib
;
getffpbase	equ	$c900
;
;	lib - 64835: lmullib
;
quickmult	equ	$ca00
longmult	equ	$ca01
;
;	lib - 64735: ldivlib
;
quickdiv	equ	$cb00
longdiv	equ	$cb01
;
;	lib - 64635: clrlib
;
clrloc	equ	$cc00
;
;	lib - 64535: datalib
;
getdstart	equ	$cd00
;
;	lib - 64435: strcomplib
;
strcomp	equ	$ce00
casestrcomp	equ	$ce01
;
;	lib - 64335: maxslib
;
setmaxs	equ	$cf00
allocst	equ	$cf01
freest	equ	$cf02
;
;	lib - 64135: maxlenlib
;
maxlen	equ	$d000
lmaxlen	equ	$d001
;
;	lib - 64100: chipbaselib
;
;	lib - 64080: floatquicklib
;
qutofl	equ	$d300
fltoqu	equ	$d301
;
;	lib - 64070:modlib
;
modbyte	equ	$d400
modword	equ	$d401
modlong	equ	$d402
modquick	equ	$d403
modfloat	equ	$d404
;
loclabch	equ	39
inclen	equ	1024	;how much of an include to load.
maxmacros	equ	8
ifmacmax	equ	8
vcodelen	equ	256
mostres	equ	8
userand	equ	$7f80

;
;	lib - 64060:debug lib
;

debuglib	equ	64060

;	lib - 1 : dhandlerlib!
;
dhandlerlib	equ	1

			;$d500...

rundebuglib	equ	64050

			;$d600...

;
;	lib - 64040: errtraplib
;
ern	equ	$d200
seterr	equ	$d201
clrerr	equ	$d202
;getsp	equ	$d203
;putsp	equ	$d204
errfail	equ	$d205

mathq	equ	247-55

mainbit	;
	include	wbheader	;get 'progfile' and stack size
	;
	ifeq	final
	move.l	#4000,d2
	endc
	;
	move.l	d2,stackfuck
	bra	actualbegin
	;
	include	options2.src.new
	;
tsthead	dc.l	$3f3,0,1,0,0
tstsize1	dc.l	256,$3e9
tstsize2	dc.l	256
	;
tstend	dc.l	$3ec
tstsize3	dc.l	0,0
	;
tstdone	dc.l	$3f2

edstruct	dc.l	tokens
	dc.l	menus
	dc.l	loadxtra	;load .xtra routine
	dc.l	savextra	;save .xtra routine
	dc.l	menu	;Menu Routine
	dc.l	0	;cleanup (?)
	dc.b	':".;'
	even
	
tokens	dc.l	tok2	;*****
	dc	1
	dc.b	'NEWTYPE',0
	dc.b	'.Typename',0
	even
tok2	dc.l	tok3	;*****
	dc	2
	dc.b	'End',0
	dc.b	'[If|While|Select|Statement|Function|SetInt|SetErr|NEWTYPE|MACRO]',0
	even
tok3	dc.l	tok4	;*****
	dc	3
	dc.b	'Let',0
	dc.b	'Var=|Operator Expression',0
	even
tok4	dc.l	tok5	;*****
	dc	4
	dc.b	'Dim',0
	dc.b	'Arrayname [List] (Dimension1[,Dimension2..])',0
	even
tok5	dc.l	tok6	;*****
	dc	5
	dc.b	'Goto',0
	dc.b	'Program Label',0
	even
tok6	dc.l	tok7	;*****
	dc	6
	dc.b	'Gosub',0
	dc.b	'Program Label',0
	even
tok7	dc.l	tok8	;*****
	dc	7
	dc.b	'Return',0,0
	even
tok8	dc.l	tok9	;*****
	dc	8
	dc.b	'Statement',0
	dc.b	'Procedurename{[Parameter1[,Parameter2...]]}',0
	even
tok9	dc.l	tok10	;*****
	dc	9
	dc.b	'Function',0
	dc.b	'[.Type] Procedurename{[Parameter1[,Parameter2...]]}',0
	even
tok10	dc.l	tok11	;*****
	dc	10
	dc.b	'MouseWait',0,0
	even
tok11	dc.l	tok12	;*****
	dc	11
	dc.b	'If',0
	dc.b	'Expression [Then...]',0
	even
tok12	dc.l	tok13	;*****
	dc	12
	dc.b	'While',0
	dc.b	'Expression',0
	even
tok13	dc.l	tok14	;*****
	dc	13
	dc.b	'Macro',0
	dc.b	'Macroname',0
	even
tok14	dc.l	tok15	;*****
	dc	14
	dc.b	'Select',0
	dc.b	'Expression',0
	even
tok15	dc.l	tok16	;*****
	dc	15
	dc.b	'Case',0
	dc.b	'Expression',0
	even
tok16	dc.l	tok17	;tok17	;*****
	dc	16
	dc.b	'Default',0,0
	even
tok17	dc.l	tok18
	dc	17
	dc.b	'AsmExit',0,0	;'Ashr',0,0
	even
tok18	dc.l	tok19	;*****
	dc	18
	dc.b	'XINCLUDE',0
	dc.b	'Filename',0
	even
tok19	dc.l	tok20	;*****
	dc	19
	dc.b	'INCLUDE',0
	dc.b	'Filename',0
	even
tok20	dc.l	tok21
	dc	20
	dc.b	'Jimi',0,0	;'Unless',0,0
			;dc.b	'expression [comparison expression] [Then...]',0
	even
tok21	dc.l	tok22	;*****
	dc	21
	dc.b	'SHARED',0
	dc.b	'Var[,Var...]',0
	even
tok22	dc.l	tok23	;*****
	dc	22
	dc.b	'For',0
	dc.b	'Var=Expression1 To Expression2 [Step Expression3]',0
	even
tok23	dc.l	tok24	;*****
	dc	23
	dc.b	'Next',0
	dc.b	'[Var[,Var...]]',0
	even
tok24	dc.l	tok25	;*****
	dc	24
	dc.b	'To',0
	dc.b	'Expression2 [Step Expression3]',0
	even
tok25	dc.l	tok26	;*****
	dc	25
	dc.b	'Step',0
	dc.b	'increment',0
	even
tok26	dc.l	tok27	;*****
	dc	26
	dc.b	'Data',0
	dc.b	'[.Type] Item[,Item...]',0
	even
tok27	dc.l	tok28	;*****
	dc	27
	dc.b	'Read',0
	dc.b	'Var[,Var...]',0
	even
tok28	dc.l	tok29	;*****
	dc	28
	dc.b	'CNIF',0
	dc.b	'Constant Comparison Constant',0
	even
tok29	dc.l	tok30	;*****
	dc	29
	dc.b	'CSIF',0
	dc.b	'"String" Comparison "String"',0
	even
tok30	dc.l	tok31	;*****
	dc	30
	dc.b	'CELSE',0,0
	even
tok31	dc.l	tok32	;*****
	dc	31
	dc.b	'CEND',0,0
	even
tok32	dc.l	tok33	;*****
	dc	32
	dc.b	'CERR',0
	dc.b	'Errormessage',0
	even
tok33	dc.l	tok34	;*****
	dc	33
	dc.b	'Then',0
	dc.b	'statement...',0
	even
tok34	dc.l	tok35	;*****
	dc	34
	dc.b	'Else',0
	dc.b	'[Statement...]',0
	even
	;
	;below should not activate runtime error checking
	;
tok35	dc.l	tok36
	dc	35
	dc.b	'Even4',0
	dc.b	'; align to 4 byte boundary',0
	even
tok36	dc.l	tok37
	dc	36
	dc.b	'Even8',0
	dc.b	'; align to 8 byte boundary',0
	even
tok37	dc.l	tok38	;*****
	dc	37
	dc.b	'Dc',0
	dc.b	'[.Size] Data[,Data...]',0
	even
tok38	dc.l	tok39	;*****
	dc	38
	dc.b	'Ds',0
	dc.b	'[.Size] Length',0
	even
tok39	dc.l	tok40	;*****
	dc	39
	dc.b	'Even',0,0
	even
tok40	dc.l	tok41	;*****
	dc	40
	dc.b	'Dcb',0
	dc.b	'[.Size] Repeats,Data',0
	even
tok41	dc.l	tok42	;*****
	dc	41
	dc.b	'GetReg',0
	dc.b	'68000 Reg,Expression',0
	even
tok42	dc.l	tok43	;*****
	dc	42
	dc.b	'IncBin',0
	dc.b	'Filename',0
	even
	;
	;end of disablables
	;
tok43	dc.l	tok44	;*****
	dc	43
	dc.b	'Free',0
	dc.b	'Objectname Object#',0
	even
tok44	dc.l	tok45	;*****
	dc	44
	dc.b	'Use',0
	dc.b	'Objectname Object#',0
	even
tok45	dc.l	tok46	;*****
	dc	45
	dc.b	'Stop',0,0
	even
tok46	dc.l	tok47	;*****
	dc	46
	dc.b	'Cont',0
	dc.b	'[N]',0
	even
tok47	dc.l	tok48	;*****
	dc	47
	dc.b	'SizeOf',0
	dc.b	'.Typename[,Entrypath]',0
	even
tok48	dc.l	tok49	;*****
	dc	48
	dc.b	'SetInt',0
	dc.b	'Type',0
	even
tok49	dc.l	tok50	;*****
	dc	49
	dc.b	'ClrInt',0
	dc.b	'Type',0
	even
tok50	dc.l	tok51	;*****
	dc	50
	dc.b	'MaxLen',0
	dc.b	'StringVar=Expression',0
	even
tok51	dc.l	tok52	;*****
	dc	51
	dc.b	'DEFTYPE',0
	dc.b	'.Typename [Var[,Var...]]',0
	even	
tok52	dc.l	tok53	;*****
	dc	52
	dc.b	'BLITZ',0,0
	even
tok53	dc.l	tok54	;*****
	dc	53
	dc.b	'AMIGA',0,0
	even
tok54	dc.l	tok55	;*****
	dc	54
	dc.b	'QAMIGA',0,0
	even
tok55	dc.l	tok56	;*****
	dc	55
	dc.b	'VWait',0
	dc.b	'[Frames]',0
	even
tok56	dc.l	tok57	;*****
	dc	56
	dc.b	'ALibJsr',0
	dc.b	'Token[,Form]',0
	even
tok57	dc.l	tok58	;*****
	dc	57
	dc.b	'TokeJsr',0
	dc.b	'Token[,Form]',0
	even
tok58	dc.l	tok59	;*****
	dc	58
	dc.b	'BLibJsr',0
	dc.b	'Token[,Form]',0
	even
tok59	dc.l	tokasm
	dc	59
	dc.b	'Jimi',0,0	;'AbortVBOK',0
	even
	;
lnum	equ	60
fnum	equ	60
tnum	set	fnum
	;
tokasm	include	asmmac
	;
toktnum	dc.l	toktnum2	;*****
	dc	tnum	;next one is tnum+1, tnum+2...
	dc.b	'List',0,0
	even
toktnum2	dc.l	toktnum3	;*****
	dc	tnum+1
	dc.b	'SetErr',0,0
	even
toktnum3	dc.l	toktnum5	;toktnum4	;*****
	dc	tnum+2
	dc.b	'ClrErr',0,0
	even
;toktnum4	dc.l	toktnum5
;	dc	tnum+3
;	dc.b	'Ern',0,0
;	even
toktnum5	dc.l	toktnum6	;*****
	dc	tnum+4
	dc.b	'ErrFail',0,0
	even
toktnum6	dc.l	toktnum7	;*****
	dc	tnum+5
	dc.b	'Addr',0
	dc.b	'Objectname(Object#)',0
	even
toktnum7	dc.l	toktnum8
	dc	tnum+6
	dc.b	'MOD',0,0
	even
toktnum8	dc.l	toktnum9
	dc	tnum+7
	dc.b	'Pi',0,0
	even
toktnum9	dc.l	toktnum10	;*****
	dc	tnum+8
	dc.b	'Repeat',0,0
	even
toktnum10	dc.l	toktnum11	;*****
	dc	tnum+9
	dc.b	'Until',0
	dc.b	'Expression',0
	even
toktnum11	dc.l	toktnum12	;*****
	dc	tnum+10
	dc.b	'PutReg',0
	dc.b	'68000 Reg,Variable',0
	even
toktnum12	dc.l	toktnum13	;*****
	dc	tnum+11
	dc.b	'Pop',0
	dc.b	'Gosub|For|Select|If|While|Repeat',0
	even
toktnum13	dc.l	toktnum14	;*****
	dc	tnum+12
	dc.b	'INCDIR',0
	dc.b	'Pathname',0
	even
toktnum14	dc.l	toktnum15	;*****
	dc	tnum+13
	dc.b	'EndIf',0,0
	even
toktnum15	dc.l	toktnum16	;*****
	dc	tnum+14
	dc.b	'Wend',0,0
	even
toktnum16	dc.l	toktnum17	;*****
	dc	tnum+15
	dc.b	'SysJsr',0
	dc.b	'Routine',0
	even
toktnum17	dc.l	toktnum18	;*****
	dc	tnum+16
	dc.b	'WBStartup',0,0
	even
toktnum18	dc.l	toktnum19	;*****
	dc	tnum+17
	dc.b	'Maximum',0
	dc.b	'Objectname',0
	even
toktnum19	dc.l	toktnum20	;**???
	dc	tnum+18
	dc.b	'On',0
	dc.b	'Expression Goto|Gosub Program Label[,Program Label...]',0
	even
toktnum20	dc.l	toktnum21
	dc	tnum+19
	dc.b	'Off',0,0
	even
toktnum21	dc.l	toktnum22	;*****
	dc	tnum+20
	dc.b	'Forever',0,0
	even
toktnum22	dc.l	toktnum23	;*****
	dc	tnum+21
	dc.b	'Restore',0
	dc.b	'[Program Label]',0
	even
toktnum23	dc.l	toktnum24	;*****
	dc	tnum+22
	dc.b	'Exchange',0
	dc.b	'Var,Var',0
	even
toktnum24	dc.l	toktnum25
	dc	tnum+23
	dc.b	'USEPATH',0
	dc.b	'Pathtext',0
	even
toktnum25	dc.l	toktnum26
	dc	tnum+24
	dc.b	'CloseEd',0,0
	even
toktnum26	dc.l	toktnum27
	dc	tnum+25
	dc.b	'NoCli',0,0
	even
toktnum27	dc.l	toktnum28
	dc	tnum+26
	dc.b	'BitTst',0,0
	even
toktnum28	dc.l	toktnum29
	dc	tnum+27
	dc.b	'BitSet',0,0
	even
toktnum29	dc.l	toktnum30
	dc	tnum+28
	dc.b	'BitClr',0,0
	even
toktnum30	dc.l	toktnum31
	dc	tnum+29
	dc.b	'BitChg',0,0
	even
toktnum31	dc.l	toktnum32
	dc	tnum+30
	dc.b	'Used',0
	dc.b	'Objectname(Object#)',0
	even
toktnum32	dc.l	toktnum33	;last must be zero, else pointer to next
	dc	tnum+31	;increment this
	dc.b	'Runerrson',0,0	;name
	even
toktnum33	dc.l	0
	dc	tnum+32
	dc.b	'Runerrsoff',0,0
	even

menus	dc.b	'COMPILER',0
	dc.b	'COMPILE AND RUN        ',0,'X'
	dc.b	'RUN                    ',0,'M'
	dc.b	'CREATE EXECUTABLE      ',0,'E'
	dc.b	'COMPILER OPTIONS       ',0,'O'
	dc.b	'CREATE RESIDENT        ',0,';'
	dc.b	'VIEW NEWTYPES          ',0,'-'
	dc.b	'CLI ARGUMENT           ',0,'='
	dc.b	'CALCULATOR             ',0,'H'
	dc.b	'RELOAD ALL LIBS        ',0,'\'
	dc.b	'LOAD DEBUG MODULE      ',0,'.'
	ifeq	final
	dc.b	'PRINT TOKENS',0,0
	endc
	dc.b	0
	even

menuadds	dc.l	menu0,menu10,menu1,menu4,menu5
	dc.l	menu6,menu9,menu7,menu8,menu_d
	ifeq	final
	dc.l	menu3
	endc

	cnop	0,4
undobuffer	ds.b	128

libsdir	dc.b	'blitz2:userlibs/',0
	even

nomemreq	dc.l	0
	dc.w	116,58,304,68,0,0
	dc.l	nomemreqga1,nomemreqbo1,nomemreqin1
	dc.w	0
	dc.b	0,0
	dc.l	0
	ds.b	32
	dc.l	0,0
	ds.b	36

nomemreqbo1	dc.w	0,0
	dc.b	1,2,1,3
	dc.l	nomemreqla1,nomemreqla2
nomemreqla1	dc.w	303,0,0,0,0,67
nomemreqla2	dc.w	0,0
	dc.b	2,1,1,3
	dc.l	nomemreqla3,0
nomemreqla3	dc.w	303,1,303,67,1,67
nomemreqbo2	dc.w	0,0
	dc.b	1,2,1,3
	dc.l	nomemreqla5,nomemreqla6
nomemreqla5	dc.w	207,0,0,0,0,11
nomemreqla6	dc.w	0,0
	dc.b	2,1,1,3
	dc.l	nomemreqla7,0
nomemreqla7	dc.w	207,1,207,11,1,11
nomemreqbo3	dc.w	0,0
	dc.b	1,2,1,3
	dc.l	nomemreqla9,nomemreqla10
nomemreqla9	dc.w	207,0,0,0,0,11
nomemreqla10	dc.w	0,0
	dc.b	2,1,1,3
	dc.l	nomemreqla11,0
nomemreqla11	dc.w	207,1,207,11,1,11
nomemreqbo4	dc.w	0,0
	dc.b	1,2,1,3
	dc.l	nomemreqla13,nomemreqla14
nomemreqla13	dc.w	119,0,0,0,0,11
nomemreqla14	dc.w	0,0
	dc.b	2,1,1,3
	dc.l	nomemreqla15,0
nomemreqla15	dc.w	119,1,119,11,1,11

nomemreqin1	dc.b	1,0,1,0
	dc.w	12,6
	dc.l	0
	dc.l	nomemreqla4,0
nomemreqla4	dc.b	'Not Enough Object Memory Available!',0
	even
nomemreqin2	dc.b	1,0,1,0
	dc.w	4,2
	dc.l	0
	dc.l	nomemreqla8,0
nomemreqla8	dc.b	'INCREASE 150% - RECOMPILE',0
	even
nomemreqin3	dc.b	1,0,1,0
	dc.w	4,2
	dc.l	0
	dc.l	nomemreqla12,0
nomemreqla12	dc.b	'MAKE SMALLEST - RECOMPILE',0
	even
nomemreqin4	dc.b	1,0,1,0
	dc.w	4,2
	dc.l	0
	dc.l	nomemreqla16,0
nomemreqla16	dc.b	'CANCEL COMPILE',0
	even

nomemreqga1	dc.l	nomemreqga2
	dc.w	48,20,208,12,0,5,1
	dc.l	nomemreqbo2,0,nomemreqin2,0,0
	dc.w	1
	dc.l	0
nomemreqga2	dc.l	nomemreqga3
	dc.w	48,36,208,12,0,5,1
	dc.l	nomemreqbo3,0,nomemreqin3,0,0
	dc.w	2
	dc.l	0
nomemreqga3	dc.l	0
	dc.w	96,52,120,12,0,5,1
	dc.l	nomemreqbo4,0,nomemreqin4,0,0
	dc.w	3
	dc.l	0

asmpnts	ds.l	tnum-fnum

verreq	dc.l	0
	dc.w	108,58,280,60,0,0
	dc.l	verreqga1,verreqbo1,verreqin1
	dc.w	0
	dc.b	0,0
	dc.l	0
	ds.b	32
	dc.l	0,0
	ds.b	36

verreqbo1	dc.w	0,0
	dc.b	1,2,1,3
	dc.l	verreqla1,verreqla2
verreqla1	dc.w	279,0,0,0,0,59
verreqla2	dc.w	0,0
	dc.b	2,1,1,3
	dc.l	verreqla3,0
verreqla3	dc.w	279,1,279,59,1,59
verreqbo2	dc.w	0,0
	dc.b	1,2,1,3
	dc.l	verreqla7,verreqla8
verreqla7	dc.w	103,0,0,0,0,11
verreqla8	dc.w	0,0
	dc.b	2,1,1,3
	dc.l	verreqla9,0
verreqla9	dc.w	103,1,103,11,1,11

verreqin1	dc.b	1,0,1,0
	dc.w	36,6
	dc.l	0
	dc.l	verreqla4,verreqin2
verreqla4	dc.b	'Blitz Basic 2 Version '
tver	set	version/100
	dc.b	tver+48,'.'
tver	set	version-(tver*100)
tver2	set	tver/10
	dc.b	tver2+48
tver	set	tver-(tver2*10)
	dc.b	tver+48,0
	;dc.b	(version/10)+48,'.',version-((version/10)*10)+48,'0',0
	even
verreqin2	dc.b	1,0,1,0
	dc.w	12,18
	dc.l	0
	dc.l	verreqla5,verreqin3
verreqla5	dc.b	'(C)opyright 1995 - Acid Software',0
	even
verreqin3	dc.b	1,0,1,0
	
	ifne	demo
	dc	64-8,30
	dc.l	0,verreqla6,0
verreqla6	dc.b	'AmigaFormat Demo Version',0
	endc

	ifne	release
	dc	64+16,30
	dc.l	0,verreqla6,0
verreqla6	dc.b	'Chocolate Version',0
	endc

	even
verreqin4	dc.b	1,0,1,0
	dc.w	4,2
	dc.l	0
	dc.l	verreqla10,0
verreqla10	dc.b	' OKEE DOKEE ',0
	even

verreqga1	dc.l	0
	dc.w	92,44,104,12,0,5,1
	dc.l	verreqbo2,0,verreqin4,0,0
	dc.w	1
	dc.l	0

objects	;some object codes for compile

lslimm	lsl	#8,d0

use	move.l	0(a5),a3
	add	d0,a3
	move.l	a3,0(a5)
usef	;

beginarr	move.l	#0,d0

mularr	mulu	d1,d0

putarr	move.l	d0,0(a5)

doarr	move	#0,d2
	move	#0,d3
doarrf	;

tstword	tst.w	d0
tstlong	tst.l	d0

nops8	nop
	nop
	nop
	nop
nops4	nop
nops3	nop
	nop
	nop
nopsf	;

dataget	move.l	0(a5),a3
	
dataput	move.l	a3,0(a5)

stlenget	move.l	(a3)+,-(a7)

stalign	addq	#1,a3
	exg	d0,a3
	bclr	#0,d0
	exg	d0,a3
stalignf

	;byte...
	;
dataletb	addq	#1,a3
	move.b	(a3)+,0(a5)
dataletbf

dataletbl	addq	#1,a3
	move.b	(a3)+,0(a4)
dataletblf

dataletb2	addq	#1,a3
	move.b	(a3)+,(a2)
dataletb2f

	;word...
	;
dataletw	move	(a3)+,0(a5)
	move	(a3)+,(a2)

	move	(a3)+,0(a4)

	;long...
dataletl	move.l	(a3)+,0(a5)
	move.l	(a3)+,(a2)

	move.l	(a3)+,0(a4)

nextfixw	addq	#8,a7

nextfixw2	lea	10(a7),a7

nextfixl	lea	12(a7),a7

nextfixl2	lea	14(a7),a7

nextb	;
	move.l	4(a7),a2
	move	(a7),d0
	add.b	d0,(a2)
nextbf

nextw	;a word type next
	;
	move.l	4(a7),a2
	move	(a7),d0
	add	d0,(a2)
nextwf

nextl	;
	move.l	8(a7),a2
	move.l	(a7),d0
	add.l	d0,(a2)
nextlf

nextf	;
	move.l	8(a7),a2
	move.l	(a2),d0
	move.l	(a7),d1
	jsr	-66(a6)
	move.l	d0,(a2)
nextff	;

forcompb	;
	move.l	4(a7),a2
	move.b	(a2),d0
	move	2(a7),d1
	tst	(a7)
	bpl	.skip
	exg	d0,d1
.skip	cmp.b	d1,d0
forcompbf	;

forcompw	;the For...Next Compare..... for words
	;
	move.l	4(a7),a2
	move	(a2),d0
	move	2(a7),d1
	tst	(a7)
	bpl	.skip
	exg	d0,d1
.skip	cmp	d1,d0
forcompwf	;

forcompl	;
	move.l	8(a7),a2
	move.l	(a2),d0
	move.l	4(a7),d1
	tst	(a7)
	bpl	.skip
	exg	d0,d1
.skip	cmp.l	d1,d0
forcomplf	;

forcompf	;floating point for/next compare.....
	;
	move.l	8(a7),a2
	move.l	(a2),d0
	move.l	4(a7),d1
	btst	#7,3(a7)
	beq	.skip
	exg	d0,d1
.skip	;
forcompff

forcompf2	;continuation
	;
	jsr	-42(a6)
forcompf2f	;

swapd0	swap	d0

pushindex	move.l	a2,-(a7)

leaamp	lea	0(a5),a2
leaamp2	move.l	a2,d0

leaampl	lea	0(a4),a2

stamp	move.l	(a2),d0

stamp2	move.l	0(a5),a2

stol	addq	#4,a7	;lose string len!

pushd0wd	move	d0,-(a7)

pushd0l	move.l	d0,-(a7)

movenumrep	move	#0,d7

preplibst	lea	0(a7),a2

fixlibst	lea	0(a7),a7	

pushdn	move.l	d0,-(a7)

movea3a7	move.l	a3,-(a7)

movestst2	move.l	6(a7),d0
	;
	move	4(a7),8(a7)
	move.l	(a7)+,(a7)
	;
movestst2f

movea7dn	move.l	4(a7),d0
	move.l	(a7)+,(a7)
movea7dnf

moved0a3	move.l	d0,a3

movestdn	move.l	0(a5),d0	 

movea3dn	move.l	a3,d0

putstlen	move.l	d0,-(a7)	;push string length

getstlen	move.l	(a7)+,d0	;pop string length

moverts	move.l	(a7),0(a7)

fixstack	lea	0(a7),a7

fixq	addq	#8,a7

fix1	move.l	(a7)+,(a7)

movedna3	move.l	d0,a3

least	lea	0(a4),a2

funcst	move.l	0(a4),-(a7)

addq4a2	addq	#4,a2

savesbase	move.l	a3,-(a7)
savesbase2	move.l	a3,0(a5)
savesbasef

ressbase	move.l	(a7)+,a3
ressbase2	move.l	a3,0(a5)
ressbasef

exga4a5	exg.l	a4,a5

linka4	link	a4,#0

unlinka4	unlk	a4

a2toa7	move.l	a2,-(a7)

a7toa2	move.l	(a7)+,a2

gotocode	jmp	0

gosubcode	jsr	0

mwait	btst	#6,$bfe001
	bne	mwait
mwaitf

libreg	move.l	d0,d0

libbase	move.l	0(a5),a6

libjsr	jsr	0(a6)

regtransd	move.l	0(a5),d0
regtransa	move.l	0(a5),a0

litget	move.l	#0,a3
litget2	move	(a3)+,-(a7)

movea2dn	move.l	(a2),d0

moved3a5dn	move.l	0(a5),d0

stvarget2	moveq	#0,d0
	move.l	d0,-(a7)
	tst.l	(a2)
	beq	varget2skip
	move.l	(a2),a0
	subq	#4,a0
	move.l	(a0)+,(a7)
stvarget2f	;
	jsr	0
	;
varget2skip	;

addcode	move.l	(a7)+,d0
	add.l	d0,(a7)
addcodef

pushlen	move.l	(a0)+,-(a7)

leaa5d3a2	lea	0(a5),a2

pusha2	move.l	a2,-(a7)

geta2	move.l	(a7),a2

pulla2	move.l	(a7)+,a2

pulla2st	move.l	4(a7),a2
	move.l	(a7)+,(a7)
pulla2stf	;

pusha3	move.l	0(a5),-(a7)
pusha32	move.l	a3,0(a5)
pusha3f

pulla3	move.l	(a7)+,0(a5)
pulla3f

geta3	move.l	0(a5),a3
geta3f

numtoa0	move.l	#0,a0

numtoa2	move.l	#0,a2

	;free up all arrays code
endarray	move	#0,d4

preparray	move	#0,d2
	move	#0,d3
preparrayf	;

dimbegin	move.l	#4,d0
dimbeginf	;

dimb4	move.l	d0,0(a5)
dimb4f	;

dimaf	mulu	d1,d0
dimaff	;

dimfin	move.l	d0,0(a5)
dimfinf	;

movea0	move.l	(a2),a2

adda0a0	add.l	a2,a2
	add.l	a2,a2

getebase	move.l	4.w,a6
getebasef	;

movea5a0	move.l	0(a5),a2

movea0a0	move.l	0(a2),a2

addqa0	addq	#1,a2

leaa0a0	lea	0(a2),a2

addrega2	add	d0,a2

tstname	dc.b	'ram:test',0
	even

;-----------end of object codes!--------------;

memat	dc.l	0
memlen	dc	0

memstackf	;
maths	dc.l	0
regat	dc	0	;register being used!
typelen	dc	0
prevtype	dc.l	0
prevloc	dc.l	0
lastchar	dc	0
thistype	dc.l	0
errstack	dc.l	0
errcont	dc.l	0
linemode	dc	0	;0 if norm, 1 if newtype
linesleft	dc	0
thisitem	dc.l	0
firstvar	dc.l	0
alllocals	dc.l	0
firstlocal	dc.l	0
firstglob	dc.l	0
varoff	dc	0
locvaroff	dc	0
firstitem	dc.l	0
numlines	dc	0
returncode	dc	0
firstif	dc.l	0

segadd	dc.l	0
segname	dc.b	'blitz2:ted',0
	even
mathsname	dc.b	'mathffp.library',0
	even

cifbras	dc.l	ciflt,cifeq,cifgt,0
	dc.l	cifle,cifne,cifle,0
	dc.l	cifge,cifne,cifge,0

atokens	dc.l	donewtype,doend,dolet,dodim,dogoto
	dc.l	dogosub,doreturn
	dc.l	dostate,dofunc,domwait,doif,dowhile
	dc.l	domacro,doselect,docase
	dc.l	dodefault,eos
	dc.l	doxinclude,doinclude,syntaxerr
	dc.l	doshared,dofor,donext,syntaxerr,syntaxerr
	dc.l	dodata,doread
	;
	;the folowing should all be intercepted by getchar
	;	
	dc.l	syntaxerr,syntaxerr,syntaxerr,syntaxerr
	dc.l	docerr,dothen,doelse,doeven4,doeven8
	;
	dc.l	dodc,dods,doeven,dodcb,dosetreg,doincbin
	dc.l	dofree,douse,dostop,docont,syntaxerr
	dc.l	dosetint,doclrint,domaxlen,dodeftype
	dc.l	doblitz,doamiga,doqamiga,dovwait,dolibjsr
	dc.l	dotokejsr,doblibjsr,syntaxerr
	;
	;A break goes in here for the assembler stuff!
	;
	dc.l	syntaxerr	;flash2	; for list
	dc.l	doseterr,doclrerr,syntaxerr,doerrfail
	dc.l	syntaxerr
	dc.l	syntaxerr	;Mod
	dc.l	syntaxerr	;Pi
	dc.l	dorepeat
	dc.l	dountil
	dc.l	doputreg
	dc.l	dopop
	dc.l	doincdir
	dc.l	mydoendif2
	dc.l	dowend
	dc.l	dosysjsr
	dc.l	dowbstartup
	dc.l	syntaxerr
	dc.l	doongo
	dc.l	syntaxerr
	dc.l	doforever
	dc.l	dorestore
	dc.l	doexchange
	dc.l	dousepath
	dc.l	docloseed
	dc.l	donocli
	dc.l	syntaxerr
	dc.l	syntaxerr
	dc.l	syntaxerr
	dc.l	syntaxerr
	dc.l	syntaxerr
	dc.l	dorunerrson
	dc.l	dorunerrsoff
	;
atokensend

actualbegin	;
	;OKAY, Here it is - The actual compiler!
	;
	;
begin	;find out how many system tokens exist
	moveq	#0,d0
	lea	tokens(pc),a0
.loop	addq	#1,d0
	move.l	(a0),d1
	beq	.gotlast
	move.l	d1,a0
	bra	.loop
.gotlast	move.l	a0,lasttoken
	bsr	makeasmtab
	jsr	optreqprep
	;
	move	#-1,returncode
	move.l	#mathsname,a1
	move.l	4.w,a6
	jsr	oldopenlibrary(a6)
	move.l	d0,maths
	beq	fail0
	;
	move.l	constmaxpc,d0
	moveq	#1,d1
	jsr	allocmem(a6)
	move.l	d0,constpcat
	beq	failme
	add.l	constmaxpc,d0
	move.l	d0,constlibat
	;
	move.l	macrolen,d0
	moveq	#1,d1
	jsr	allocmem(a6)
	move.l	d0,macrobuff
	beq	fail2
	add.l	macrolen,d0
	move.l	d0,macrobufff
	;
	move.l	#segname,d1
	calldos	loadseg
	move.l	d0,segadd
	beq	fail2a
	move.l	d0,a2
	add.l	a2,a2
	add.l	a2,a2
	lea	edstruct,a1
	jsr	8(a2)
	bne	fail3
	move.l	a0,-(a7)
	move.l	a1,comdata
	;
	clr	returncode
	move.l	44(a1),int
	move.l	#verreq,a0
	move.l	(a1),a1
;	jsr	(a1) ;Chocolate - don't show the about requester
	;
	bsr	sleepon
	move	#-1,linenumat
	bsr	makelibs
	bsr	loadlibs
	bsr	makeiallox
	bsr	pointeron
	;
	;click cancel of version requester...
	;
;.vloop	move.l	comdata,a0 ;Chocolate - don't wait for the requester to finish
;	move.l	8(a0),a0
;	jsr	(a0)
;	cmp	#-1,d7
;	bne	.vloop
;	cmp	#1,d6
;	bne	.vloop
	;
	;grab a panic bit
	;
	moveq	#-1,d0
	move.l	4.w,a6
	jsr	allocsignal(a6)
	move.l	d0,panicbit
	moveq	#0,d1
	bset	d0,d1
	move.l	d1,panicmask
	;
	;loadseg default debugger (blitz2:dhandler)
	;
	move.l	#debugname,d1
	calldos	loadseg
	move.l	d0,dseg
	;
	move.l	(a7)+,a1
	lea	progfile(pc),a0
	jsr	(a1)	;goto editor with filename!
	;
.skip	move.l	panicbit(pc),d0
	move.l	4.w,a6
	jsr	freesignal(a6)
	;
	move.l	dseg(pc),d1
	beq.s	.noseg
	calldos	unloadseg
.noseg	;
	bsr	freeemup
	bsr	freeres
	bsr	freelibs
	;
fail3	move.l	segadd,d1
	calldos	unloadseg
fail2a	bsr	freeallox
fail2b	move.l	macrobuff,a1
	move.l	macrolen,d0
	move.l	4.w,a6
	jsr	freemem(a6)
fail2	closedos
fail1a	;
fail1	move.l	constpcat,a1
	move.l	constmaxpc,d0
	move.l	4.w,a6
	jsr	freemem(a6)
	;
failme	move.l	maths,a1
	move.l	4.w,a6
	jsr	closelibrary(a6)
fail0	jsr	optreqdone
	bsr	flushlibs
	move	returncode,d0
	ext.l	d0
	bra	wb_exit
t
debugname	dc.b	'blitz2:defaultdbug',0
	even
dseg	dc.l	0
 
;-----------menu handler---------------;
handler

pointeron	move.l	comdata,a0
	move.l	72(a0),a0
	jmp	(a0)

sleepon	move.l	comdata,a0
	move.l	76(a0),a0
	jmp	(a0)

menu	move.l	a5,firstitem
	move	d7,numlines
	lsl	#2,d6
	lea	menuadds,a0
	move.l	0(a0,d6),a0
	move	#-1,linenumat
	move	#-1,menuret
	jsr	(a0)
	move	menuret,d0
	rts

dtext	dc.b	'Debug module to load',0
	even
dpath	dc.b	'Blitz2:'
	dcb.b	192,0
	even
dname	dcb.b	192,0
	even
dname2	dc.l	0

menu_d	;select debug module
	;
	move.l	comdata,a3
	move.l	24(a3),a3
	lea	dtext,a2
	lea	dpath,a0
	lea	dname,a1
	jsr	(a3)
	beq	nodload
	;
loaddmod	;d0=name of module to load!
	;
	move.l	d0,dname2
	bsr	sleepon
	move.l	a7,errstack
	move.l	#nodload,errcont
	move.l	dname2(pc),d1
	calldos	loadseg
	move.l	d0,d7
	beq	dloaderr
	move.l	dseg,d1
	beq.s	.ndseg
	calldos	unloadseg
	bsr	pointeron
.ndseg	move.l	d7,dseg
	;
nodload	rts

dloaderr	jsr	err
	dc.b	"Can't LoadSeg debug module!",0
	even

xtext	dc.b	'Name of Executable to create',0
	even
xpath	dcb.b	192,0
xname	dcb.b	192,0
execname	dc.l	0

menu1	;compile/save
	;
	move.l	comdata,a3
	move.l	24(a3),a3
	lea	xtext,a2
	lea	xpath,a0
	lea	xname,a1
	jsr	(a3)
	beq	.err
.tryit	;
	;O.K.... Now to create it
	move.l	d0,execname
	move	#-1,makeexec
	move	optreqga15+12,-(a7)
	bset	#7,optreqga15+13	;make small!
	bsr	compile
	tst	anyerrs
	bne.s	.skip
	bsr	savefile
.skip	move	(a7)+,optreqga15+12
.err	rts

docloseed	move	#-1,closeed
	rts

donocli	move	#-1,nocli
	rts

closeed	dc	0
nocli	dc	0

flushc	movem.l	a0-a1/d0-d1/a6,-(a7)
	move.l	4.w,a6
	cmp	#636,16(a6)
	bcs.s	.skip
	jsr	-636(a6)
.skip	movem.l	(a7)+,a0-a1/d0-d1/a6
	rts

menu0	;compile/run
	;
	clr	makeexec
	clr	closeed
	clr	nocli
	;
	bsr	compile
	;
	;RUN!
	;
menu10	tst	anyerrs
	bne	dontrun
	move	closeed(pc),d1
	beq	.noclose
	move.l	comdata,a0
	move.l	-8(a0),a0
	jsr	(a0)	;close editor
	bra.s	.nopanic
	;
.noclose	lea	executing(pc),a0
	bsr	openstopreq
	;
.nopanic	;find current dir...
	;
	move.l	dos,a6
	moveq	#0,d1
	jsr	currentdir(a6)
	move.l	d0,tasklock
	move.l	d0,d1
	jsr	currentdir(a6)
	;
	clr.l	panictask
	move.l	#procname,d1
	moveq	#0,d2
	move.l	#procstart,d3
	lsr.l	#2,d3
	move.l	stackfuck,d4
	move.l	dos,a6
	jsr	-138(a6)
	tst.l	d0
	beq.s	.fatal
	;
	;OK, task should be running here! see if we get a panic!
	;
.nostop	move.l	panicmask(pc),d0
	move.l	4.w,a6
	jsr	wait(a6)
	tst	stopit
	beq.s	.nostop
	bpl.s	.notpanic
	;
	bsr	chkrealstop
	beq.s	.nostop
	;
	move.l	panictask(pc),d0
	beq.s	.notpanic
	move.l	d0,a1
	move.l	4.w,a6
	jsr	remtask(a6)
	;
.notpanic	tst	closeed
	bne.s	.fatal
	bsr	endstop
	;
.fatal	clr.l	firstlocal
	clr.l	firstglob
	;
	move	closeed(pc),d1
	beq	.noopen
	move.l	comdata,a0
	move.l	-4(a0),a0
	jsr	(a0)
	;
.noopen	move.l	comdata,a0
	move.l	80(a0),a0	;window
	move.l	int,a6
	jmp	activatewindow(a6)
	;
dontrun	rts

tasklock	dc.l	0
panictask	dc.l	0
panicbit	dc.l	0
panicmask	dc.l	0

procname	dc.b	'Blitz ][ Program Proc',0
	even
	;
	cnop	0,4
	;
	dc.l	0	;length
procstart	dc.l	0	;next
	;
runtheprog	move.l	4.w,a0
	move.l	276(a0),panictask
	;
	move.l	dos,a6
	move.l	tasklock(pc),d1
	jsr	currentdir(a6)
	;
	move	nocli(pc),d1
	bne.s	.nocli
	move.l	comdata,a0
	move.l	60(a0),a0
	jsr	(a0)	;open hendrix
.nocli	;
	bsr	calcvbr
	move.l	vbr,a0
	move.l	#tokens,132(a0)
	move.l	firsttype,136(a0)
	move.l	#directtrap,128+15*4(a0)
	clr	dirmode
	clr.l	firstglob
	clr.l	firstlocal
	move.l	pc,dirpcat
	;
	bsr	flushc
	;
	move.l	stackfuck,d2
	move.l	#'bLtZ',d7	;force cli-type run
	lea	argreqla8,a0	;cli arguement
	move.l	pcat,a1
	;
runthing	jsr	(a1)		;Run the thing!
	;
	move	nocli(pc),d1
	bne.s	.nocli2
	move.l	comdata,a0
	move.l	64(a0),a0
	jsr	(a0)	;close the Hendrix IO Window
	;
.nocli2	move	#1,stopit	;ended OK!
	move.l	panicmask(pc),d0
	move.l	us,a1
	move.l	4.w,a6
	jsr	signal(a6)
	;
	rts

calcvbr	move.l	4.w,a6
	move	296(a6),d0
	moveq	#0,d1
	and	#15,d0
.loop	beq.s	.skip
	addq	#1,d1
	lsr	#1,d0
	bra.s	.loop
.skip	moveq	#0,d2
	cmp	#2,d1
	bcs.s	.skip2
	jsr	-150(a6)
	dc	$4e7a,$2801
	jsr	-156(a6)
.skip2	move.l	d2,vbr
	rts

flash	move	d0,-(a7)
	move	#-1,d0
.loop	move	d0,$dff180
	dbf	d0,.loop
	move	(a7)+,d0
	rts

flash2	move	d0,-(a7)
	move	#-1,d0
.loop	move	#15,$dff180
	dbf	d0,.loop
	move	(a7)+,d0
	rts

flushlibs	move.l	4.w,a6
	move.l	#1024*1024*256,d0	;ask for 256 MEG!
	moveq 	#1,d1
	jmp	-198(a6)

defname	dc.b	'blitz2:deflibs',0
	even
deflibs	dc.l	0

acidname	dc.b	'blitz2:acidlibs',0
	even
acidlibs	dc.l	0

menu8	bsr	sleepon
	bsr	freeblitzlibs
	bsr	makeblitzlibs
	bsr	loadblitzlibs
	bra	pointeron

checklib	moveq	#-2,d2
	jsr	lock(a6)
	move.l	d0,d7
	beq.s	.rts
	;
	;'deflibs' has been found! - lock in d7
	;
	;pick up file length
	;
	move.l	d7,d1
	move.l	#namebuff,d2
	jsr	examine(a6)
	move.l	d7,d1
	jsr	unlock(a6)
	move.l	namebuff+124,d0
.rts	rts

makelibs	;find all lib dirs in 'libsdir' and make a list of 'em
	;unless 'blitz2:deflibs' is there!
	;
	;return eq if error
	;
	move.l	dos,a6
	;
	move.l	#defname,d1
	bsr	checklib
	move.l	d0,deflibs
	;
	move.l	#acidname,d1
	bsr	checklib
	move.l	d0,acidlibs
	;
makeblitzlibs	move.l	#libsdir,d1
	moveq	#-2,d2
	move.l	dos,a6
	jsr	lock(a6)
	move.l	d0,d7
	beq	.done
	;
	move.l	d7,d1
	move.l	#namebuff,d2
	jsr	examine(a6)
	tst.l	d0
	beq	.done2
	move.l	namebuff+4,d0
	bmi	.done2
	;
	;OK to do exnext on dir...
	;
.loop	move.l	d7,d1
	move.l	#namebuff,d2
	jsr	exnext(a6)
	tst.l	d0
	beq	.ok
	move.l	namebuff+4,d0
	bmi	.loop
	;
	lea	namebuff+8,a0
	bsr	endininfo
	beq	.loop
	;
	move.l	4.w,a6
	moveq	#38,d0
	moveq	#1,d1
	jsr	doallocmem
	move.l	dos,a6
	;
	move.l	d0,d6
	lea	libslist,a0
.insloop	move.l	(a0),d5
	beq	.here
	move.l	d5,a2
	addq	#6,a2
	lea	namebuff+8,a1	;filename
.comloop	moveq	#0,d0
	move.b	(a1)+,d0
	beq	.here	;I'm shorter
	moveq	#0,d1
	move.b	(a2)+,d1
	beq	.next	;I'm longer
	bsr	tstalpha
	bne	.acskip
	and	#255-32,d0
.acskip	exg	d0,d1
	bsr	tstalpha
	bne	.acskip2
	and	#255-32,d0
.acskip2	exg	d0,d1
	cmp.b	d1,d0
	beq	.comloop
	bcs	.here	;I'm less than
.next	move.l	d5,a0
	bra	.insloop
	;
.here	;addq	#1,numlibs
	move.l	d6,a1
	move.l	(a0),(a1)	;next of last is next of me
	move.l	a1,(a0)	;I am next of last
	addq	#4,a1
	move	#-1,(a1)+	;set 'Used' flag
.yo	move.l	#namebuff+8,a0
.coploop	move.b	(a0)+,(a1)+
	bne	.coploop
	bra	.loop
	;
.ok	move.l	d7,d1
	jsr	unlock(a6)
	moveq	#-1,d0
.done	rts
.done2	move.l	d7,d1
	jsr	unlock(a6)
	moveq	#0,d0
	rts

frlibslist	;free up a libs list
	move.l	4.w,a6
	move.l	libslist,a2
	clr.l	libslist
	;clr	numlibs
.loop	cmp	#0,a2
	beq	.done
	move.l	a2,a1
	moveq	#38,d0
	move.l	(a2),a2
	jsr	freemem(a6)
	bra	.loop
.done	rts

;-----------main compiler functions!------------;
funcs

smallpass	dc	0

compile	;O.K. Here we go.....
	;
	move.l	a7,errstack
	move.l	#freeemup,errcont
	move.l	#concomstack,concomsp
	;
	;racing stripe stuff...
	;
	move.l	comdata,a0
	move.l	80(a0),a0
	move	8(a0),d0
	lsr	#3,d0
	subq	#7,d0
	move	d0,riteend
	swap	d0
	clr	d0
	divu	numlines,d0
	tst	d0
	bne	.ok
	moveq	#-1,d0
.ok	move	d0,titleadd
	;
	move.l	comdata,a0
	move	92(a0),d0
	move	d0,bmapmul
	mulu	#9,d0
	move	d0,botline	;offset to bottom of racing stripe
	;
	btst	#7,optreqga10+13
	sne	debugga
	;
;***;	clr	mywindow+2
	clr	dirmode		;direct mode flag
	clr	ezerr		;quiet error
	clr.l	thisproc
	clr	connest
	clr	varmode
	clr	procmode
	clr	numincs
	clr	intstring
	clr	smallpass
	;
.retry	bsr	dopass
	;
	btst	#7,optreqga15+13
	beq.s	.nosmall
	;
.makesmall	bsr	alloxadj
	beq	.anerr
	addq	#1,smallpass
	bsr	dopass
	;
.nosmall	move	nomemleft,d1
	beq	.dosave
	;
	move.l	#nomemreq,a0
	move.l	comdata,a1
	move.l	(a1),a1
	jsr	(a1)	;open the requester
	;
.loop	move.l	comdata,a1
	move.l	8(a1),a1
	jsr	(a1)	;getinput
	;
	cmp	#-1,d7
	bne	.loop
	cmp	#1,d6
	beq	.inc
	cmp	#2,d6
	beq	.makesmall
	cmp	#3,d6
	bne	.loop
.anerr	move	#-1,anyerrs
	bra	qfree
	;
.inc	bsr	alloxinc
	beq	freeemup
	bra	.retry
	;
.dosave	bra	qfree	;used to go after beq .nosave

qfree	;free up un-necessary stuff
	;
	jsr	freereps
	jsr	freesels
	jsr	freetlist
	jsr	freepends
	jsr	freeifs
	jsr	freeincs
	jsr	freexincs
	jsr	freefors
	jmp	freeasms

freeemup	bsr	qfree
	jsr	killoffs	;free up DOS offset table
	jsr	frallvars	;free up Global vars
	jsr	fralltypes	;free up all types
	jsr	freelabels	;free up labels
	jsr	freemacs	;free up actual macro defines.
	jsr	freeprocs	;free up states/funcs
	jmp	freeprocvs	;free up outstanding proc stuff

fralltypes	move.l	lastrestype,a0
	move.l	(a0),a2
	clr.l	(a0)
	bra	freetypes
	;
frallvars	move.l	firstvar,a3
	clr.l	firstvar
	bra	freevars

freeifs	lea	firstif,a2
	moveq	#14,d2
	jmp	freeslist

bmapmul	dc	0
botline	dc	0	;offset to bottom of stripe
riteend	dc	0	;right end of include strip

macmask	dc	0

nextline	;
	;go on to the next line of the program.....
	;
	clr	macmask
	bsr	freembuff
	clr	quoteflag
	tst	numincs
	beq	.skip3
	jsr	readinc
	beq	.skip3
	;
	;do include stripe
	;
	move	numincs,d0
	cmp	#4,d0
	bcc	.stskip
	add	d0,d0
	lea	titleadd,a0
	move	0(a0,d0),d2	;offset in line
	cmp	riteend(pc),d2
	bcc	.stskip
	addq	#1,0(a0,d0)
	;
	lsr	#1,d0
	mulu	bmapmul(pc),d0
	;
	move.l	comdata,a0
	move.l	36(a0),a1
	add	d0,a1
	not.b	0(a1,d2)
	move.l	36(a0),a1
	add	botline(pc),a1
	sub	d0,a1
	not.b	0(a1,d2)
.stskip	moveq	#-1,d0
	rts
	;
.skip3	;do main stripe
	;
	move.l	titleat,d0
	moveq	#0,d1
	move	titleadd,d1
	add.l	d1,d0
	move.l	d0,d1
	swap	d0
	cmp	titleat,d0
	beq	.skip3a
	move.l	comdata,a0
	move.l	36(a0),a0
	not.b	-1(a0,d0)
	add	botline(pc),a0
	not.b	-1(a0,d0)
.skip3a	move.l	d1,titleat
	;
.skip2	;
	addq	#1,linenumat
	clr	linedone
	;
.norunerr	subq	#1,linesleft
	beq	.skip
	move.l	thisitem,a0
	move.l	(a0),a0
	move.l	a0,thisitem
	lea	9(a0),a5
	;
.skip	rts

hexascii	;convert d1.w to ascii at a0
	;
	move	d0,-(a7)
	moveq	#3,d0
.loop	move	d1,d2
	and	#15,d2
	add	#48,d2
	cmp	#58,d2
	bcs	.skip
	addq	#7,d2
.skip	move.b	d2,0(a0,d0)
	lsr	#4,d1
	dbf	d0,.loop
	move	(a7)+,d0
	rts

expandmax	;
	;go through statement and expand macros
	;
	;line at a5.....
	;check it for !'s
	;
	move	comflag,d1
	bne	.loop0
	rts
	;
.loop0	move.l	a5,-(a7)
	moveq	#':',d1
	moveq	#'!',d2
	moveq	#';',d3
	moveq	#'"',d4
	;
.loop	move.b	(a5)+,d0
	beq	.done
	bpl	.test
	move.b	(a5)+,d0
	bra	.loop
.test	cmp.b	d4,d0
	bne	.notq
	;
.qloop	move.b	(a5)+,d0
	beq	notqerr
	bpl	.qskip
	move.b	(a5)+,d0
	bra	.qloop
.qskip	cmp.b	#'"',d0
	bne	.qloop
	bra	.loop
	;
.notq	cmp.b	d1,d0
	beq	.done
	cmp.b	d3,d0
	beq	.done
	cmp.b	d2,d0	;macro character!
	bne	.loop
	;
	;expand the macro!
	;
	move	#-1,macmask
	move.l	a5,a3
	;
	bsr	makename
	bne	.fkitme
	jmp	syntaxerr
.fkitme	bsr	bakup
	;
	bsr	findmac
	beq	.kl1
	jmp	nomacerr
.kl1
	;
	move.l	a5,a4	;start of parameters!
	moveq	#0,d4	;narg=0
	cmp.b	#'{',(a4)+
	bne	.nops
	move.l	macrobuff,a0	;start of parameter collect	
.ppl	addq	#1,d4	;another p
	move.l	a4,(a0)
	bsr	findit
	move.l	a4,d1
	sub.l	(a0)+,d1
	subq	#1,d1
	move	d1,(a0)+
	cmp.b	#'}',d0
	bne	.ppl
	move.l	a4,a5
.nops	move	d4,numarg
	;
	move.l	macrolen,d0
	moveq	#1,d1
	move.l	4.w,a6
	jsr	doallocmem
	;
	move.l	myline,myoline
	move.l	d0,myline
	move.l	d0,a1
	move.l	a1,a6
	add.l	macrolen,a6	;end of macro buffer
	;
	move.l	(a7)+,a0	;start of the line
.loop2	cmp.l	a6,a1
	bcc	mbovererr
	move.b	(a0)+,(a1)+
	cmp.l	a3,a0
	bcs	.loop2
	subq	#1,a1	;back over '#'
	;
	move	8(a2),d1	;mac len
	beq	.loop4
	move	10(a2),macnum
	addq	#1,10(a2)
	move.l	4(a2),a2
	subq	#1,d1
.loop3	moveq	#0,d0
	move.b	(a2)+,d0
	cmp.b	#'`',d0
	bne	.oky
	subq	#1,d1
	move.b	(a2)+,d0
	cmp	#'{',d0
	beq	.evalit
	cmp	#'@',d0
	bne	.notnum
	;
	;macro num parameter
	;
	moveq	#0,d2
	move	macnum,d2
	move.l	a1,a0
	move	d1,-(a7)
	jsr	makelong
	move.l	a0,a1
	move	(a7)+,d1
	;
	bra	.oky2
	;
.notnum	or	#32,d0
	cmp	#'z',d0
	bcs	.fkit
	jmp	ilconsterr
.fkit	sub	#48,d0
	cmp	#10,d0
	bcs	.itsgot
	;
	sub	#39,d0
	cmp	#10,d0
	bcc	.fkit2
	jmp	ilconsterr
.fkit2	bra	.itsgot
	;
.evalit	move.l	a5,-(a7)
	movem.l	d1/a1/a2/a6,-(a7)
	move.l	a2,a5
	jsr	evalconst2
	cmp	#'}',d0
	beq	.allisok
	jmp	syntaxerr
.allisok	movem.l	(a7)+,d1/a1/a2/a6
	move.l	a5,d2
	sub.l	a2,d2
	sub	d2,d1
	move.l	a5,a2
	;
	clr	quoteflag
	move.l	(a7)+,a5
	;
	move.l	d3,d0
	bpl	.itsgot
	jmp	ilconsterr
	;
.itsgot	subq	#1,d0
	bpl	.ok
	;
	;here, we do a numarg text replace
	;
	move	numarg,d0
	divu	#10,d0
	add	#48,d0
	cmp.l	a6,a1
	bcc	mbovererr
	move.b	d0,(a1)+
	swap	d0
	add	#48,d0
	cmp.l	a6,a1
	bcc	mbovererr
	move.b	d0,(a1)+
	bra	.oky2
	;
.ok	;ok to do parameter replacement
	;d0= number for parameter replacement!
	;
	cmp	numarg,d0
	bcc	.oky2
	lsl	#1,d0
	move	d0,d4
	lsl	#1,d0
	add	d4,d0	;*6
	move.l	macrobuff,a0
	add	d0,a0
	move	4(a0),d4	;len of replacetext
	beq	.oky2
	move.l	(a0),a0
	subq	#1,d4
.plp	cmp.l	a6,a1
	bcc	mbovererr
	move.b	(a0)+,(a1)+
	dbf	d4,.plp
	bra	.oky2
	;
.oky	cmp.l	a6,a1
	bcc	mbovererr
	move.b	d0,(a1)+
	bpl	.oky2
	cmp.l	a6,a1
	bcc	mbovererr
	move.b	(a2)+,(a1)+
	subq	#1,d1
.oky2	dbf	d1,.loop3
	;
.loop4	cmp.l	a6,a1
	bcc	mbovererr
	move.b	(a5)+,(a1)+
	bne	.loop4
	;
	move.l	myline,a5
	;
	move.l	myoline,d0
	beq	.skip3
	move.l	d0,a1
	move.l	macrolen,d0
	move.l	4.w,a6
	jsr	freemem(a6)
.skip3	bra	.loop0
	;
.done	move.l	(a7)+,a5
	rts

freembuff	move.l	myline,d0
	beq	.no
	clr.l	myline
	move.l	d0,a1
	move.l	macrolen,d0
	move.l	4.w,a6
	jmp	freemem(a6)
.no	rts

findit	;find the end of a parameter
	;
	moveq	#0,d2	;no nesting
.loop	move.b	(a4)+,d0
	beq	syntaxerr
	bpl	.tst
	addq	#1,a4
	bra	.loop
.tst	cmp.b	#'"',d0
	bne	.notq
	not	quoteflag
	bra	.loop
.notq	tst	quoteflag
	bne	.loop
	cmp.b	#',',d0
	bne	.notc
	tst	d2
	beq	.done
	bra	.loop
.notc	bsr	isitopen
	bne	.noto
	addq	#1,d2
	bra	.loop
.noto	cmp.b	#'}',d0
	bne	.notcb
	tst	d2
	beq	.done
.notcb	bsr	isitclose
	bne	.loop
	subq	#1,d2
	bra	.loop
.done	rts

isitopen	cmp.b	#'{',d0
	beq	.yes
	cmp.b	#'(',d0
.yes	rts

isitclose	cmp.b	#'}',d0
	beq	.yes
	cmp.b	#')',d0
.yes	rts

stopreq	dc.l	0
	dc.w	172,38,208,44,0,0
	dc.l	stopreqga1,stopreqbo1,stopreqin1
	dc.w	0
	dc.b	0,0
	dc.l	0
	ds.b	32
	dc.l	0,0
	ds.b	36

stopreqbo1	dc.w	0,0
	dc.b	1,2,1,3
	dc.l	stopreqla1,stopreqla2
stopreqla1	dc.w	199,4,8,4,8,23
stopreqla2	dc.w	0,0
	dc.b	2,1,1,3
	dc.l	stopreqla3,stopreqbo2
stopreqla3	dc.w	199,5,199,23,9,23
stopreqbo2	dc.w	0,0
	dc.b	1,2,1,3
	dc.l	stopreqla4,stopreqla5
stopreqla4	dc.w	207,0,0,0,0,43
stopreqla5	dc.w	0,0
	dc.b	2,1,1,3
	dc.l	stopreqla6,0
stopreqla6	dc.w	207,1,207,43,1,43
stopreqbo3	dc.w	0,0
	dc.b	1,2,1,3
	dc.l	stopreqla8,stopreqla9
stopreqla8	dc.w	63,0,0,0,0,11
stopreqla9	dc.w	0,0
	dc.b	2,1,1,3
	dc.l	stopreqla10,0
stopreqla10	dc.w	63,1,63,11,1,11

stopreqin1	dc.b	1,0,1,0
	dc.w	20,10
	dc.l	0
	dc.l	stopreqla7,0
stopreqla7	dc.b	'***** '
reqmessage	dc.b	'COMPILING *****',0
	even
stopreqin2	dc.b	1,0,1,0
	dc.w	4,2
	dc.l	0
	dc.l	stopreqla11,0
stopreqla11	dc.b	' STOP! ',0
	even
	;
stopreqga1	dc.l	0
	dc.w	72,28,64,12,0,1,1
	dc.l	stopreqbo3,0,stopreqin2,0,0
	dc.w	1
	dc.l	0

stopbit	dc	0
stopit	dc	0
clrreq	dc	0

stopcode	move	stopit(pc),d1
	bne.s	.skip
	move	stopbit(pc),d1
	btst	d1,d0
	beq.s	.skip
	move	#-1,stopit
	;
	movem.l	d0/a6,-(a7)
	move.l	panicmask(pc),d0
	move.l	us,a1
	move.l	4.w,a6
	jsr	signal(a6)
	movem.l	(a7)+,d0/a6
	;
.skip	rts

endstop	move	clrreq(pc),d0
	beq	.skip
	move.l	comdata,a1
	move.l	4(a1),a1
	jsr	(a1)	;turn off the requester
	not	clrreq
	move.l	us,a0
	clr.l	30(a0)
	clr.l	42(a0)
.skip	rts

intsused	dc	0

setcvars	;
	move	#-1,blitzoff
	clr	intsused
	clr	anyerrs
	clr	blitzmode
	clr	nomemleft
	clr	constmode
	clr	cmake
	clr	cfetchmode
	clr.l	intdata1
	clr	fuckpos
	clr	procnum
	clr	procnum2
	clr	dfetch
	clr.l	titleat
	clr.b	usedpath
	clr	inerr
	clr	intlevel
	clr.l	cont_pc
	clr.l	cont_pc2
	clr.l	lastcontlink
	;
	move.l	pcat,pc
	move.l	pcat,bigpc
	move.l	libat,lib
	move.l	data1at,data1
	move.l	data2at,data2
	;
	move	#-1,comflag
	move	#-1,linemode
	clr	oldvcodelen
	clr.b	lastbiglab
	;
	rts

varsizeat	dc.l	0
debugga	dc	0	;debugger enabled?

compiling	dc.b	'COMPILING',0
	dc.b	' STOP! ',0

executing	dc.b	'EXECUTING',0
	dc.b	'!PANIC!',0

openstopreq	;
	not	clrreq
	lea	reqmessage(pc),a1
	;
.loop	move.b	(a0)+,(a1)+
	bne.s	.loop
	move.b	#32,-(a1)
	;
	lea	stopreqla11,a1
.loop2	move.b	(a0)+,(a1)+
	bne.s	.loop2
	;
	move.l	comdata,a1
	move.l	(a1),a1
	move.l	#stopreq,a0
	jsr	(a1)	;open requester
	clr	stopit
	;
	move.l	us,a0
	move.l	#stopcode,42(a0)
	move.l	comdata,a1
	move.l	94(a1),a1	;window
	move.l	86(a1),a1	;user MsgPort
	moveq	#1,d0
	move.b	15(a1),d1	;Sig Bits.
	move.b	d1,stopbit+1
	lsl.l	d1,d0
	move.l	d0,30(a0)	;Signal Bits
	rts

dopass	;compile entire program based on 'pass'
	;
	lea	compiling(pc),a0
	bsr	openstopreq
	;
	bsr	sleepon
	;
	bsr	setcvars
	;
	move	#$8000,varoff
	move.l	#quicktype,defaulttype
	;
	move.l	a7,passstack
	move.l	#firstitem,thisitem
	move	numlines,linesleft
	addq	#1,linesleft
	move	#-1,linenumat
	;
	bsr	resetlibs
	bsr	freeemup
	;
	lea	titleadd+2,a0
	moveq	#3,d0
.okloop	clr	(a0)+
	dbf	d0,.okloop
	;
	;put in 4 nops for dummy JSR to init routines! (was 3)
	;
	lea	nops4,a0
	lea	nopsf,a1
	bsr	pokecode2
	;
	move.b	debugga(pc),d1
	beq.s	.dskip
	;
	move	#runerrlib,d1
	bsr	uselib
	;
	tst	makeexec
	bne.s	.exec
	;
	;not executable!
	;
	move	#debuglib,d1
	bsr	uselib
	move	#dhandlerlib,d1
	bsr	uselib
	bra.s	.dskip
	;
.exec	;is executable!
	;
	move	#rundebuglib,d1
	bsr	uselib
	;
.dskip	bsr	nextline
	;
passloop	bsr	doline
passnxt	bsr	nextline
	bne	passloop
	;
	bsr	dorunerrson
	;
	bsr	pointchk
	clr	linenumat
	bsr	errchx2
	;
	move.b	debugga(pc),d1
	beq.s	.nodb
	;
	bsr	debugstuff
	move	#finalscheck,d1
	jsr	tokejsr
	;
	bsr	debugstuff
	move.l	eopcode(pc),d1
	bsr	pokel
	move.l	lastcontlink(pc),d1
	beq.s	.nocl
	move.l	d1,a0
	clr	6(a0)
.nocl	;
.nodb	;
	;end of whole program!
	;
	move.l	pc,endop		;where end goes...
	;
	tst	blitzmode
	beq	.nobl
	bsr	doamiga		;back to amiga if in blitz!
	;
.nobl	tst	intsused
	beq.s	.noints
	move	#$c105,d1	;interupts off!
	jsr	tokejsr2
	;
.noints	bsr	calcstatic
	move	d4,numstatic
	move.l	d3,staticdata
	bsr	calcmaxs
	;
	tst.l	tokeslist
	beq.s	.skipjsrs
	;
	move	gotocode,d1		;jmp!
	bsr	pokewd
	move.l	pc,endjmpat
	bsr	addoff
	bsr	pokel
	;
	bsr	fixjsrs		;has to be done before finits!
	;
	;misc finish-ups
	;
	tst	nomemleft
	bne.s	.skipjsrs
	move.l	endjmpat(pc),a4
	move.l	pc,(a4)
	;
.skipjsrs	bsr	makefinits
	move.l	#$70004e75,d1
	bsr	pokel
	bsr	makeinits
	bsr	asmfixer
	;
	bsr	endstop
	bra	pointeron

eopcode	moveq	#3,d0
	trap	#0

endjmpat	dc.l	0

pointchk	move.l	firsttype,a2
	move.l	#$ff,d0
.loop	cmp	#0,a2
	beq	.done
	cmp.l	4(a2),d0
	bne	.next
	move	8(a2),linenumat
	bra	notypeerr
.next	move.l	(a2),a2
	bra	.loop
.done	rts

errchx2	lea	firstlabel,a2
	;Make sure all the labels have been resolved
.loop	move.l	(a2),d0
	beq	.done
	move.l	d0,a2
	move.l	4(a2),d0
	btst	#0,d0
	bne	.loop
	move.l	8(a2),d0
	bne	.loop 
	move	16(a2),linenumat
	jmp	nolaberr
	;
.done	move.l	concomsp,d0
	cmp.l	#concomstack,d0
	bne	chxerr4
	move	connest,d1
	bne	chxerr4
	;
errchx	move.l	d1,-(a7)
	move.l	firstsel,d1
	bne	.err1
	move.l	firstrep,d1
	bne	.err2
	move	intstring,d1
	bne	.err3
	move.l	firstif,d1
	bne	.err5
	move	procmode,d1
	bne	.err6
	move.l	firstfor,d1
	bne	.err7
	move.l	(a7)+,d1
	rts

.err1	move	sellineat,linenumat
	jmp	selerrz
.err2	move	replineat,linenumat
	jmp	unterr3
.err3	move	intlineat,linenumat
	jmp	interr2
.err5	move	iflineat,linenumat
	jmp	noenderr
.err6	move	prolineat,linenumat
	jmp	nopenderr
.err7	move	forlineat,linenumat
	jmp	nonexterr
chxerr4	move	ciflineat,linenumat
	jmp	nocenderr

calcmaxs	;How many max's used in prog?
	;
	move.l	data1,maxsat
	moveq	#0,d4
	move.l	firstlib,a2
.loop	cmp	#0,a2
	beq	.done
	tst	12(a2)
	bpl	.next
	move.l	18(a2),d0
	tst	-2(a2,d0.l)
	beq	.next
	;
	addq	#1,d4
	move	-6(a2,d0.l),d1
	bsr	pokedata1
	moveq	#1,d1
	move	-2(a2,d0.l),d2
	lsl	d2,d1
	mulu	-4(a2,d0.l),d1
	bsr	pokedata1l
	;
.next	move.l	(a2),a2
	bra	.loop
.done	move	d4,maxsused
	beq	.done2
	move	#65530,d1	;use memlib
	bra	uselib
.done2	rts

doline	;
	bsr	dostatement
	bsr	reget
	bne	illeolerr
	cmp	#$8000+34,d0
	bne	.notelse
	jsr	doelse2
	bra	doline
.notelse	tst	d0
	bne	doline
	;
	;here we do any 'un-thens'
	;
.unthen	move.l	firstif,d0
	beq	.done
	move.l	d0,a0
	move	12(a0),d1
	bpl	.done
	;
	;an If...Then... found!
	;
	bclr	#15,d1
	jsr	doendif2
	jsr	freetheifz
	bra	.unthen
.done	rts

createlab	;loclabch fetched, make a big label!
	;
	lea	lastbiglab,a0
	tst.b	(a0)
	beq	nolocerr
	lea	namebuff,a1
	moveq	#0,d2
.loop	addq	#1,d2
	move.b	(a0)+,(a1)+
	bne	.loop
	move.b	#loclabch,-1(a1)
	move	d2,-(a7)
	bsr	makename4
	cmp	(a7)+,d2
	beq	syntaxerr
	rts

prepstack	move.l	#forthstack,forthsp
	move.l	#precstack,precsp
	rts

chkrealstop	;
	;return ne if really a stop!
	;
	moveq	#0,d4
.loop	move.l	comdata,a0
	move.l	32(a0),a0
	jsr	(a0)
	tst.l	d7
	beq.s	.skip
	cmp	#-1,d7
	bne.s	.loop
	cmp	#1,d6
	bne.s	.loop
	moveq	#-1,d4
	bra.s	.loop
.skip	move	d4,stopit
	rts
	

chkstop	move	stopit(pc),d0
	bne.s	.chk
.rts	rts
.chk	bsr	chkrealstop
	beq.s	.rts
	;
gostop	bsr	endstop
	bsr	pointeron
	;
	move.l	errstack(pc),a7
	move.l	errcont(pc),a0
	move	#-1,anyerrs
	jmp	(a0)

d_pc	ds.l	1
d_bigpc	ds.l	1
d_nomemleft	ds.w	1
cont_pc	ds.l	1
cont_pc2	ds.l	1
lastcontlink	ds.l	1

maketrap	or	#$4e40,d1
	bra	pokewd

debugstuff	tst.b	debugga
	beq	.rts
	tst	macmask
	bne.s	.rts	;no debugging of Macros!
	tst	dirmode	;or while in direct mode...
	bne.s	.rts
	;
	move.l	pc,d_pc
	move.l	bigpc,d_bigpc
	move	nomemleft,d_nomemleft
	;
	movem.l	d0-d1,-(a7)
	;
	moveq	#1,d1
	bsr	maketrap
	;
	;hook up cont address...
	;
	move.l	pc,d0
	move.l	cont_pc,d1
	move.l	d0,cont_pc
	move.l	d1,cont_pc2
	beq.s	.skip
	;
	tst	nomemleft
	bne.s	.skip
	;
	move.l	d1,a4
	sub.l	a4,d0
	move	d0,6(a4)
	move.l	a4,lastcontlink
	;
.skip	move.l	thisitem(pc),d1
	bsr	pokel
	move.l	a5,d1
	sub.l	thisitem(pc),d1
	bsr	pokewd
	;
	moveq	#0,d1
	bsr	pokewd		;next cont goes here!
	;
	movem.l	(a7)+,d0-d1
.rts	rts

undodebug	tst.b	debugga
	beq.s	.rts
	tst	macmask
	bne.s	.rts
	;
	move	d_nomemleft,nomemleft
	move.l	d_bigpc,bigpc
	move.l	d_pc,pc
	move.l	cont_pc2,cont_pc
	;
.rts	rts

setsvars	;set statement vars...
	;
	bsr	prepstack
	clr	regat
	clr	nonew
	clr	sbasegot
	move	varcodelen,oldvcodelen
	clr	varcodelen
	move	#-1,lasta6
	;
	rts

smode	;special mode...d1...
	;
	tst	linemode
	bmi.s	.skip
	bsr	undodebug
	move	linemode,d1
	addq	#4,a7
	lsl	#2,d1
	lea	modetable,a0
	move.l	0(a0,d1),a0
	bsr	reget
	jmp	(a0)
.skip	rts

dostatement	;process individual statement
	;
	bsr	chkstop
	bsr	expandmax
	bsr	debugstuff
	;
	;bra	handlechar
	;
handlechar	;Handle the first character in statement
	;
	bsr	getchar3
	beq	handleeol
	bsr	setsvars
	bsr	smode
	;
	cmp	#'.',d0
	beq	handlemouse
	cmp	#'#',d0
	beq	handleconst
	cmp	#loclabch,d0
	beq	handlelocal
	tst	d0
	bmi	handletoken
	;
handleascii	;
	move.l	a5,letstart
	bsr	getvname
	bsr	reget
	beq	handlelabel
	cmp	#'{',d0
	beq	handleproc
	jmp	dolet2
	
handleeol	cmp	#$8000+34,d0
	beq	handletoken
	bra	undodebug	;!*!*!
;	rts
	
handlelocal	bsr	undodebug	!***!
	;
	bsr	createlab
	bra	handlelab2

handlemouse	bsr	getchar3
	beq	handleeol	;syntaxerr
	cmp	#loclabch,d0
	beq	handlelocal
	bsr	makename2
	
handlelabel	;an ordinary label
	;
	bsr	undodebug	!***!
	;
	lea	namebuff,a0
	lea	lastbiglab,a1
.coplab	move.b	(a0)+,(a1)+
	bne	.coplab
	;
handlelab2	bsr	findadd
	beq	.found
	;
	bsr	addhere
	;
.done	clr.l	4(a2)		;no refs
	move.l	pc,8(a2)		;pc of label.
	move.l	data2,12(a2)	;pc for data statements
	move	procnum,16(a2)
	rts
	;
.found	move.l	4(a2),d0
	btst	#0,d0
	bne	illlaberr
	move.l	8(a2),d0
	bne	duplaberr
	move	procnum,16(a2)
	;
	;now, we have to fill in blanks in the Bloody past code....
	;
	move.l	4(a2),a3	;start of refs list
	move.l	4.w,a6
.floop	cmp	#0,a3
	beq	.done
	move	8(a3),d1
	cmp	16(a2),d1
	beq	.isok
	;
	;Bad Reference
	;
	move	10(a3),linenumat
	bra	referr
	;
.isok	move	nomemleft,d1
	bne	.isaskip
	move.l	4(a3),a1
	btst	#0,7(a3)
	beq	.pcref
	;
	;OK it's a 'Restore' references
	;
	subq	#1,a1
	move.l	data2,(a1)
	bra	.isaskip
	;
.pcref	move.l	pc,(a1)
	;
.isaskip	move.l	a3,a1
	move.l	(a3),a3
	move.l	a3,4(a2)	;new first.
	moveq	#12,d0
	jsr	freemem(a6)
	bra	.floop

handleconst	bsr	prepstack	;forth stax
	bsr	makename
	bsr	findadd
	beq	.cfound
	bsr	addhere
	move.l	#1,4(a2)
	bra	.cn		
.cfound	cmp.l	#1,4(a2)
	bne	illconerr
.cn	cmp	#'=',d0
	beq	.asscon
	rts
.asscon	move.l	a2,-(a7)
	bsr	evalconst2
	move.l	(a7)+,a2
	move.l	d3,8(a2)
	rts

handleproc	;a procedure! - eg gameover{score.l,player}
	;
	bsr	findproc
	bne	noprocerr
	tst.b	5(a2)
	bpl	illprocerr
	move.l	14(a2),-(a7)	;pc of proc.
	moveq	#0,d0
	move.b	4(a2),d0
	beq	.nopars
	lea	22(a2),a2	;pointer to var desc list
	bsr	fetchpees2
	bra	.nopars3
.nopars	bsr	getchar3
.nopars3	cmp	#'}',d0
	bne	syntaxerr
	;
	jsr	chkstak
	move.l	(a7)+,d1
	bsr	makefjsr
	bra	getchar3

handletoken	;process a token in d0
	;
	cmp	#$8000+fnum,d0
	bcs	.nono
	cmp	#$8000+tnum,d0
	bcc	.nono
	;
	btst	#7,optreq2ga3+13
	bne.s	.asmok
	bsr	undodebug
.asmok	bra	asmit	;assemble the bastard
	;
.nono	;check if asm type things....
	;
	;if so, no line remembering etc!
	;
	bclr	#15,d0
	move	d0,d1
	and	#$7f00,d1
	bne	handlelib
	;
	cmp	#tnum,d0
	bcs	.isokat
	;
	sub	#tnum-fnum,d0
	cmp	#fnum+15,d0
	beq	.noerr
	cmp	#fnum+10,d0
	beq	.noerr
	bra	.doerr
	;
.isokat	cmp	#56,d0	;check for things which don't want
	beq	.noerr	;error checking...
	cmp	#57,d0
	beq	.noerr
	cmp	#13,d0
	beq	.noerr
	cmp	#18,d0
	beq	.noerr
	cmp	#19,d0
	beq	.noerr
	cmp	#26,d0
	beq	.noerr
	cmp	#42,d0
	bhi	.doerr
	cmp	#35,d0
	bcs.s	.doerr
	;
.noerr	bsr	undodebug
.doerr	;
	subq	#1,d0
	lsl	#2,d0
	cmp	#atokensend-atokens,d0
	bcs	.ok
	;
	;Freaked out Token!
	bsr	flash
	;
	rts
.ok	lea	atokens,a0
	move.l	0(a0,d0),a0
	move.l	a0,-(a7)
	bra	getchar3

handlelib	;a token from a library!
	;
	move	d0,d1
	bsr	findtoke	;toke stuff in a3
	btst	#2,1(a3)
	bne	stamigalib
	btst	#0,1(a3)
	beq	syntaxerr	;check it's a statement
	;
	bsr	sizespec	;does it need a size specifier?
	bsr	countpees
	;
dolibtoke	;number of parameters in d1....
	;a2=lib base, a3=sub for this toke
	;
	move	numreps,-(a7)
	move	userp,-(a7)
	move	stackuse,-(a7)
	move.l	a2,-(a7)		;recurs.
	move	usertype,userp
	lea	6(a3),a1
	;
	;now to find a form with d1 parameters in it.....
.loop	move	(a1),d2
	bmi	syntaxerr
	and	#255,d2
	cmp	d2,d1
	beq	.found
	bcs	.next
	move.b	(a1),d3
	and	#7,d3
	beq	.next
	move	d2,d4
	sub	d3,d4
	moveq	#0,d5
	move	d1,d5
	sub	d4,d5
	divu	d3,d5
	swap	d5
	tst	d5
	beq	.found
	;
.next	addq	#2,a1
	add	d2,a1
	bsr	aligna1
	bsr	skiplibreg
	lea	12(a1),a1
	bra	.loop
.found	;Got it!
	move.b	(a1),d2
	lsl	#8,d2
	or	d2,d1
	move.l	a1,-(a7)
	clr	stackuse
	tst	d1
	beq	.nopees
	lea	2(a1),a2
	bsr	fetchlibps
	bra	.skip
.nopees	bsr	getchar3
.skip	move.l	(a7)+,a1
	move.l	(a7)+,a2
	move	stackuse,d1
	beq	.skip2
	move	d1,preplibst+2
	move.l	preplibst,d1
	bsr	pokel
	move	numreps,movenumrep+2
	beq	.skip2
	move.l	movenumrep,d1
	bsr	pokel
.skip2	bsr	userjsr	;make the JSR
	move	stackuse,d1
	beq	.skip3
	cmp	#8,d1
	bhi	.skip4
	and	#7,d1
	lsl	#8,d1
	lsl	#1,d1
	or	#$504f,d1	;addq #x,a7
	bsr	pokewd
	bra	.skip3
	;
.skip4	move	d1,fixlibst+2
	move.l	fixlibst,d1
	bsr	pokel
.skip3	move	(a7)+,stackuse
	move	(a7)+,userp
	move	(a7)+,numreps
	bra	reget

sizespec2	movem.l	a2-a3,-(a7)
	move.l	a5,prevloc
	bsr	getchar
	cmp	#'.',d0
	beq	.ok1
	move.l	defaulttype,a2
	cmp	#'$',d0
	bne	.none
	moveq	#7,d1
	bra	.skip
.ok1	bsr	makename
	beq	syntaxerr
	lea	alltypes,a2
	bsr	findtype
	bne	notypeerr
.none	bsr	bakup
	cmp.l	#256,4(a2)
	bcc	illtypeerr
	move	6(a2),d1
.skip	move	d1,usertype
	movem.l	(a7)+,a2-a3
	rts

sizespec	btst	#3,1(a3)
	beq	.skip
	bsr	sizespec2
	or	#$7000,d1
	bsr	pokewd
	addq	#1,regat
.skip	rts

;-----------subs-------------------------------;
subs

dorunerrson	;turn on runtime error checking!
	;
	btst	#7,optreqga10+13
	sne	debugga
	rts

dorunerrsoff
	sf	debugga
	rts

usedpath	ds.b	128

dousepath	beq	syntaxerr
	lea	usedpath(pc),a0
.loop	tst	d0
	bmi	syntaxerr
	move.b	d0,(a0)+
	bsr	getchar3
	bne	.loop
.done	move.b	#2,(a0)
	rts

swapb	move.b	(a2),d0
	move.b	(a1),(a2)
	move.b	d0,(a1)
swapbf

swapw	move	(a2),d0
	move	(a1),(a2)
	move	d0,(a1)
swapwf

swapl	move.l	(a2),d0
	move.l	(a1),(a2)
	move.l	d0,(a1)
swaplf

pulla1	move.l	(a7)+,a1

srctype	dc	0
	;
doexchange	;'swap' 2 variables.
	;
	bsr	excget
	cmp	#',',d0
	bne	syntaxerr
	move.b	d2,srctype
	move	pusha2(pc),d1
	bsr	pokewd
	bsr	getchar3
	bsr	excget
	cmp.b	srctype(pc),d2
	bne	excerr2
	move	pulla1(pc),d1
	bsr	pokewd
	;
	cmp.b	#2,d2
	bcs	.byte
	beq	.word
	lea	swapl(pc),a0
	lea	swaplf(pc),a1
	bra	pokecode
.word	lea	swapw(pc),a0
	lea	swapwf(pc),a1
	bra	pokecode
.byte	lea	swapb(pc),a0
	lea	swapbf(pc),a1
	bra	pokecode

excget	bsr	getvname
	bsr	fetchvar
	bsr	calcvar
	btst	#14,d2
	beq	.skip
	move.b	#4,d2
.skip	tst.b	d2
	beq	excerr
	btst	#15,d2
	bne	.done
	move	leaamp(pc),d1
	bsr	pokewda5s
	move	d3,d1
	bra	pokewd
.done	rts

doallocmem	move.l	comdata,a0
	move.l	88(a0),a0
	jmp	(a0)

dowbstartup	move	#wbstart,d1
	jmp	tokejsr

dopop	cmp	#$8006,d0
	beq	popreturn
	cmp	#$8000+22,d0
	beq	popnext2
	cmp	#$8000+14,d0
	beq	popselect2
	;
	cmp	#$8000+11,d0
	beq	getchar3
	cmp	#$8000+12,d0
	beq	getchar3
	cmp	#$8000+20,d0
	beq	getchar3
	cmp	#$8000+tnum+8,d0
	beq	getchar3
	bra	syntaxerr

popreturn	tst.b	debugga
	beq	.norerr
	lea	.rfix(pc),a0
	lea	.rfixf(pc),a1
	bsr	pokecode
	move	#chkret,d1
	bsr	tokejsr
	move	.rfix2(pc),d1
	bsr	pokewd
	bra	getchar3
	;
.rfix	cmp	#"gS",4(a7)
	beq	.rfix2
.rfixf	jsr	0
.rfix2	addq	#6,a7
	;
.norerr	move	.sfix(pc),d1
	bsr	pokewd
	bra	getchar3
.sfix	addq	#4,a7
	
popnext2	move.l	firstfor,d0
	beq	noforerr
	move.l	d0,a2
	bsr	getchar3
	bsr	popnext
	;
popnext3	tst.b	debugga
	beq	.ner
	move.l	nextfixw2,d1
	cmp	#3,12(a2)
	bcs	pokel
	move.l	nextfixl2,d1
	bra	pokel
	;
.ner	cmp	#3,12(a2)
	bcs	.skip2
	move.l	nextfixl,d1
	bra	pokel
	;
.skip2	move	nextfixw,d1
	bra	pokewd

popnext	move	12(a2),d0
	tst.b	debugga
	beq	.norunerr
	move	#snxtchk,d1
	cmp	#3,d0
	bcs	.oktc
	addq	#1,d1
.oktc	move.l	a2,-(a7)
	bsr	tokejsr
	move.l	(a7)+,a2
	;
.norunerr	rts

	
popselect2	move.l	firstsel,d0
	beq	eselerr
	move.l	d0,a2
	bsr	getchar3
	;
popselect	move	12(a2),d2
	tst.b	debugga
	beq	.norerr
	;
	move	#casechkw,d1
	cmp	#3,d2
	bcs	.chkit
	addq	#1,d1
.chkit	bsr	tokejsr	;make sure next thing on stack
			;is a select
.norerr	moveq	#2,d1
	cmp	#3,d2
	bcs	.doit
	moveq	#4,d1
	cmp	#7,d2
	bcs	.doit
	;
	lea	endselstr,a0
	lea	endselstrf,a1
	tst.b	debugga
	beq	.norerr3
	lea	endselstrf2,a1
.norerr3	bsr	pokecode
	move	#$c003,d1	;global freemem
	bra	tokejsr
	;
.doit	tst.b	debugga
	beq	.norerr2
	;
	addq	#2,d1	;for the "sE"
	;
.norerr2	lsl	#8,d1
	lsl	#1,d1
	or	endsel,d1
	bra	pokewd

firstrep	dc.l	0
replineat	dc	0

dorepeat	;Repeat...
	;.
	;.
	;.
	;Until a=10
	move	linenumat,replineat
	moveq	#8,d0
	moveq	#1,d1
	move.l	4.w,a6
	jsr	doallocmem
	move.l	d0,a0
	move.l	firstrep(pc),(a0)
	move.l	a0,firstrep
	move.l	pc,4(a0)
	rts	

infochk	ds.b	6
	;
endininfo	;does a0 end in .info?
	;
	lea	infochk(pc),a1
	clr	(a1)
	clr.l	2(a1)
.loop2	moveq	#4,d0
.loop	move.b	1(a1),(a1)+
	dbf	d0,.loop
	lea	infochk(pc),a1
	move.b	(a0),d0
	or.b	#32,d0
	move.b	d0,5(a1)
	tst.b	(a0)+
	bne	.loop2
	cmp	#'.i',(a1)+
	bne	.no
	cmp.l	#'nfo ',(a1)
.no	rts

gettokeps	;toke jsr
	;
	bpl	.evaltoke
	move	d0,d1
	and	#userand,d1
	beq	tokeerr
	bclr	#15,d0
	move	d0,d4	;got toke number
	bsr	getchar3
	bra	.gotnum
.evaltoke	bsr	evalconst
	cmp.l	#65535,d3
	bhi	tokeerr
	tst	d6
	bne	tokeerr
	move	d3,d4
.gotnum	moveq	#0,d5
	cmp	#',',d0
	bne	.gotform
	move	d4,-(a7)
	bsr	evalconst2
	cmp.l	#65535,d3
	bhi	tokeerr
	tst	d6
	bne	tokeerr
	move	d3,d5
	move	(a7)+,d4
.gotform	;
	rts	;d4=toke, d5=form

dolibjsr	tst	d0
	bsr	gettokeps
	move	#$4eb9,d1
	bsr	pokewd
	bsr	addoff
	move	d5,d1
	or	#$8000,d1	;Toke of Amiga type.
	swap	d1
	move	d4,d1
	bra	pokel

doblibjsr	tst	d0
	bsr	gettokeps
	move	#$4eb9,d1
	bsr	pokewd
	bsr	addoff
	move	d5,d1
	or	#$c000,d1	;Toke of Blitz type.
	swap	d1
	move	d4,d1
	bra	pokel

dosysjsr	bsr	evalconst
	cmp.l	#$10000,d3
	bcc	tokeerr
	move	d3,d1
	bra	tokejsr

dotokejsr	bsr	gettokeps
	move	#$4eb9,d1
	bsr	pokewd
	move.l	pc,d3
	btst	#7,blitzmode
	beq	.inamiga
	bset	#14,d5
.inamiga	bsr	maketjsr
	bsr	addoff
	bra	pokel

dovwait	beq	.zero
	moveq	#2,d2	;get a word
	bsr	bakeval
	move	fvwait(pc),d1
	bra	.vcont
.zero	move	#$7000,d1	;moveq #0,d0
.vcont	bsr	pokewd
	move	#intvwait,d1
	bra	tokejsr

fvwait	subq	#1,d0

cgoblitz	move	#-1,0(a5)

cgoamiga	clr	0(a5)

debugmode	move.b	debugga(pc),d1
	beq.s	.skip
	move	#$d500,d1
	bra	tokejsr
.skip	rts

doblitz	;go into Blitz mode!
	;
	bset	#0,blitzmode
	bset	#7,blitzmode
;	bne	.skip		;paul's bug!
	move	#goblitz,d1
	bsr	tokejsr
.skip	tst.b	debugga
	beq	.done
	move	cgoblitz(pc),d1
	bsr	pokewd
	moveq	#-1,d1
	bsr	pokewd
	bsr	getbbase
	bsr	pokewd
.done	bra	debugmode

doamiga	;go into Amiga mode
	;
	move	#goamiga,d1
	bra	toamode
	;
doqamiga	;go into quick amiga mode
	;
	move	#goqamiga,d1
	;
toamode	bset	#0,blitzmode
	bclr	#7,blitzmode
;	beq	.skip		;paul's bug
	bsr	tokejsr
.skip	tst.b	debugga
	beq	.done
	move	cgoamiga(pc),d1
	bsr	pokewd
	bsr	getbbase
	bsr	pokewd
.done	bra	debugmode	

intstart0	movem.l	d2-d7/a2-a4,-(a7)

intfin	movem.l	(a7)+,d2-d7/a2-a4

doclrint	;
	bsr	evalconst
	cmp.l	#14,d3
	bcc	interr4
	move	#$7000,d1
	or	d3,d1
	bsr	pokewd
	move	#clrint,d1
	bra	tokejsr	;clear the interupt

inerr	dc	0	;flag - in error trap mode
errjmp	dc.l	0	;where err jump is
errcode	dc.l	0

doclrerr	move	#clrerr,d1
	bra	tokejsr

doendseterr	move	inerr(pc),d1
	beq	errerr3
	clr	inerr
	move	nomemleft,d1
	bne	.skip
	move.l	errjmp(pc),a0
	move.l	pc,(a0)
.skip	bra	getchar3

doerrfail	move	#errfail,d1
	bra	tokejsr

doseterr	move	procmode,d1
	bne	errerr1
	move	inerr(pc),d1
	bne	errerr2
	not	inerr
	move	#$203c,d1	;move.l #x,d0
	bsr	pokewd
	move.l	pc,errcode
	bsr	addoff
	bsr	pokel
	move	#seterr,d1
	bsr	tokejsr
	move	#$4ef9,d1	;JMP
	bsr	pokewd
	move.l	pc,errjmp
	bsr	addoff
	bsr	pokel
	move	nomemleft,d1
	bne	.skip
	move.l	errcode(pc),a0
	move.l	pc,(a0)
.skip	rts

intlineat	dc	0

dosetint	;
	moveq	#-1,d1	;type - need new string space
setint2	bsr	errchx
	move	d1,intstring
	move	linenumat,intlineat
	bsr	evalconst	;get constant - int level
	cmp.l	#14,d3
	bcc	interr4
	;
	st	intsused
	move	d3,intlevel
	move	#$7000,d1
	or	d3,d1
	bsr	pokewd	;moveq #x,d0
	move	#$223c,d1	;move.l #x,d1
	bsr	pokewd
	bsr	addoff
	move.l	pc,-(a7)
	bsr	pokel
	;
	move	#setint,d1
	bsr	tokejsr
	move	#$4ef9,d1	;jmp
	bsr	pokewd
	bsr	addoff
	move.l	pc,intjmpat
	bsr	pokel
	move.l	(a7)+,a0
	move	nomemleft,d1
	bne	.dontpoke
	move.l	pc,(a0)
.dontpoke	move.l	intstart0(pc),d1
	bsr	pokel
	;
	tst.b	debugga
	beq	.norerr
	;
	;debugga stuff..
	;
	moveq	#2,d1
	bsr	maketrap
	bsr	addoff
	move.l	pc,intcleanat
	bsr	pokel
	move	intlevel,d1
	bsr	pokewd
	;
	move	#gosup,d1		;disable stack checks
	bsr	tokejsr
.norerr	;
	move	#65235,d1
	bsr	uselib
;	move	intlevel(pc),d1	;moveq #level,d1 !?!?!?!?
;	or	#$7200,d1
;	bsr	pokewd
	move	#newint,d1
	bsr	tokejsr
	;
.nostring	move	#-1,lasta6
	move	linenumat,intline
	rts

intallox	dc	0	;mask for allocates for
			;interrupts
intdata1	dc.l	0	;where in data1 a5 is being
			;kept
intjmpat	dc.l	0
intline	dc	0
intstring	dc	0	;flag 0 = no setint
			;>0=setint, no st space
			;<0=set, st space
intlevel	dc	0
intcleanat	dc.l	0

ret15add	dc.l	0
ret15cc	dc	0

directtrap	;trap #15
	;
	;.l : input - code to compile
	;.l : firstlocal
	;.l : firstglobal
	;.l : returned - 0 if no compile error, else pointer to err text
	;.w : blitz mode status
	;
	add.l	#18,2(a7)
	move.l	2(a7),ret15add
	move	(a7),ret15cc
	move.l	#directdo,2(a7)
	rte
	;
directdo	move.l	ret15add(pc),-(a7)
	move	ret15cc(pc),-(a7)
	;
	movem.l	d0-d7/a0-a6,-(a7)	;15*4
	;
	move.l	#dircont,errcont
	move.l	a7,errstack
	move	#-1,dirmode
	;
	move.l	ret15add(pc),a1
	move	-(a1),blitzmode
	clr.l	-(a1)
	move.l	-(a1),firstglob
	move.l	-(a1),firstlocal
	clr	procmode
	move.l	firstglob,d0
	or.l	firstlocal,d0
	beq.s	.skip
	not	procmode
.skip	move.l	-(a1),a0		;address of string
	;
	move.l	a0,-(a7)
	move.l	comdata,a1
	move.l	56(a1),a1
	jsr	(a1)		;tokenise line.....
	move.l	(a7)+,a5
	;
	move.l	dirpcat,pc
	clr	nomemleft
	move	#-1,lasta6
	bsr	doline	;.....compile it
	;
	clr	procmode
	bsr	errchx
	;
	move	#$4ef9,d1
	bsr	pokewd	;JMP
	move.l	ret15add(pc),d1
	bsr	pokel	;jmp to done
	;
	move	nomemleft,d0
	bne	nodirmem
	;
	move.l	dirpcat,4*15+2(a7)	;install code address
	;
direxit	clr	dirmode
	move	ret15cc(pc),4*15(a7)
	movem.l	(a7)+,d0-d7/a0-a6
	;
	bsr	flushc
	rtr
	;
dircont	;direct mode error! - d0=error text
	;
	move.l	ret15add(pc),a0
	subq	#2,a0
	move.l	d0,-(a0)
	;
	bra	direxit

stamigalib	;an amigalib called through a statement!
	;
	move	6(a3),d1
	bsr	uselib	;get lib for base address
	move	10(a1),-(a7)	;libbase reg
	addq	#8,a3
	move	(a3)+,-(a7)		;get offset for lib
	move.l	a3,-(a7)
	;
	;collect longs for lib
	;
	moveq	#0,d3
.loop	move.b	(a3)+,d1
	bmi	.done
	moveq	#3,d2
	addq	#1,d3
	movem.l	d3/a3,-(a7)
	bsr	peval
	movem.l	(a7)+,d3/a3
	cmp	#',',d0
	beq	.loop
	tst.b	(a3)
	bpl	syntaxerr
	;
.done	;move	(a7)+,d1
	;bsr	tstbras
	move.l	(a7)+,a3
	subq	#1,d3
	bpl	.toend
	bsr	getchar3	;no pars - get :
	bra	.nopars
	;
.toend	tst.b	(a3)+	;go to end of params
	bpl	.toend
	subq	#1,a3
.loop2	moveq	#0,d1
	move.b	-(a3),d1
	btst	#4,d1
	bne	.addreg
	lsl	#8,d1
	lsl	#1,d1
	or	#$201f,d1
	bra	.gotit
.addreg	and	#7,d1
	lsl	#8,d1
	lsl	#1,d1
	or	#$205f,d1
.gotit	bsr	pokewd
	dbf	d3,.loop2
	;
.nopars	move	(a7)+,libjsr+2
	move	(a7)+,libbase+2
	move.l	libbase,d1
	bsr	pokel
	move.l	libjsr,d1
	bra	pokel

alloxinc	;increment allocs by 150%
	;
	move.l	maxpc,d2
	lsr.l	#1,d2
	add.l	maxpc,d2
	;
	move.l	maxlib,d3
	lsr.l	#1,d3
	add.l	maxlib,d3
	;
	move.l	maxdata1,d4
	lsr.l	#1,d4
	add.l	maxdata1,d4
	;
	move.l	maxdata2,d5
	lsr.l	#1,d5
	add.l	maxdata2,d5
	;
	bra	newallox

alloxadj	;ne if enough mem for allox
	;
	move.l	bigpc,d2
	sub.l	pcat,d2		;size of object buffer
	tst	makeexec
	bne.s	.skip
	add.l	#1024,d2
.skip	move.l	lib,d3
	sub.l	libat,d3
	move.l	data1,d4
	sub.l	data1at,d4
	move.l	data2,d5
	sub.l	data2at,d5
newallox	bsr	makeallox
	bne	.done
	bra	makeiallox
.done	rts

freeallox	move.l	4.w,a6
	move.l	objlen,d0
	beq	.skip
	clr.l	objlen
	move.l	pcat,a1
	jmp	freemem(a6)
.skip	rts

makeiallox	;initial allox
	move.l	maxpc,d2
	move.l	maxlib,d3
	move.l	maxdata1,d4
	move.l	maxdata2,d5
	;
makeallox	;d2=pc size,d3=lib size,d4=data1,d5=data2
	;
	move	#-1,anyerrs
	bsr	freeallox
	;
	;word align blocks
	;
	addq.l	#1,d2
	bclr	#0,d2
	addq.l	#1,d3
	bclr	#0,d3
	addq.l	#1,d4
	bclr	#0,d4
	addq.l	#1,d5
	bclr	#0,d5
	;
	move.l	d2,d0
	add.l	d3,d0
	add.l	d4,d0
	add.l	d5,d0
	move.l	d0,d6
	move.l	#$10001,d1
	jsr	doallocmem
	tst.l	d0
	beq	.done
	move.l	d6,objlen
	move.l	d2,maxpc
	move.l	d3,maxlib
	move.l	d4,maxdata1
	move.l	d5,maxdata2
	move.l	d0,pcat
	add.l	d2,d0
	move.l	d0,libat
	add.l	d3,d0
	move.l	d0,data1at
	add.l	d4,d0
	move.l	d0,data2at
	add.l	d5,d0
	move.l	d0,allat
.done	rts

	ifeq	final
	;
prtname	dc.b	'PAR:',0
	even

menu3	;rts
	;
	;print tokens to PRT:
	;
	move.l	#prtname,d1
	move.l	#1006,d2
	calldos	open
	move.l	d0,d7
	beq	.fuct
	;
	lea	tokens,a2
	;
.loop	lea	namebuff,a0
	move.l	a0,d2
	lea	6(a2),a1
.loop2	move.b	(a1)+,(a0)+
	bne	.loop2
	move.b	#10,-1(a0)
.loop3	move.b	(a1)+,(a0)+
	bne	.loop3
	move.b	#10,-1(a0)
	move.b	#10,(a0)+
	move.l	a0,d3
	sub.l	d2,d3
	move.l	d7,d1
	jsr	write(a6)
	move.l	(a2),a2
	cmp	#0,a2
	bne	.loop
	;
	move.l	d7,d1
	jmp	close(a6)
	;
.fuct	rts
	;
	endc

divisors	dc.l	1,10,100,1000,10000,100000
	dc.l	1000000,10000000,100000000,1000000000

makelong	;put long in d2 into (a0)+
	;
	moveq	#0,d1	;no zero printed
	moveq	#36,d3
.loop	moveq	#48,d4
.loop2	cmp.l	divisors(pc,d3),d2
	bcs	.skip
	sub.l	divisors(pc,d3),d2
	addq	#1,d4
	bra	.loop2
.skip	cmp.b	#48,d4
	bne	.doit
	tst	d1
	beq	.skip2
.doit	move.b	d4,(a0)+
	moveq	#1,d1
.skip2	subq	#4,d3
	bpl	.loop
	tst	d1
	bne	.skip3
	move.b	#'0',(a0)+
.skip3	clr.b	(a0)
	rts
	;
restext	dc.b	'Name of Resident File to Create',0
	even
respath	dc.b	0
	ds.b	191
resname	dc.b	0
	ds.b	191

menu5	;make resident!
	;
	move.l	firstmacro,d0
	bne	.skip
	move.l	firsttype,d0
	bne	.skip
	move.l	firstlabel,a2
.loop	cmp	#0,a2
	beq	.err
	cmp.l	#1,4(a2)
	beq	.skip
	move.l	(a2),a2
	bra	.loop
.err	;
	rts
	;
.skip	move.l	comdata,a3
	move.l	24(a3),a3
	lea	restext,a2
	lea	respath,a0
	lea	resname,a1
	jsr	(a3)
	beq	.err
.tryit	;
	;O.K.... Now to create it
	move.l	d0,d1
	move.l	#1006,d2
	calldos	open
	move.l	d0,d7	;handle
	beq	.err
	bsr	sleepon
	;
	bsr	killoffs
	;
	move.l	d7,d1
	move.l	#tsthead,d2	;header
	moveq	#32,d3
	calldos	write
	;
	moveq	#0,d6	;offset from start of file!
	bsr	restypes
	bsr	resmacs
	bsr	resconsts
	;
	move.l	d6,d3
	addq.l	#3,d3
	and.l	#$fffffffc,d3	;long word align
	move.l	d3,-(a7)
	sub.l	d6,d3
	beq	.noalign
	move.l	#hello,d2
	move.l	d7,d1
	jsr	write(a6)
.noalign	move.l	numoffs,tstsize3
	beq	.skip2a
	move.l	d7,d1
	move.l	#tstend,d2
	moveq	#12,d3
	jsr	write(a6)
	;
	;and offsets.....
	;
	move.l	firstoff,a2
.oloop	cmp	#0,a2
	beq	.skip2
	lea	4(a2),a1
	move.l	d7,d1
	move.l	a1,d2
	moveq	#4,d3
	jsr	write(a6)
	move.l	(a2),a2
	bra	.oloop
.skip2	;
	move.l	d7,d1
	move.l	#zero,d2
	moveq	#4,d3
	jsr	write(a6)
.skip2a	;
	move.l	d7,d1
	move.l	#tstdone,d2
	moveq	#4,d3
	jsr	write(a6)
	move.l	(a7)+,d0
	lsr.l	#2,d0
	move.l	d0,temp1
	;
	move.l	d7,d1
	moveq	#20,d2
	moveq	#-1,d3
	jsr	seek(a6)
	move.l	d7,d1
	move.l	#temp1,d2
	moveq	#4,d3
	jsr	write(a6)
	move.l	d7,d1
	moveq	#28,d2
	moveq	#-1,d3
	jsr	seek(a6)
	move.l	d7,d1
	move.l	#temp1,d2
	moveq	#4,d3
	jsr	write(a6)
	;
	move.l	d7,d1
	jsr	close(a6)
	bra	pointeron

hello	dc.b	'ZAP',0

writelist	;a2=first, d5=.b len offset
	;
.loop	cmp	#0,a2
	beq	.done
	bsr	writeitem
	move.l	(a2),a2
	bra	.loop
.done	rts

writeitem	moveq	#0,d3
	move.b	0(a2,d5),d3
	addq	#1,d3
	bclr	#0,d3	;word align
	move.l	(a2),-(a7)
	beq	.skip
	bsr	resoff
	add.l	d3,d6
	move.l	d6,(a2)
	sub.l	d3,d6
	;
.skip	add.l	d3,d6
	move.l	a2,d2
	move.l	d7,d1
	jsr	write(a6)
	move.l	(a7)+,(a2)
	rts

resoff	move.l	d6,d2
	bra	addoff2

writeoffs	;write the offsets
	;
.loop	cmp	#0,a2
	beq	.done
	move.l	alltypes,a1
	moveq	#0,d1
.loop2	cmp	#0,a1
	beq	.found
	cmp.l	10(a2),a1
	beq	.found
	addq	#1,d1
	move.l	(a1),a1
	bra	.loop2
.found	move	10(a2),-(a7)
	move	d1,10(a2)
	bsr	writeitem
	move	(a7)+,10(a2)
	move.l	(a2),a2
	bra	.loop
.done	rts

countem	moveq	#0,d0
.loop	cmp	#0,a2
	beq	.done
	addq	#1,d0
	move.l	(a2),a2
	bra	.loop
.done	move	d0,temp1
	move.l	d7,d1
	move.l	#temp1,d2
	moveq	#2,d3
	addq.l	#2,d6
	jmp	write(a6)	

resmacs	;put out! macros
	;
	move.l	firstmacro,a3
	move.l	a3,a2
	bsr	countem
.loop	cmp	#0,a3
	beq	.done
	move.l	d6,d5
	move.l	(a3),-(a7)
	move.l	4(a3),-(a7)
	moveq	#0,d3
	move.b	12(a3),d3
	addq	#1,d3
	bclr	#0,d3
	add.l	d3,d6	;add len of struct
	tst	8(a3)
	beq	.notext
	move.l	d6,4(a3)
	move.l	d5,d2
	addq.l	#4,d2
	bsr	addoff2
.notext	moveq	#0,d4
	move	8(a3),d4
	addq	#1,d4
	bclr	#0,d4
	add.l	d4,d6
	tst.l	(a3)
	beq	.nomore
	move.l	d6,(a3)
	move.l	d5,d2
	bsr	addoff2
.nomore	move.l	a3,d2
	move.l	d7,d1
	jsr	write(a6)
	tst.l	d4
	beq	.skip
	move.l	(a7),d2
	move.l	d4,d3
	move.l	d7,d1
	jsr	write(a6)
.skip	move.l	(a7)+,4(a3)
	move.l	(a7)+,(a3)
	move.l	(a3),a3
	bra	.loop
.done	rts

restypes	move.l	firsttype,a3
	move.l	a3,a2
	bsr	countem
.loop	cmp	#0,a3
	beq	.done
	move.l	d6,-(a7)
	move.l	4(a3),a2
	moveq	#14,d5
	bsr	writeoffs
	;
	move.l	(a7)+,d0
	move.l	4(a3),-(a7)
	move.l	d0,4(a3)
	move.l	d6,d2
	addq.l	#4,d2
	bsr	addoff2
	moveq	#0,d3
	move.b	10(a3),d3
	addq	#1,d3
	bclr	#0,d3
	add.l	d3,d6
	move.l	a3,d2
	move.l	d7,d1
	jsr	write(a6)
	move.l	(a7)+,4(a3)
	move.l	(a3),a3
	bra	.loop
.done	rts

resconsts	move.l	firstlabel,a2
	moveq	#0,d0
.loop	cmp	#0,a2
	beq	.done
	cmp.l	#1,4(a2)
	bne	.next
	addq	#1,d0
.next	move.l	(a2),a2
	bra	.loop
.done	move	d0,temp1
	move.l	d7,d1
	move.l	#temp1,d2
	moveq	#2,d3
	addq.l	#2,d6
	jsr	write(a6)
	move.l	firstlabel,a2
.loop2	cmp	#0,a2
	beq	.done2
	cmp.l	#1,4(a2)
	bne	.next2
	moveq	#0,d3
	move.b	18(a2),d3	;length
	addq	#1,d3
	bclr	#0,d3
	move.l	d6,d2
	add.l	d3,d6
	move.l	(a2),-(a7)
	tst.l	(a2)
	beq	.nonext
	move.l	d6,(a2)
	bsr	addoff2
.nonext	move.l	a2,d2
	move.l	d7,d1
	jsr	write(a6)
	move.l	(a7)+,(a2)
	;
.next2	move.l	(a2),a2
	bra	.loop2
.done2	rts

loadres	;load in resident structs.....
	;
	move.l	a7,errstack
	move.l	#.next,errcont
	move	#-1,ezerr
	;
	bsr	freeemup
	bsr	freeres
	;
	lea	resbuff,a5
	moveq	#7,d6
.loop	tst.b	(a5)
	beq	.next
	move.l	a5,d1
	jsr	loadseg(a6)
	move.l	d0,64(a5)
	bne	.yeah
	;
	bsr	reserr
	;
.yeah	;res loaded O.K.
	;
	move.l	d0,a3
	add.l	a3,a3
	add.l	a3,a3
	addq	#4,a3	;start of res
	;
	bsr	fixtypes
	bsr	fixmacs
	bsr	fixconsts
	;
.next	lea	68(a5),a5
	dbf	d6,.loop
	;
	;check resident clashes!
	;
	move.l	#freeres,errcont
	move.l	firsttype,a3
	moveq	#11,d7
	bsr	checkclash
	move.l	firstmacro,a3
	moveq	#13,d7
	bsr	checkclash
	move.l	firstconst,a3
	moveq	#25,d7
	bsr	checkclash
	rts

checkclash	move.l	a3,a4
.loop	cmp	#0,a4
	beq	.done
	lea	namebuff,a0
	lea	0(a4,d7),a1
	moveq	#-1,d2
.loop2	addq	#1,d2
	move.b	(a1)+,(a0)+
	bne	.loop2
	move.l	a3,a2
.more	bsr	findlab
	bne	.next	;not found
	cmp.l	a2,a4
	bne	clasherr
	bra	.more
.next	move.l	(a4),a4
	bra	.loop
.done	rts

freeres	;
	move.l	dos,a6
	lea	firsttype,a0
	move.l	a0,lastrestype
	clr.l	(a0)
	lea	firstmacro,a0
	move.l	a0,lastresmac
	clr.l	(a0)
	lea	firstlabel,a0
	move.l	a0,lastrescon
	clr.l	(a0)
	clr	rescnt
	;
freeres2	lea	resbuff,a2
	moveq	#7,d2
.loop	move.l	64(a2),d1
	beq	.next
	clr.l	64(a2)
	jsr	unloadseg(a6)
.next	lea	68(a2),a2
	dbf	d2,.loop
	rts

fixconsts	move	(a3)+,d1
	beq	.done
	move.l	lastrescon,a2
	move.l	a3,(a2)
	subq	#1,d1
.loop	move.l	a3,a2
	move.l	(a3),a3
	dbf	d1,.loop
	move.l	a2,lastrescon
	move.l	a2,a3
	moveq	#0,d0
	move.b	18(a3),d0
	addq	#1,d0
	bclr	#0,d0
	add	d0,a3
.done	rts

fixmacs	move	(a3)+,d1
	beq	.done
	move.l	lastresmac,a2
	move.l	a3,(a2)
	subq	#1,d1
.loop	move.l	a3,a2
	move.l	(a3),a3
	dbf	d1,.loop
	move.l	a2,lastresmac
	move.l	a2,a3
	moveq	#0,d0
	move.b	12(a3),d0
	addq	#1,d0
	bclr	#0,d0
	move	8(a3),d1
	addq	#1,d1
	bclr	#0,d1
	add	d0,a3
	add	d1,a3
.done	rts

fixtypes	;fix up all load types
	move	(a3)+,d1	;number of types to do
	beq	.done
	move	d1,-(a7)
	subq	#1,d1
	move.l	lastrestype,a2
	move.l	a2,-(a7)
.loop	move.l	(a3),d0	;skip through offsets
	beq	.loopme
	move.l	d0,a3
	bra	.loop
.loopme	move.b	14(a3),d0
	addq	#1,d0
	bclr	#0,d0
	add	d0,a3	;a3=type
	move.l	a3,(a2)	;link
	move.l	a3,a2
	moveq	#0,d0
	move.b	10(a3),d0
	addq	#1,d0
	bclr	#0,d0
	add	d0,a3	;next offset
	dbf	d1,.loop
	;
	;Now, Fix up pointers to Stuff!
	;
	move.l	(a7)+,a0
	move.l	(a0),a0
.floop	cmp	#0,a0
	beq	.fdone
	move.l	4(a0),a1	;first offset!
	;
.floop2	cmp	#0,a1
	beq	.fofd
	;
	move	10(a1),d0	;number of type
	move.l	alltypes,a4
	cmp	#7,d0
	bcs	.fsys
	sub	rescnt,d0
.fsys	subq	#1,d0
	bmi	.fdone2
.floop3	move.l	(a4),a4
	dbf	d0,.floop3
.fdone2	move.l	a4,10(a1)
	move.l	(a1),a1
	bra	.floop2
.fofd	move.l	(a0),a0
	bra	.floop
	;
.fdone	move	(a7)+,d0
	add	d0,rescnt
	move.l	a2,lastrestype
	;
.done	rts

runerropts	move	optreq2ga1+12,-(a7)
	move	optreq2ga2+12,-(a7)
	move	optreq2ga3+12,-(a7)
	move	optreq2ga4+12,-(a7)
	move	optreq2ga5+12,-(a7)
	move	optreq2ga6+12,-(a7)
	move	optreq2ga7+12,-(a7)
	;
	lea	optreq2,a0
	move.l	comdata,a1
	move.l	(a1),a1
	jsr	(a1)
	;
.loop2	move.l	comdata,a0
	move.l	8(a0),a0
	jsr	(a0)	;getinput
	cmp	#-1,d7
	bne	.loop2
	cmp	#8,d6
	bcs	.loop2
	bne	.cancel2
	lea	14(a7),a7
	rts
.cancel2	move	(a7)+,optreq2ga7+12
	move	(a7)+,optreq2ga6+12
	move	(a7)+,optreq2ga5+12
	move	(a7)+,optreq2ga4+12
	move	(a7)+,optreq2ga3+12
	move	(a7)+,optreq2ga2+12
	move	(a7)+,optreq2ga1+12
	rts

makeasmtab	;make a table of pointers to ASM data
	;
	lea	tokens,a0
	move	#lnum-2,d0
.loop	move.l	(a0),a0
	dbf	d0,.loop
	move	#tnum-fnum-1,d0
	move.l	#asmpnts,a1
.loop2	lea	6(a0),a2
.loop3	tst.b	(a2)+
	bne	.loop3
.loop4	tst.b	(a2)+
	bne	.loop4
	addq	#1,a2
	exg	d1,a2
	bclr	#0,d1
	exg	d1,a2
	move.l	a2,(a1)+
	move.l	(a0),a0
	dbf	d0,.loop2
	rts	

getimm	;get an immediate value
	bsr	asmconst
	moveq	#11,d5
	rts

unmove	dc	0

regmovems	;d4=reg#
	move	#$48e7,d1
	bsr	pokewd	;movem.l -(a7)
	move	#15,d2
	sub	d4,d2
	moveq	#-1,d1
	bclr	d2,d1
	bsr	pokewd
	moveq	#-1,d1
	bclr	d4,d1
	move	d1,unmove
	rts
	
dounmove	move	#$4cdf,d1
	bsr	pokewd
	move	unmove(pc),d1
	bra	pokewd

	;if bit 15 of d2 then code has been generated for
	;address of thing in a2. else d3=offset from a5
	;for simple variable.
	;
	;d2 & ff=type. 0=struct address
	;
	;bit 14 of d2=1 if result is a pointer
	;

doputreg	bsr	getreg2
	cmp	#',',d0
	bne	syntaxerr
	move.l	#$48e7fffe,d1	;movem to stack
	bsr	pokel
	move	d4,d1
	or	#$2f00,d1
	bsr	pokewd
	;
	bsr	getchar3
	bsr	getvname
	bsr	fetchvar
	bsr	calcvar
	btst	#14,d2
	beq	.notp
.issa	move.b	#3,d2
	bra	.pd
.notp	tst.b	d2
	beq	.issa
	cmp.b	#7,d2
	beq	.issa
.pd	btst	#15,d2
	bne	.nsimp
	;
	move	#$45ed,d1	;lea x(a5),a2
	bsr	pokewd
	move	d3,d1
	bsr	pokewd
	;
.nsimp	move	#$201f,d1	;move.l	(a7)+,d0
	bsr	pokewd
	move	#$1480,d1
	cmp.b	#1,d2
	beq	.pg
	eor	#$3000,d1
	cmp.b	#2,d2
	bne	.pg
	or	#$1000,d1
.pg	bsr	pokewd
	move.l	#$4cdf7fff,d1
	bra	pokel

dosetreg	bsr	getreg2
	cmp	#',',d0
	bne	syntaxerr
	bsr	regmovems
	move	d4,-(a7)
	moveq	#3,d2	;get a long
	bsr	eval
	move	(a7)+,d1
	beq	.done
	cmp	#8,d1
	bcc	.addreg
	lsl	#8,d1
	lsl	#1,d1
	or	#$2000,d1
	bsr	pokewd
	bra	.done
.addreg	subq	#8,d1
	lsl	#8,d1
	lsl	#1,d1
	or	#$2040,d1
	bsr	pokewd
.done	bra	dounmove

getreg	bsr	getchar3
getreg2	or	#32,d0
	cmp	#'d',d0
	beq	getan3
	cmp	#'a',d0
	bne	syntaxerr
	bsr	getan3
	addq	#8,d4
	rts

getan	bsr	getchar3
	or	#32,d0
getan2	cmp	#'a',d0
	bne	syntaxerr
getan3	bsr	getchar3
	sub	#48,d0
	bmi	syntaxerr
	cmp	#7,d0
	bhi	syntaxerr
	move	d0,d4
	bra	getchar3

getmovem2	addq	#8,d4
getmovem	moveq	#0,d5	;bits for reg
	sub	#48,d4
	;
.loop	cmp	#'-',d0
	beq	.range
	cmp	#'/',d0
	beq	.one
	bra	syntaxerr
.done2	bset	d4,d5
.done	move	d5,d4
	moveq	#15,d5
	rts
.one	bset	d4,d5
	bsr	getreg
	bsr	tstend2
	bne	.loop
	bra	.done2
.range	move	d4,d1	;from
	bsr	getreg
	cmp	d4,d1
	bls	.loop2
	exg	d4,d1
.loop2	bset	d1,d5
	addq	#1,d1
	cmp	d4,d1
	bls	.loop2
	bsr	tstend2
	bne	.loop
	bra	.done

getea	;evaluate the ea of an asm bit
	;
	move.l	a5,a4
	bsr	getchar3
	cmp	#'#',d0
	beq	getimm
	cmp	#'(',d0
	beq	.ind
	cmp	#'-',d0
	bne	.more
	bsr	getchar3
	cmp	#'(',d0
	bne	.notccr
	bsr	getan
	cmp	#')',d0
	bne	syntaxerr
	moveq	#4,d5
	bra	getchar3
	;
.ind	bsr	getan
	cmp	#')',d0
	bne	syntaxerr
	bsr	getchar3
	cmp	#'+',d0
	beq	.postinc
	moveq	#2,d5
	rts
.postinc	moveq	#3,d5
	bra	getchar3

.more	or	#32,d0
	move	d0,d1	;first
	bsr	getchar3	;get second
	cmp	#'d',d1
	bne	.notdn
	cmp	#'0',d0
	bcs	.notan
	cmp	#'7',d0
	bhi	.notan
	move	d0,d4
	bsr	getchar3
	bsr	tstend2
	beq	.dn
	cmp	#'-',d0
	beq	getmovem
	cmp	#'/',d0
	beq	getmovem
	bra	.notan2
	;
.dn	moveq	#0,d5
	sub	#48,d4
	rts
	;
.notdn	cmp	#'a',d1
	bne	.notan
	;
	cmp	#'0',d0
	bcs	.notan
	cmp	#'7',d0
	bhi	.notan
	move	d0,d4
	bsr	getchar3
	bsr	tstend2
	beq	.an
	cmp	#'-',d0
	beq	getmovem2
	cmp	#'/',d0
	beq	getmovem2
	bra	.notan2
.an	;
	;An
	;
	moveq	#1,d5
	sub	#48,d4
	rts
	;
.notan	or	#32,d0
	move	d0,d4
	bsr	getchar3	;get third
.notan2	;d1,d4,d0=chars
	bsr	tstend2
	bne	.notsx
	cmp	#'s',d1
	bne	.notsx
	cmp	#'p',d4
	bne	.notsp2
	bsr	tstend2
	bne	.notccr
	;
	;Sp
	;
	moveq	#7,d4
	moveq	#1,d5
	rts
.notsp2	cmp	#'r',d4
	bne	.notccr
	bsr	tstend2
	bne	.notccr
	;
	;Sr
	;
	moveq	#13,d5
	rts
.notsx	or	#32,d0
	cmp	#'c',d1
	bne	.notccr0
	cmp	#'c',d4
	bne	.notccr
	cmp	#'r',d0
	bne	.notccr
	bsr	getchar3
	beq	.ccr
	cmp	#',',d0
	bne	.notccr
.ccr	;
	;ccr
	;
	moveq	#12,d5
	rts
	;
.notccr0	cmp	#'u',d1
	bne	.notccr
	cmp	#'s',d4
	bne	.notccr
	cmp	#'p',d0
	bne	.notccr
	bsr	getchar3
	beq	.usp
	cmp	#',',d0
	bne	.notccr
.usp	moveq	#14,d5
	rts
.notccr	;
	;not anything - must be a label or abs address of some kind
	;
	move.l	a4,a5
	bsr	asmconst
	;
	bsr	tstend2
	beq	.absl
	cmp	#'.',d0
	beq	.absx
	cmp	#'(',d0
	bne	syntaxerr
	bsr	getchar3
	or	#32,d0
	cmp	#'p',d0
	bne	.notpcrel
	bsr	getchar3
	or	#32,d0
	cmp	#'c',d0
	bne	syntaxerr
	bsr	getchar3
	bsr	getrest
	addq	#4,d5
	rts

.notpcrel	bsr	getan2
	bra	getrest

.absx	bsr	getchar3
	or	#32,d0
	cmp	#'w',d0
	beq	.absw
	cmp	#'l',d0
	bne	syntaxerr
.absl	moveq	#8,d5
	rts
.absw	moveq	#7,d5
	rts

tstend2	tst	d0
	beq	.ok
	cmp	#':',d0
	beq	.ok
	cmp	#',',d0
.ok	rts

getrest	cmp	#',',d0
	bne	.dis
	bsr	getchar3
	or	#32,d0
	moveq	#0,d1
	cmp	#'d',d0
	beq	.ianxi
	cmp	#'a',d0
	bne	syntaxerr
	bset	#15,d1
.ianxi	bsr	getchar3
	sub	#48,d0
	bmi	syntaxerr
	cmp	#7,d0
	bhi	syntaxerr
	lsl	#8,d0
	lsl	#4,d0
	or	d0,d1
	bsr	getchar3
	cmp	#'.',d0
	bne	.ok2
	bsr	getchar3
	or	#32,d0
	cmp	#'w',d0
	beq	.ok
	cmp	#'l',d0
	bne	syntaxerr
	bset	#11,d1
.ok	bsr	getchar3
.ok2	cmp	#')',d0
	bne	syntaxerr
	move	d1,extraword
	moveq	#6,d5
	bra	getchar3
.dis	cmp	#')',d0
	bne	syntaxerr
	moveq	#5,d5
	bra	getchar3
	
asmconst	;store the text of the eval into asmfirst...
	;
	;text till '(','.'
	;
	move.l	asmbuff,a0
	move	numincs,d1
	or	macmask,d1
	move	d1,(a0)+	;flag!
	bne	copyconst
	move.l	a5,-(a7)
	bsr	copyconst
	move.l	asmbuff,a0
	cmp	#4,d1
	bls	.leave
	tst	lc
	bne	.leave
	;
	addq	#2,a0
	move.l	(a7)+,(a0)+
	clr.b	(a0)
	move	#4,asmlen2	;pointer + 0
	rts
.leave	not	(a0)
	addq	#4,a7
	rts
	
lc	dc	0

copyconst	;
	clr	lc
	moveq	#0,d1
.loop	addq	#1,d1
	bsr	getchar3
	beq	.done
	;
	tst	d0
	bpl	.notmi
	move	d0,-(a7)
	lsr	#8,d0
	move.b	d0,(a0)+
	move	(a7)+,d0
	move.b	d0,(a0)+
	addq	#1,d1
	bra	.loop
	;
.notmi	tst	quoteflag
	bne	.putbyte
	cmp	#'(',d0
	beq	.done
;	cmp	#'.',d0
;	beq	.done
	cmp	#',',d0
	beq	.done
	cmp.b	#loclabch,d0
	bne	.putbyte
	move	d0,lc
	move.l	a1,-(a7)
	lea	lastbiglab,a1
	tst.b	(a1)
	beq	nolocerr
.cloop	addq	#1,d1
	move.b	(a1)+,(a0)+
	bne	.cloop
	subq	#1,d1
	subq	#1,a0
	move.l	(a7)+,a1
.putbyte	move.b	d0,(a0)+
	bra	.loop
.done	clr.b	(a0)
	move	d1,asmlen2
	rts

asmit	bsr	alignpc
	sub	#$8000+fnum,d0
	lsl	#2,d0
	move.l	#asmpnts,a0
	move.l	0(a0,d0),a0
	move	d0,temp1
	move.l	a0,-(a7)
	;
	moveq	#1,d1	;word len (byte=0, long=2)
	bsr	getchar3
	cmp	#'.',d0
	bne	.dsize
	bsr	getchar3
	or	#32,d0
	cmp	#'w',d0
	beq	.wsize
	cmp	#'b',d0
	beq	.bsize
	cmp	#'l',d0
	bne	syntaxerr
	bra	.lsize
.bsize	moveq	#0,d1
	move	8(a0),d0
	bra	.tstsize
.dsize	moveq	#4,d1
	bra	.putsize
.wsize	moveq	#4,d1
	move	8(a0),d0
	lsr	#4,d0
	bra	.tstsize
.lsize	moveq	#8,d1
	move	8(a0),d0
	lsr	#8,d0
.tstsize	and	#15,d0
	cmp	#15,d0
	beq	illsizeerr
	bsr	getchar3
.putsize	move	d1,asmsize
	moveq	#-1,d3
	bsr	reget
	beq	.done0
	move.l	#namebuff,asmbuff
	bsr	bakup
	bsr	getea
	move.l	d4,d2	;to src
	move.l	d5,d3
	move	asmlen2,asmlen
	moveq	#-1,d5
	move	extraword,extraword2
	cmp	#',',d0
	bne	.done0
	move.l	#namebuff2,asmbuff
	bsr	getea	;dest
.done0	;
	;all stuff fetched!
	;now to assemble it.....
	;
	move.l	(a7)+,a0
	;
	;O.K. - Let's assemble it!
	;
	move.l	pc,a1		;pc
	;
	move.l	a1,a4
	addq	#2,a1
	move	(a0),d1	;opcode
	tst	d3
	bmi	.none	;no src/dest ea!
	;
	;make into movea, addi etc. if possible
	;
	move	14(a0),d0
	bpl	.noia
	btst	#0,d0
	beq	.noa
	cmp	#1,d5
	bne	.noa
	cmp	#14,d3
	beq	.noia
	move	temp1,d0
	addq	#4,d0
	bra	.moveon
.noa	btst	#1,d0
	beq	.noia
	cmp	#11,d3
	bne	.noia
	move	temp1,d0
.moveon	addq	#4,d0
	move.l	#asmpnts,a0
	move.l	0(a0,d0),a0
	move	(a0),d1
	;
.noia	move.l	#namebuff,buff1
	move.l	#namebuff2,buff2
	move.l	10(a0),d0
	beq	.nojsr
	move.l	d0,a3
	move	asmsize,d6
	jsr	(a3)
	bpl	.noerr
	cmp	#-2,d0
	beq	illsizeerr
	bra	illeaerr
.noerr	beq	.nojsr
	;
	exg	d2,d4
	exg	d3,d5
	;
	move.l	extraword,d6
	swap	d6
	move.l	d6,extraword
	;
	move.l	#namebuff2,buff1
	move.l	#namebuff,buff2
	;
	move	asmlen,d6
	move	asmlen2,d7
	move	d6,asmlen2
	move	d7,asmlen
.nojsr	;
	move.l	buff1,asmbuff
	move	14(a0),d0
	beq	.nothing
	bmi	.nothing
	cmp	#1,d0
	bne	.n1to8
	cmp	#11,d3
	bne	.nothing
	;
.skipsrc	bsr	insasm
	move	d4,d2
	move	d5,d3
	bra	.skipsrc2
	;
.n1to8	cmp	#2,d0
	bne	.notbcc
	cmp	#8,d3
	bne	illeaerr
	moveq	#9,d3
	bra	.nothing
.notbcc	;
	cmp	#3,d0
	beq	.skipsrc
	;
.notmq	cmp	#4,d0
	beq	.skipsrc
	;
.nottrap	cmp	#5,d0
	bne	.notdbf
	cmp	#8,d5
	bne	illeaerr
	or	d2,d1
	moveq	#9,d5
	;
.notdbf
.nothing	move	2(a0),d6
	move.b	6(a0),d7
	movem.l	d4-d5,-(a7)
	move	extraword2,d4
	bsr	doea	;do src
	;
	movem.l	(a7)+,d2-d3
.skipsrc3	tst	d3
.skipsrc2	bmi	.one
	move	extraword,d4
	move	4(a0),d6
	move.b	7(a0),d7
	move.l	buff2,asmbuff
	move	asmlen2,asmlen
	bsr	doea
	bra	.putit
	;
.one	move	4(a0),d0
	bne	illeaerr
	bra	.putit
	;
.none	move	2(a0),d0
	or	4(a0),d0
	bne	illeaerr
	;
.putit	;put in the opcode
	;
	move	8(a0),d0
	and	#$f000,d0
	cmp	#$f000,d0
	beq	.nosizep
	lsr	#8,d0
	lsr	#4,d0	;shift for size
	;
	move	8(a0),d2
	move	asmsize,d3
	lsr	d3,d2
	and	#15,d2
	lsl	d0,d2
	or	d2,d1	;size into opcode
	;
.nosizep
	cmp.l	libat,a4
	bcs	.oky
	move	#-1,nomemleft
	bra	.done
.oky	move	d1,(a4)
	;
.done	move.l	a1,pc
	rts

asmoff	;add an offset
	move.l	pc,-(a7)
	move.l	a1,pc
	bsr	addoff
	move.l	pc,a1
	move.l	(a7)+,pc
	rts

asmfixer	;end of pass asm filler-inner
	;
	move	nomemleft,d1
	bne	.done
	btst	#7,optreqga15+13
	beq	.go
	move	smallpass(pc),d1
	beq	.done
	;
.go	move.l	firstasm,a2
	move	#-1,constmode
	clr	regat
	bsr	prepstack
.loop	move.l	a2,-(a7)
	bsr	chkstop
	move.l	(a7)+,a2
.loopdo	cmp	#0,a2
	beq	.done2
	move.l	a2,asmbuff
	lea	16(a2),a5
	tst.b	15(a2)
	bne	.skipo
	move.l	(a5),a5	;pointer to real text
	;
.skipo	clr	asmtype
	bsr	evalconst3
	move.l	asmbuff,a2
	beq	.oko
	cmp	#'(',d0
	beq	.oko
	cmp	#',',d0
	beq	.oko
	bra	syntaxerr
.oko	move.l	4(a2),a1
	move	8(a2),d1
	;
	cmp	#5,d1
	bne	.notdan
.word	bsr	chkword
.word2	move	d3,(a1)
	bra	.next
.notdan	cmp	#6,d1
	bne	.notdanxi
.isbyte	bsr	chkbyte
.isbyte2	move.b	d3,1(a1)
	bra	.next
.notdanxi	cmp	#17,d1
	beq	.isbyte2
	cmp	#7,d1
	beq	.word
	cmp	#8,d1
	bne	.notabsl
.isabsl	move	asmtype,d1
	beq	.notpcrel
	bsr	asmoff
.notpcrel	move.l	d3,(a1)
	bra	.next
.notabsl	cmp	#9,d1
	bne	.notdpc
	sub.l	a1,d3
	bsr	chkword
	move	d3,(a1)
	bra	.next
.notdpc	cmp	#10,d1
	bne	.imm
	sub.l	a1,d3
	bra	.isbyte
	;
.imm	move	10(a2),d0
	beq	.noflag
	cmp	#1,d0
	beq	.tocount
	cmp	#3,d0
	beq	.tomoveq
	cmp	#4,d0
	beq	.totrap
.noflag	cmp	#11,d1
	beq	.isabsl
	bra	.word2
	;
.totrap	cmp.l	#15,d3
	bhi	illtraperr
	or.b	d3,-(a1)
	bra	.next
.tocount	cmp.l	#8,d3
	bhi	illimmerr
	tst.l	d3
	beq	illimmerr
	and	#7,d3
	lsl	#8,d3
	lsl	#1,d3
	or	d3,-(a1)
	bra	.next
.tomoveq	bsr	chkbyte
	move.b	d3,-(a1)
.next	move.l	(a2),a2
	bra	.loop
.done2	clr	constmode
.done	rts

doea	;d2=reg, d3=ea, d4=extraword, d5=asm type
	;d6=allowable mask, d7=shift data
	;
	;or in bits for opcode in d1
	;
	btst	d3,d6
	beq	illeaerr
	;
	bsr	makemode
	;
	cmp	#7,d3
	bcs	.skip
	move	d3,d2
	subq	#7,d2	
	;
	;
	cmp	#5,d2
	bcs	.skip0
	moveq	#4,d2
.skip0	;
	;
	moveq	#7,d3
.skip	move.b	d7,d0
	and	#15,d0
	cmp	#15,d0
	beq	.skip2
	lsl	d0,d3
	or	d3,d1
.skip2	lsr	#4,d7
	and	#15,d7
	cmp	#15,d7
	beq	.skip3
	lsl	d7,d2
	or	d2,d1
.skip3	;
	rts

chkbyte	cmp.l	#127,d3
	bgt	illdiserr
	cmp.l	#-128,d3
	blt	illdiserr
	rts

chkword	cmp.l	#32767,d3
	bgt	illdiserr
	cmp.l	#-32768,d3
	blt	illdiserr
	rts
	
insasm	;ass asmbuff, asmlen, pc, ea to list
	;
	movem.l	d0-d2/a0,-(a7)
	move	14(a0),-(a7)
	bpl	.ok
	clr	(a7)
.ok	move.l	a1,-(a7)
	;
	moveq	#16,d0
	add	asmlen,d0
	move	d0,d2
	moveq	#1,d1
	move.l	4.w,a6
	jsr	doallocmem
	move.l	d0,a0
	move	linenumat,12(a0)
	move.l	firstasm,(a0)
	move.l	a0,firstasm
	move.l	(a7),4(a0)
	move	d3,8(a0)
	move	4(a7),10(a0)
	;
	lea	14(a0),a0
	move.b	d2,(a0)+	;length
	move.l	asmbuff,a1
	addq	#1,a1
	move.b	(a1)+,(a0)+	;type - 0 = indirect,else direct
	bne	.loop
	move.l	(a1)+,(a0)+
	bra	.loopdone
	;
.loop	move.b	(a1)+,(a0)+
	bne	.loop
	;
.loopdone	move.l	(a7)+,a1
	addq	#2,a7
	movem.l	(a7)+,d0-d2/a0
	rts

makemode	cmp	#5,d3
	bcs	.done
	cmp	#11,d3
	bhi	.done2
	beq	.imm
	bsr	insasm
	cmp	#5,d3
	beq	.word
	cmp	#6,d3
	beq	.dxi
	cmp	#7,d3
	beq	.word
	cmp	#8,d3
	beq	.long
	cmp	#9,d3
	beq	.word
	;d(pc,xi)
.dxi	cmp.l	libat,a1
	bcs	.ok7
	addq	#2,a1
	rts
.ok7	move	d4,(a1)+
	rts
.imm	cmp	#8,asmsize
	bcc	.immlong
	moveq	#16,d3
	bsr	insasm
	moveq	#11,d3
	bra	.word
.immlong	bsr	insasm
.long	addq	#2,a1
.word	addq	#2,a1
	rts
	;
.done2	cmp	#15,d3
	bne	.done
	cmp.l	libat,a1
	bcs	.ok3
	addq	#2,a1
	addq	#4,a7
	rts
.ok3	move	d2,(a1)+
	addq	#4,a7
.done	rts

countpees	;count up how many parameters are following
	;nest a-la {,(,},)
	;
	;return how many parameters in d1
	;
	bsr	storeloc
	moveq	#0,d1
	bsr	getchar3	;eol?
	beq	.done
	moveq	#0,d3
	bra	.skiphelp
	;
.loop	bsr	getchar3
	bne	.skip
	tst	d3
	bne	syntaxerr
	bra	.done2
.skip	;
	move	quoteflag,d4
	bne	.loop
	;
.skiphelp	cmp	#')',d0
	bne	.skip2
	tst	d3
	beq	.done2
.skip3	subq	#1,d3
	bra	.loop
.skip2	cmp	#'}',d0
	beq	.skip3
	cmp	#'(',d0
	bne	.skip4a
.skip4	addq	#1,d3
	bra	.loop
.skip4a	cmp	#'{',d0
	beq	.skip4
	cmp	#',',d0
	bne	.loop
	tst	d3
	bne	.loop
	addq	#1,d1
	bra	.loop
.done2	addq	#1,d1
.done	bra	resloc

fetchlibps	;fetch library parameters....
	;
	;d1=number. lo byte = # parameters
	;hi byte and 7= number of repeatables
	;(eg:- Line 0,0,319,0,319,199,0,199,0,0 ,3)
	;hi byte and $78 lsr 3 = pos of first repeat
	;
	;a2=start of types table.....
	;
	clr	numreps
	move	d1,d0
	and	#$ff00,d0
	beq	.noreps
	lsr	#8,d0
	lsr	#4,d0	;d0= start of reps
	beq	.skip
	sub.b	d0,d1	;new number to fetch
	bsr	fetchpees2	;fetch first parms
	cmp	#',',d0
	bne	syntaxerr
	;
.skip	;O.K., now to fetch repeats.....
	;
	move	d1,d2
	lsr	#8,d2
	and	#7,d2	;# repeatable....
	;
.rloop	cmp.b	d2,d1
	bcs	.repsdone	;all reps done....
	sub.b	d2,d1
	movem.l	d2/a2,-(a7)
	move	d2,d0
	bsr	fetchpees4
	movem.l	(a7)+,d2/a2
	addq	#1,numreps
	bra	.rloop
	;
.repsdone	move	numreps,d3
	beq	syntaxerr
	add	d2,a2
	and	#255,d1
	beq	.done
;	;
;	;handle 'else' for repeating parameters...
;	;
;	cmp	#$8000+34,d0
;	beq	.done
;	;
	cmp	#',',d0
	bne	syntaxerr
.noreps	move	d1,d0
	bne	fetchpees2
.done	rts

ptype	move	#0,-(a7)
pmode	dc	0

fetchpees4	moveq	#1,d2	;always push
	bra	fetchpees3	
	;
fetchpees2	moveq	#0,d2	;dont push unless told.
fetchpees3	and	#15,d0
	;
fetchpees	;fetch a list of parameters.
	;
	;d0=number to fetch, a2=pointer to type buffer
	;d1=push mode
	;
	move	d1,-(a7)
	move	pmode(pc),-(a7)	;in case of recursion
	move	d2,pmode
	move	d0,-(a7)
	;
.loop	move.b	(a2)+,d2
	bne	.skip0
	move	userp,d2	;user selected type
.skip0	move.l	a2,-(a7)
	bsr 	handlep
	move.l	(a7)+,a2
	subq	#1,(a7)
	beq	.done
	cmp	#',',d0
	bne	notparerr
	bra	.loop
	;
.done	addq	#2,a7
	move	(a7)+,pmode
	move	(a7)+,d1
	rts

handlep	;d2=what to get. various flags are as follows:
	;
	;BIT 7 : The Address of a var - d2.b = type of var
	;BIT 6 : We want to push any results that
	;	would normally go into D(regat).
	;	this should apply to all others too.
	;
	;BIT 5 : We want array info.
	;
	
	move	d2,d1
	and	#64,d1	;push bit
	move.b	d1,pmode
	tst.b	d2
	bmi	handlevara
	btst	#5,d2
	bne	handlearr
	;
	;normal p get
	;
	bsr	getap
	;
putap	;push D(regat), type in d2.
	;
	move	pmode(pc),d1
	beq	putapincreg
pushap	;push D(regat), type in d2.
	addq	#4,stackuse
	move	pushdn,d1
	or	regat,d1	;push long
	cmp	#3,d2
	bcc	.skip
	subq	#2,stackuse
	or	#$1000,d1	;push word only
.skip	bsr	pokewd
	rts
putapincreg	addq	#1,regat
	;cmp	#7,regat
	;bcs	.regok
	;move	#6,regat	
.regok	rts

putalp	moveq	#3,d2
	bra	putap

handlevara	;Here, we want the address of a var type d2
	;
	and	#7,d2
	move	d2,-(a7)
	;
	bsr	ampersand2
	;
	cmp.b	#7,d2	;ignore pnt to $
	beq	.nop2
	;
	btst	#14,d2
	beq	.nop
	move.b	#3,d2	;pointer to long
	bra	.nop2
.nop	tst.b	d2
	bne	.nop2
	move.b	#3,d2
.nop2	move	(a7)+,d3
	tst.b	d3
	beq	.unp
	cmp.b	d2,d3
	beq	putalp
	bra	mismatcherr
	;
.unp	addq	#2,stackuse
	move	ptype(pc),d1
	bsr	pokewd
	moveq	#0,d1
	move.b	d2,d1
	bsr	pokewd
	bra	putalp

handlearr	;
	move	d2,-(a7)
	bsr	baseadd
	btst	#4,1(a7)
	beq	.nohigh
	bsr	highadd
.nohigh	btst	#3,1(a7)
	beq	.notype
	bsr	sendtype
.notype	move	(a7)+,d2
	bra	getchar3

sendtype	;OK, type of array is gonna be put on stack
	;
	move	regat,d1
	lsl	#8,d1
	lsl	#1,d1
	or	#$7000,d1
	btst	#0,7(a3)
	bne	.isap	;A Pointer
	cmp.l	#256,4(a2)
	bcc	arrerr1	;illegal type to send
	move.b	7(a2),d1
.puit	bsr	pokewd	;moveq #type,d regat
	moveq	#2,d2	;just a word.
	bra	pushap
.isap	move.b	#3,d1
	bra	.puit

baseadd	;send base on stack or in reg
	;
	bsr	getchar3
	bsr	getvname
	btst	#1,flagmask+1
	beq	syntaxerr
	bsr	fetchvar
	;
	bsr	getchar3
	cmp	#')',d0	;we just want a() or whatever
	bne	syntaxerr
	move	added,d1
	bne	noarrayerr
	move	regat,d1
	lsl	#8,d1
	lsl	#1,d1
	or	fbase(pc),d1
	bsr	pokewd
	move	4(a3),d1
	bsr	pokewd
	bra	putalp	;OK, we've got da base reg.

highadd	;send high end of array on stack
	;
	move	regat,d1
	lsl	#8,d1
	lsl	#1,d1
	or	fbase(pc),d1
	bsr	pokewd
	;
	move	8(a3),d1
	lsl	#2,d1
	move	varmode,d2
	beq	.isglob
	neg	d1
.isglob	add	4(a3),d1
	bsr	pokewd
	move	regat(pc),d1
	lsl	#8,d1
	lsl	#1,d1
	;
	move	pmode(pc),d2
	bne	.dopadd	;we just pushed last parameter!
	cmp	#7,regat
	bcc	.dopadd	;last was d6, it must have been
			;pushed too.
	or	pushlast(pc),d1
	move	regat,d2
	subq	#1,d2
	or	d2,d1
	bra	.pp
	;
.dopadd	;last one was pushed. we have to add to stack!
	;
	or	pushadd(pc),d1
.pp	bsr	pokewd
	move.b	#1,pmode
	bra	putalp

fbase	move.l	0(a5),d0
pushadd	add.l	(a7),d0
pushlast	add.l	d0,d0

getap	and	#7,d2	;0-7 (unknown to string)
	beq	evalu2
	bra	eval

resetlibs	move.l	firstlib,a1
.loop	cmp	#0,a1
	beq	.done
	move	#-1,10(a1)
	bclr	#7,12(a1)
	move.l	(a1),a1
	bra	.loop
.done	rts

usevars	move	#allocvars,d1
	;
uselib	;lib number in d1 - turn it on baby!
	;
	bsr	findlib
	;
uselib3	tst	cfetchmode
	beq	.noconst
	btst	#6,12(a1)
	bne	.constok
	;
	bra	badconerr	;Can't use this Library!
	;
.constok	rts
	;
.noconst	bset	#7,12(a1)
	bne	.skip	;already done....
	;
	cmp	#-1,10(a1)
	bne	.skip	;something already here
	;
	;o.k. - move in the lib!
	;
	tst	dirmode
	beq.s	.oktouse
	;
	bclr	#7,12(a1)
	bra	dirliberr
	;
.oktouse	movem.l	a0/a2/d1,-(a7)
	;
	;is it a maximum type lib....
	;if so, create a varoff for it's structs.....
	;
	move.l	a1,a0
	add.l	18(a1),a0
	tst	-2(a0)
	beq	.notmax
	movem.l	a0-a1,-(a7)
	move	#64335,d1
	bsr	uselib
	movem.l	(a7)+,a0-a1
	addq	#1,varoff
	bclr	#0,varoff+1
	move	varoff,-6(a0)
	addq	#4,varoff
	tst.l	-14(a0)
	beq	.notmax
	addq	#4,varoff
	;
.notmax	move.l	lib,40(a1)	;pc of lib
	move.l	a1,a0
	add.l	18(a1),a0	;start of lib
	;
	move.l	a1,d1
	add.l	6(a1),d1	;end of lib
	tst.l	44(a1)
	beq	.nor
	tst.b	debugga
	bne	.nor	;errs turned on
	move.l	a1,d1
	add.l	44(a1),d1	;copy only non-errchks
.nor	;
	move.l	lib,a2
.loop	cmp.l	data1at,a2
	bcs	.okp
	move	#-1,nomemleft
.bad	addq	#2,a0
	addq	#2,a2
	cmp.l	d1,a0
	bcs	.bad
	bra	.toreloc
.okp	move	(a0)+,(a2)+
	cmp.l	d1,a0
	bcs	.loop
.toreloc	move.l	a2,lib
	move.l	32(a1),d1
	beq	.noreloc
	;
	movem.l	d0/d2-d3,-(a7)
	move.l	36(a1),a0	;start of reloc table
	moveq	#0,d3	;no tokejsrs (yet!)
.reloop	;
	;relocate library code!
	;
	move.l	(a0)+,d2
	tst.l	44(a1)
	beq	.skipr
	tst.b	debugga
	bne	.skipr
	cmp.l	44(a1),d2
	bcc	.next
.skipr	tst	0(a1,d2.l)
	bpl	.notajsr
	tst.l	d3
	bne	.notajsr	;already done...
	move.l	a0,d0
	move.l	d1,d3	;number left to do!
.notajsr	sub.l	18(a1),d2
	bmi	.next
	add.l	40(a1),d2
	move.l	d2,-(a7)
	sub.l	pcat,d2
	bsr	addoff2
	move.l	(a7)+,a2
	tst	nomemleft
	bne	.next
	move.l	40(a1),d2
	sub.l	18(a1),d2
	add.l	d2,(a2)
	;
.next	subq.l	#1,d1
	bne	.reloop
	move.l	d3,d2
	beq	.nohand
	move.l	d0,a2
	subq	#4,a2
	;
	bsr	handlejsrs
	;
.nohand	movem.l	(a7)+,d0/d2-d3
.noreloc
	movem.l	(a7)+,a0/a2/d1
	;
	movem.l	d1/d2,-(a7)
	tst	26(a1)
	bne	.skip2a
	clr	10(a1)
	bra	.skip2
.skip2a	;
	addq	#1,varoff
	bclr	#0,varoff+1
	move	varoff,10(a1)
	;
	cmp	#65235,d1
	bne	.nots1
	;
	move	10(a1),movestdn+2
	move	10(a1),pusha3+2
	move	10(a1),pusha32+2
	move	10(a1),pulla3+2
	move	10(a1),geta3+2
	;
.nots1	cmp	#64535,d1
	bne	.notd
	;
	move	10(a1),dataget+2
	move	10(a1),dataput+2
	move	10(a1),rescode+6
	move	10(a1),rescode2+2
	;
.notd	addq	#2,varoff
	tst	26(a1)
	bmi	.jword
	addq	#2,varoff
.jword	;
	movem.l	d1/a1,-(a7)
	bsr	usevars
	movem.l	(a7)+,d1/a1
	;
.skip2	move	d1,d2
	move.l	22(a1),d1
	bsr	uselib2
	move.l	28(a1),d1
	bsr	uselib2
	movem.l	(a7)+,d1/d2
.skip	rts

fixjsrs	;OK, we have to create code and fill in offsets
	;for all tokejsrs done through the program
	;
	moveq	#0,d2	;do list till this...
.loop	move.l	tokeslist,a2
	cmp.l	d2,a2
	beq	.done
	move.l	a2,-(a7)	;next till...
.loop2	;do this list...
	moveq	#0,d3
.loop3	move.l	8(a2),a3
	cmp.l	d3,a3
	beq	.done4
	;
	move.l	a3,-(a7)
	movem.l	d2-d3/a2-a3,-(a7)
	move	4(a2),d1
	move	6(a2),d2
	;
	bsr	tokecode
	;
	movem.l	(a7)+,d2-d3/a2-a3
.loop4	move	nomemleft,d0
	beq	.ok
.loop5	move.l	(a3),a3
	cmp.l	d3,a3
	bne	.loop5
	bra	.skipz
.ok	move.l	4(a3),a0
	move.l	d7,(a0)
	move.l	(a3),a3
	cmp.l	d3,a3
	bne	.ok
.skipz	move.l	(a7)+,d3
	bra	.loop3
	;
.done4	move.l	(a2),a2
	cmp.l	d2,a2
	bne	.loop2
	move.l	(a7)+,d2
	bra	.loop
	;
.done	rts

tokecode	;d1=token number, d2=form number!
	;
	;return d7, address to jsr!
	;
	move	d2,-(a7)
	bsr	findtoke
	move	(a7)+,d2
	;
	bclr	#7,blitzmode
	bclr	#14,d2
	beq	.isamiga
	bset	#7,blitzmode
.isamiga	;
	tst	(a3)
	beq	.simple
	btst	#2,1(a3)
	bne	tokeerr
	btst	#3,1(a3)
	bne	tokeerr
	;
	;OK, it's a complex sorta token...
	;
	lea	6(a3),a3	;skip node
.loop	move	(a3)+,d0
	bmi	tokeerr
	and	#255,d0
	add	d0,a3
	addq	#1,a3
	exg	a3,d0
	bclr	#0,d0
	exg	a3,d0
	subq	#1,d2
	bpl	.loop2
	;
	tst	(a3)
	bne	.go4it	;no libs to fetch....
	move.l	2(a3),d0
	or.l	10(a3),d0
	bne	.go4it	;no error chx...
	btst	#0,9(a3)
	bne	.go4it	;ditto...
	move.l	6(a3),d7	;sub offset
	move	0(a2,d7.l),d0
	and	#$f000,d0
	cmp	#$a000,d0
	beq	.go4it
	;
.penis	sub.l	18(a2),d7
	add.l	40(a2),d7
	rts
	;
.go4it	lea	cutejsr,a0
.putcode	;a0=route in
	move.l	pc,-(a7)
	move	#-1,lasta6
	;
	jsr	(a0)
	move	#$4e75,d1
	bsr	pokewd
	;
	move.l	(a7)+,d7
	rts
	;
.loop2	tst	(a3)+
	beq	.skip
	addq	#2,a3
	bra	.loop2
.skip	lea	12(a3),a3
	bra	.loop
	;
.simple	tst	d2
	bne	tokeerr
	;
	tst	6(a3)
	bne	.be4it
	move.l	8(a3),d0
	or.l	16(a3),d0
	bne	.be4it
	btst	#0,15(a3)
	bne	.be4it
	move.l	12(a3),d7
	move	0(a2,d7.l),d0
	and	#$f000,d0
	cmp	#$a000,d0
	bne	.penis
	;
.be4it	move.l	a3,d1
	sub.l	a2,d1
	lea	makelibsub,a0
	bra	.putcode

freetlist	move.l	4.w,a6
	move.l	tokeslist,a2
	clr.l	tokeslist
.floop	cmp	#0,a2
	beq	.done2
	move.l	8(a2),a3
.floop2	cmp	#0,a3
	beq	.done3
	move.l	a3,a1
	move.l	(a3),a3
	moveq	#8,d0
	jsr	freemem(a6)
	bra	.floop2
.done3	move.l	a2,a1
	move.l	(a2),a2
	moveq	#12,d0
	jsr	freemem(a6)
	bra	.floop
.done2	rts

handlejsrs	;a2=first, d2=how many to do.
	;
	movem.l	a1-a6/d3-d5,-(a7)
	move.l	a1,a4
	;
.loop	move.l	(a2)+,d3
	move	0(a4,d3.l),d5
	bpl	.next
	;
	tst.l	44(a4)
	beq	.skipr
	tst.b	debugga
	bne	.skipr
	cmp.l	44(a4),d3
	bcc	.next
.skipr	;
	bclr	#15,d5	;to offset number
	move	2(a4,d3.l),d4
	sub.l	18(a4),d3
	add.l	40(a4),d3
	;
	movem.l	d2/a2/a4,-(a7)
	bsr	maketjsr
	movem.l	(a7)+,d2/a2/a4
	;
.next	subq.l	#1,d2
	bne	.loop
	;
	movem.l	(a7)+,a1-a6/d3-d5
	rts

maketjsr	;d3=address to poke jsr into,
	;d4=token number, d5=offset number
	;bit 14 of d5=1 if BLITZ type.
	;
	lea	tokeslist,a3
	move.l	4.w,a6
.loop2	move.l	(a3),d0
	beq	.notfound
	move.l	d0,a3
	cmp	4(a3),d4
	bne	.loop2
	cmp	6(a3),d5
	bne	.loop2
	bra	.found
	;
.notfound	;None done yet...make one up!
	;
	moveq	#12,d0
	moveq	#1,d1
	jsr	doallocmem
	move.l	d0,a3
	move.l	tokeslist,(a3)
	move.l	a3,tokeslist
	move	d4,4(a3)
	move	d5,6(a3)
	clr.l	8(a3)
	;
.found	moveq	#8,d0
	moveq	#1,d1
	jsr	doallocmem
	move.l	d0,a0
	move.l	d3,4(a0)
	move.l	8(a3),(a0)
	move.l	a0,8(a3)
	;
	move	d4,d1
	bra	findtoke	;use this library - NOW!

tokeslist	dc.l	0

;	00.l : Next
;	04.w : token number
;	06.w : form number	;bit 14=1 if Blitz
;	08.l : list of offsets
		;
		;00.l : Next
		;04.l : Offset

uselib2	beq	.skip
	move.l	a1,-(a7)
	add.l	d1,a1
	addq	#6,a1
.loop	move	(a1)+,d1
	beq	.done
	cmp	d2,d1
	beq	.skip2
	move.l	a1,-(a7)
	bsr	uselib
	move.l	(a7)+,a1
.skip2	addq	#2,a1
	bra	.loop
.done	move.l	(a7)+,a1
.skip	rts

findlibnoerr	;
	move.l	firstlib,a1
.loop	cmp	#0,a1
	beq.s	.rts
	cmp	4(a1),d1
	beq	.found
	move.l	(a1),a1
	bra	.loop
.found	moveq	#-1,d1
.rts	rts

findlib	;find lib number d1 - return in a1
	;
	move.l	firstlib,a1
.loop	cmp	#0,a1
	;
	beq	noliberr
	;
	cmp	4(a1),d1
	beq	.found
	move.l	(a1),a1
	bra	.loop
.found	rts

findtoke	;d1=token.
	;
	;return a2.l=lib, a3.l=sub
	;
	;
	move.l	firstlib,a2
.loop	cmp	#0,a2
	beq	notokerr
	cmp	14(a2),d1
	bcs	.next
	cmp	16(a2),d1
	bcc	.next
	;
	;lib found!
	;
	lea	48(a2),a3
	tst	4(a2)
	bpl	.userlib
.loop2	cmp	14(a2),d1
	beq	.found
	subq	#1,d1
	move.l	2(a3),a3
	bra	.loop2
.found	movem.l	d1/a1,-(a7)
	move.l	a2,a1
	move	4(a1),d1	;set lib#
	bsr	uselib3
	movem.l	(a7)+,d1/a1
	rts
	;
.userlib	;move	(a3),d0
	;and	#15,d0
	;beq	.notoke
	cmp	14(a2),d1
	beq	.found
	subq	#1,d1
.notoke	move.l	2(a3),a3
	bra	.userlib
.next	move.l	(a2),a2
	bra	.loop

deflibsat	dc.l	0
acidlibsat	dc.l	0
blitzlibsat	dc.l	0	;start of blitzlibs list!

loadlibgroup	;load a group of libraries!
	;
	;d0=len, d1=name
	;return d0=address
	;
	tst.l	d0
	beq	.rts
	move.l	d0,d6	;d6=len
	move.l	dos,a6
	move.l	#1005,d2
	jsr	open(a6)
	move.l	d0,d7
	beq	.rts
	move.l	d6,d0
	moveq	#1,d1
	move.l	4.w,a6
	jsr	doallocmem
	move.l	d0,d5	;start address
	move.l	d7,d1
	move.l	d5,d2
	move.l	d6,d3
	move.l	dos,a6
	jsr	read(a6)
	move.l	d7,d1
	jsr	close(a6)
	;
	move.l	d5,a0
.linkloop	move.l	(a0)+,d0
	beq.s	.linkdone
	lea	32(a0),a1
	move.l	a1,(a3)	;link in.
	move.l	a1,a3
	add.l	d0,a0
	;
	;fix stuff - done by loadalib
	;
	move.l	-4(a1),d0	;number of longwords.
	add.l	d0,d0	;to bytes...
	add.l	d0,d0
	move.l	d0,6(a1)	;fix 1
	clr.l	32(a1)	;no relocs
	lea	12(a1,d0.l),a2	;reloc info.
	cmp.l	a0,a2	;is it over?
	bcc.s	.linkloop
	;
	move.l	-8(a2),32(a1)	;number of relocs.
	move.l	a2,36(a1)		;pointer to relocs.
	bra	.linkloop
	;
.linkdone	move.l	d5,d0
.rts	rts

loadlibs	;use libslist to load in used libs dir contents
	;
	lea	firstlib,a3
	;
	move.l	acidlibs,d0
	move.l	#acidname,d1
	bsr	loadlibgroup
	move.l	d0,acidlibsat
	;
	move.l	deflibs,d0
	move.l	#defname,d1
	bsr	loadlibgroup
	move.l	d0,deflibsat
	;
	;all libs read in, now to link 'em up.
	;
	clr.l	(a3)
	move.l	a3,blitzlibsat
loadblitzlibs	;
	;load in blitz libs only!
	;
	lea	undobuffer,a0
	lea	libsdir,a1
.loop0	move.b	(a1)+,(a0)+
	bne.s	.loop0
	subq	#2,a0
	cmp.b	#'/',(a0)+	;SIMON WAS HERE THE FUCK HEAD
	beq.s	.yup
	cmp.l	#undobuffer,a0
	beq.s	.yup
	move.b	#'/',(a0)+
.yup	move.l	a0,-(a7)	;store first pos for chars
			;("BLITZLIBS:")

	lea	libslist,a2	;lib names!
	move.l	blitzlibsat,a3
	move.l	dos,a6
	;
.loop	move.l	(a2),d0
	bne.s	.more
	clr.l	(a3)
	addq	#4,a7
	bra	fixlibs
	;
.more	move.l	d0,a2
	tst	4(a2)
	beq.s	.loop
	;
	lea	6(a2),a1	;add dir name to libsdir
	move.l	(a7),a0
.loop2	move.b	(a1)+,(a0)+
	bne	.loop2
	move.l	a0,-(a7)	;pointer for lib name
	;
	move.l	#undobuffer,d1
	moveq	#-2,d2
	jsr	lock(a6)
	move.l	d0,d1
	beq	.exdone2
	move.l	(a7),a0
	move.b	#'/',-1(a0)
	;
	move.l	d1,-(a7)	;lock
	move.l	#namebuff,d2
	jsr	examine(a6)
	tst.l	d0
	beq	.exdone
	;
	;O.K. for exnext loop....
	;
.exloop	move.l	(a7),d1
	move.l	#namebuff,d2
	jsr	exnext(a6)
	tst.l	d0
	beq	.exdone
	move.l	namebuff+4,d0	;+4
	bpl	.exloop
	;
	;*** NEW ***
	lea	namebuff+8,a0
	bsr	endininfo
	beq	.exloop
	;
	lea	namebuff+8,a0
	move.l	4(a7),a1
.mnamel	move.b	(a0)+,(a1)+
	bne	.mnamel
	move.l	#undobuffer,d1
	bsr	loadalib
	bra	.exloop
	;
.exdone	move.l	(a7)+,d1
	jsr	unlock(a6)
.exdone2	addq	#4,a7	;forget namepos
	bra	.loop

loadalib	;filename pointed to by d1	;dos base in a6
	;lib in a3
	;
	move.l	#1005,d2
	jsr	open(a6)
	move.l	d0,d7
	beq	.openerr
	move.l	d7,d1
	move.l	#optstuff,d2
	moveq	#32,d3
	jsr	read(a6)
	move.l	optstuff+28,d6	;long words to read
	lsl.l	#2,d6
	move.l	d6,d0
	moveq	#1,d1
	move.l	4.w,a6
	jsr	doallocmem
	move.l	d0,a5
	move.l	dos,a6
	;
	move.l	d7,d1
	move.l	a5,d2
	move.l	d6,d3
	jsr	read(a6)		;read in struct
	;
	move.l	a5,(a3)
	move.l	a5,a3
	move.l	d6,6(a5)
	clr.l	32(a5)
	move.l	d7,d1
	move.l	#optstuff,d2
	moveq	#12,d3
	jsr	read(a6)
	;
	cmp.l	#12,d0
	bcs	.closeup
	move.l	optstuff+4,d0
	move.l	d0,32(a5)
	lsl.l	#2,d0
	move.l	d0,d5		;length of reloc info
	moveq	#1,d1
	move.l	4.w,a6
	jsr	doallocmem
	move.l	dos,a6
	;
	move.l	d0,36(a5)		;pointer to reloc mem
	move.l	d7,d1
	move.l	d0,d2
	move.l	d5,d3
	jsr	read(a6)
	;
.closeup	move.l	d7,d1
	jmp	close(a6)
.openerr	rts

fixlibs	;
	;fill in blanks in lib list
	;
	;tokens, links etc
	;
	clr	nummaxs
	move.l	lasttoken,a3
	move.l	firstlib,a2
	;
.loop	cmp	#0,a2
	beq	.done
	move	4(a2),d7
	bmi	.syslib
	lsl	#7,d7
	addq	#1,d7
	move	d7,14(a2)
.syslib	lea	48(a2),a1
	lea	temp1,a4
	;
.loop2	move	(a1),d0
	bmi	.next
	move.l	a1,(a4)
	move.l	a1,a4	;last link for subs
	addq	#2,a4
	addq	#6,a1
	cmp	#8,d0
	beq	.addtoke
	and	#15,d0
	bne	.something
	;
	;skip sys sub
	;
	bsr	skiplibreg
	lea	12(a1),a1
	addq	#1,d7	;in case it's a user lib
	bra	.loop2	
.something	btst	#2,d0
	beq	.notalib
	addq	#4,a1
.alibloop	tst.b	(a1)+
	bpl	.alibloop
	bsr	aligna1
	bra	.addtoke
.notalib	;process standard function or statement
.stloop	move	(a1)+,d0
	bmi	.addtoke
	and	#255,d0
	add	d0,a1
	bsr	aligna1
	bsr	skiplibreg
	lea	12(a1),a1
	bra	.stloop
.addtoke	move.l	a1,(a3)
	move.l	a1,a3
	addq	#4,a1
	;
	move	d7,(a1)+
	;
.tokeloop	tst.b	(a1)+
	bne	.tokeloop
.tokeloop2	tst.b	(a1)+
	bne	.tokeloop2
	bsr	aligna1
	addq	#1,d7
	bra	.loop2
	;
.next	tst	4(a2)
	bmi	.notulib
	move	d7,16(a2)
.notulib	addq	#2,a1
	tst.l	(a1)+
	beq	.nomax
	addq	#1,nummaxs
	lea	22(a1),a1
.nomax	sub.l	a2,a1
	move.l	a1,18(a2)
	move.l	(a2),a2
	bra	.loop
	;
.done	clr.l	(a3)
	move.l	a7,errstack
	move.l	#.cont,errcont
	move	#-1,ezerr
	move	#65530,d1
	bsr	findlib	;get address of mem lib
	move.l	a1,memlib
	move	#64935,d1
	bsr	findlib
	move.l	a1,ffplib
.cont	rts

ffplib	dc.l	0

skiplibreg	tst	(a1)+
	beq	.done
	addq	#2,a1
	bra	skiplibreg
.done	rts
	
aligna0	exg.l	a0,a1
	bsr	aligna1
	exg.l	a0,a1
	rts
	;
aligna1	exg.l	a1,d0
	addq.l	#1,d0
	bclr	#0,d0
	exg.l	a1,d0
	rts

freeblitzlibs	move.l	4.w,a6
	move.l	blitzlibsat,a2
	move.l	(a2),d0
	clr.l	(a2)
	move.l	d0,a2
.loop	cmp	#0,a2
	beq	frlibslist
	move.l	32(a2),d0
	beq.s	.skip
	lsl.l	#2,d0
	move.l	36(a2),a1
	jsr	freemem(a6)
.skip	move.l	a2,a1
	move.l	6(a1),d0
	move.l	(a2),a2
	jsr	freemem(a6)
	bra	.loop

freelibs	;free up all memory used by libs
	;
	bsr	freeblitzlibs
	;
	move.l	4.w,a6
	clr.l	firstlib
	move.l	lasttoken,a0
	clr.l	(a0)
	;
	move.l	deflibs,d0
	beq.s	.defskip
	move.l	deflibsat,d1
	beq.s	.defskip
	clr.l	deflibsat
	move.l	d1,a1
	jsr	freemem(a6)
.defskip	;
	move.l	acidlibs,d0
	beq.s	.acidskip
	move.l	acidlibsat,d1
	beq.s	.acidskip
	clr.l	acidlibsat
	move.l	d1,a1
	jsr	freemem(a6)
.acidskip	;
	rts
	
freemacs	;
	move.l	lastresmac,a0
	move.l	(a0),a2
	clr.l	(a0)
	move.l	4.w,a6
.loop	cmp	#0,a2
	beq	.done
	moveq	#0,d0
	move	8(a2),d0
	beq	.skip
	move.l	4(a2),a1
	jsr	freemem(a6)
	;
.skip	move.l	a2,a1
	move.l	(a2),a2
	moveq	#0,d0
	move.b	12(a1),d0
	jsr	freemem(a6)
	bra	.loop
.done	rts

freeasms	move.l	firstasm,a2
	clr.l	firstasm
	move.l	4.w,a6
.loop	cmp	#0,a2
	beq	.done
	moveq	#0,d0
	move.b	14(a2),d0
	move.l	a2,a1
	move.l	(a2),a2
	jsr	freemem(a6)
	bra	.loop
.done	rts

pokedata1b	;byte into data1
	move.l	data1,a4
	cmp.l	data2at,a4
	bcc	.over
	move.b	d1,(a4)+
	move.l	a4,data1
	rts
.over	move	#-1,nomemleft
	addq.l	#1,data1
	rts

pokedata1l	swap	d1
	bsr	pokedata1
	swap	d1
	;
pokedata1	;poke word in d1 into data block
	move.l	data1,a4
	cmp.l	data2at,a4
	bcc	.over
	move	d1,(a4)+
	move.l	a4,data1
	rts
.over	move	#-1,nomemleft
	addq.l	#2,data1
	rts

calcstatic	;calculate static structures stuff - put num of structs d4.w
	;address of data1 table in d3.l
	;
	;data1: .w=structsize,.w=offset
	;
	move.l	firstvar,a2
calcstatic2	move.l	data1,d3
	moveq	#0,d4
.loop	cmp	#0,a2
	beq	.done
	tst	6(a2)
	bne	.next
	move.l	10(a2),a3
	cmp.l	#256,4(a3)
	bcs	.next
	move	4(a2),d1
	bsr	pokedata1
	move	8(a3),d1
	bsr	pokedata1
	addq	#1,d4
.next	move.l	(a2),a2
	bra	.loop
.done	tst	d4
	beq	.skip
	move	#65335,d1
	bsr	uselib	;use statics lib
	move	#65530,d1	;use memlib
	bra	uselib
.skip	rts

datastart	;set up a2 (d3.l) and d4 (d4.w)
	;
	move	numtoa2,d1
	bsr	pokewd
	bsr	addoff
	move.l	d3,d1
	bsr	pokel
	subq	#1,d4
	move	d4,endarray+2
	move.l	endarray,d1
	bra	pokel

nextopt	macro
	addq	#8,\1
	cmp.l	optend,\1
	bne	.nextopt\@
	move.l	optbuff,\1
.nextopt\@	;
	endm

mywrite	move.l	d3,-(a7)
	jsr	write(a6)
	cmp.l	(a7)+,d0
	bne	.skip
	rts
.skip	move.l	d7,d1
	jsr	close(a6)
execerr	jmp	makeexecerr
	rts

savefile	;
	;make all abs refs pcat relative
	;
	ifeq	cripple
	;
	move.l	a7,errstack
	move.l	#.rts,errcont
	;
	bsr	sleepon
	;
	move	#-1,anyerrs
	move	nomemleft,d1
	bne	.fixdone
	move.l	firstoff,a2
	move.l	pcat,a1
	move.l	a1,d2
	add.l	noinits,d2
.loop0	cmp	#0,a2
	beq	.fixdone
	move.l	4(a2),d0
	tst	0(a1,d0.l)
	bmi	.noway
	sub.l	d2,0(a1,d0.l)
.noway	move.l	(a2),a2
	bra	.loop0
.fixdone	move.l	execname,d1
	move.l	#1006,d2
	move.l	dos,a6
	jsr	open(a6)
	move.l	d0,d7
	beq	execerr
	;
	move.l	objlen,d0
	sub.l	noinits,d0
	addq	#3,d0
	lsr.l	#2,d0
	move.l	d0,tstsize1
	move.l	d0,tstsize2
	move.l	d7,d1
	move.l	#tsthead,d2
	moveq	#32,d3
	bsr	mywrite
	;
	move.l	d7,d1
	move.l	pcat,d2
	add.l	noinits,d2
	move.l	objlen,d3
	sub.l	noinits,d3
	addq.l	#3,d3
	and.l	#$fffffffc,d3
	bsr	mywrite
	;
	move.l	numoffs,tstsize3
	beq	.skip
	move.l	d7,d1
	move.l	#tstend,d2
	moveq	#12,d3
	bsr	mywrite
	;
	move.l	firstoff,a2
	move.l	noinits,d4
.loop	cmp	#0,a2
	beq	.skip2
	lea	4(a2),a1
	sub.l	d4,(a1)
	move.l	d7,d1
	move.l	a1,d2
	moveq	#4,d3
	bsr	mywrite
	;
	add.l	d4,4(a2)
	move.l	(a2),a2
	bra	.loop
.skip2	clr.l	tstsize3
	move.l	d7,d1
	move.l	#tstsize3,d2
	moveq	#4,d3
	bsr	mywrite
	;
.skip	btst	#7,optreqga16+13
	beq	.nodebug
	;
	move.l	#sysdebug,d2
	moveq	#4,d3
	move.l	d7,d1
	bsr	mywrite
	;
	move.l	firstlabel(pc),a2
.deloop	cmp	#0,a2
	beq	.dedone
	btst	#0,7(a2)
	beq	.dodeb
	cmp.l	#1,4(a2)
	bne	.denext
	;
.dodeb	moveq	#0,d4
	move.b	18(a2),d4
	sub	#19,d4
	addq	#3,d4
	and	#$fffc,d4	;long align
	move.l	d4,d5
	lsr	#2,d5
	move.l	d5,temp1
	lsl	#2,d5	;#bytes
	move.l	#temp1,d2
	moveq	#4,d3
	move.l	d7,d1
	bsr	mywrite
	;
	lea	19(a2),a1
	move.l	a1,d2
	move.l	d4,d3
	move.l	d7,d1
	bsr	mywrite
	;
	sub.l	d4,d5
	beq	.dooff
	move.l	#zero,d2
	move.l	d5,d3
	move.l	d7,d1
	bsr	mywrite
	;
.dooff	move.l	8(a2),d2
	sub.l	pcat,d2
	sub.l	noinits,d2
	move.l	d2,temp1
	move.l	#temp1,d2
	moveq	#4,d3
	move.l	d7,d1
	bsr	mywrite
	;
.denext	move.l	(a2),a2
	bra	.deloop
.dedone	move.l	#zero,d2
	moveq	#4,d3
	move.l	d7,d1
	bsr	mywrite
	;
.nodebug	move.l	d7,d1
	move.l	#tstdone,d2
	moveq	#4,d3
	bsr	mywrite
	;
	move.l	d7,d1
	jsr	close(a6)
	;
	btst	#7,optreqga9+13
	beq	.done
	;
	;OK, create an icon for the object code!
	;
	move.l	execname,a0
.iloop	tst.b	(a0)+
	bne	.iloop
	subq	#1,a0
	move.l	a0,-(a7)	;to later null out!
	lea	infoname(pc),a1
.iloop2	move.b	(a1)+,(a0)+
	bne	.iloop2
	;
	move.l	execname,d1
	moveq	#-2,d2
	jsr	lock(a6)
	move.l	d0,d1
	beq	.dildo	;not exist
	jsr	unlock(a6)
	bra	.ifail
	;
.dildo	move.l	execname,d1
	move.l	#1006,d2
	jsr	open(a6)
	move.l	d0,d7
	beq	.ifail
	move.l	#objicon,d2
	move.l	#objiconf-objicon,d3
	move.l	d7,d1
	jsr	write(a6)
	move.l	d7,d1
	jsr	close(a6)
	;
.ifail	move.l	(a7)+,a0
	clr.b	(a0)
	;
.done	;
	bsr	pointeron
	;
	endc
.rts	rts

objicon	incbin	obj.info
objiconf	;

infoname	dc.b	'.info',0
	even

sysdebug	dc.l	$3f0

addoff	;add pc to list of offsets
	;
	move.l	d2,-(a7)
	move.l	pc,d2
	sub.l	pcat,d2
	bsr	addoff2
	move.l	(a7)+,d2
	rts

addoff2	;add d2 to linked list of all offsets
	;
	movem.l	a0-a1/a6/d0-d1,-(a7)
	moveq	#8,d0
	moveq	#1,d1
	move.l	4.w,a6
	jsr	doallocmem
	;
	addq.l	#1,numoffs
	move.l	d0,a0
	move.l	firstoff,(a0)
	move.l	a0,firstoff
	move.l	d2,4(a0)
	movem.l	(a7)+,a0-a1/a6/d0-d1
	rts

killoffs	;kill all offsets
	;
	move.l	4.w,a6
	move.l	firstoff,a2
	clr.l	firstoff
.loop	cmp	#0,a2
	beq	.skip
	move.l	a2,a1
	moveq	#8,d0
	move.l	(a2),a2
	jsr	freemem(a6)
	bra	.loop
.skip	clr.l	numoffs
	rts

cmakebuff	ds	12
cmakea5	dc.l	0
cmake	dc	0
cmakebak	ds.b	128

getchar	move.l	a5,prevloc
	move	quoteflag,oldqflag
	bsr	getcharb
	;
	move	d0,lastchar
	beq	.done
	bpl	.done2
	;
	cmp	#$801c,d0
	beq	.cnif
	cmp	#$801d,d0
	beq	.csif
	cmp	#$801e,d0
	beq	.celse
	cmp	#$801f,d0
	beq	.cend
	;
.done2	tst	comflag
	beq	getchar
	;
	cmp	#'~',d0
	beq	.cmake
	cmp	#2,d0
	bne	.notunpath
	move.l	usedfrom,a5
	bra	getchar
.notunpath	cmp	#1,d0
	bne	.done
	;
	;End of Cmake chars got
	;
	move.l	cmakea5(pc),a5
	bra	getchar
	;
.cmake	tst	cmake
	bne	.done
	not	cmake
	;
	movem.l	d0-d7/a0-a6,-(a7)
	;
	lea	cmakebak(pc),a0
	lea	namebuff,a1
	moveq	#128/4-1,d0
.cmloop	move.l	(a1)+,(a0)+
	dbf	d0,.cmloop
	;
	bsr	evalconst2	;get constant into d3
	cmp	#'~',d0
	bne	syntaxerr
	move.l	a5,cmakea5
	;
	lea	cmakebuff(pc),a0
	move.l	d3,d2
	bsr	makelong
	addq.b	#1,(a0)
	not	cmake
	;
	lea	cmakebak(pc),a0
	lea	namebuff,a1
	moveq	#128/4-1,d0
.cmloop2	move.l	(a0)+,(a1)+
	dbf	d0,.cmloop2
	;
	movem.l	(a7)+,d0-d7/a0-a6
	;
	lea	cmakebuff(pc),a5
	bra	getchar
	;
.done	rts
	;
.csif	move	linenumat,ciflineat
	tst	comflag
	beq	.incnest
	bsr	getchar3
	bsr	docsif
	bra	getchar
	;
.cnif	move	linenumat,ciflineat
	tst	comflag
	beq	.incnest
	bsr	getchar3
	bsr	docnif
	bra	getchar
	;
.incnest	addq	#1,connest
	bra	getchar
	;	
.celse	move	connest,d0
	bne	getchar
	not	comflag
	bra	getchar
	;
.cend	subq	#1,connest
	bpl	getchar
	addq	#1,connest
	move.l	concomsp,a0
	cmp.l	#concomstack,a0
	beq	nociferr
	subq	#2,a0
	move.l	a0,concomsp
	move	(a0),comflag
	bra	getchar

ciflineat	dc	0

getcharb	;
	;get next character into d0... a5=charpointer	
	;set hi bit if token, and lo 15 bits to token number (0-32767)
	;
	moveq	#0,d0
.loop0	move.b	(a5)+,d0
	beq.s	.done
	bpl.s	.stuff
	lsl	#8,d0
	move.b	(a5)+,d0
	rts
.stuff	cmp	#34,d0
	beq.s	swapquote
	cmp	#';',d0
	bne.s	.done
	tst	quoteflag
	bne.s	.done
.loop	move.b	(a5)+,d0
	bne.s	.loop
	move	d0,lastchar
.done	rts

swapquote	not	quoteflag
	rts

getchar2	;as above and skip spaces
	;
	bsr	getchar
	tst	quoteflag
	bne	.skip
	cmp	#32,d0
	beq	getchar2
.skip	rts

gs	ds.b	26
	dc.b	228,246,252,196,214,220

getchar3	;as above. return z=1 if 0 or ':'
	;
	bsr	getchar2
	tst	d0
gchar2	beq.s	.zero
	tst	quoteflag
	beq.s	.noquote
	cmp.b	#32,d0
	bcc.s	.skip
	move.b	gs(pc,d0),d0
	rts
.noquote	cmp	#$8000+34,d0	;else
	beq.s	.zero
	cmp	#':',d0
	beq.s	.zero
.skip	tst	d0
.zero	rts

reget	move	lastchar,d0
	bra	gchar2

bakup	move	oldqflag,quoteflag
	move.l	prevloc,a5
	rts

storeloc	;remember character pointer
	;
	move	d0,locchar
	move.l	a5,locloc
	rts

resloc	;recall char pointer....
	move.l	locloc,a5
	move	locchar,d0
	move	d0,lastchar
	rts

errs
badstoperr	bsr	err
	dc.b	'Debugger must be enabled for STOP',0
	even
makeexecerr	bsr	err
	dc.b	'Error creating Executable',0
	even
fornexterr	bsr	err
	dc.b	'Duplicate For...Next Error',0
	even
excerr2	bsr	err
	dc.b	'Can',39,'t Exchange different types',0
	even
excerr	bsr	err
	dc.b	'Can',39,'t Exchange NewTypes',0
	even
arrerr1	bsr	err
	dc.b	'Illegal Array type',0
	even
nocenderr	bsr	err
	dc.b	'CNIF/CSIF without CEND',0
	even
referr	bsr	err
	dc.b	'Label reference out of context',0
	even
illlaberr	bsr	err
	dc.b	'Label has been used as a Constant',0
	even
selerrz	bsr	err
	dc.b	'Select without End Select',0
	even
unterr1	bsr	err
	dc.b	'Until without Repeat',0
	even
unterr2	bsr	err
	dc.b	'Repeat Block too large',0
	even
unterr3	bsr	err
	dc.b	'Repeat without Until',0
	even
vbokerr1	bsr	err
	dc.b	'AbortVBOK MUST be in a SETINT 5',0
	even
errerr1	bsr	err
	dc.b	'SetErr not allowed in Procedures',0
	even
errerr2	bsr	err
	dc.b	'Can',39,'t nest SetErr',0
	even
errerr3	bsr	err
	dc.b	'End SetErr without SetErr',0
	even
noarrayerr	bsr	err
	dc.b	'Array not found',0
	even
nolisterr	bsr	err
	dc.b	'Array is not a List',0
	even
defaerr	bsr	err
	dc.b	'Default without Select',0
	even
eselerr	bsr	err
	dc.b	'End Select without Select',0
	even
cbraerr	bsr	err
	dc.b	'Previous Case Block too Large',0
	even
caseerr	bsr	err
	dc.b	'Case Without Select',0
	even
tokeerr	bsr	err
	dc.b	'Illegal TokeJsr token number',0
	even
opterr	bsr	err
	dc.b	'Optimizer Error! - $'
opchars	dc.b	'ffff,$'
opchars2	dc.b	'ffff.',0
	even
blitzerr	bsr	err
	dc.b	'Only Available in Blitz mode',0
	even
amigaerr	bsr	err
	dc.b	'Only Available in Amiga mode',0
	even
interr4	bsr	err
	dc.b	'Illegal Interrupt Number',0
	even
interr5	bsr	err
	dc.b	'Illegally nested Interrupts',0
	even
interr3	bsr	err
	dc.b	'Can',39,'t use Set/ClrInt in Local Mode',0
	even
interr	bsr	err
	dc.b	'End SetInt without SetInt',0
	even
interr2	move	intline,linenumat
	bsr	err
	dc.b	'SetInt without End SetInt',0
	even
conmemerr	bsr	err
	dc.b	'Expression too Complex',0
	even
pserr	bsr	err
	dc.b	'Precedence Stack Overflow',0
	even
clasherr	bsr	err
	dc.b	'Clash in Residents',0
	even
reserr	bsr	err
	dc.b	'Can',39,'t Load Resident',0
	even
dupofferr	bsr	err
	dc.b	'Duplicate Offset Error',0
	even
notparerr	bsr	err
	dc.b	'Not Enough Parameters',0
	even
badconterr	bsr	err
	dc.b	'Cont not Currently Available',0
	even
dirliberr	bsr	err
	dc.b	'Library not Available in Direct Mode',0
	even
baddirerr	bsr	err
	dc.b	'Illegal direct mode command',0
	even
nodirmem	bsr	err
	dc.b	'Not enough room in direct mode buffer',0
	even
illdirerr	bsr	err
	dc.b	'Can',39,'t Create in Direct Mode',0
	even
nosuperr	bsr	err
	dc.b	'Not Supported',0
	even
freeerr	bsr	err
	dc.b	'Illegal Token',0
	even
asmerr2	move.l	asmbuff,a2
asmerr	;
	move	12(a2),linenumat
	rts

mbovererr	bsr	err
	dc.b	'Macro Buffer Overflow',0
	even
illvgerr	bsr	err
	dc.b	'Illegal VGoto/VGosub Parameter',0
	even
notqerr	bsr	err
	dc.b	'No Terminating Quote',0
	even
illcgeterr	bsr	err
	dc.b	'Can',39,'t Use Constant',0
	even
illconerr	bsr	err
	dc.b	'Can',39,'t Assign Constant',0
	even
redimerr	bsr	err
	dc.b	'Illegal number of Dimensions',0
	even
illeolerr	bsr	err
	dc.b	'Garbage at End of Line',0
	even
illelseerr	bsr	err
	dc.b	'Illegal Else in While Block',0
	even
illgotoerr	bsr	err
	dc.b	'Can',39,'t Goto/Gosub a Procedure',0
	even
	;
	;assembler errors
	;
illtraperr	bsr	err
	dc.b	'Illegal Trap Vector',0
	even
illimmerr	bsr	err
	dc.b	'Illegal Immediate Value',0
	even
illabserr	bsr	err
	dc.b	'Illgeal Absolute',0
	even
illdiserr	bsr	err
	dc.b	'Illegal Displacement',0
	even
illsizeerr	bsr	err
	dc.b	'Illegal Assembler Instruction Size',0
	even
illeaerr	bsr	err
	dc.b	'Illegal Assembler Addressing Mode',0
	even
	;
	;end of asm errs
	;
nolocerr	bsr	err
	dc.b	'Illegal Local Name',0
	even
fpconerr	bsr	err
	dc.b	'Fractions Not allowed in Constants',0
	even
syntaxerr	bsr	err
	dc.b	'Syntax Error',0
	even
typeerr	bsr	err
	dc.b	'Duplicated Type',0
	even
laberr	bsr	err
	dc.b	'Illegal Label Name',0
	even
modeerr	bsr	err
	dc.b	'End NewType without NewType',0
	even
notypeerr	bsr	err
	dc.b	'Type Not Found',0
	even
illtypeerr	bsr	err
	dc.b	'Illegal Type',0
	even
offerr	bsr	err
	dc.b	'Duplicate Offset',0
	even
overerr	bsr	err
	dc.b	'Numeric Over Flow',0
	even
toolongerr	bsr	err
	dc.b	'Type too Big',0
	even
rongtypeerr	bsr	err
	dc.b	'Mismatched Types',0
	even
noarrerr	bsr	err
	dc.b	'Array not yet Dim',39,'d',0
	even
noofferr	bsr	err
	dc.b	'Offset not Found',0
	even
pointerr	bsr	err
	dc.b	'Element isn',39,'t a pointer',0
	even
noleterr	bsr	err
	dc.b	'Can',39,'t Assign Expression',0
	even
illoperr	bsr	err
	dc.b	'Illegal Operator for Type',0
	even
mismatcherr	bsr	err
	dc.b	'Type Mismatch',0
	even
arraldimerr	bsr	err
	dc.b	'Array already Dim',39,'d',0
	even
nonewerr	bsr	err
	dc.b	'Can',39,'t Create Variable inside Dim',0
	even
arrnotdimd	bsr	err
	dc.b	'Array not Dim',39,'d',0
	even
noconsterr	bsr	err
	dc.b	'Constant not defined',0
	even
alconsterr	bsr	err
	dc.b	'Constant already defined',0
	even
ilconsterr	bsr	err
	dc.b	'Illegal Constant',0
	even
noliberr	lea	liberrnum(pc),a0
	bsr	hexascii
	bsr	err
	dc.b	'Library not Found : $'
liberrnum	dc.b	'ffff.',0
	even
notokerr	lea	tokerrnum(pc),a0
	bsr	hexascii
	bsr	err
	dc.b	'Token Not Found : $'
tokerrnum	dc.b	'ffff.',0
duplaberr	bsr	err
	dc.b	'Duplicate Label',0
	even
nolaberr	bsr	err
	dc.b	'Label not Found',0
	even
typeiferr	bsr	err
	dc.b	'Can',39,'t Compare Types',0
	even
noiferr	bsr	err
	dc.b	'End Condition without Condition',0
	even
bigiferr	bsr	err
	dc.b	'If Block too Large',0
	even
badenderr	bsr	err
	dc.b	'Illegaly nested Condition',0
	even
dupmacerr	bsr	err
	dc.b	'Macro already Defined',0
	even
macnesterr	bsr	err
	dc.b	'Can',39,'t create Macro inside Macro',0
	even
macenderr	move	macline,linenumat
	bsr	err
	dc.b	'Macro without End Macro',0
	even
macbigerr	bsr	err
	dc.b	'Macro too Big',0
	even
tmmacerr	bsr	err
	dc.b	'Macros Nested too Deep',0
	even
nomacerr	bsr	err
	dc.b	'Macro not Found',0
	even
comerr	bsr	err
	dc.b	'Too many comma',39,'s in Let',0
	even
nocomerr	bsr	err
	dc.b	'Can',39,'t use comma in Let',0
	even
conintype	bsr	err
	dc.b	'Can',39,'t use a Constant in New Type',0
	even
alincerr	bsr	err
	dc.b	'Already Included',0
	even
noincerr	bsr	err
	dc.b	'Can',39,'t open Include',0
	even
readerr	bsr	err
	dc.b	'Error Reading File',0
	even
toifmacerr	bsr	err
	dc.b	'If Macro',39,'s Nested too Deep',0
	even
noenderr	bsr	err
	dc.b	'If Without End If',0
	even
dupprocerr	bsr	err
	dc.b	'Duplicate Procedure name',0
	even
duplocerr	bsr	err
	dc.b	'Duplicate parameter variable',0
	even
noprocerr	bsr	err
	dc.b	'Procedure not found',0
	even
toovarerr	bsr	err
	dc.b	'Too many parameters',0
	even
illvarerr	bsr	err
	dc.b	'Illegal Parameter Type',0
	even
nopenderr	bsr	err
	dc.b	'Unterminated Procedure',0
	even
illprocerr	bsr	err
	dc.b	'Illegal Procedure Call',0
	even
functypeerr	bsr	err
	dc.b	'Illegal Function Type',0
	even
illprocperr	bsr	err
	dc.b	'Illegal Parameter Type',0
	even
extlaberr	bsr	err
	dc.b	'Can',39,'t Access Label',0
	even
sreterr	bsr	err
	dc.b	'Illegal Procedure return',0
	even
sharederr	bsr	err
	dc.b	'Shared outside of Procedure',0
	even
dupsherr	bsr	err
	dc.b	'Variable already Shared',0
	even
badforerr	bsr	err
	dc.b	'Bad Type for For...Next',0
	even
noforerr	bsr	err
	dc.b	'Next without For',0
	even
bigforerr	bsr	err
	dc.b	'For...Next Block to Long',0
	even
nonexterr	bsr	err
	dc.b	'For Without Next',0
	even
zprocerr	bsr	err
	dc.b	'Can',39,'t Nest Procedures',0
	even
nodimerr	bsr	err
	dc.b	'Can',39,'t Dim Globals in Procedures',0
	even
noconerr	bsr	err
	dc.b	'Can',39,'t Convert Types',0
	even
baddaterr	bsr	err
	dc.b	'Bad Data',0
	even
nociferr	bsr	err
	dc.b	'CEND without CNIF/CSIF...',0
	even
cnferr	bsr	err
	dc.b	'Constant Not Found',0
	even
badconerr	bsr	err
	dc.b	'Illegal Constant Expression',0
	even
badpenderr	bsr	err
	dc.b	'Illegal End Procedure',0
	even

ezerr	dc	0	;for simple errors
			;(ie not during compile)

comperror	;compile time error...
	;
err	tst	dirmode
	bne.s	.quiet
	;
	bsr	pointeron
	;
	move	ezerr(pc),d0
	bne	.skip
	move	cfetchmode,d0
	beq	.skip2
	move.l	oldlibat,libat	;fix up lib thing.
.skip2	move	constmode,d0
	beq.s	.skip3
	bsr	asmerr2
.skip3	;
	move.l	firstlocal,d1
	or.l	firstglob,d1
	beq.s	.notproc	;?!?!?!
	;
	bsr	droplocals
	;
.notproc	move	#-1,anyerrs
	move	linenumat,menuret
	;
	jsr	endstop
	;
.skip	move.l	(a7)+,a0
	move.l	comdata,a1
	move.l	12(a1),a1
	movem.l	d7/a6,-(a7)
	jsr	(a1)
	movem.l	(a7)+,d7/a6
	move.l	errstack,a7
	move.l	errcont,a0
	jmp	(a0)
	;
.quiet	move.l	(a7),d0
	move.l	errstack,a7
	move.l	errcont,a0
	jmp	(a0)

tstalpha	;tst if d0 is alphabetic
	;return z=1 if yes
	cmp	#'z',d0
	bhi	.no
	cmp	#'A',d0
	bcs	.no
	cmp	#'a',d0
	bcc	.yes
	cmp	#'Z',d0
	bhi	.no
.yes	cmp	d0,d0
.no	rts

tstnum	;tst if d0 is numeric, eq=1 if yes
	;cmp	#'-',d0
	;beq	.skip
tstnum2	cmp	#'0',d0
	bcs	.skip
	cmp	#'9',d0
	bhi	.skip
	cmp	d0,d0
.skip	rts

tstlab	;tst if d0 is a lable character
	;eq=1 if yes
	bsr	tstalpha
	beq	.skip
	bsr	tstnum2
	beq	.skip
	cmp	#'_',d0
	beq	.skip
	cmp	#loclabch,d0
.skip	rts

makename2	bsr	bakup
makename	;
	;pick up label name from a5...
	;
	;put into name buff, return len in d2 (eq if zero)
	;
	lea	namebuff,a1
makename3	moveq	#0,d2
makename4	bsr	getchar3
	cmp	#'_',d0
	beq	.oloop
	bsr	tstalpha
	bne	.done
.oloop	;not	quoteflag	;force 'space' gets
.loop	move.b	d0,(a1)+
	addq	#1,d2
	;
	bsr	getchar
	bsr	tstlab
	beq	.loop
	;
	;not	quoteflag	;back to norm...
	;not	oldqflag
	;
	cmp	#32,d0
	bne	.done
	bsr	getchar3
.done	clr.b	(a1)
	tst	d2
	rts

findlast	;look for last entry in list from a2
	;
	move.l	(a2),d0
.loop	beq	.here
	move.l	d0,a2
	bra	.loop
.here	bra	reget

addhere2	;insert at beginning
	;
	move.l	(a2),-(a7)
	bsr	addhere
	move.l	(a7)+,(a2)
	rts

addhere	tst	dirmode
	bne	illdirerr
	;
	;add namebuff after a2,d7
	;
	;d2=len of name, name in namebuff
	;set a2 to address of struct
	;
	moveq	#0,d0
	move	d7,d0
	add	d2,d0
	addq	#1,d0
	move	d0,d2
	moveq	#1,d1
	move.l	4.w,a6
	jsr	doallocmem
	;
	move.l	d0,a0
	move.l	a0,(a2)
	move.l	a0,a2
	clr.l	(a0)	;clear next
	lea	-1(a0,d7),a0
	move.b	d2,(a0)+	;put in struct length
	lea	namebuff,a1
.loop2	move.b	(a1)+,(a0)+
	bne	.loop2	
	bra	reget

findinc	moveq	#19,d7
	lea	firstinc,a2
	bra	findlab

findxinc	moveq	#5,d7
	lea	firstxinc,a2
	bra	findlab

findconst	moveq	#9,d7
	lea	firstconst,a2
	bra	findlab

findmac	moveq	#13,d7
	lea	firstmacro,a2
	bra	findlab

findadd	lea	firstlabel,a2
	moveq	#19,d7
	bra	findlab

findtype	moveq	#11,d7
	bra	findlab

findproc	lea	firstproc,a2
	moveq	#33,d7
	bra	findlab

findfor	lea	firstfor,a2
	moveq	#17,d7
	bra	findlab

findvar	moveq	#15,d7
	;
findlab	;see if namebuff is in list at a2, char offset in d7
	;
	;z=1 if yes, a2=item loc
	;
	;if no, a2=last for link
	;
.loop	move.l	(a2),d0
	beq.s	.no
	move.l	d0,a2
	moveq	#0,d0
	move.b	-1(a2,d7),d0
	sub	d7,d0
	subq	#1,d0
	cmp	d0,d2
	bne.s	.loop
	lea	0(a2,d7),a1
	lea	namebuff,a0
	subq	#1,d0
.loop2	cmpm.b	(a1)+,(a0)+
	bne.s	.loop
	dbf	d0,.loop2
	bsr	reget
	cmp	d0,d0
	rts
.no	bsr	reget
	moveq	#-1,d1
	rts

freeprocvs	move.l	alllocals,a4
	clr.l	alllocals
.loop	cmp	#0,a4
	beq.s	.done
	move.l	4(a4),a3
	bsr	freevars
	move.l	8(a4),a3
	bsr	freevars
	move.l	a4,a1
	move.l	(a4),a4
	moveq	#12,d0
	move.l	4.w,a6
	jsr	freemem(a6)
	bra.s	.loop
.done	rts

freevars	;free up var structs from a3 on
freevars2	cmp	#0,a3
	beq	.done
	move.l	a3,a1
	move.l	(a3),a3
	moveq	#0,d0
	move.b	14(a1),d0
	move.l	4.w,a6
	jsr	freemem(a6)
	bra	freevars2
.done	rts

freelabels	;free up label structs from firstlabel on...
	;
	move.l	lastrescon,a0
	move.l	(a0),a2
	clr.l	(a0)
	move.l	4.w,a6
.loop	cmp	#0,a2
	beq	.done
	move.l	4(a2),d0
	btst	#0,d0
	bne	.skip
	move.l	d0,a3
.loop2	cmp	#0,a3
	beq	.skip
	move.l	a3,a1
	move.l	(a3),a3
	moveq	#12,d0
	jsr	freemem(a6)
	bra	.loop2
.skip	moveq	#0,d0
	move.b	18(a2),d0
	move.l	a2,a1
	move.l	(a2),a2
	jsr	freemem(a6)
	bra	.loop
.done	;
	rts

freepends	move.l	firstpend,a3
	clr.l	firstpend
	move.l	4.w,a6
fpnd2	cmp	#0,a3
	beq	.done
	move.l	a3,a1
	moveq	#8,d0
	move.l	(a3),a3
	jsr	freemem(a6)
	bra	fpnd2
.done	rts

freeprocs	;free up all proc structs
	;
	move.l	firstproc,a2
	clr.l	firstproc
	move.l	4.w,a6
.loop	cmp	#0,a2
	beq	.done
	move.l	a2,a1
	move.l	(a2),a2
	moveq	#0,d0
	move.b	32(a1),d0
	jsr	freemem(a6)
	bra	.loop
.done	rts

freetypes	;free up type structs from a2 on
.loop	cmp	#0,a2
	beq	.done
	move.l	4(a2),a3
	cmp	#$ff,a3
	beq	.noway
	;
	;free offsets too
	;
	bsr	freevars2
	;
.noway	move.l	a2,a1
	move.l	(a2),a2
	moveq	#0,d0
	move.b	10(a1),d0
	move.l	4.w,a6
	jsr	freemem(a6)
	bra	.loop
.done	rts

fetchvar	;find/create variable/struct from namebuff
	;flagmask.0=1 if pointer
	;
	;get pointer to variable in a3, pointer to type in a2
	;
	jsr	usevars
	clr	added
	clr	varmode	;local mode
	move	procmode,d1
	bne	fvarlocal
	;
	lea	firstvar,a2
fvarback	bsr	findvar
.more	bne	fvaradd
	move.b	flagmask+1,d1
	move.b	7(a2),d3
	eor.b	d3,d1
	beq	fvarfound
	bsr	findlab
	bra	.more
fvaradd	move	nonew,d1
	bne	nonewerr
	bsr	addhere	;create var
	not	added	;set added flag
	move.l	a2,a3	
	move.l	defaulttype,a2
	cmp	#'.',d0
	beq	.clapton
	cmp	#'$',d0
	bne	.usedef
	lea	stringtype,a2
	bsr	getchar3
	bra	.usedef
.clapton	bsr	makename
	lea	alltypes,a2
	bsr	findtype
	bne	notypeerr
.usedef	cmp.l	#bytetype,a2
	beq	.byte
	move	varmode,d1
	bne	.pit
	addq	#1,varoff
.pit	bclr	#0,varoff+1
.byte	move.l	a2,10(a3)	;set type
	move	flagmask,6(a3)
	moveq	#4,d1
	btst	#0,flagmask+1
	bne	.skip3
	btst	#1,flagmask+1
	bne	.skip3
	cmp.l	#256,4(a2)
	bcc	.skip3
	move	8(a2),d1
.skip3	tst	varmode
	beq	.pit2
	neg	d1
	add	d1,varoff
	move	varoff,4(a3)	;loc offset
	rts
.pit2	move	varoff,4(a3)	;global
	add	d1,varoff
	rts

fvarlocal	lea	firstglob,a2
	bsr	findvar
.more	bne	.hendrix
	move.b	flagmask+1,d1
	move.b	7(a2),d3
	eor.b	d3,d1
	beq	fvarfound
	bsr	findlab
	bra	.more
.hendrix	move	#-1,varmode
	move	varoff,-(a7)
	move	locvaroff,varoff
	lea	firstlocal,a2
	bsr	fvarback
	move	varoff,locvaroff
	move	(a7)+,varoff
	rts

fvarfound	move.l	a2,a3
	;
	;var found, establish if type is correct!
	;
	cmp	#'.',d0
	beq	.skipsh
	cmp	#'$',d0
	bne	.skip4
	cmp.l	#stringtype,10(a3)
	bne	rongtypeerr
	bsr	getchar3
	bra	.skip4
.skipsh	bsr	makename
	lea	alltypes,a2
	bsr	findtype
	bne	notypeerr
	cmp.l	10(a3),a2
	bne	rongtypeerr
.skip4	btst	#0,flagmask+1
	beq	.skip4z
	;
	btst	#0,7(a3)
	beq	pointerr
	;
.skip4z	move.l	10(a3),a2
	rts

addd0a0	tst	d3
	beq	.done2a
	cmp	#9,d3
	bcc	.done3a
	and	#7,d3
	lsl	#8,d3
	lsl	#1,d3
	and	#$f1ff,addqa0
	or	d3,addqa0
	move	addqa0,d1
	bra	pokewd
.done3a	move	d3,leaa0a0+2
	move.l	leaa0a0,d1
	bsr	pokel
.done2a	rts

zarrchk	cmp.l	0(a5),d0
arrchk2	bcs	arrchk3
arrchkf	jsr	0
arrchk3

makeamul	;

makelmul	;make long multiply for array calc
	;
	move	regat,d2
	;
	move	arrmul1(pc),d1
	or	d2,d1
	subq	#1,d1
	bsr	pokewd
	move	arrmul2(pc),d1
	or	d2,d1
	move	d2,d3
	subq	#1,d3
	lsl	#8,d3
	lsl	#1,d3
	or	d3,d1
	bsr	pokewd
	move	arrmul3(pc),d1
	move	d2,d3
	lsl	#8,d3
	lsl	#1,d3
	or	d3,d1
	bsr	pokewda5s
	move	4+0(a7),d1
	addq	#2,d1
	bsr	pokewd
	;
	move	arrmul4(pc),d1
	move	d2,d3
	subq	#1,d3
	lsl	#8,d3
	lsl	#1,d3
	or	d3,d1
	bsr	pokewda5s
	move	4+0(a7),d1
	bsr	pokewd
	;
	move	arrmul5(pc),d1
	or	d2,d1
	subq	#1,d1
	bsr	pokewd
	move	arrmul6(pc),d1
	or	d2,d1
	subq	#1,d1
	bsr	pokewd
	move	arrmul7(pc),d1
	or	d2,d1
	subq	#1,d1
	move	d2,d3
	lsl	#8,d3
	lsl	#1,d3
	or	d3,d1
	bsr	pokewd
	move	arrmul8(pc),d1
	move	d2,d3
	subq	#1,d3
	lsl	#8,d3
	lsl	#1,d3
	or	d3,d1
	bsr	pokewd
	;
	move	regat,d1
	subq	#1,d1
	lsl	#8,d1
	lsl	#1,d1
	or	#$d080,d1
	or	regat,d1
	bra	pokewd

	;code for doing long array calculations.
	;d1.w=this subscript, d0.l=array offset
	;
	;do a x(a5).l * d1 + d0.l
	;
arrmul1	move.l	d0,-(a7)	;move.l d0,-(a7)
arrmul2	move	d0,d0	;move   d1,d0
arrmul3	mulu	0(a5),d0	;mulu   x+2(a5),d1	;lo*lo
arrmul4	mulu	0(a5),d0	;mulu   x(a5),d0	;hi*lo
arrmul5	swap	d0	;swap   d0
arrmul6	clr	d0	;clr    d0
arrmul7	add.l	d0,d0	;add.l  d0,d1
arrmul8	move.l	(a7)+,d0	;move.l (a7)+,d0

listcode1	move.l	0(a5),a2	;pointer to start of array data
listcode2	move.l	-32(a2),a2	;pointer to current
listarfix	addq	#8,a2

calcvar	;used to optimize this...no more!
	;
calcvar2	;use a3 = var, a2 = type, flagmask = flags.
	;
	;if bit 15 of d2 then code has been generated for
	;address of thing in a2. else d3=offset from a5
	;for simple variable.
	;
	;d2 & ff=type. 0=struct address
	;
	;bit 14 of d2=1 if result is a pointer
	;
	clr.l	lastoffset
	btst	#1,7(a3)
	beq	.notarr
	move	added,d1
	bne	noarrerr
	;
	bsr	getchar3
	cmp	#')',d0
	bne	.notalist
	;
	btst	#0,6(a3)
	beq	nolisterr
	move	4(a3),listcode1+2
	move.l	listcode1(pc),d1
	bsr	pokela5s
	move.l	listcode2(pc),d1
	bsr	pokel
	tst.b	debugga
	beq	.nolrerr
	;
	;a2=0 error check
	;
	move.l	a2,-(a7)
	move	#currentchk,d1
	bsr	tokejsr
	move.l	(a7)+,a2
	;
.nolrerr	move	listarfix(pc),d1	;addq #8,a2
				;skip node.
	bsr	pokewd
	bra	.normalar
	;
.listoff	dc	0
	;
.notalist	clr	.listoff
	btst	#0,6(a3)
	beq	.knob
	move	#8,.listoff	;adjust size of one element if list.
.knob	movem.l	a2-a3,-(a7)
	move	varmode,-(a7)
	move	8(a3),-(a7)	;number of dims
	move	4(a3),-(a7)	;varoff
	move.l	a2,-(a7)
	;
	move	flagmask,-(a7)
	bsr	bakup
	bsr	arreval
	move	(a7)+,flagmask
	;
	move	8(a7),varmode
	tst.b	debugga
	beq	.noszchk
	bsr	arrszchk
.noszchk	move.l	(a7)+,a2
	moveq	#4,d1
	btst	#0,flagmask+1	;pointer?
	bne.s	.domul		;yes, then use 4 byte mul...
	move	8(a2),d1
.domul	add	.listoff(pc),d1
	bsr	muld1
	addq	#1,regat
	;
.arloop	addq	#4,(a7)
	tst	4(a7)
	beq	.isglob
	subq	#8,(a7)
.isglob	tst.b	debugga
	beq	.noer1
	;
	move	regat,d1
	subq	#1,d1
	lsl	#8,d1
	lsl	#1,d1
	or	zarrchk(pc),d1
	bsr	pokewda5s	;cmp.l x(a5),D regat
	move	(a7),d1
	bsr	pokewd
	move.l	arrchk2(pc),d1
	bsr	pokel
	move	#arrerr,d1
	bsr	tokejsr
	;
.noer1	subq	#1,2(a7)
	beq	.ardone
	;
	cmp	#',',d0
	bne	syntaxerr
	bsr	arrevalchk
	move	4(a7),varmode
	bsr	makeamul
	bra	.arloop
	;
.ardone	cmp	#')',d0
	bne	syntaxerr
	subq	#1,regat
	addq	#6,a7
	movem.l	(a7)+,a2-a3
	move	4(a3),movea5a0+2
	move.l	movea5a0,d1
	bsr	pokela5s
	move	regat,d1
	or	#$d5c0,d1	;add.l Dr,a2
	bsr	pokewd
	btst	#0,6(a3)
	beq	.normalar
	;
	;addq #8,a2 to skip node.
	;
	move	listarfix(pc),d1
	bsr	pokewd
	;
.normalar	bsr	getchar3
	;
	;this shit added lately - after the major fucking crash!
	;
	btst	#0,7(a3)
	beq	.noppnt
	;
	cmp	#'\',d0
	bne	.pmskip
	move	.pfix(pc),d1
	bsr	pokewd
	;
.noppnt	move	#$8000,d2
	bra	.loopm1
	;
.pmskip	move	#$c000,d2
	bra	.loopm1
	;
.pfix	move.l	(a2),a2
	;
.notarr	cmp	#'(',d0
	beq	noarrerr
	cmp.l	#256,4(a2)
	bcs	.simpvar
	btst	#0,7(a3)
	beq	.notap
	;
	;it's a pointer - is it a simple one?
	;
	cmp	#'\',d0
	beq	.notap
	moveq	#0,d2
	bra	.simpvar2
	;
.notap	move	#$8000,d2
	move	4(a3),movea5a0+2
	move.l	movea5a0,d1
	bsr	pokela5s	;move.l x(a5),a2
.loopm1	moveq	#0,d3
.loop0	cmp	#'\',d0
	bne	.done
	cmp.l	#256,4(a2)	;?
	bcs	rongtypeerr	;?
	move	d2,-(a7)
	bsr	makename
	beq	syntaxerr
	addq	#4,a2
	bsr	findvar
	bne	noofferr
	move	(a7)+,d2
	;
	move.l	a2,a3	;pointer to offset
	move.l	10(a3),a2	;pointer to type
	add	4(a3),d3
	move.l	a3,lastoffset
	;
	cmp	#'[',d0
	bne	.realdone
	btst	#1,7(a3)
	beq	rongtypeerr
	bsr	addd0a0
	;
	movem.l	a2-a3,-(a7)
	move	varmode,-(a7)
	move.l	lastoffset,-(a7)
	move	pusha2,d1
	bsr	pokewd
	;
	moveq	#2,d2
	bsr	eval
	cmp	#']',d0
	bne	syntaxerr
	;
	move	pulla2,d1
	bsr	pokewd
	move.l	(a7)+,lastoffset
	move	(a7)+,varmode
	movem.l	(a7)+,a2-a3
	;
	;[] ***** error checking here! *****
	;
	;8(a3) = how many we can handle. special case for 0!
	;
	tst	debugga
	beq.s	.nobchk
	move	8(a3),d1
	beq.s	.nobchk	;no [0] checks!
	;
	;ok, check regat<8(a3)
	;
	move	d1,brchkcode+2
	move	regat,d1
	lsl	#8,d1
	lsl	#1,d1
	or	brchkcode0(pc),d1
	move	d1,brchkcode
	move.l	brchkcode(pc),d1
	bsr	pokel
	move.l	brchkcode+4(pc),d1
	bsr	pokel
	move	brchkcode+8(pc),d1
	bsr	pokewd
.nobchk	;
	moveq	#4,d1
	btst	#0,7(a3)
	bne	.dothemul
	move	8(a2),d1
.dothemul	bsr	muld1
	move	addrega2,d1
	or	regat,d1
	bsr	pokewd
	bsr	getchar3
	moveq	#0,d3
	move	#$8000,d2
	;
.realdone	btst	#0,7(a3)
	bne	.pointer
	bra	.loop0
	;
.pointer	cmp	#'\',d0
	bne	.done3
	tst	d3
	bne	.pskip
	move	movea0,d1
	bsr	pokewd
	bra	.pmore
.pskip	move	d3,movea0a0+2
	move.l	movea0a0,d1
	bsr	pokel
.pmore	btst	#2,7(a3)
	beq	.loopm1
	move.l	adda0a0,d1
	bsr	pokel
	bra	.loopm1
.done3	bset	#14,d2
	btst	#2,7(a3)
	bne	.done
	bset	#13,d2
.done	cmp.l	#256,4(a2)
	bcc	.done2
	move.b	7(a2),d2
.done2	bra	addd0a0

.simpvar	move	6(a2),d2
.simpvar2	move	4(a3),d3
	btst	#0,7(a3)
	beq	.nopoint
	bset	#14,d2
.nopoint	rts

brchkcode0	cmp	#0,d0
	;
brchkcode	cmp	#0,d0
	bcs.s	.ok
	moveq	#2,d0
	trap	#0
.ok	;

;-----------Poking to Object code stuff-------------------;

pokewda5s	tst	varmode
	beq	pokewd
	bclr	#0,d1
	bra	pokewd

pokewda5d	tst	varmode
	beq	pokewd
	bclr	#9,d1
	bra	pokewd

pokela5d	tst	procmode
	beq	pokel
	bclr	#25,d1
	bra	pokel

pokela5s	tst	varmode
	beq	pokel
	bclr	#16,d1
	;
pokel	swap	d1
	bsr	pokewd
pokelc	swap	d1
	;
pokewd	;poke d1.w into pc - not an opcode
	;
	addq.l	#1,pc
	bclr	#0,pc+3
	move.l	pc,a4
	cmp.l	libat,a4
	bcc	.over
	move	d1,(a4)+	
.ms	move.l	a4,pc
	cmp.l	bigpc(pc),a4
	bhi	.nbp	
	rts
.nbp	tst	cfetchmode
	bne	.nbp2
	move.l	a4,bigpc
.nbp2	rts
.over	move	#-1,nomemleft
	addq	#2,a4
	bra	.ms

pokebyte	move.l	pc,a4
	cmp.l	libat,a4
	bcc	.over
	move.b	d1,(a4)+
.ms	move.l	a4,pc
	cmp.l	bigpc(pc),a4
	bhi	.nbp
	rts
.nbp	tst	cfetchmode
	bne	.nbp2
	move.l	a4,bigpc
.nbp2	rts
.over	move	#-1,nomemleft
	addq	#1,a4
	bra	.ms

bigpc	dc.l	0

pokecode	;a0=start of code to poke, a1=end
	;
	move	(a0)+,d1
	bsr	pokewd
.loop	cmp.l	a1,a0
	bcc	.done
	move	(a0)+,d1
	bsr	pokewd
	bra	.loop
.done	rts

pokecode2	move	(a0)+,d1
	bsr	pokewd
	cmp.l	a1,a0
	bcs	pokecode2
	rts

;-----------End of poking to Object code------------------;

bytetoword	;
	rts
	;
	;Below should ALWAYS be done when something is fetched
	;
;	move	#$4880,d1
;	or	regat(pc),d1
;	bra	pokewd
bytetolong	;
	bsr	bytetoword
wordtolong	move	#$48c0,d1
	or	regat,d1
	bra	pokewd
bytetoquick	;
	bsr	bytetoword
wordtoquick	move	#$4840,d1
	or	regat,d1
	bsr	pokewd
	move	#$4240,d1
	or	regat,d1
	bra	pokewd
bytetofloat	;
	bsr	bytetolong
bytetof2	move	#-36,d1
fdo2	move	d1,libjsr+2
	bsr	savereg
	move.l	d4,d1
	bsr	pokemovem
	move	#getffpbase,d1
	bsr	tokejsr
	bsr	ritetod0
	move.l	libjsr,d1
	bsr	pokel
	bsr	ritefromd0
	move.l	d5,d1
	bra	pokemovem
	rts
wordtobyte	;
	move	#wtobover,d1
	;
overchk	;d1=overflow check routine.
	tst.b	debugga
	beq	.skip
	btst	#7,optreq2ga4+13	;*** was 7! overflow checking?
	beq	.skip
	;
	tst	cfetchmode
	bne	.skip
	;	
	tst	regat
	beq	.isok
	move	d1,-(a7)
	move	.code1(pc),d1
	bsr	pokewd
	move	regat,d1
	or	.code3(pc),d1
	bsr	pokewd
	move	(a7)+,d1
	bsr	.isok
	move	.code2(pc),d1
	bra	pokewd
	;
.isok	movem.l	d0-d7/a0-a6,-(a7)
	bsr	tokejsr
	movem.l	(a7)+,d0-d7/a0-a6
	;
.skip	rts
.code1	move.l	d0,-(a7)
.code2	move.l	(a7)+,d0
.code3	move.l	d0,d0

wordtofloat	;
	bsr	wordtolong
	bra	bytetof2
longtobyte	;
	move	#ltobover,d1
	bra	overchk
longtoword	;
	move	#ltowover,d1
	bra	overchk
longtoquick	;
	move	#ltowover,d1
	bsr	overchk
	bra	wordtoquick
longtofloat	;
	bra	bytetof2
	rts
quicktobyte	;
	move	#qtobover,d1
	bsr	overchk
	;
quicktob2	move	#$4240,d1
	or	regat,d1
	bsr	pokewd
	move	#$4840,d1
	or	regat,d1
	bra	pokewd
quicktoword	;
	bra	quicktob2
quicktolong	;
	bsr	quicktob2
	bra	wordtolong
quicktofloat;
	;put my own routine here
	;
	move	#qutofl,d1
qtof2	move	d1,-(a7)
	bsr	savereg
	move.l	d4,d1
	bsr	pokemovem
	;
	bsr	ritetod0
	move	(a7)+,d1
	bsr	tokejsr
	;
	bsr	ritefromd0
	move.l	d5,d1
	bra	pokemovem
	rts
floattobyte	;
	move	#ftobover,d1
	bsr	overchk
	;
	bsr	floattolong2
	bra	longtobyte
	rts
floattoword	;
	move	#ftowover,d1
	bsr	overchk
	;
	bsr	floattolong2
	bra	longtoword
	rts
floattolong	;
	move	#ftolover,d1
	bsr	overchk
floattolong2
	move	#-30,d1
	bra	fdo2
	rts
floattoquick;
	;do my own routine here for float to quick conversion
	;
	move	#ftowover,d1
	bsr	overchk
	;
	move	#fltoqu,d1
	bra	qtof2
stringtolong;
	move	stol(pc),d1
	bsr	pokewd
	bra	sbtolong

convtypef	;as below, but regat+1 should be saved!
	;
	addq	#1,fuckpos
	bsr	convtype
	subq	#1,fuckpos
	rts

convtype	;convert type d3 to d2
	move	d3,d1
	subq	#1,d1
	mulu	#7,d1
	add	d2,d1
	subq	#1,d1
	lsl	#2,d1
	lea	convtable,a0
	move.l	0(a0,d1),d1
	beq	.skip
	move.l	d1,a0
	jmp	(a0)
.skip	rts

usedfrom	dc.l	0

getvname	;transfer chars to namebuff. set flagmask according
	;to array/pointer etc status
	;
	cmp	#'\',d0
	bne	.skip0
	subq	#1,a5
	move.l	a5,usedfrom
	lea	usedpath,a5
	bsr	getchar3
	;
.skip0	clr	flagmask
	cmp	#'*',d0
	bne	.skip
	move	#1,flagmask
.more2	bsr	makename
.more	beq	syntaxerr
	cmp	#'(',d0
	beq	.setmask
	cmp	#'.',d0
	beq	.morem
	cmp	#'$',d0
	bne	.done
	or	#8,flagmask
	bsr	storeloc
	bsr	getchar3
	bra	.morez
	;
.morem	bsr	storeloc
	move	d2,-(a7)
	lea	namebuff2,a1
	bsr	makename3
	beq	syntaxerr
	move	(a7)+,d2
.morez	move	d0,d1
	bsr	resloc
	cmp	#'(',d1
	bne	.done
.setmask	or	#2,flagmask
.done	rts
.skip	cmp	#'@',d0
	bne	.skip2
	move	#5,flagmask
	bra	.more2
.skip2	bsr	makename2
	bra	.more

dopusha3	move	#65235,d1
	bsr	uselib
	lea	pusha3,a0
	lea	pusha3f,a1
	bra	pokecode

dopulla3	move	#65235,d1
	bsr	uselib
	lea	pulla3,a0
	lea	pulla3f,a1
	bra	pokecode

ceos	clr.b	(a3)+	;*!

sbtolong	;make sbase into a long
	;
	move	ceos(pc),d1
	bsr	pokewd	;clr.b (a3)
	;
	move	regat,d1
	lsl	#8,d1
	lsl	#1,d1
	cmp	#2,sbgot
	bcs	.skip2
	move	stackuse,d3
	sub	thisstuse,d3
	cmp	#6,d3
	bne	.lenonly
	or	movestst2,d1
	bsr	pokewd
	lea	movestst2+2,a0
	lea	movestst2f,a1
	bra	pokecode2
	;
.lenonly	or	movea7dn,d1
	bsr	pokewd
	move.l	movea7dn+2,d1
	bra	pokel
	;
.skip2	or	movestdn,d1
	bsr	pokewd
	move	#65235,d1
	bsr	uselib
	move	10(a1),d1
	bra	pokewd

unknown	dc	0

somecode	cmpi.l	#65536,d0
somecode2	bcs	codeisok
	jsr	0
	;
codeisok

arrevalchk	tst.b	debugga
	beq	sharreval
	bsr	arreval
arrszchk	move	somecode(pc),d1
	or	regat,d1
	bsr	pokewd
	moveq	#1,d1
	swap	d1
	bsr	pokel
	move.l	somecode2(pc),d1
	bsr	pokel
	move	#arrerr,d1
	bra	tokejsr

sharreval	moveq	#2,d2
	moveq	#0,d1
	moveq	#0,d3
	bra	maineval2

arreval	moveq	#3,d2	;getlong
	moveq	#0,d1	;no push
	moveq	#0,d3	;and convert
	bra	maineval2	;2!*

bakpevalu	bsr	bakup
	;
pevalu	moveq	#-1,d1
	moveq	#-1,d3
	bra	peval

bakpeval	bsr	bakup
	;
peval	moveq	#-1,d1
	moveq	#0,d3
	bra	maineval

bakevalu	bsr	bakup
	;
evalu	moveq	#0,d1
	moveq	#-1,d3
	bra	maineval

evalu2	moveq	#1,d1
	moveq	#-1,d3
	bra	maineval

bakeval	bsr	bakup
	;
eval:	moveq	#0,d1	;no push
	moveq	#0,d3
	;
maineval	;Big Evaluation routine.....
	;
	;d2 = type to collect - 0 if unknown
	;
	;d3 = 0 if conv to original type
	;
	;d1 = push result flag, 0 = no push, < 0 = push result
	;     > 0 = push type when known
	;
	;result will be pushed anyway if using reg d6+
	;
	;if getting a string, then strings len is on stack
	;(a long), and a3 points at arse end of string
	;while D(regat) points to start of string
	;
	cmp	#6,regat
	bcs	maineval2
	moveq	#-1,d1
	move	#6,regat
maineval2	;
	;d2=type to get, d1=push flag (should I push result?)
	;
	move	thisstuse,-(a7)
	move	stackuse,thisstuse
	;
	move	pushflag,-(a7)
	move	d1,pushflag
	move	sbgot,-(a7)
	clr	sbgot	;not pushed yet
	move	unknown(pc),-(a7)
	move	d3,unknown
	;
	move	d2,-(a7)
	bsr	eval3
	move	(a7)+,d3	;type asked for
	beq	.noconv
	move	unknown(pc),d1
	bne	.noconv
	exg	d2,d3
	bsr	convtype
.noconv	;
	move	(a7)+,unknown
	move	pushflag,d1
	beq	.skipme
	bmi	.skipme
	;
	;push the type got.
	;
	move	regat(pc),d1
	lsl	#8,d1
	lsl	#1,d1
	cmp	#7,d2
	bne	.hi1
	move	d1,-(a7)
	or	getstlen,d1
	bsr	pokewd
	move	(a7)+,d1
	;
.hi1	addq	#2,stackuse
	or	#$7000,d1
	add	#$0200,d1	;moveq #x,dREGAT+1
	or	d2,d1
	bsr	pokewd
	move	pushut(pc),d1
	or	regat(pc),d1
	addq	#1,d1
	bsr	pokewd
	;
	cmp	#7,d2
	bne	.skipme
	move	putstlen(pc),d1
	or	regat(pc),d1
	bsr	pokewd
	;
.skipme	cmp	#7,d2
	bne	.notst
	;
	addq	#4,stackuse	;a length on da stack.....
	bsr	sbtolong
	bra	.notst2
.notst	;
	cmp	#2,sbgot
	bcs	.notst2
	move	ststfix(pc),d1
	bsr	pokewd	
	;
.notst2	move	(a7)+,sbgot
	;
	move	pushflag,d1
	bpl	.skip
	addq	#2,stackuse
	move	pushd0wd,d1
	cmp	#3,d2
	bcs	.ok
	addq	#2,stackuse
	move	pushd0l,d1
.ok	or	regat,d1
	bsr	pokewd
.skip	move	(a7)+,pushflag
	move	(a7)+,thisstuse
	rts

thisstuse	dc	0

ststfix	addq	#4,a7

pushut	move	d0,-(a7)

eval3	bsr	eval4
	sub.l	#18,forthsp
	rts
	
eval4	;
	moveq	#1,d1
	bsr	pushprec
	;
	bsr	eval5
	tst	d1
	bne	syntaxerr
	;
	subq.l	#6,precsp	;pop the prec set up
	rts

eval5	bsr	eval2
.more	move.l	precsp(pc),a1
	cmp	-(a1),d1
	bhi	.higher
	rts

.higher	bsr	pushprec
	;
	move	d2,-(a7)
	addq	#1,regat
	bsr	eval5
	subq	#1,regat
	move	(a7)+,d3
	movem.l	d1/a0,-(a7)
	beq	.skip
	bsr	convtypef	;could possibly fuck regat+1 !
.skip	bsr	popprec
	bsr	doop
	;
	;O.K., lets check the forth stack to see if last
	;two operators are constants!
	;
	;if so, we can JSR the routine to optimize into a constant!
	;
	move.l	forthsp(pc),a0
	move	-2(a0),d1
	or	-20(a0),d1
	move	d1,-20(a0)
	bne	.no
	move	nomemleft,d1
	bne	.no
	;
	;YES! We can do it!
	;
	;Set up MOVE.l regat,d0
	;
	move	#$2000,d1
	or	regat(pc),d1
	bsr	pokewd
	move	#$4e75,d1
	bsr	pokewd
	move	-24(a0),lasta6	
	move.l	-28(a0),lasta6
	move.l	-36(a0),a0
	move.l	a0,pc
	;
	movem.l	d2/a5,-(a7)
	;
	move.l	maths,a6
	move.l	ffplib,a1
	move	10(a1),d0
	lea	maths,a5
	sub	d0,a5
	;
	bsr	flushc
	jsr	(a0)
	;
	movem.l	(a7)+,d2/a5
	;
	;d0 has got constant!
	;
	move	regat(pc),d1
	lsl	#8,d1
	lsl	#1,d1
	or	#$203c,d1	;move.l #x,dn
	cmp	#3,d2
	bcc	.ok
	or	#$1000,d1
	bsr	pokewd
	move	d0,d1
	bsr	pokewd
	bra	.mode
.ok	bsr	pokewd
	move.l	d0,d1
	bsr	pokel
	;
.mode	;Move #x,Dn
	;
	;clean up offset stack
	;
	move.l	forthsp(pc),a0
	move.l	-32(a0),a3
	move.l	firstoff,a2
	move.l	a3,firstoff
	move.l	4.w,a6
.loop	cmp.l	a3,a2
	beq	.done
	subq.l	#1,numoffs
	move.l	a2,a1
	move.l	(a2),a2
	moveq	#8,d0
	jsr	freemem(a6)
	bra	.loop
.done	move.l	forthsp(pc),a0
	;
.no	lea	-18(a0),a0
	move.l	a0,forthsp
	;
	movem.l	(a7)+,d1/a0
	bsr	reget
	bra	.more

eval2	;
	;get 1 element and operator
	;d1=op prec, or 0 if .done
	;a0=operator address
	;
	bsr	getelement
	;
	lea	operators,a0
.loop	tst	(a0)
	beq	.done
	cmp	(a0),d0
	beq	.found
	lea	32(a0),a0
	bra	.loop
.done	moveq	#0,d1
	rts
.found	;
	cmp	#'<',d0
	bne	.notlt
	bsr	getchar3
	cmp	#'=',d0
	bne	.notlteq
	lea	ople,a0
	bra	.found2
.notlteq	cmp	#'>',d0
	bne	.found3
	bra	.isne
	;
.notlt	cmp	#'>',d0
	bne	.notgt
	bsr	getchar3
	cmp	#'=',d0
	bne	.notgteq
	lea	opge,a0
	bra	.found2
.notgteq	cmp	#'<',d0
	beq	.isne
.found3	bsr	bakup
	bra	.found2
	;
.notgt	cmp	#'=',d0
	bne	.found2
	bsr	getchar3
	cmp	#'>',d0
	bne	.noteqgt
	lea	opge,a0
	bra	.found2
.noteqgt	cmp	#'<',d0
	bne	.found3
.isne	lea	opne,a0
	;
.found2	;	
	;We've found the operator.
	;
	move	30(a0),d1
	rts

doop	;a0=operator,d2=type
	;
	move	d2,d1
	subq	#1,d1
	bmi	illoperr
	lsl	#2,d1
	move.l	2(a0,d1),d1
	beq	illoperr
	move.l	d1,a0
	jmp	(a0)

pushprec	;push operator on stack
	;
	move.l	precsp(pc),a1
	move.l	a0,(a1)+
	move	d1,(a1)+
	move.l	a1,precsp	
	rts

popprec	;pull precedence into d1 from stack
	;
	move.l	precsp(pc),a1
	cmp.l	#precstackf,a1
	bcc	pserr
	move	-(a1),d1
	move.l	-(a1),a0
	move.l	a1,precsp
	rts

precsp	dc.l	precstack

precstack	ds	6*32	;Lotsa Room?
precstackf	;

;-----------PLUS------------;

mseq	seq	d0
msne	sne	d0
mslt	slt	d0
msle	sle	d0
msgt	sgt	d0
msge	sge	d0

cmp0	cmp.b	d0,d0
cmp1	cmp	d0,d0
cmp2	cmp.l	d0,d0

doeqb	move	cmp0(pc),d1
	bra	doeqcmp2
doneb	move	cmp0(pc),d1
	bra	donecmp2
doltb	move	cmp0(pc),d1
	bra	doltcmp2
doleb	move	cmp0(pc),d1
	bra	dolecmp2
dogtb	move	cmp0(pc),d1
	bra	dogtcmp2
dogeb	move	cmp0(pc),d1
	bra	dogecmp2

doeqw	move	cmp1(pc),d1
	bra	doeqcmp2
donew	move	cmp1(pc),d1
	bra	donecmp2
doltw	move	cmp1(pc),d1
	bra	doltcmp2
dolew	move	cmp1(pc),d1
	bra	dolecmp2
dogtw	move	cmp1(pc),d1
	bra	dogtcmp2
dogew	move	cmp1(pc),d1
	bra	dogecmp2

doeql	move	cmp2(pc),d1
	bra	doeqcmp2
donel	move	cmp2(pc),d1
	bra	donecmp2
doltl	move	cmp2(pc),d1
	bra	doltcmp2
dolel	move	cmp2(pc),d1
	bra	dolecmp2
dogtl	move	cmp2(pc),d1
	bra	dogtcmp2
dogel	move	cmp2(pc),d1
	bra	dogecmp2

cfregat	dc	0
docflib	move	d1,libjsr+2
	bsr	savereg
	move.l	d4,d1
	bsr	pokemovem
	move	#getffpbase,d1
	bsr	tokejsr
	bsr	ritetod0
	move.l	libjsr,d1
	bsr	pokel
	move	regat,cfregat
	clr	regat
	rts

docflib2	move	cfregat,regat
	bsr	ritefromd0
	move.l	d5,d1
	bra	pokemovem


doeqf	moveq	#-42,d1
	bsr	docflib
	bsr	doeqcmp
	bra	docflib2
donef	moveq	#-42,d1
	bsr	docflib
	bsr	donecmp
	bra	docflib2
doltf	moveq	#-42,d1
	bsr	docflib
	bsr	doltcmp
	bra	docflib2
dolef	moveq	#-42,d1
	bsr	docflib
	bsr	dolecmp
	bra	docflib2
dogtf	moveq	#-42,d1
	bsr	docflib
	bsr	dogtcmp
	bra	docflib2
dogef	moveq	#-42,d1
	bsr	docflib
	bsr	dogecmp
	bra	docflib2

doeqs	move	#strcomp,d1
	bsr	tokejsr
	bra	doeqcmp
dones	move	#strcomp,d1
	bsr	tokejsr
	bra	donecmp
dolts	move	#strcomp,d1
	bsr	tokejsr
	bra	doltcmp
doles	move	#strcomp,d1
	bsr	tokejsr
	bra	dolecmp
dogts	move	#strcomp,d1
	bsr	tokejsr
	bra	dogtcmp
doges	move	#strcomp,d1
	bsr	tokejsr
	bra	dogecmp

cmpit	move	regat,d3
	or	d3,d1
	lsl	#8,d3
	lsl	#1,d3
	or	d3,d1
	addq	#1,d1
	bra	pokewd
	
doeqcmp2	bsr	cmpit
doeqcmp	move	mseq(pc),d1
	bra	cpoke

donecmp2	bsr	cmpit
donecmp	move	msne(pc),d1
	bra	cpoke

doltcmp2	bsr	cmpit
doltcmp	move	mslt(pc),d1
	bra	cpoke

dolecmp2	bsr	cmpit
dolecmp	move	msle(pc),d1
	bra	cpoke

dogtcmp2	bsr	cmpit
dogtcmp	move	msgt(pc),d1
	bra	cpoke

dogecmp2	bsr	cmpit
dogecmp	move	msge(pc),d1
cpoke	or	regat(pc),d1
	bsr	pokewd
	move	#$4880,d1		;ext.w D regat
	or	regat(pc),d1
	bsr	pokewd		
	;
	moveq	#2,d2	;type now WORD!
	rts

;doplusb	move	#$d000,d1
;	bra	doplus2

doplusb	move	#$d040,d1
	moveq	#2,d2	;now a word
	bra 	doplus2
doplusw	move	#$d040,d1
	moveq	#3,d2	;now a long
	bsr	doplus2
	bra	wordtolong
doplusl	;add regat+1 to regat
	move	#$d080,d1
doplus2	move	regat,d3
	or	d3,d1
	addq	#1,d1
	lsl	#8,d3
	lsl	#1,d3
	or	d3,d1
	bra	pokewd

doplusf	;
	;ffp add
	;
	move	#-66,d1
doflib	move	d1,libjsr+2
	bsr	savereg
	move.l	d4,d1
	bsr	pokemovem
	move	#getffpbase,d1
	bsr	tokejsr
	bsr	ritetod0
	move.l	libjsr,d1
	bsr	pokel
	bsr	ritefromd0
	move.l	d5,d1
	bra	pokemovem

addstrings	move	regat,d1
	lsl	#8,d1
	lsl	#1,d1
	move	d1,-(a7)
	or	addcode,d1
	bsr	pokewd
	move	(a7)+,d1
	or	addcode+2,d1
	bra	pokewd

;-----------end of PLUS, start of MINUS---------;
	
dominusb	move	#$9040,d1
	;moveq	#2,d2	;now a word!
	bra	doplus2
dominusw	move	#$9040,d1
	;moveq	#3,d2	;now a long
	bra	doplus2
dominusl	move	#$9080,d1
	bra	doplus2
dominusf	move	#-72,d1	
	bra	doflib

;-----------end of MINUS, start of TIMES---------;

;dotimesb	move	#$48c0,d1
;	or	regat(pc),d1
;	bsr	pokewd
;	addq	#1,d1
;	bsr	pokewd
;	bsr	dotimesw
;	moveq	#2,d2	;now a word
;	rts

dotimesb	move	#$c1c0,d1
	moveq	#2,d2	;now a word
	bra	doplus2
	
dotimesw	move	#$c1c0,d1
	moveq	#3,d2	;now a long.
	bra	doplus2

dotimesq	move	#quickmult,d1
	bra	domylib

dotimesl	move	#longmult,d1
domylib	move	d1,-(a7)
	bsr	savereg
	move.l	d4,d1
	bsr	pokemovem
	bsr	ritetod0
	move	(a7)+,d1
	bsr	tokejsr
	bsr	ritefromd0
	move.l	d5,d1
	bra	pokemovem

dotimesf	move	#-78,d1
	bra	doflib

dopow	move	d2,-(a7)
	move	d2,d3
	moveq	#5,d2	;now a float
	bsr	convtypef
	addq	#1,regat
	move	(a7)+,d3
	moveq	#5,d2
	bsr	convtype
	subq	#1,regat
	bsr	nocando
	move	#mathq*128+1,d1
	bra	domylib

nocando	;can't eval this as a const!
	;
	move.l	forthsp(pc),a0
	move	#-1,-(a0)
	rts

;-----------end of times, start of mod-------;

domodb	move	#modbyte,d1
	bra	domylib

domodw	move	#modword,d1
	bra	domylib

domodl	bsr	nocando	;modlib uses an alibjsr here!
	move	#modlong,d1
	bra	domylib

domodq	move	#modquick,d1
	moveq	#2,d2	;now a word.
	bra	domylib

domodf	bsr	nocando	;modlib lib uses an alibjsr!
	move	#modfloat,d1
	moveq	#3,d2	;now a long
	bra	domylib

;-----------end of mod, start of POWER OF----;

;-----------end of mod, start of DIVIDE------;

dodivb	move	#$48c0,d1
	or	regat,d1
	bsr	pokewd
	addq	#1,d1
	bsr	pokewd
	;
dodivw	move	#$48c0,d1	;ext.l Dn
	or	regat,d1
	bsr	pokewd
	move	#$81c0,d1
	bra	doplus2
dodivl	move	#longdiv,d1
	bra	domylib
dodivq	move	#quickdiv,d1
	bra	domylib
dodivf	move	#-84,d1
	bra	doflib

;-----------end of DIVIDE, start of AND-----------;

doandb	move	#$c000,d1
	bra	doplus2
doandw	move	#$c040,d1
	bra	doplus2
doandl	move	#$c080,d1
	bra	doplus2

;-----------end of AND, start of OR---------------;

doorb	move	#$8000,d1
	bra	doplus2
doorw	move	#$8040,d1
	bra	doplus2
doorl	move	#$8080,d1
	bra	doplus2

;-----------end if OR, start of EOR---------------;

doeorb	move	#$b100,d1
	;
doeor2	move	regat,d3
	or	d3,d1
	addq	#1,d3
	lsl	#8,d3
	lsl	#1,d3
	or	d3,d1
	bra	pokewd
doeorw	move	#$b140,d1
	bra	doeor2
doeorl	move	#$b180,d1
	bra	doeor2

;-----------end of OR, start of LSL---------------;

dolslb	;
dolslw	;
dolsll	move	#$e1a8,d1
	bra	shpoke

;-----------end of LSL, start of LSR--------------;

dolsrb	;	andi.l #255,regat
dolsrw	;	andi.l #$ffff,regat
dolsrl	move	#$e0a8,d1
	bra	shpoke

;-----------end of LSR, start of ASR--------------;

doasrb	;
doasrw	;
doasrl	move	#$e0a0,d1
	bra	shpoke

;-----------end of ASR----------------------; 

shpoke	move	d1,-(a7)
	addq	#1,regat	;make second a word!
	move	d2,-(a7)
	move	d2,d3
	moveq	#2,d2
	bsr	convtype
	move	(a7)+,d2	;type
	subq	#1,regat
	cmp	#4,d2	;don't fuck with quix
	beq	.skip
	move	d2,d3
	moveq	#3,d2
	bsr	convtypef	;make first (and current) a long
.skip	move	(a7)+,d1
	;
	move	regat,d3
	or	d3,d1
	addq	#1,d3
	lsl	#8,d3
	lsl	#1,d3
	or	d3,d1
	bra	pokewd

;-----------start of bittst-----------------;

bittst	move	#$100,d1
	bsr	dothebit
	;
	move	regat,d1
	or	#$56c0,d1		;sne regat
	bsr	pokewd
	;
	move	regat,d1
	or	#$4880,d1		;ext.w D regat
	bsr	pokewd		
	;
	moveq	#2,d2	;type now WORD!
	rts

bitset	move	#$1c0,d1
	;
dobitmip	bsr	dothebit
	;
	moveq	#3,d2	;type now LONG!
	rts

bitclr	move	#$180,d1
	bra	dobitmip

bitchg	move	#$140,d1
	bra	dobitmip

dothebit	move	d1,-(a7)
	;
	;make first a long
	;
	move	d2,-(a7)
	move	d2,d3
	moveq	#3,d2	;first to long!
	bsr	convtypef
	;
	move	(a7)+,d3
	moveq	#1,d2	;second to byte!
	addq	#1,regat
	bsr	convtype
	subq	#1,regat
	;
	move	regat,d1
	move	d1,d2
	addq	#1,d2
	lsl	#8,d2
	lsl	#1,d2
	or	(a7)+,d1
	or	d2,d1
	bra	pokewd		;btst regat+1,regat

ritetod0	;put regat to d0
	;
	move	regat,d1
	beq	.skip
	or	#$2000,d1
	bsr	pokewd
	add	#$201,d1
	bsr	pokewd
.skip	rts

ritefromd0	;get regat from d0
	;
	move	regat,d1
	beq	.skip
	lsl	#8,d1
	lsl	#1,d1
	or	#$2000,d1
	bsr	pokewd
.skip	rts

getelement	cmp	#7,regat
	bcs	getelement2
	move	#$3f06,d1
	cmp	#3,d2
	bcs	.skip
	move	#$2f06,d1
.skip	bsr	pokewd
	move	d1,-(a7)
	;
	subq	#1,regat
	bsr	getelement2
	addq	#1,regat
	;
	move	#$3e06,d1
	cmp	#3,d2
	bcs	.skip2
	move	#$2e06,d1
.skip2	bsr	pokewd
	;
	move	(a7)+,d1
	and	#$f000,d1
	or	#$c1f,d1
	bra	pokewd

negate	bsr	getelement2
	move	#$4440,d1
	cmp	#3,d2
	bcs	.doneg
	move	#$4480,d1
	cmp	#5,d2
	bcs	.doneg
	cmp	#6,d2
	bcc	illoperr
	move	#-60,d1
	bra	fdo2
.doneg	or	regat,d1
	bra	pokewd

bracket	bsr	eval4
	cmp	#')',d0
	beq	.done
	cmp	#'}',d0
	bne	syntaxerr
.done	bra	getchar3

notit	;do NOT.
	;
	bsr	eval4
	cmp	#5,d2
	bcc	illoperr
	move	regat,d1
	or	#$4640,d1	;not.w
	cmp	#3,d2
	bcs	pokewd
	eor	#$c0,d1
	bra	pokewd

fetchpi	moveq	#5,d2	;return Pi.f
	move	regat,d1
	lsl	#8,d1
	lsl	#1,d1
	or	#$203c,d1
	bsr	pokewd	;move.l #x,dn
	move.l	#$c90fda42,d1
	bsr	pokel
	bra	getchar3

	;stack contains.....
	;pc.l,firstoff.l,optat.l,lasta6.w,0,constgot.w!
	;
	;18 bytes!

forthstack	ds.b	18*32
forthsp	dc.l	forthstack

getelement2	;
	;recursive stuff first.....
	;
	bsr	getchar3
	cmp	#'(',d0
	beq	bracket
	cmp	#'{',d0
	beq	bracket
	cmp	#'-',d0
	beq	negate
	cmp	#(opnot-opabcd)/$1c+$8000+fnum,d0
	beq	notit
	;
	move.l	forthsp(pc),a1
	cmp.l	#forthsp,a1
	bcc	conmemerr
	;
	move.l	pc,(a1)+
	move.l	firstoff,(a1)+
	move.l	lasta6,(a1)+
	move	lasta6,(a1)+
	clr	(a1)+
	;
	clr	(a1)+
	move.l	a1,forthsp
	;
	;First, we have stuff which won't fuck constgot
	;
	bsr	tstnum
	beq	fetchnum
	cmp	#'.',d0
	beq	fetchfrac
	cmp	#'#',d0
	beq	fetchconst
	cmp	#'$',d0
	beq	fetchhex
	cmp	#'%',d0
	beq	fetchbin
	cmp	#$8000+47,d0
	beq	fetchsize
	cmp	#$8007+tnum,d0
	beq	fetchpi
	cmp	#$8000+tnum+18,d0
	beq	fetchon
	cmp	#$8000+tnum+19,d0
	beq	fetchoff
	;
	move	constmode,d1
	beq	.noasm
	;
	bsr	tstalpha
	beq	fetchasm
	cmp	#'_',d0
	beq	fetchasm
	cmp	#'"',d0
	beq	fetchqasm
	;
	bra	syntaxerr

.noasm	move	cfetchmode,d1
	beq	.asmok
	bra	badconerr	;we're trying to get a const here!
.asmok	not	-(a1)	;set forth stack type to non-const
	;
	;Here, we have stuff which will fuck it!
	;
	bsr	tstalpha
	beq	variable
	cmp	#'*',d0
	beq	variable
	cmp	#'\',d0
	beq	variable
	cmp	#'"',d0
	beq	litstring
	btst	#15,d0
	bne	function
	cmp	#'&',d0
	beq	ampersand
	cmp	#'?',d0
	beq	qmark
	;
	bra	syntaxerr

fetchsize	bsr	getchar3
	cmp	#'.',d0
	beq.s	.sizeobj
	;
	;find size of a var!
	;
	bsr	bakup
	move	d2,-(a7)
	bsr	makename
	beq	syntaxerr
	lea	firstvar,a2
	bsr	findvar
	bne	notypeerr	;!
.found	move	4(a2),d3
	ext.l	d3
	move	(a7)+,d2
	bra	fetchnum2

.sizeobj	move	d2,-(a7)
	bsr	makename
	beq	syntaxerr
	lea	alltypes,a2
	bsr	findtype
	bne	notypeerr
	moveq	#0,d3
	cmp	#'\',d0
	bne	.jty
	bsr	makename
	beq	syntaxerr
	lea	4(a2),a2
	bsr	findvar
	bne	noofferr
	move	4(a2),d3
	bra	.jty2
.jty	move	8(a2),d3
.jty2	move	(a7)+,d2
	bra	fetchnum2

fetchon	moveq	#-1,d3
	bsr	getchar3
	bra	fetchnum2

fetchoff	moveq	#0,d3
	bsr	getchar3
	bra	fetchnum2

chkhex	;is d0 a hex number?
	;
	cmp	#'0',d0
	bcs	.no
	cmp	#'9',d0
	bls	.yes
	and	#$ffdf,d0
	cmp	#'F',d0
	bhi	.no
	cmp	#'A',d0
	bcs	.no
.yes	cmp	d0,d0
.no	rts

chkbin	cmp	#'1',d0
	beq	.ok
	cmp	#'0',d0
.ok	rts

fetchhex	bsr	getchar3
	bsr	chkhex
	bne	syntaxerr
	moveq	#0,d3
.loop	cmp.l	#$10000000,d3
	bcc	overerr
	lsl.l	#4,d3
	sub	#48,d0
	cmp	#9,d0
	bls	.skip
	subq	#7,d0
.skip	or	d0,d3
	bsr	getchar3
	bsr	chkhex
	beq	.loop
	bra	fetchnum2

fetchbin	bsr	getchar3
	bsr	chkbin
	bne	syntaxerr
	moveq	#0,d3
.loop	lsl.l	#1,d3
	bcs	overerr
	sub	#48,d0
	or	d0,d3
	bsr	getchar3
	bsr	chkbin
	beq	.loop
	bra	fetchnum2

fetchconst	move	d2,-(a7)
	bsr	makename
	bsr	findadd
	bne	cnferr
	cmp.l	#1,4(a2)
	bne	cnferr
	move.l	8(a2),d3
	move	(a7)+,d2
	bra	fetchnum2	;to right type.

ampersand	bsr	ampersand2
	moveq	#3,d2
	rts

ampersand2	bsr	getchar3
	bsr	getvname
	bsr	fetchvar
	bsr	calcvar
	;
	cmp.b	#7,d2
	bne	.notst
	btst	#15,d2
	bne	.algot2
	move	d3,stamp2+2
	move.l	stamp2,d1
	bsr	pokela5s
	bra	.algot
.algot2	move	regat,d1
	lsl	#8,d1
	lsl	#1,d1
	or	stamp,d1
	bsr	pokewd
	rts
	;
.notst	btst	#15,d2
	bne	.algot
	move	d3,leaamp+2
	move.l	leaamp,d1
	bsr	pokela5s
.algot	move	regat,d1
	lsl	#8,d1
	lsl	#1,d1
	or	leaamp2,d1
	bra	pokewd

doern	;read err number
	move	#ern,d1
	bsr	tokejsr
	moveq	#3,d2
	rts

addrcode	move.l	0(a5),a0
	add	d0,a0
	move.l	a0,d0
addrcodef	;

fetchit
	bsr	getchar3
	;
	move	d0,d1
	bpl	syntaxerr
	move	d2,-(a7)
	bclr	#15,d1
	bsr	findtoke
	move.l	18(a2),d0
	tst	-2(a2,d0.l)
	beq	freeerr
	move	(a7)+,d2
	rts

usedcode	move.l	0(a5),d0
	bne.s	ucodeskip
	moveq	#-1,d0
	bra.s	usedcodef
ucodeskip	sub.l	0(a5),d0
ucodediv	lsr	#8,d0
usedcodef	;

usedcode2	move.l	0(a5),d0
	bne.s	ucodeskip2
	moveq	#-1,d0
	bra.s	usedcodef2
ucodeskip2	sub.l	0(a5),d0
	lsr	#8,d0
ucodediv2	lsr	#8,d0
usedcodef2	;

usedprep	move.l	d0,-(a7)

useddone	move.l	(a7)+,d0

usedfix	move.l	d0,d0

doused	;return 'used' object.
	;
	bsr	fetchit
	;
	move	-2(a2,d0.l),d3
	cmp	#9,d3
	bcc	.skip
	;
	;shift 1-8
	;
	lea	usedcode(pc),a0
	lea	usedcodef(pc),a1
	;
	and	#$f1ff,ucodediv-usedcode(a0)
	and	#7,d3
	lsl	#8,d3
	lsl	#1,d3
	or	d3,ucodediv-usedcode(a0)
	bra	.skip2
	;
.skip	;shift 9+
	;
	lea	usedcode2(pc),a0
	lea	usedcodef2(pc),a1
	;
	and	#$f1ff,ucodediv2-usedcode2(a0)
	subq	#8,d3
	lsl	#8,d3
	lsl	#1,d3
	or	d3,ucodediv2-usedcode2(a0)
.skip2	;
	move	-6(a2,d0.l),d3
	move	d3,ucodeskip-usedcode+2(a0)
	addq	#4,d3
	move	d3,2(a0)
	;
	move	regat,d1
	beq	.skip3
	move	usedprep(pc),d1
	bsr	pokewd
.skip3	bsr	pokecode
	move	regat,d1
	beq	.skip4
	lsl	#8,d1
	lsl	#1,d1
	or	usedfix(pc),d1
	bsr	pokewd
	move	useddone(pc),d1
	bsr	pokewd
.skip4	;
	moveq	#2,d2
	bra	getchar3

domaximum	;number of maximums
	;
	;eg a=Maximum Shape
	;
	bsr	fetchit
	;
	moveq	#0,d3
	move	-4(a2,d0.l),d3
	bsr	getchar3
	bra	fetchnum2

doaddr	;address of something
	;eg a.l=Addr Window(0)
	;
	bsr	getchar3	;get the token
	move	d0,-(a7)
	bsr	getchar3	;and the bracket?
	cmp	#'(',d0
	bne	syntaxerr
	move	(a7)+,d0
	bsr	getmaxel
	bsr	reget
	cmp	#')',d0
	bne	syntaxerr
	;
	;OK, now a2=lib it's from
	;
	lea	addrcode(pc),a0
	lea	addrcodef(pc),a1
	move	-6(a2),2(a0)	;x(a5)
	move	4(a0),d1
	and	#$fff8,d1
	or	regat,d1
	move	d1,4(a0)		;add Dregat,a0
	move	6(a0),d1
	and	#$f1ff,d1
	move	regat,d0
	lsl	#8,d0
	lsl	#1,d0
	or	d0,d1
	move	d1,6(a0)		;move.l a0,Dregat
	bsr	pokecode
	moveq	#3,d2		;now a long
	bra	getchar3

function	;do a function
	cmp	#$8000+tnum,d0
	bhi	.overasm
	;
	bra	syntaxerr
	;
.overasm	cmp	#$8003+tnum,d0
	beq	doern
	cmp	#$8005+tnum,d0
	beq	doaddr
	cmp	#$8011+tnum,d0
	beq	domaximum
	cmp	#$801e+tnum,d0
	beq	doused
	;
	move	d2,-(a7)	;remember old type!
	move	d0,d1
	bclr	#15,d1
	bsr	findtoke
	move	(a3),d1
	btst	#1,d1
	beq	syntaxerr
	btst	#2,d1
	bne	amigalib
	;
libfunction	;do a user library function -
	;eg a=pixel{x,y}
	;
	lsr	#8,d1
	btst	#3,1(a3)
	beq	.no0
	;
	bsr	sizespec2
	;
.no0	move	d1,-(a7)
	cmp	#7,d1
	bne	.notst0
	move.l	a2,-(a7)
	bsr	makesbase
	move.l	(a7)+,a2
.notst0	bsr	savem
	move	d3,-(a7)	;the movem regs
	;
	bsr	getchar3
	moveq	#0,d1
	cmp	#'(',d0
	bne	.nopars
	bsr	countpees
	tst	d1
	beq	syntaxerr
	bra	.skip0
.nopars	bsr	bakup
.skip0	move	regat,-(a7)
	clr	regat
	move	d1,-(a7)
	btst	#3,1(a3)
	beq	.no2
	move	6(a7),d1
	or	#$7000,d1
	bsr	pokewd
	addq	#1,regat
	move	(a7),d1
.no2	bsr	dolibtoke
	tst	(a7)+
	beq	.skip
	cmp	#')',d0
	bne	syntaxerr
	bsr	getchar3
.skip	move	(a7)+,d1
	move	d1,regat
	beq	.skip2
	lsl	#8,d1
	lsl	#1,d1
	or	#$2000,d1
	bsr	pokewd	;move.l d0,regat
.skip2	;
	move	(a7)+,d3
	beq	.nomovem
	move	#$4cdf,d1
	bsr	pokewd
	moveq	#0,d1
	moveq	#15,d4
.loopsw	lsl	#1,d3
	roxr	#1,d1
	dbf	d4,.loopsw	
	bsr	pokewd	;poke movem (a7)+...
.nomovem	;
	move	(a7)+,d2
	cmp	#7,d2
	bne	.notst
	move	putstlen,d1
	or	regat,d1
	bsr	pokewd	
	;
.notst	bra	varcont

amigalib	move	6(a3),d1
	bsr	uselib	;get lib for base address
	bsr	savereg
	move.l	d4,d1
	move.l	d5,-(a7)
	bsr	pokemovem
	move	10(a1),-(a7)	;libbase reg
	addq	#8,a3
	move	(a3)+,-(a7)		;get offset for lib
	move.l	a3,-(a7)
	bsr	getchar3
	move	d0,-(a7)	;remember first bracket....
	;
	;collect longs for lib
	;
	moveq	#0,d3
.loop	move.b	(a3)+,d1
	bmi	.done
	moveq	#3,d2
	addq	#1,d3
	movem.l	d3/a3,-(a7)
	bsr	peval
	subq	#4,stackuse	;readjust stack! it's coming off later!
	movem.l	(a7)+,d3/a3
	cmp	#',',d0
	beq	.loop
	tst.b	(a3)
	bpl	syntaxerr
	;
.done	move	(a7)+,d1
	bsr	tstbras
	move.l	(a7)+,a3
	subq	#1,d3
	bmi	.nopars
	;
.toend	tst.b	(a3)+	;go to end of params
	bpl	.toend
	subq	#1,a3
.loop2	moveq	#0,d1
	move.b	-(a3),d1
	btst	#4,d1
	bne	.addreg
	cmp	regat,d1
	bcc	.nomovem
	bset	d1,d5
	moveq	#15,d0
	sub	d1,d0
	bset	d0,d4
.nomovem	lsl	#8,d1
	lsl	#1,d1
	or	#$201f,d1
	bra	.gotit
.addreg	and	#7,d1
	lsl	#8,d1
	lsl	#1,d1
	or	#$205f,d1
.gotit	bsr	pokewd
	dbf	d3,.loop2
	;
.nopars	move	(a7)+,libjsr+2
	move	(a7)+,libbase+2
	move.l	libbase,d1
	bsr	pokel
	move.l	libjsr,d1
	bsr	pokel
	move	regat,d1
	beq	.nofin
	lsl	#8,d1
	lsl	#1,d1
	or	#$2000,d1
	bsr	pokewd
.nofin	move.l	(a7)+,d1
	bsr	pokemovem
	moveq	#3,d2
	bsr	reget
	bra	varcont

tstbras	;chk that d1 (first bra char) and d0 (last)
	;are consistent with d3 (number of parameters)
	;also, skip last if nec.
	;
	tst	d3
	beq	.nopars
	cmp	#'(',d1
	bne	syntaxerr
	cmp	#')',d0
	bne	syntaxerr
	bra	getchar3
.nopars	cmp	#'(',d1
	bne	.skip
	bsr	getchar3
	cmp	#')',d0
	bne	syntaxerr
	bra	getchar3
.skip	rts

pokemovem	tst	d1
	bne	pokel
	rts

savereg	;set up d4 for movem -(a7) and d5 for movem (a7)+
	move	#$48e7,d4
	swap	d4
	clr	d4
	move	#$4cdf,d5
	swap	d5
	clr	d5
	move	regat,d1
	beq	.skip
	bset	#15,d4
	bset	#0,d5
	cmp	#2,d1
	bcs	.skip2
.skip3	bset	#14,d4
	bset	#1,d5
.skip2	rts
.skip	tst	fuckpos
	bne	.skip3
	rts

fuckpos	dc	0

makesbase:	move	sbasegot,d1
	beq	.skip
	;
	;S base has been got, was it for this Eval?
	;
	move	sbgot(pc),d1
	bne	.skip2
	;
	;No, push it on da stack!
	;
	move	#2,sbgot	
	move	movea3a7,d1
	bra	pokewd
.skip2	rts
	;
.skip	;no sbase got at all!
	;
	move	#-1,sbasegot
	move	#1,sbgot	;voodoo magic! - Will it work?
	move	#workstart,d1
	bra	tokejsr

litstring	bsr	makesbase
	move.l	data1,litdata1
	bsr	pokedata1
	bsr	pokedata1
	moveq	#0,d2
.loop	bsr	getchar3
	tst	d0
	beq	notqerr
	cmp	#'"',d0
	beq	.done
	addq	#1,d2
	move	d0,d1
	bsr	pokedata1b
	bra	.loop
.done	move	nomemleft,d1
	bne	.skip
	move.l	litdata1,a0
	clr	(a0)+
	move	d2,(a0)
.skip	addq.l	#1,data1
	bclr	#0,data1+3
	bsr	makelit
	moveq	#7,d2
	bra	getchar3

makealab	bsr	makename2
makealab2	bsr	findadd
	beq	.found
	;
	bsr	addhere
	clr.l	4(a2)	;no refs
	clr.l	8(a2)	;not created yet (no PC)
	clr.l	12(a2)	;no data label
	move	linenumat,16(a2)	;context
	bra	.makeit
	;
.found	tst.l	8(a2)
	bne	.gotit	;already made
	;
	;create an oustanding reference to this label!
	;
.makeit	;
	move.l	4.w,a6
	moveq	#12,d0
	moveq	#1,d1
	jsr	doallocmem
	move.l	d0,a0
	move.l	4(a2),(a0)
	move.l	a0,4(a2)
	move.l	pc,4(a0)
	addq.l	#2,4(a0)
	move	procnum,8(a0)
	move	linenumat,10(a0)
	rts
	;
.gotit	move.l	4(a2),d1
	btst	#0,d1
	bne	illlaberr
	move	procnum,d1
	cmp	16(a2),d1
	bne	referr
	;
.skip	rts

makelit	;put lit string from d3 (data1) into stringbuff
	;
	move	d0,-(a7)
	move	numtoa0,d1
	bsr	pokewd
	bsr	addoff
	move.l	litdata1,d1
	bsr	pokel
	move	pushlen,d1
	bsr	pokewd
	move	#copstring,d1
	bsr	tokejsr
	move	(a7)+,d0
	rts

qmark	bsr	getchar3
	bsr	makealab
	;
	move	regat,d1
	lsl	#8,d1
	lsl	#1,d1
	or	#$203c,d1
	bsr	pokewd	;create move.l #loc,dn
	bsr	addoff
	move.l	8(a2),d1
	bsr	pokel
	moveq	#3,d2
	bra	reget

;variable	
;	;
;	cmp	#6,d2
;	bne	calcadd
;	;
;	;get address for goto Etc!
;	;
;agoto	movem.l	a5/d2/d0,-(a7)
;	bsr	makename2
;	cmp	#'.',d0
;	bne	.nottype
;	movem.l	(a7)+,a5/d2/d0
;	bra	calcadd
;	;
;.nottype	lea	12(a7),a7
;	bsr	makealab2
;	;
;	move	regat,d1
;	lsl	#8,d1
;	lsl	#1,d1
;	or	#$203c,d1
;	bsr	pokewd	;create move.l #loc,dn
;	bsr	addoff
;	move.l	8(a2),d1
;	bsr	pokel
;	moveq	#6,d2
;	bra	reget
	;

fetchqasm	moveq	#0,d3
.loop	bsr	getchar3
	beq	syntaxerr
	cmp	#'"',d0
	beq	.done
	lsl.l	#8,d3
	move.b	d0,d3
	bra	.loop
.done	bsr	getchar3
	bra	fetchnum2
	
fetchasm	move	d2,-(a7)
	bsr	makename2	;get the things name
	bsr	findadd
	bne	cnferr
	move.l	8(a2),d3	;val.
	cmp.l	#1,4(a2)
	beq	.npc
	not	asmtype
.npc	move	(a7)+,d2
	bra	fetchnum2

variable:	;
	move	d2,-(a7)	;remember old type
	bsr	getvname
	cmp	#'{',d0
	beq	afunction
	bsr	fetchvar
	bsr	calcvar
	bsr	variable2
varcont	cmp	#1,d2
	bne	.notabyte
	;
	;ALWAYS CONVERT BYTE TO WORD.
	;
	move	regat,d1
	or	#$4880,d1	;ext.w Dn
	bsr	pokewd
	;
.notabyte	move	(a7)+,d3	;old type
	beq	.done	;type not set yet...
			;it is now!
	cmp	#3,d3
	bne	.nob
	cmp	#4,d2
	beq	.conv2
	;
.nob	cmp	d2,d3
	bls	.done	
.conv2	exg	d2,d3
	bsr	convtype	;bump up new type to old....
.done	bra	reget

savem	moveq	#0,d3
	move	regat,d1
	beq	.skip
	subq	#1,d1
.loop	lsr.l	#1,d3
	bset	#15,d3
	dbf	d1,.loop
	move	#$48e7,d1
	bsr	pokewd
	move	d3,d1
	bra	pokewd
.skip	rts	
	
makefjsr	move.l	d1,-(a7)
	move	#$4eb9,d1
	bsr	pokewd
	bsr	addoff
	move.l	(a7)+,d1
	bra	pokel

afunction:	;do a local function -
	;eg a=pixel{x,y}
	;
	bsr	findproc
	bne	noprocerr
	moveq	#0,d1
	move.b	5(a2),d1
	bmi	illprocerr
	move	d1,-(a7)
	moveq	#0,d1
	move.b	4(a2),d1
	lsr	#4,d1
	beq	.skip
	lsl	#2,d1
	sub	d1,stackuse
.skip	;
	cmp	#7,(a7)	;function type!
	bne.s	.sss
	move.l	a2,-(a7)
	bsr	makesbase
	move.l	(a7)+,a2
.sss	move	sbasegot,-(a7)
	beq.s	.sssz
	bsr	dopusha3
.sssz	;
	bsr	savem
	move	d3,-(a7)		;the movem regs
	;
	move.l	14(a2),d1	;pc of function call
	tst.b	4(a2)
	bne	.somepars
	bsr	makefjsr
	bsr	getchar3
	bra	.nopars
.somepars	move	regat,-(a7)	;old regat
	move.l	d1,-(a7)
	moveq	#0,d0
	move.b	4(a2),d0
	lea	22(a2),a2		;pointer to var desc
	clr	regat
	bsr	fetchpees2
	;
	jsr	chkstak
	move.l	(a7)+,d1	
	bsr	makefjsr
	move	(a7)+,regat
	;
.nopars	cmp	#'}',d0
	bne	syntaxerr
	;
	move	regat,d1
	beq	.nopars3
	lsl	#8,d1
	lsl	#1,d1
	or	#$2000,d1
	bsr	pokewd	;move.l d0,regat
.nopars3	;
	move	(a7)+,d3
	beq	.nomovem
	move	#$4cdf,d1
	bsr	pokewd
	moveq	#0,d1
	moveq	#15,d4
.loopsw	lsl	#1,d3
	roxr	#1,d1
	dbf	d4,.loopsw	
	bsr	pokewd	;poke movem (a7)+...
.nomovem	;
	move	(a7)+,d1
	beq.s	.nores
	cmp	#7,(a7)
	beq.s	.issb
	;not a string...set a3 back to start of any strings...
	lea	geta3,a0
	lea	geta3f,a1
	bsr	pokecode
	bra.s	.nosb
.issb	;is a string, wack off last '0'
	move	deca3,d1
	bsr	pokewd
.nosb	bsr	dopulla3	;fix up string base
.nores	;
	move	(a7)+,d2	;what it returns!
	cmp	#7,d2
	bne	.notst
	move	putstlen,d1
	or	regat,d1
	bsr	pokewd
	;
.notst	bsr	getchar3
	;
	bra	varcont

deca3	subq	#1,a3

stvar	;handle string variable get!
	;
	bsr	makesbase
	btst	#15,d2
	bne	.already
	move	d3,leaa5d3a2+2
	move.l	leaa5d3a2,d1
	bsr	pokela5s
.already	move	regat,d1
	lsl	#8,d1
	lsl	#1,d1
	or	#$7000,d1
	lea	stvarget2,a0
	move	d1,(a0)
	move	regat,d1
	and	#$fff8,2(a0)
	or	d1,2(a0)
	lea	stvarget2f,a1
	bsr	pokecode
	move	#copstring,d1
	bsr	tokejsr
	moveq	#7,d2
	bra	reget

variable2	cmp.b	#7,d2
	beq	stvar
	move	regat,d1
	lsl	#8,d1
	lsl	#1,d1
	btst	#14,d2
	bne	.pointer
	tst.b	d2
	bne	.skip2
	moveq	#3,d2
	or	#$200a,d1
	bra	pokewd
.pointer	move.b	#3,d2
.skip2	btst	#15,d2
	beq	.simpvar
	or	movea2dn,d1
	bsr	.size
	bsr	pokewd
	;
.more	and	#255,d2
	rts
	;
.simpvar	or	moved3a5dn,d1
	bsr	.size
	bsr	pokewda5s
	move	d3,d1
	bsr	pokewd
	bra	.more
	;
.size	;correct for size
	;	
	btst	#14,d2
	bne	.long
	cmp.b	#1,d2
	beq	.byte
	cmp.b	#2,d2
	beq	.word
.long	rts
.byte	eor	#$3000,d1
	rts
.word	or	#$1000,d1
	rts

;-----------fetch number and update type if necessary!----------;

fetchdata	move	#-1,dfetch
	bsr	getchar3
	cmp	#'-',d0
	bne	.datado
	bsr	getchar3
	bsr	.datado
	;
	cmp	#5,d2
	bcc	.nfp
	neg.l	d0
	rts
.nfp	;negate floating point data!
	bchg	#7,d0
	rts

.datado	cmp	#'$',d0
	beq	fetchhex
	cmp	#'%',d0
	beq	fetchbin
	;
.doit	cmp	#'.',d0
	bne	fetchnum
	;
fetchfrac	moveq	#0,d3
	bra	fetchpoint2

fetchnum	;
	moveq	#0,d3
	;
	bsr	fetchdec
	;
	cmp	#'.',d0
	beq	fetchpoint
	or	#32,d0
	cmp	#'e',d0
	bne	fetchnum2
	cmp.l	#$800000,d3
	bcc	overerr
	moveq	#-1,d6
	move.l	d3,d0
	move.l	maths,a6
	jsr	-36(a6)	;int to ffp
	move.l	d0,d3
	bsr	dothee
	bsr	reget
	bsr	consttype2
	bra	fetchnum3
	;
fetchpoint	cmp.l	#$800000,d3
	bcc	overerr
	;
fetchpoint2	moveq	#-1,d6	;now a float.
	move.l	d3,d0
	move.l	maths,a6
	jsr	-36(a6)	;int to ffp
	move.l	d0,-(a7)	;save whole number
	bsr	getchar3
	bsr	tstnum
	bne	syntaxerr
	moveq	#0,d3
	bsr	fetchdec	;get int frac
	tst.l	d3
	beq	.pskip
	cmp.l	#$800000,d3
	bcc	overerr
	move.l	d5,d0
	jsr	-36(a6)	;divisor to ffp
	move.l	d0,d5
	move.l	d3,d0
	jsr	-36(a6)	;to ffp
	move.l	d5,d1
	jsr	-84(a6)	;num/divisor (eg .25=25/100)
	move.l	(a7)+,d1
	jsr	-66(a6)	;add 'em
	move.l	d0,d3
	bsr	reget
	or	#32,d0
	cmp	#'e',d0
	bne	.pskip2
	;
	;E Something!
	bsr	dothee
	;
.pskip2	bsr	reget
	bsr	consttype2
	bra	fetchnum3
.pskip	move.l	(a7)+,d3
	bra	.pskip2

dothee	;Suss stuff after the E
	bsr	getchar3
	cmp	#'+',d0
	beq	.pos
	cmp	#'-',d0
	bne	.pos2
	;neg
	bsr	getchar3
	bsr	getsign
	;
	;d3=number, d4=divisor
	;
	move.l	d3,d0
	move.l	d4,d1
	jsr	-84(a6)
	move.l	d0,d3
	rts
	;
.pos	bsr	getchar3
.pos2	bsr	getsign
	;
	;d3=number so far, d4=multiplier
	;
	move.l	d3,d0
	move.l	d4,d1
	jsr	-78(a6)
	move.l	d0,d3
	rts

getsign	bsr	tstnum
	bne	syntaxerr
	move	d0,d4
	sub	#48,d4
	bsr	getchar3
	bsr	tstnum
	bne	.skip
	mulu	#10,d4
	sub	#48,d0
	add	d0,d4
	bsr	getchar3
.skip	;d4=number E+10
	cmp	#18,d4
	bhi	overerr
	lsl	#2,d4
	move.l	facts(pc,d4),d4
	rts

facts	dc.l	$80000041,$a0000044
	dc.l	$c8000047,$fa00004a
	dc.l	$9c40004e,$c3500051
	dc.l	$f4240054,$98968058
	dc.l	$bebc205b,$ee6b285e
	dc.l	$9502f962,$ba43b765
	dc.l	$e8d4a568,$9184e76c
	dc.l	$b5e6216f,$e35fa972
	dc.l	$8e1bca76,$b1a2bd79
	dc.l	$de0b6c7c

fetchdec	moveq	#1,d5
.loop	lsl.l	#1,d5
	move.l	d5,d1
	lsl.l	#2,d5
	add.l	d1,d5	;divisor for frac convert!
	;
	lsl.l	#1,d3
	bcs	overerr
	move.l	d3,d1
	lsl.l	#1,d3
	bcs	overerr
	lsl.l	#1,d3
	bcs	overerr
	add.l	d1,d3
	sub	#48,d0
	add.l	d0,d3
	bsr	getchar3
	bsr	tstnum
	beq	.loop
	rts

dfetch	dc	0	;fetching data?

fetchnum3	move	dfetch(pc),d1
	beq	.doit
	clr	dfetch
	rts
.doit	cmp	#1,d2
	beq	.word ;Byte?
	cmp	#2,d2
	beq	.word ;Word?
	cmp	#3,d2
	beq	.long ;Long?
	cmp	#4,d2
	beq	.long ;Quick?
	cmp	#5,d2
	beq	.long ;Float?
	bra	mismatcherr
	;
.word	move	regat,d1
	lsl	#8,d1
	lsl	#1,d1
	or	#$303c,d1
	
;Chocolate - this is a WORD/BYTE length constant. Apply moveq if it's within the -128 to 127 range
	cmp.l #127,D0
	bgt .notmoveq_word
	cmp.l #-128,D0
	blt .notmoveq_word
	bra .pokemoveq
	
.notmoveq_word
	bsr	pokewd
	move	d0,d1
	bsr	pokewd
	bra	reget
	
.long	move	regat,d1
	lsl	#8,d1
	lsl	#1,d1
	or	#$203c,d1
	
;Chocolate - this is a LONG length constant. Apply moveq if it's within the -128 to 127 range

	cmp.l #127,D0
	bgt .notmoveq
	cmp.l #-128,D0
	blt .notmoveq
	bra .pokemoveq
	
.notmoveq
	bsr	pokewd
	move.l	d0,d1
	bsr	pokel
	bra	reget
		
;D0 must be the actual value, between -128 to 127
;D1 must be the old move opcode
.pokemoveq
	And.w #$0F00,D1 ;Fix the opcode
	Or.w #$7000,D1
	Or.b D0,D1
	
	bsr	pokewd
	bra	reget

;-----------end of number fetch-------------;

makeint	move.l	d3,d0
	tst	d6
	beq	.skip	;already integer
	move.l	maths,a6
	jsr	-30(a6)
	bvc	.skip
	addq	#4,a7
	bra	numdofloat
.skip	rts

fetchnum2	moveq	#0,d6	;no frac
	bsr	consttype2
	bra	fetchnum3

constotype	;fetch a constant of type d2
	;
	;return new type in d2!
	;
	move	d2,-(a7)
	bsr	evalconst
	move	(a7)+,d2
consttype2	;
	tst	d2
	bne	.something
	;
	;Let's set type
	;
	tst	d6
	beq	.nofrac
	moveq	#4,d2
	bra	.quick2
.nofrac	moveq	#1,d2
	bra	.byte
	;
.something	cmp	#1,d2
	beq	.byte
	cmp	#2,d2
	beq	.word
	cmp	#3,d2
	beq	.long
	cmp	#4,d2
	beq	.quick
	cmp	#5,d2
	beq	.float
	bra	mismatcherr
	;
.byte	bsr	makeint
	cmp.l	#127,d0
	bgt	.over1
	cmp.l	#-128,d0
	bge	.dobword
	;
.over1	moveq	#2,d2
	cmp.l	#32767,d0
	bgt	.byte2
	cmp.l	#-32768,d0
	bge	.dobword
	;
.byte2	moveq	#3,d2
	bra	.dolong
	;
.word	tst	d6
	bne	.quick2
	bsr	makeint
	bra	.over1
	;
.quick	bsr	makeint
	tst	d6
	beq	.qint
.quick2	cmp.l	#32767,d0
	bgt	numdofloat
	cmp.l	#-32768,d0
	blt	numdofloat
	;
	move	d0,-(a7)	;save whole part
	jsr	-36(a6)	;back to ffp
	move.l	d0,d1
	move.l	d3,d0
	jsr	-72(a6)	;subtract - d0=fraction!
	move.l	#$80000051,d1	;65536
	jsr	-78(a6)	;*65536
	jsr	-30(a6)	;back to int
	;
	beq	.knob	;numdofloat
	cmp.l	#65536,d0
	bcc	.knob	;numdofloat
	move	d0,d1
	move	(a7)+,d0
	swap	d0
	move	d1,d0
	bra	.dolong
	;
.knob	addq	#2,a7
	bra	numdofloat
	;
.qint	cmp.l	#32767,d0
	bgt	.byte2
	cmp.l	#-32768,d0
	blt	.byte2
	swap	d0
	bra	.dolong
	;
.long	tst	d6
	bne	numdofloat
	move.l	d3,d0
	bra	.dolong
	;
.float	tst	d6
	bne	numdofloat
	move.l	d3,d0
	move.l	maths,a6
	jsr	-36(a6)	;int to float
	move.l	d0,d3
	bra	numdofloat
	;
.dobword	;
.dolong	;
	rts
	;
numdofloat	moveq	#5,d2
	move.l	d3,d0
	rts

pushfrom	dc.l	0
pushpc	dc.l	0
pushoff	dc.l	0
pushdooff	dc.l	0
pushclen	dc	0
pushat	dc.l	0

pushstart	;Here, we prepare to collect code to be saved and added
	;later
	move.l	pc,pushpc
	move.l	firstoff,pushoff
	rts

pushdo	;OK, push code since push start
	;
	movem.l	d0-d1/a0-a1,-(a7)
	;
	move.l	pc,d0
	move.l	pushpc(pc),d1
	move.l	d1,pc	;New PC
	sub.l	d1,d0	;len
	move	d0,pushclen
	beq	.skip
	move	nomemleft,d1
	bne	.skip
	;
	moveq	#1,d1
	move.l	4.w,a6
	jsr	doallocmem
	move.l	d0,pushat
	move.l	d0,a0	;destination
	move.l	pushpc,a1	;source
	move.l	a1,pc
	move	pushclen,d0
	lsr	#1,d0
	subq	#1,d0	;to word dbf
.loop	move	(a1)+,(a0)+
	dbf	d0,.loop
	move.l	firstoff,pushdooff
.skip	movem.l	(a7)+,d0-d1/a0-a1
	rts

pushput	;replace pulled out code!
	;
	movem.l	d0-d1/a0-a1,-(a7)
	moveq	#0,d0
	move	pushclen,d0
	beq	.skip
	move.l	pc,d1	;pc before put
	add.l	d0,pc
	tst	nomemleft
	bne	.skip
	;
	lsr	#1,d0
	subq	#1,d0
	;
	move.l	d1,a1
	move.l	pushat,a0
	;
.loop	cmp.l	libat,a1
	bcs	.ok
	move	#-1,nomemleft
	bra	.skip
.ok	move	(a0)+,(a1)+
	dbf	d0,.loop
	;
	;OK, now all offsets between pushdooff and pushoff must
	;be adjusted by d1-pushpc
	;
	sub.l 	pushpc,d1
	beq	.skip2
	move.l	pushdooff,a0
.loop2	cmp.l	pushoff,a0
	beq	.done
	move.l	4(a0),a1	;address in prog.
	add.l	pcat,a1
	cmp.l	libat,a1
	bcc	.next	;leave offs >= lib
	add.l	d1,4(a0)
.next	move.l	(a0),a0
	bra	.loop2
.done	;Whew!
.skip2	move.l	pushat,a1
	moveq	#0,d0
	move	pushclen,d0
	move.l	4.w,a6
	jsr	freemem(a6)
	;
.skip	movem.l	(a7)+,d0-d1/a0-a1
	rts	

muld1	;generate code for #d1.w*regat
	;
	move	d1,-(a7)
	moveq	#0,d2
	moveq	#15,d3
.shloop	lsl	#1,d1
	bcc	.shskip
	addq	#1,d2
	move	d3,d4
.shskip	dbf	d3,.shloop
	subq	#1,d2
	bne	.domul
	addq	#2,a7
	move	d4,d1
	beq	.done
	cmp	#8,d1
	bcs	.once
	sub	#8,d1
	bsr	.once
	moveq	#0,d1
.once	lsl	#8,d1
	lsl	#1,d1
	or	#$e188,d1
	or	regat,d1
	bra	pokewd
.done	rts
.domul	move	regat,d1
	lsl	#8,d1
	lsl	#1,d1
	or	#$c0fc,d1
	bsr	pokewd
	move	(a7)+,d1
	bra	pokewd

makeinits	;make any initialing jsr's
	;
	move.l	pc,-(a7)
	moveq	#-1,d7
.loop	bsr	findhilib
	beq	.done
	tst	12(a2)
	bpl	.loop
	move.l	22(a2),d1
	beq	.loop
	;
	move	4(a2),d1
	cmp	#allocvars,d1
	bne	.notvar
	bsr	makevsize
	bra	.more
	;
.notvar	cmp	#debuglib,d1
	bne	.notdebuglib
	;
	;pass flag in d0 : non zero=auto run
	;
	move	#$7000,d1		;moveq #0,d0
	btst	#7,optreq2ga1+13
	sne	d1
	bsr	pokewd
	bra	.more
.notdebuglib	;
	cmp	#65235,d1
	bne	.notstring1
	bsr	makessize
	bra	.more
	;
.notstring1	cmp	#65035,d1
	bne	.notexit
	;
.isexit	move	#$203c,d1
	bsr	pokewd
	bsr	addoff
	move.l	endop,d1
	bsr	pokel
	bra	.more
.notexit	;
	cmp	#64535,d1
	bne	.notdatalib
	move	#$203c,d1
	bsr	pokewd
	bsr	addoff
	move.l	data2at,d1
	bsr	pokel
	bra	.more
.notdatalib	;
	cmp	#dhandlerlib,d1
	bne	.notdhandler
	move	#$203c,d1	;move.l #x,d0 (?)
	bsr	pokewd
	move.l	dseg,d1
	bsr	pokel
.notdhandler	;
.more	move.l	22(a2),d1
	move	#-1,lasta6
	bsr	makelibsub
	cmp	#allocvars,4(a2)
	bne	.notvar2
	;
	move.l	intdata1,d1
	beq	.notvar2
	move	putidata1,d1
	bsr	pokewd
	bsr	addoff
	move.l	intdata1,d1
	bsr	pokel
	;
.notvar2	move	#$2b40,d1
	tst	26(a2)
	beq	.loop
	bpl	.long
	move	#$3b40,d1
.long	bsr	pokewd
	move	10(a2),d1
	bsr	pokewd
	cmp	#65530,4(a2)
	bne	.loop
	;
	move	d7,-(a7)
	move	numstatic,d4
	beq	.nostats
	move.l	staticdata,d3
	bsr	datastart
	move	#alstat,d1
	bsr	tokejsr2
.nostats	;
	move	maxsused,d4
	beq	.nomaxs
	move.l	maxsat,d3
	bsr	datastart
	move	#setmaxs,d1
	bsr	tokejsr2
.nomaxs	move	(a7)+,d7
	;
	bra	.loop
.done	;
	;misc inits
	;
	move.l	pc,d1
	cmp.l	(a7),d1
	bne	.yi
	move	#8,noinits+2
	bra	.yi3
	;
.yi	clr	noinits+2
	move	nomemleft,d1
	bne	.yi2
	move.l	pcat,a0
	move	#$4eb9,(a0)+
	move.l	(a7),(a0)
	moveq	#2,d2
	bsr	addoff2	
.yi2	move	#$4e75,d1
	bsr	pokewd
.yi3	addq	#4,a7
	rts

prepd1	move.l	0(a5),d1

putidata1	move.l	a5,0

prepint	move.l	#0,a2

makessize	move.l	stringwork,d1
	bra	makesize

makevsize	;create code for amount of variables in d0
	;
	moveq	#0,d1
	move	varoff,d1
	sub	#$8000,d1
	bne	makesize	
	moveq	#8,d1
	;
makesize	;create code for #d1 into d0
	;
	move.l	d1,-(a7)
	move	#$203c,d1
	bsr	pokewd
	move.l	(a7)+,d1
	bra	pokel

findhilib	;find highest lib# under d7. set d7 to this lib number
	;
	;ne if found, eq if not
	;
	moveq	#0,d1
	move.l	firstlib,a1
.loop	cmp	#0,a1
	beq	.done
	cmp	4(a1),d7
	bls	.next
	cmp	4(a1),d1
	bcc	.next
	move	4(a1),d1
	move.l	a1,a2
.next	move.l	(a1),a1
	bra	.loop
.done	move	d1,d7
	rts

findlolib	;find lowest lib# above d7. set d7 to this lib number
	;
	;ne if found, eq if not
	;
	moveq	#-1,d1
	move.l	firstlib,a1
.loop	cmp	#0,a1
	beq	.done
	cmp	4(a1),d7
	bcc	.next
	cmp	4(a1),d1
	bls	.next
	move	4(a1),d1
	move.l	a1,a2
.next	move.l	(a1),a1
	bra	.loop
.done	move	d1,d7
	cmp	#-1,d1
	rts

makefinits	;create jsr's to FINIT routines from libs
	;
	;also calculate the REGAT variables for inits!
	;
	addq	#1,varoff
	bclr	#0,varoff+1
	moveq	#0,d7
.loop	bsr	findlolib
	beq	.azdone
	tst	12(a2)
	bpl	.loop
.skipvar	move.l	a2,a1
	add.l	18(a1),a1
	tst	-2(a1)
	beq	.nomax
	;
	;A max lib, possible multiple frees!
	;
	move.l	-10(a1),d1
	lea	6(a2,d1.l),a3
.plop	tst	(a3)+
	beq	.plopf
	addq	#2,a3
	bra	.plop
.plopf	tst.l	4(a3)
	beq	.nomax
	;
	;Something to Do!
	;
	move	freemax(pc),d1	;move.w #x,-(a7)
	bsr	pokewd
	move	-4(a1),d1
	bsr	pokewd	;x (max)
	move.l	free,d1
	move	-6(a1),d1
	bsr	pokel	;move.l x(a5),a3
	;
	move.l	pc,-(a7)
	moveq	#1,d1
	move	-2(a1),d2
	lsl	d2,d1
	move	d1,-(a7)
	move.l	-10(a1),d1
	bsr	makelibsub
	move	freemax3(pc),d1
	bsr	pokewd	;lea x(a3),a3
	move	(a7)+,d1
	bsr	pokewd
	move.l	freemax2(pc),d1
	bsr	pokel
	move.l	(a7)+,d1
	sub.l	pc,d1
	bsr	pokewd
	move	freemax4(pc),d1
	bsr	pokewd
	;
.nomax	move.l	28(a2),d1
	beq	.loop
	;
	;check special cases!
	;
	move	4(a2),d1
	cmp	#allocvars,d1
	bne	.notvfin
	bsr	makevsize
;	move.l	pc,varsizeat
	bra	.more
	;
.notvfin	cmp	#65235,d1
	bne	.notstring1
	bsr	makessize
	bra	.more
	;
.notstring1	;
.more	move.l	28(a2),d1
	move	#-1,lasta6
	bsr	makelibsub
	bra	.loop
.azdone	rts

freemax	move	#0,-(a7)

freemax2	subq	#1,(a7)
	bne	freemax2

freemax4	addq	#2,a7

freemax3	lea	0(a3),a3

chkstak	tst.b	debugga
	beq.s	.skip
	;
	tst	makeexec
	bne.s	.skip
	;
	move	#stchk,d1
	bra	tokejsr
	;
.skip	rts

tokejsr2	;cmp	#stchk,d1	;ignore stack checking if making an executable!
	;bne	.skip
	;tst	makeexec
	;beq	.skip
	;rts
.skip	move	#-1,lasta6
	;
tokejsr	;make a jsr (or simple reg get) from d1
	;
	movem.l	d2/a3,-(a7)
	bsr	findtoke
	move.l	a3,d1
	sub.l	a2,d1
	bsr	makelibsub
	movem.l	(a7)+,d2/a3
	rts

userjsr	;a2 = lib base
	;a1 = start of #parameters
	;
	move.l	libisat,-(a7)
	move.l	a2,libisat
	move.l	a1,a2
	move	(a2)+,d1
	and	#255,d1
	add	d1,a2
	exg	a2,d0
	addq.l	#1,d0
	bclr	#0,d0
	exg	a2,d0
	bra	makelsub2

cutejsr	move.l	libisat,-(a7)
	move.l	a2,libisat
	move.l	a3,a2
	bra	makelsub2

libisat	dc.l	0

makelibsub	;lib in a2, sub offset in d1
	;
	move.l	libisat,-(a7)
	move.l	a2,libisat
	lea	6(a2,d1.l),a2
makelsub2	bsr	makelsub3
	move.l	(a7)+,libisat
	rts
makelsub3	bsr	fetchregs
	;
	tst.b	debugga
	beq	.norerr
	;
	move.l	(a2),d1
	or.l	8(a2),d1
	bclr	#0,d1
	tst.l	d1
	beq	.norerr
	;
	move.l	(a2)+,d1
	btst	#0,d1
	beq	.skiptt
	tst	blitzmode
	bpl	blitzerr
	tst.b	debugga
	beq	.skiptt2
	move.l	d1,-(a7)
	move	#inblitz,d1
	bsr	makebtst
	move.l	(a7)+,d1
.skiptt2	bclr	#0,d1
.skiptt	tst.l	d1
	;
	bsr	doajsr
	move.l	(a2)+,d1
	bsr	doajsrrout
	move.l	(a2)+,d1
	bsr	doajsr
	bra	.more
	;
.norerr	btst	#0,3(a2)
	beq	.penis
	;
	;Here, the routine can only run in Blitz Mode
	;
	move	blitzmode(pc),d1
	bpl	blitzerr
.penis	move.l	4(a2),d1
	bsr	doajsrrout
.more	move.l	libisat,a2
	rts

doajsrrout	;Here, we suss out bit 0 to see if this
	;can only happen in Amiga mode.
	;
	btst	#0,d1
	beq	.doajsr
	tst	blitzmode
	bmi	amigaerr
	;btst	#0,optreqga10+13	;!!!
	tst.b	debugga
	beq	.doajsr2
	move.l	d1,-(a7)
	move	#inamiga,d1
	bsr	makebtst
	move.l	(a7)+,d1
.doajsr2	bclr	#0,d1
.doajsr	tst.l	d1
	;
doajsr	beq	.skip
	move.l	a1,-(a7)
	bsr	doajsr2
	move.l	(a7)+,a1
.skip	rts

doajsr2	move.l	libisat,a0
	tst	cfetchmode
	beq	.nfetch
	add.l	a0,d1
	move.l	d1,-(a7)
	move	#$4eb9,d1
	bsr	pokewd
	move.l	(a7)+,d1
	bra	pokel
.nfetch	;
	;d1 is an offset from start of lib.
	;a0 is start of lib.
	;
	lea	0(a0,d1.l),a1
	clr	inline
.cute	cmp.b	#$a0,(a1)+
	bne	.ugly
	tst.b	(a1)+
	beq	.iszero
	cmp.b	#1,-1(a1)
	beq	.isone
	;
.iszero	;here, code can be made inline.
	move	(a1)+,inline
	addq.l	#4,d1
	bra	.cute
	;
.isone	;here, a blitzmode variation is available
	;
	tst	blitzmode
	bpl	.inamiga
	;
	tst.b	debugga
	beq	.nobrerr
	move	#inblitz,d1
	bsr	makebtst
.nobrerr	move.l	(a1)+,d1
	lea	0(a0,d1.l),a1
	bra	.cute
	;
.inamiga	tst.b	debugga
	beq	.noarerr
	move.l	d1,-(a7)
	move	#inamiga,d1
	bsr	makebtst
	move.l	(a7)+,d1
.noarerr	addq	#4,a1
	addq.l	#6,d1
	bra	.cute
	;
.ugly	tst	inline
	beq	.notin
	;here, we copy the inline code.
	subq	#1,a1
	move.l	a1,a0
	add	inline(pc),a1
	bra	pokecode2
	;
.notin	move.l	d1,-(a7)
	move	#$4eb9,d1
	bsr	pokewd
	move.l	(a7)+,d1
	bsr	addoff
	sub.l	18(a0),d1
	add.l	40(a0),d1
	bra	pokel

makebtst	move	d1,-(a7)
	move	tstmode(pc),d1
	bsr	pokewd
	bsr	getbbase
	bsr	pokewd
	move	(a7)+,d1
	movem.l	d0/d3-d7/a0-a2/a4,-(a7)
	bsr	tokejsr
	movem.l	(a7)+,d0/d3-d7/a0-a2/a4
	rts

getbbase	;this return returns varoff for blitzmode flag
	;in d1
	;it will create blitzoff if necessary
	;
	move	blitzoff(pc),d1
	cmp	#-1,d1
	bne	.done
	addq	#1,varoff
	bclr	#0,varoff+1
	move	varoff,d1
	move	d1,blitzoff
	addq	#2,varoff
.done	rts

tstmode	tst	0(a5)
	
inline	dc	0
blitzoff	dc	-1
blitzmode	dc	0	;+=amiga, -=blitz

fetchregs	;
.loop	move	(a2)+,d1
	beq	.done
	move	(a2)+,d2
	bsr	toreg
	bra	.loop
.done	rts

toreg	;d1=lib num, d2.b=reg num
	;
	cmp	#$ff00,d2
	bcc	.yeah
	;
	bclr	#15,d2	;btst	#15,d2
	beq	.nobm
	;OK, blitz mode must be ON for us to bother doing this one
	tst	blitzmode
	bmi	.yeah
	rts
.nobm	bclr	#14,d2	;btst	#14,d2
	beq	.yeah
	;OK, must be in amiga mode
	tst	blitzmode
	bpl	.yeah
	rts
.yeah	bsr	uselib
	tst.b	d2
	beq	.norm
	cmp.b	#4,d2
	bne	.suv
	move	#4,-(a7)
	move.l	#-6,-(a7)
	bra	.sendmd
	;
.suv	cmp.b	#3,d2
	bne	.notnmax
	clr	-(a7)
	move.l	#-4,-(a7)
	;
	;O.K., we are going to send the current maximum settings.
	;
.sendmd	lsr	#8,d2
	move	#$303c,d1	;move.w #x,dn
	btst	#7,d2
	beq	.skipad
	move	#$307c,d1	;move.w #x,an
	cmp	#$16,d2
	bne	.skipad
	move	#-1,lasta6
.skipad	and	#7,d2
	lsl	#8,d2
	lsl	#1,d2
	or	d2,d1
	bsr	pokewd
	move.l	18(a1),d1
	add.l	(a7)+,d1
	move	0(a1,d1.l),d1
	add	(a7)+,d1
	bra	pokewd
.notnmax	;
	move	d2,-(a7)
	lsr	#8,d2
	cmp	#$16,d2
	bne	.isnta6
	move	#-1,lasta6
.isnta6	move.l	18(a1),d1
	move	-6(a1,d1.l),-(a7)
	bsr	makeregop
	bsr	pokewd
	move	(a7)+,d1
	move	(a7)+,d2
	tst.b	d2
	bpl	.skippy1
	;
	;<0 - the rest is a register spec.
	;this reg is used to calc a max item (must be dn)
	;
	bsr	pokewd	;move.l x(a5),dn
	move	d2,-(a7)	;store reg used
	;
	add.l	18(a1),a1
	move.b	d2,d1
	and	#7,d1
	;
	tst.b	debugga
	beq	.norerr
	;
	move	d1,-(a7)
	lsl	#8,d1
	lsl	#1,d1
	or	#$b07c,d1	;cmp #x,dn
	bsr	pokewd
	move	-4(a1),d1
	bsr	pokewd
	move.l	maxchk(pc),d1	;bcs
	bsr	pokel
	move.l	a2,-(a7)
	move	#maxerr,d1
	bsr	tokejsr
	move.l	(a7)+,a2
	move	(a7)+,d1
	;
.norerr	move	-2(a1),d2	;shift amount
.shloop	cmp	#9,d2
	bcs	.simp
	movem	d2/d1,-(a7)
	;
	;and	#7,d2	;?????
	moveq	#0,d2	;!!!!!
	;
	lsl	#8,d2
	lsl	#1,d2
	or	d2,d1
	or	lsldn(pc),d1
	bsr	pokewd
	movem	(a7)+,d1/d2
	subq	#8,d2
	bra	.shloop
.simp	move	d1,-(a7)
	tst	d2
	beq	.simp2
	;
	and	#7,d2	;?????
	;
	lsl	#8,d2
	lsl	#1,d2
	or	d2,d1
	or	lsldn(pc),d1
	bsr	pokewd
.simp2	;
	;Shifts are done, add'em to the opcode
	;
	move	(a7)+,d1
	and	#7,d1
	or	maxdo(pc),d1
	move	(a7)+,d2
	lsl	#1,d2
	and	#$e00,d2
	or	d2,d1
	bra	pokewd
	;
.skippy1	cmp.b	#1,d2
	beq	.skippy
	;
	;select used of a max block
	;
	addq	#4,d1
	;
	tst.b	debugga
	beq	.skippy
	;
	bsr	pokewd
	swap	d1
	move	.theretest(pc),d1
	swap	d1
	bsr	pokel
	move.l	.theretest+4(pc),d1
	bsr	pokel
	move.l	.theretest+8(pc),d1
	bra	pokel
	;
.skippy	;select base of a max block
	bra	pokewd

.theretest	tst.l	0(a5)
	bne	.ttskip
	moveq	#1,d0
	trap	#0
.ttskip

.norm	;
	lsr	#8,d2
	cmp.b	#$16,d2
	bne	.nota6
	move	10(a1),d1
	cmp	lasta6,d1
	beq	.sk
	move	d1,lasta6
.nota6	bsr	makeregop
	tst	26(a1)
	bpl	.long
	cmp	stackop(pc),d1
	bne	.notst
	subq	#2,stackuse
.notst	or	#$1000,d1
.long	bsr	pokewd
	move	10(a1),d1
	bsr	pokewd
.sk	rts

lsldn	lsl	#8,d0

maxchk	bcs	.ok
	jsr	0
.ok	;

maxdo	add	d0,a0
	;lea	0(a0,d0),a0

stackopuse	dc	0
stackop	move.l	0(a5),-(a7)

makeregop	;make move x(a5),dn/an based on d2
	;
	cmp.b	#$ff,d2
	bne	.notst
	move	stackop(pc),d1
	addq	#4,stackuse
	rts
.notst	move.l	a3,-(a7)
	lea	regtransd,a3
	btst	#4,d2
	beq	.skip
	lea	regtransa,a3
.skip	and	#7,d2
	move	d2,d1
	lsl	#8,d1
	lsl	#1,d1
	or	(a3),d1
	move.l	(a7)+,a3
	rts

ifchar	;return eq=1 if <,=,>
	;
	cmp	#60,d0
	bcs	.no
	cmp	#62,d0
	bhi	.no
	sub	#60,d0
	cmp	d0,d0
.no	rts

evalconst	;
	bsr	bakup
	;
	;evaluate a constant at a5...
	;first char in d0...
	;
	;get long into d3 (d6=0)
	;or ffp into d3 (d6<>0)
	;
evalconst2	;
evalconst3	;move.l maths,a6
	;
	move	regat,-(a7)
	clr	regat
	move.l	pc,-(a7)
	move.l	libat,-(a7)
	move	nomemleft,-(a7)
	move	lasta6,-(a7)
	move	cfetchmode,-(a7)
	;
	bne	.something
	;
	move.l	libat,oldlibat
	move.l	constpcat,a0
	move.l	a0,pc
	bra	.some2
	;
.something	;already cfetching!
	;
	move.l	pc,a0	;continue in cmode buff
	;
.some2	move.l	a0,-(a7)
	;
	move.l	constlibat,libat	;for overflow
	clr	nomemleft
	move	#-1,lasta6
	move	#-1,cfetchmode
	;
	bsr	arreval	;!
	;
	move	#$2600,d1	;move.l d0,d3
	or	regat,d1
	bsr	pokewd
	move	#$4e75,d1	;rts!
	bsr	pokewd
	;
	move	nomemleft,d1
	bne	conmemerr
	;
	move.l	(a7)+,a0
	jsr	flushc
	;
	jsr	(a0)
	;
	move	(a7)+,cfetchmode
	move	(a7)+,lasta6
	move	(a7)+,nomemleft
	move.l	(a7)+,libat
	move.l	(a7)+,pc
	move	(a7)+,regat
	;
	bra	reget

oldlibat	dc.l	0

doincdir	lea	incdir,a0
.loop	cmp	#'"',d0
	beq	.skip
	move.b	d0,(a0)+
	tst	d0
	beq	.done
	bmi	syntaxerr
.skip	bsr	getchar3
	bra	.loop
.done	rts

makeiname	;
	;create include name
	;
	lea	namebuff,a1
	lea	incdir,a0
	moveq	#-1,d2
.loop0	addq	#1,d2
	move.b	(a0)+,(a1)+
	bne	.loop0
	subq	#1,a1
	bsr	bakup
	;
.loop	bsr	getchar3
	tst	d0
	bmi	syntaxerr
	cmp.b	#'"',d0
	beq	.loop
	move.b	d0,(a1)+
	beq	.done
	addq	#1,d2
	bra	.loop
.done	tst	d2
	beq	syntaxerr
	rts

readinc	;do include next line
	;a5=position in buffer
	;
	move.l	firstinc,a2
	;
	move.l	14(a2),a5
	move.l	4(a2),a0
	move	12(a2),d0
	lea	0(a0,d0),a0	;end of buffer!
	move.l	a5,a1
.loop	cmp.l	a0,a1
	bcc	readpend
	tst.b	(a1)+
	bne	.loop
	bra	imakeend
	
readpend	;o.k., no 0's past where we're at!
	;
	move.l	4(a2),a1
.loop	cmp.l	a0,a5
	bcc	.skip
	move.b	(a5)+,(a1)+
	bra	.loop
.skip	move.l	a1,d0
	sub.l	4(a2),d0
	move	d0,12(a2)	;chars in there
	;
	move.l	dos,a6
	move.l	8(a2),d1
	move.l	a1,d2
	move.l	#inclen-1,d3
	sub	d0,d3
	;
	jsr	read(a6)
	;
	tst.l	d0 
	bmi	readerr
	add	d0,12(a2)
	beq	closeinc
	move.l	4(a2),a5
	move	12(a2),d0
	clr.b	0(a5,d0)
imakeend	move.l	a5,a0
.loop2	tst.b	(a0)+
	bne	.loop2
	move.l	a0,14(a2)
	rts

closeinc	move.l	8(a2),d1
	jsr	close(a6)
	move.l	4.w,a6
	move.l	4(a2),a1
	move.l	#inclen,d0
	jsr	freemem(a6)
	;
	move.l	(a2),firstinc
	move.l	a2,a1
	moveq	#0,d0
	move.b	18(a2),d0
	move.l	4.w,a6
	jsr	freemem(a6)
	subq	#1,numincs
	bne	readinc
	rts

freexincs	move.l	firstxinc,a2
	clr.l	firstxinc
.loop	cmp	#0,a2
	beq	.done
	moveq	#0,d0
	move.b	4(a2),d0
	move.l	a2,a1
	move.l	(a2),a2
	move.l	4.w,a6
	jsr	freemem(a6)
	bra	.loop
.done	rts

freeincs	move.l	firstinc,a2
	clr.l	firstinc
.loop	cmp	#0,a2
	beq	.done
	move.l	8(a2),d1
	beq	.noclose
	move.l	dos,a6
	jsr	close(a6)
.noclose	move.l	4(a2),d0
	beq	.skip
	move.l	d0,a1
	move.l	#inclen,d0
	move.l	4.w,a6
	jsr	freemem(a6)
	;
.skip	moveq	#0,d0
	move.b	18(a2),d0
	move.l	a2,a1
	move.l	(a2),a2
	move.l	4.w,a6
	jsr	freemem(a6)
	bra	.loop
.done	rts

pokedata2l	;
	;poke a long into data2!
	;
	swap	d0
	bsr	pokedata2
	swap	d0
	;
pokedata2	;poke a word into data2 (data staements)
	;
	move.l	data2,a4
	cmp.l	allat,a4
	bcc	.over
	move	d0,(a4)+
	move.l	a4,data2
	rts
.over	move	#-1,nomemleft
	addq.l	#2,data2
	rts
	;

pokedata2b	move.l	data2,a4
	cmp.l	allat,a4
	bcc	.over
	move.b	d0,(a4)+
	move.l	a4,data2
	rts
.over	move	#-1,nomemleft
	addq.l	#1,data2
	rts

getsp	;get a string parameter for conditional stuff
	;into a0
	cmp	#'"',d0
	bne	syntaxerr
getsp2	bsr	getchar3
	cmp.b	#'"',d0
	beq	.done
	tst	d0
	beq	syntaxerr
	move.b	d0,(a0)+
	bra	getsp2
.done	clr.b	(a0)
	rts

numcom	tst.l	d3
	rts

strcom	;compare strings. set flags accordingly
	;
	lea	namebuff,a0
	lea	namebuff2,a1
.loop	move.b	(a0)+,d0
	beq	.short
	cmp.b	(a1)+,d0
	beq	.loop
	rts
.short	tst.b	(a1)
	bne	.lt
	rts
.lt	cmp	#1,d0
	rts

;-----------built in tokens------------;
tokes

dodeftype	cmp	#'.',d0
	bne	syntaxerr
	bsr	makename
	lea	alltypes,a2
	bsr	findtype
	bne	notypeerr
	bsr	reget
	bne	.more
	move.l	a2,defaulttype
	rts	
.more	;
	;deftype.l varlist...
	;
	move.l	defaulttype,-(a7)
	move.l	a2,defaulttype
	;
.loopz	bsr	getvname
	bsr	fetchvar
	cmp	#',',d0
	bne	.done
	bsr	getchar3
	bra	.loopz
	;
.done	move.l	(a7)+,defaulttype
	rts

maxprep1	lea	0(a5),a2
maxprep2	move.l	a2,d0

domaxlen	;set a strings maximum length.
	;
	bsr	getvname
	bsr	fetchvar
	bsr	calcvar
	;
	cmp.b	#7,d2
	bne	mismatcherr
	move	varmode(pc),-(a7)
	cmp	#'=',d0
	bne	syntaxerr
	btst	#15,d2
	bne	.already
	move	maxprep1(pc),d1
	bsr	pokewda5s
	move	d3,d1
	bsr	pokewd
.already	move	maxprep2(pc),d1
	bsr	pokewd
	addq	#1,regat
	moveq	#3,d2
	bsr	eval
	move	#maxlen,d1
	tst	(a7)+
	beq	tokejsr
	addq	#1,d1
	bra	tokejsr

getmaxel	move	d0,d1
	bpl	syntaxerr
	bclr	#15,d1
	bsr	findtoke
	move.l	18(a2),d0
	tst	-2(a2,d0.l)
	beq	freeerr
	moveq	#2,d2
	move.l	a2,-(a7)
	;
	bsr	eval
	;
	move.l	(a7)+,a2
	move.l	a2,mymaxlib
	;
	add.l	18(a2),a2
	tst.b	debugga
	beq	.pen
	;
	;check maximum overflow
	;
	move	regat,d1
	lsl	#8,d1
	lsl	#1,d1
	or	#$b07c,d1	;cmp #x,dn
	bsr	pokewd
	move	-4(a2),d1
	bsr	pokewd
	move.l	maxchk,d1	;bcs
	bsr	pokel
	move.l	a2,-(a7)
	move	#maxerr,d1
	bsr	tokejsr
	move.l	(a7)+,a2
	;
.pen	move	-2(a2),d2	;# shifts
.loop	move	regat,d1
	or	lslimm,d1
	cmp	#8,d2
	bcs	.under
	bsr	pokewd
	subq	#8,d2
	bne	.loop
	bra	.shdone
.under	move	d2,d0
	lsl	#8,d0
	lsl	#1,d0
	or	d0,d1
	bsr	pokewd
.shdone	rts

free	move.l	0(a5),a3
	add	d0,a3
freef	;

mymaxlib	dc.l	0

dofree	bsr	getmaxel
	;
	lea	free(pc),a0
	lea	freef(pc),a1
	move	-6(a2),2(a0)
	bsr	pokecode
	;
	move.l	-10(a2),d1
	;
maxjsr	beq	nosuperr
	move.l	mymaxlib(pc),a2
	bra	makelibsub

douse	bsr	getmaxel
	;
	lea	use,a0
	lea	usef,a1
	move	-6(a2),2(a0)
	move	-6(a2),-2(a1)
	addq	#4,-2(a1)
	bsr	pokecode
	;
	move.l	-14(a2),d1
	;
	bra	maxjsr

doelse2	bsr	getchar3
doelse	move.l	firstif,d0
	beq	noiferr
	move.l	d0,a0
	cmp.b	#1,13(a0)
	beq	illelseerr
	move	#$6000,d1
	swap	d1
	bsr	pokel
	moveq	#0,d1
	bsr	doendif2
	move.l	pc,8(a0)
	bra	dothen

docerr	;
	lea	namebuff,a0
	move.l	a0,-(a7)
	bsr	getsp
	bra	err

docnif	;
	bsr	evalconst
	moveq	#5,d1	;beq
	bsr	bakup
	lea	numcom,a0
	bra	compare

docsif	;
	lea	namebuff,a0
	bsr	getsp
	bsr	getchar3
	bsr	collif
	lea	namebuff2,a0
	bsr	getsp
	lea	strcom,a0
	;
compare	;use subroutine in a0, cc in d1 to compare then enable
	;or disable compilation
	;accordingly
	;
	lsl	#2,d1
	lea	cifbras,a1
	move.l	0(a1,d1),-(a7)
	moveq	#-1,d1	;comp flag
	jsr	(a0)
	move.l	(a7)+,a1
	jmp	(a1)
	;
cifeq	beq	cifdo
	bra	cifdont
cifne	bne	cifdo
	bra	cifdont
ciflt	blt	cifdo
	bra	cifdont
cifle	ble	cifdo
	bra	cifdont
cifgt	bgt	cifdo
	bra	cifdont
cifge	bge	cifdo
	;
cifdont	moveq	#0,d1
cifdo	move.l	concomsp,a0
	move	comflag,(a0)+
	move.l	a0,concomsp
	move	d1,comflag
	bsr	getchar3
	bne	syntaxerr
	bra	bakup

rescode	move.l	#0,0(a5)
rescode2	move.l	d0,0(a5)

dorestore	;Restore 'label'
	;
	move	#64535,d1
	bsr	uselib
	;
	bsr	reget
	beq	.resbeg
	bsr	makealab	;get label name!
	move	rescode(pc),d1
	bsr	pokewd
	bsr	addoff	;add offset
	move.l	12(a2),d1
	bsr	pokel
	move	rescode+6(pc),d1
	bsr	pokewd
	move.l	4(a2),d1	;is it outstanding?
	beq	.no
	;yes - tell it that reference is a DATA statement one
	move.l	d1,a1
	addq.l	#1,4(a1)	;make odd - flag for data reference.
	rts
	;
.no	;data label not outstanding...this not working!?!?
	;

	rts
	;
.resbeg	;restore to beginning...
	move	#getdstart,d1
	jsr	tokejsr
	move.l	rescode2(pc),d1
	jmp	pokel

doread	;
	move	#64535,d1
	bsr	uselib
	;
.loop	move.l	dataget,d1
	bsr	pokel
	bsr	getvname
	bsr	fetchvar
	bsr	calcvar
	btst	#14,d2
	beq	.notap
	;
	move.b	#6,d2	;pointer becomes an address!
	;
.notap	tst.b	d2
	beq	noleterr	;read in a whole struct....later!
	tst.b	debugga
	beq	.norerr
	;
	move	#$7000,d1
	move.b	d2,d1
	and.b	#15,d1
	bsr	pokewd
	move	#datachk,d1
	move	d2,-(a7)
	bsr	tokejsr
	move	(a7)+,d2
	;
.norerr	cmp.b	#7,d2
	beq	.string
	cmp.b	#1,d2
	bne	.notbyte
	;
	lea	dataletb2,a0
	lea	dataletb2f,a1
	btst	#15,d2
	beq	.bimm
	bsr	pokecode
	bra	.next
.bimm	lea	dataletb,a0
	lea	dataletbf,a1
	;
	tst	varmode
	beq	.byteglobal
	lea	dataletbl,a0
	lea	dataletblf,a1
.byteglobal	;
	move	d3,4(a0)
	bsr	pokecode
	bra	.next
	;
.notbyte	lea	dataletw,a0
	cmp.b	#3,d2
	bcs	.word
	lea	dataletl,a0
.word	btst	#15,d2
	beq	.imm
	move	4(a0),d1
	bsr	pokewd
	bra	.next
.imm	tst	varmode
	beq	.wlglobal
	addq	#6,a0
.wlglobal	move	d3,2(a0)
	move.l	(a0),d1
	bsr	pokel
.next	move.l	dataput,d1
	bsr	pokel
	cmp	#',',d0
	beq	.more
	rts
.more	bsr	getchar3
	bra	.loop	
.string	move	stlenget,d1
	bsr	pokewd	;move.l (a3)+,-(a7)
	btst	#15,d2
	bne	.ok
	;
	tst	varmode
	beq	.sglobal
	move	d3,leaampl+2
	move.l	leaampl,d1
	bra	.sskip
	;
.sglobal	move	d3,leaamp+2
	move.l	leaamp,d1
.sskip	bsr	pokel
	;
.ok	move	#astring,d1
	move	varmode,d2
	beq	.global
	subq	#1,d1
.global	bsr	tokejsr
	move	#-1,lasta6
	lea	stalign,a0
	lea	stalignf,a1
	bsr	pokecode
	bra	.next

getsize2	cmp	#'.',d0
	bne	.word
	bsr	getchar3
	cmp	#'w',d0
	beq	.word2
	cmp	#'b',d0
	beq	.byte
	cmp	#'l',d0
	bne	syntaxerr
	moveq	#2,d1
	rts
.byte	moveq	#0,d1
	rts
.word2	moveq	#1,d1
	rts
.word	moveq	#1,d1
	bra	bakup

dodcb	;
dodcb2	bsr	getsize2
	move	d1,-(a7)
	bsr	evalconst2
	cmp	#',',d0
	bne	syntaxerr
	move.l	d3,-(a7)
	bsr	evalconst2
	move.l	d3,d1	;to put in memory
	move.l	(a7)+,d3	;number of times
	move	(a7)+,d2
	beq	.byte
	bsr	alignpc
	cmp	#1,d2
	beq	.word
.long	swap	d1
	bsr	pokewd
	swap	d1
	bsr	pokewd
	subq.l	#1,d3
	bne	.long
	rts
.word	bsr	pokewd
	subq.l	#1,d3
	bne	.word
	rts
.byte	bsr	pokebyte
	subq.l	#1,d3
	bne	.byte
	rts

dods	bsr	getsize2
	move	d1,-(a7)
	bsr	evalconst2
	move	(a7)+,d1
	lsl.l	d1,d3
	add.l	d3,pc
	rts

insasm2	move	d0,-(a7)
	lea	dummyasm,a0
	move.l	pc,a1
	move	asmlen2,asmlen
	bsr	insasm
	move	(a7)+,d0
	rts

dodc	bsr	getsize2
	move.l	#namebuff,asmbuff
	tst	d1
	beq	.byte
	cmp	#1,d1
	beq	.word
	;
	;Long!
	;
	moveq	#11,d3
	bsr	alignpc
.lloop	bsr	asmconst
	bsr	insasm2
	bsr	pokel
	cmp	#',',d0
	beq	.lloop
	rts
	;
.byte	;Byte!
	;
	moveq	#17,d3
.bloop	bsr	getchar3
	cmp	#'"',d0
	bne	.notq
.qloop	bsr	getchar3
	beq	syntaxerr
	cmp	#'"',d0
	beq	.qdone
	move	d0,d1
	bsr	pokebyte
	bra	.qloop
.qdone	bsr	getchar3
	bra	.bdone
.notq	bsr	bakup
	bsr	asmconst
	subq.l	#1,pc
	bsr	insasm2
	addq.l	#1,pc
	bsr	pokebyte
.bdone	cmp	#',',d0
	beq	.bloop
	rts
.word	;
	moveq	#16,d3
	bsr	alignpc
.wloop	bsr	asmconst
	bsr	insasm2
	bsr	pokewd
	cmp	#',',d0
	beq	.wloop
	rts

doeven4	;long align
	addq.l	#3,pc
	and	#$fffc,pc+2
	rts

doeven8	;phrase align
	addq.l	#7,pc
	and	#$fff8,pc+2
	rts

doeven	;word align
alignpc	addq.l	#1,pc
	bclr	#0,pc+3
	rts

datasize	dc	0

pdt	;insert type of data item into code
	;if runtime error checking is on.....
	;
	;codes for data..... Dn
	;when 'D' means data, and n = 1 (byte) to 7 (string)
	tst.b	debugga
	beq	.skip
	move	#'D ',d0
	move.b	datasize+1(pc),d0
	bra	pokedata2
.skip	rts

dodata	;
	move	#64535,d1
	bsr	uselib
	bsr	bakup 
	jsr	sizespec2	;get size of it into d1
	move	d1,datasize
	;
	;(eg. Data.w)
	;
	cmp	#7,d1
	beq	.string
	;
	move	d1,-(a7)
.more	bsr	pdt
	move	(a7),d2
	bsr	fetchdata
	cmp	(a7),d2
	beq	.dataok
	;
	move	d2,d1
	move	(a7),d2
	cmp	#2,d2
	bne	.notw
	cmp	#3,d1
	bne	baddaterr
	cmp.l	#65536,d3
	bcc	baddaterr
	bra	.dataok
	;
.notw	cmp	#1,d2
	bne	.notb
	cmp	#2,d1
	bne	baddaterr
	cmp.l	#256,d3
	bcc	baddaterr
	bra	.dataok
	;
.notb	bra	baddaterr
	;
.dataok	cmp	#3,d2
	bcc	.notword
	bsr	pokedata2
	bra	.next
.notword	bsr	pokedata2l
.next	bsr	reget
	cmp	#',',d0
	beq	.more
	addq	#2,a7
.isdone	rts	

.string	bsr	pdt
	move.l	data2,-(a7)
	bsr	pokedata2l
	moveq	#0,d1
.loop	bsr	getchar3
	beq	.done
	cmp	#'"',d0
	beq	.quoted
	cmp	#',',d0
	beq	.done
.loop2	bsr	pokedata2b
	addq	#1,d1
	bsr	getchar
	tst	d0
	beq	.done
	cmp	#',',d0
	beq	.done
	bra	.loop2
	;
.quoted	bsr	getchar3
	beq	notqerr
	cmp	#'"',d0
	beq	.done2
	bsr	pokedata2b
	addq	#1,d1
	bra	.quoted
.done2	bsr	getchar3
.done	move.l	(a7)+,a0
	move	nomemleft,d2
	bne	.nopoke
	move.l	d1,(a0)
.nopoke	addq.l	#1,data2
	bclr	#0,data2+3
	cmp	#',',d0
	beq	.string
	rts	

doshared	;
	;set up SHARED variables.....
	;
	move	procmode,d1
	beq	sharederr
	move	d1,-(a7)
	clr	procmode
.loop2	bsr	getvname
	move	d2,-(a7)
	;
	lea	firstglob,a2
	bsr	findvar
	bne.s	.notfound
	;
.try2	move.b	flagmask+1,d1
	move.b	7(a2),d3
	eor.b	d3,d1
	beq	dupsherr
	bsr	findlab
	beq.s	.try2
	;
.notfound	bsr	addhere
	move	(a7)+,d2
	move.l	a2,-(a7)	;new glob
	bsr	fetchvar
	move.l	(a7)+,a2
	moveq	#4,d1
	addq	#4,a2
	addq	#4,a3
.loop	move	(a3)+,(a2)+
	dbf	d1,.loop
	btst	#1,flagmask+1
	beq	.done
	bsr	getchar3
	cmp	#')',d0
	bne	syntaxerr
	bsr	getchar3
.done	cmp	#',',d0
	bne	.done2
	bsr	getchar3
	bra	.loop2
.done2	move	(a7)+,procmode
	rts

doxinclude	;
	;do EXCLUSIVE (once only!) include
	;
	bsr	makeiname
	bsr	findxinc
	beq	.done
	move	d2,-(a7)
	bsr	addhere
	move	(a7)+,d2
	bra	doinc2
.done	rts

doincbin	bsr	makeiname
	move.l	#namebuff,d1
	moveq	#-2,d2
	move.l	dos,a6
	jsr	lock(a6)
	move.l	d0,d7
	beq	noincerr
	move.l	d7,d1
	move.l	macrobuff,d2
	jsr	examine(a6)
	move.l	macrobuff,a0
	move.l	4(a0),d0
	bpl	noincerr
	move.l	124(a0),d3	;length
	move.l	d7,d1
	jsr	unlock(a6)
	move.l	#namebuff,d1
	move.l	#1005,d2
	jsr	open(a6)
	move.l	d0,d7
	beq	noincerr
	move.l	pc,d0
	add.l	d3,d0
	cmp.l	libat,d0
	bhi	.over
	move.l	pc,d2
	move.l	d7,d1
	jsr	read(a6)
	cmp.l	#-1,d0
	beq	readerr
	add.l	d0,pc
	bra	.close
	;
.over	move	#-1,nomemleft
	move.l	d0,pc
	;
.close	move.l	d7,d1
	jmp	close(a6)

doinclude	;
	;do a standard include
	;
	tst	dirmode
	bne	illdirerr
	;
	bsr	makeiname
doinc2	bsr	findinc
	beq	alincerr
	lea	firstinc,a2
	bsr	addhere2	
	;
	clr	12(a2)
	clr.l	4(a2)
	move.l	#inclen,d0
	moveq	#1,d1
	move.l	4.w,a6
	jsr	doallocmem
	;
	move.l	d0,4(a2)
	move.l	d0,14(a2)
	move.l	d0,a5
	;
	move.l	#namebuff,d1
	move.l	#1005,d2
	move.l	dos,a6
	jsr	open(a6)
	;
	move.l	d0,8(a2)
	beq	noincerr
	addq	#1,numincs
	move.l	passstack,a7
	jmp	passnxt

coolnest	dc	0

macline	dc	0

domacro	;shit!
	;
	move	linenumat,macline
	;
	bsr	makename2
	beq	syntaxerr
	bsr	bakup
	bsr	findmac
	beq	dupmacerr
	bsr	addhere
	clr	10(a2)
	move.l	macrobuff,a0
	moveq	#0,d2	;flag for nothing got yet!
	clr	coolnest
.gather	bsr	getcharb	;get next character
			;but not conditional stuff
	tst	d0
	bne	.skip
	movem.l	d2/a0/a2,-(a7)
	jsr	nextline
	beq	macenderr
	movem.l	(a7)+,d2/a0/a2
	tst	d2
	beq	.gather
	moveq	#58,d0
	bra	.notend2
.skip	bpl	.notend2
	cmp	#$800d,d0
	bne	.notamac
	addq	#1,coolnest
	bra	.notend
	;
.notamac	cmp	#$8002,d0
	bne	.notend
	bsr	getchar3
	cmp	#$800d,d0
	bne	.notem
	subq	#1,coolnest
	bmi	.macdone
	;
.notem	move	d0,-(a7)
	move	#$8002,d0
	bsr	macputw
	move	(a7)+,d0
	bra	.notend
	;
.notend	bsr	macputw
	bra	.gather
.notend2	bsr	macputb
	bra	.gather
	;
.macdone	addq	#4,a7
	move.l	a0,d0
	sub.l	macrobuff,d0
	;
	;clean up leading and trailing ':'s
	;
.mclean	beq	.cdone
	cmp.b	#':',-(a0)
	bne	.cdone
	cmp	#1,d0
	beq	.cdo
	tst.b	-1(a0)
	bmi	.cdone
.cdo	subq	#1,d0
	bra	.mclean
	;
.cdone	move	d0,8(a2)
	beq	.skip2
	moveq	#1,d1
	move.l	4.w,a6
	jsr	doallocmem
	;
	move.l	d0,a0
	move.l	a0,4(a2)
	move	8(a2),d1
	beq	.skip2
	subq	#1,d1
	move.l	macrobuff,a1
.lll	move.b	(a1)+,(a0)+
	dbf	d1,.lll
.skip2	;
	bra	getchar3

macputw	move	d0,d1
	lsr	#8,d1
	move.b	d1,(a0)+
macputb	moveq	#-1,d2
	move.b	d0,(a0)+
	cmp.l	macrobufff,a0
	bcc	macbigerr
	rts

collif	;collect a comparison thingy
	;
	bsr	ifchar
	bne	syntaxerr
	move	d0,d1
	bsr	getchar3
	bsr	ifchar
	bne	.skip
	addq	#1,d0
	move	d0,d2
	add	d0,d0
	add	d2,d0
	add	d0,d1
	move	d1,d0
	and	#3,d0
	cmp	#3,d0
	beq	syntaxerr
	bsr	getchar3
.skip	rts
	
thetst1	tst.b	d0
thetst2	tst.w	d0
thetst3	tst.l	d0
thetst4	tst.l	(a7)+	;Any Length?
thetst5	jsr	-48(a6)

posbr	beq	posbr
negbr	bne	negbr

dounless	moveq	#-1,d2
	bra	doifm

dowhile	moveq	#1,d1	;while flag
	moveq	#0,d2	;negate flag
	bra	doif2

freereps	lea	firstrep,a2
	moveq	#8,d2
	bra	freeslist

freesels	lea	firstsel(pc),a2
	moveq	#14,d2
	;
freeslist	;free a simple list. a2=lea of list, d2=size
	;
	moveq	#0,d3
	;
freelist	;a2=lea of list, d2=size of item
	;d3=offset to sub list, d4=size of sublist item
	;
	;if d3=0 then single list free only.
	;
	move.l	(a2),d0
	clr.l	(a2)
	move.l	d0,a2
	move.l	4.w,a6
.loop	cmp	#0,a2
	beq	.done
	tst	d3
	beq	.skip
	movem.l	a2/d2-d3,-(a7)
	add	d3,a2
	move.l	d4,d2
	bsr	freeslist
	movem.l	(a7)+,a2/d2-d3
.skip	move.l	a2,a1
	move.l	d2,d0
	move.l	(a2),a2
	jsr	freemem(a6)
	bra	.loop
.done	rts

firstsel	dc.l	0
selpushb	and	#255,d0
selpushw	move	d0,-(a7)
selpushbf	;
selpushl	move.l	d0,-(a7)
selpushlf	;
selpushs	lea	4(a7),a2	;(a7)=len of string!
selpushsf	;

selcomb	and	#255,d0
selcomw	cmp	(a7),d0
selcombf	;
selcoml	cmp.l	(a7),d0
selcomlf	;
selbne	bne	selbne

endsel	addq	#8,a7

doendsel	;END SELECT
	;
	move.l	firstsel(pc),d0
	beq	eselerr
	move.l	d0,a2
	bsr	fillbne
	;
	;fill in all bras at end of cases!
	move.l	4.w,a6
	;
.loop	move.l	4(a2),d0
	beq	.done
	;
	move.l	d0,a3
	move.l	4(a3),a0
	move.l	pc,d1
	sub.l	a0,d1
	cmp.l	#32767,d1
	bhi	cbraerr
	move	nomemleft,d0
	bne	.skip
	move	d1,(a0)
.skip	;free it up!
	move.l	(a3),4(a2)	;next of me is new first
	move.l	a3,a1
	moveq	#8,d0
	jsr	freemem(a6)
	bra	.loop
.done	;
	jsr	popselect	;fix stack on select
	;
	move.l	firstsel(pc),a1
	move.l	(a1),firstsel
	moveq	#14,d0
	move.l	4.w,a6
	jsr	freemem(a6)
	bra	getchar3

endselstr	move.l	(a7)+,a1
	subq	#8,a1
	moveq	#9,d0
	add.l	(a1),d0
endselstrf	addq	#2,a7	;for runtime errs!
endselstrf2	;

dodefault	move.l	firstsel(pc),d0
	beq	defaerr
	move.l	d0,a2
	bsr	fillbra
	bsr	fillbne
	clr.l	8(a2)
	move	12(a2),d2
	bra	casechk

fillbne	;a2=sel
	move.l	8(a2),d0
	beq	.skip	;none to do!
	move.l	d0,a0
	move.l	pc,d1
	sub.l	a0,d1
	cmp.l	#32767,d1
	bhi	cbraerr
	move	nomemleft,d0
	bne	.skip
	move	d1,(a0)
.skip	rts

fillbra	;make a bra if necessary
	;
	move.l	8(a2),d0
	beq	.skip
	;
	;OK, we're after a case thingy. add a BRA
	;
	move.l	d0,a3
	move	#$6000,d1
	bsr	pokewd	;BRA
	moveq 	#8,d0
	moveq	#1,d1
	move.l	4.w,a6
	jsr	doallocmem
	move.l	d0,a0
	move.l	4(a2),(a0)
	move.l	a0,4(a2)
	move.l	pc,4(a0)
	bra	pokewd
	;
.skip	rts

casechk	tst.b	debugga
	beq	.norerr
	move	#casechkw,d1
	cmp	#3,d2
	bcs	.dochk
	addq	#1,d1
.dochk	bra	tokejsr
.norerr	rts

docase	;eg : CASE a+10
	;
	;first, fill in last bra (if there is one!)
	;
	move.l	firstsel(pc),d0
	beq	caseerr
	move.l	d0,a2
	bsr	fillbra
	bsr	fillbne
	;
	move	12(a2),d2	;type to get!
	move	d2,-(a7)
	bsr	casechk
	move	(a7),d2
.norerr	bsr	bakeval
	move	(a7)+,d2	;types to compare
	lea	selcomb(pc),a0
	lea	selcombf(pc),a1
	cmp	#1,d2
	beq	.doit
	lea	selcomw(pc),a0
	cmp	#2,d2
	beq	.doit
	lea	selcoml(pc),a0
	lea	selcomlf(pc),a1
	cmp	#7,d2
	bcs	.doit
	;Strings....
	move	#casestrcomp,d1
	bsr	tokejsr
	bra	.doneit
	;
.doit	bsr	pokecode
.doneit	move	selbne(pc),d1
	bsr	pokewd
	move.l	firstsel(pc),a0
	move.l	pc,8(a0)
	bra	pokewd

pcchk	move	#"sE",-(a7)

clrst	clr.l	-(a7)

sellineat	dc	0

doselect	;OK, as in : SELECT opt
	;
	tst.b	debugga
	beq	.norerr
	move.l	pcchk(pc),d1	;move #"sE",-(a7)
	bsr	pokel
.norerr	;
	move	linenumat,sellineat
	bsr	pushstart	;we may have to CLR -(a7)!
	moveq 	#0,d2
	bsr	bakevalu	;Evaluate
	bsr	pushdo
	cmp	#7,d2
	bne	.nos
	move	clrst(pc),d1
	bsr	pokewd
	;
.nos	bsr	pushput
	lea	selpushb(pc),a0
	lea	selpushbf(pc),a1
	cmp	#1,d2
	beq	.doit
	lea	selpushw(pc),a0
	cmp	#2,d2
	beq	.doit
	lea	selpushl(pc),a0
	lea	selpushlf(pc),a1
	cmp	#7,d2
	bcs	.doit
	;
	move	moved0a3,d1	;d0 to a3!
	bsr	pokewd
	lea	selpushs(pc),a0
	lea	selpushsf(pc),a1
	bsr	pokecode
	move	#astring,d1
	bsr	tokejsr
	bra	.doneit
	;
.doit	bsr	pokecode
	;
.doneit	moveq	#14,d0
	moveq	#1,d1
	move.l	4.w,a6
	jsr	doallocmem	;get the mem
	move.l 	d0,a0
	move.l	firstsel(pc),(a0)
	move.l	a0,firstsel
	clr.l	4(a0)
	clr.l	8(a0)	;default mode!
	move	d2,12(a0)
	rts

doforever	move.l	firstrep,d0
	beq	unterr1
	move	#$6000,d1	;BRA
	bsr	pokewd
	move.l	d0,a0
	move.l	4(a0),d1	;dest pc
	sub.l	pc,d1
	tst	d1
	bpl	unterr2
	bsr	pokewd
	move.l	4.w,a6
	bra	unlinkrep

dountil	move.l	firstrep,d0
	beq	unterr1	;no repeat!
	bsr	doif	;do the until
	;
	bsr	reget
	bne	syntaxerr
	;tst	lastchar
	;bne	syntaxerr
	;
	move	nomemleft,d1
	bne	.skip
	move.l	firstrep,a0
	move.l	pc,a1
	subq	#2,a1
	move.l	4(a0),d2	;dest pc.
	sub.l	a1,d2
	tst	d2
	bpl	unterr2
	move	d2,(a1)	;put in pra dest.
	;
.skip	move.l	firstif,a1
	move.l	(a1),firstif
	moveq	#14,d0
	move.l	4.w,a6
	jsr	freemem(a6)
unlinkrep	move.l	firstrep,a1
	move.l	(a1),firstrep
	moveq	#8,d0
	jmp	freemem(a6)

iflineat	dc	0
doif	moveq	#0,d2	;negate flag
doifm	moveq	#0,d1	;if flag
	;
doif2	;the main IF bit
	;
	;
	move	d1,-(a7)
	move.l	pc,-(a7)
	move	d2,-(a7)
	move	linenumat,iflineat
	;
	moveq	#0,d2
	bsr	bakevalu	;Get True/False Expression!
	;
	cmp	#5,d2
	beq	.float
	move	thetst1(pc),d1
	cmp	#1,d2
	beq	.gotst
	move	thetst2(pc),d1
	cmp	#2,d2
	beq	.gotst
	move	thetst4(pc),d1
	cmp	#7,d2
	beq	.gotst
	move	thetst3(pc),d1
	bra	.gotst
.float	move	#getffpbase,d1
	bsr	tokejsr
	move.l	thetst5(pc),d1
	bsr	pokel
	bra	.gotst2
	;
.gotst	bsr	pokewd
	;
.gotst2	move.l	posbr(pc),d1
	tst	(a7)+
	beq	.skip
	move.l	negbr(pc),d1
.skip	bsr	pokel
	;	
	moveq	#14,d0
	moveq	#1,d1
	move.l	4.w,a6
	jsr	doallocmem
	;
	move.l	d0,a0
	move.l	firstif,(a0)
	move.l	a0,firstif
	move.l	(a7)+,4(a0)
	move.l	pc,8(a0)
	move	(a7)+,12(a0)
	bsr	reget
	beq	ifdone
	bset	#7,12(a0)	;one liner
dothen	bsr	bakup	;to reget last
	move	#':',lastchar
ifdone	rts

ongotocode	cmp	#1,d0	;4
	blt	gc1skip	;4
	cmp	#0,d0	;2
	bgt	gc1skip
	add	d0,d0
	add	d0,d0
	move.l	gc1labs-4(pc,d0),a0
	jmp	(a0)
gc1skip	bra	gc1skip
gc1labs	;
ongotocodef

ongosubcode cmp	#1,d0	;4
	blt	gc2skip	;4
	cmp	#0,d0	;2
	bgt	gc2skip
	add	d0,d0
	add	d0,d0
	move.l	gc2labs-4(pc,d0),a0
	jsr	(a0)
gc2skip	bra	gc2skip
gc2labs
ongosubcodef

ongcode	cmp	#1,d0	;4
	blt	gc3skip	;4
	cmp	#0,d0	;2
	bgt	gc3skip
	add	d0,d0
	add	d0,d0
	move.l	gc3labs-4(pc,d0),a0
goset	move	#'gS',-(a7)	;for runtime error checking!
	jsr	(a0)
gc3skip	bra	gc3skip
gc3labs
ongcodef

labcnt	dc	0

doongo	;On expression Goto/Gosub Label[Label...]
	;
	;Get expression as a word.
	;
	moveq	#2,d2
	bsr	bakeval
	;
	lea	ongotocode(pc),a0
	lea	ongotocodef(pc),a1
	move	#gc1skip-ongotocode,d1
	cmp	#$8005,d0
	beq	.isok
	cmp	#$8006,d0
	bne	syntaxerr
	lea	ongosubcode(pc),a0
	lea	ongosubcodef(pc),a1
	move	#gc2skip-ongosubcode,d1
	;
	tst.b	debugga
	beq.s	.isok
	;
	jsr	chkstak
	lea	ongcode(pc),a0
	lea	ongcodef(pc),a1
	move	#gc3skip-ongcode,d1
	;
.isok	move	d1,-(a7)
	move.l	pc,-(a7)	;for when we know number of labels!
	bsr	pokecode
	clr	labcnt
	;
	;now, make a labels list!
	;
.loop	bsr	getchar3
	subq.l	#2,pc	;for makealab!
	bsr	makealab
	addq.l	#2,pc
	bsr	addoff
	move.l	8(a2),d1
	bsr	pokel
	addq	#1,labcnt
	bsr	reget
	cmp	#',',d0
	beq	.loop
	;
	move.l	(a7)+,a0
	move	(a7)+,d2
	move	nomemleft,d1
	bne	.done
	;
	move	labcnt(pc),d1
	move	d1,10(a0)		;for cmp#
	add	d1,d1
	add	d1,d1
	addq	#2,d1
	move	d1,2(a0,d2)		;for bra!
	;
.done	rts

dogosub	tst.b	debugga
	beq	.noerr
	;
	jsr	chkstak
	move.l	goset,d1
	bsr	pokel
	;
.noerr	move	gosubcode,d1
	bra	dogoto2

dogoto	move	gotocode,d1
dogoto2	move	d1,-(a7)
	bsr	makealab
	move	(a7)+,d1
	bsr	pokewd
	bsr	addoff
	move.l	8(a2),d1
	bra	pokel

eos	move	procmode,d1
	beq	badpenderr
	;
	move	#$4ef9,d1
	bsr	pokewd
	bsr	addoff
	;
	move.l	4.w,a6
	moveq	#8,d0
	moveq	#1,d1
	jsr	doallocmem
	move.l	d0,a0
	move.l	firstpend,(a0)
	move.l	a0,firstpend
	move.l	pc,4(a0)
	;
	bra	pokel

stateret	bsr	eos
	bra	getchar3

funcret	;
	move.l	thisproc,a0
	moveq	#0,d2
	move.b	5(a0),d2	;type returning!
	bsr	eval	;put return val in d0.
	;
	bra	eos

doreturn	;
	tst.b	debugga
	beq	normret
	move	#chkret,d1
	bra	tokejsr

normret	;a normal return
	;
.noerrchk	move	#$4e75,d1
	bra	pokewd

localslist	dc.l	0	;all locals for procs.
proclocals	dc.l	0	;for debugga!
procnum	dc	0
procnum2	dc	0
prolineat	dc	0

dostate	cmp	#$8007,d0
	beq	stateret
	moveq	#-1,d1	;statement flag
	bra	dofunc2
dofunc	cmp	#$8007,d0
	beq	funcret
	bsr	bakup
	jsr	sizespec2
	bsr	getchar3
	;
dofunc2	;do some checking.....
	;
	jsr	errchx
	move	linenumat,prolineat
	;
	addq	#1,procnum2
	move	procnum2(pc),procnum
	move	d1,procmode
	clr	locvaroff
	bsr	makename2
	cmp	#'{',d0
	bne	syntaxerr
	move.l	memlib,a0
	move	12(a0),memlibstat
	bclr	#15-8,12(a0)
	move	#$4ef9,d1	;make a jump around the proc
	bsr	pokewd
	bsr	addoff
	bsr	pokel
	;
	bsr	findproc
	beq	dupprocerr
	bsr	addhere
	move.l	pc,14(a2)	;new!
	move.l	a2,thisproc
	;
	lea	nops8,a0
	lea	nopsf,a1
	bsr	pokecode2
	;
	tst.b	debugga
	beq.s	.nodebug
	;
	moveq	#4,d1
	jsr	maketrap
	move.l	pc,proclocals
	bsr	pokel
	bsr	pokel
.nodebug	;
	lea	22(a2),a4
	move.b	procmode+1,5(a2)
	moveq	#0,d6
	moveq	#0,d5
	bsr	getchar3
	cmp	#'}',d0
	beq	.done
.more	bsr	getvname
	bsr	fetchvar
	cmp.l	#7,4(a2)
	bne	.notst
	lea	stbuff,a0
	move	d5,d1
	lsl	#2,d1
	move	d6,0(a0,d1)
	move	4(a3),2(a0,d1)
	addq	#1,d5
	moveq	#7,d2
	bra	.pgot
.notst	move	#$2940,d1
	moveq	#3,d2
	btst	#0,flagmask+1
	bne	.sgot
	cmp.l	#256,4(a2)
	bcc	illprocperr
	move	6(a2),d2
	cmp	#2,d2
	bhi	.sgot
	beq	.wgot
	eor	#$3000,d1
	bra	.sgot
.wgot	or	#$1000,d1
.sgot	or	d6,d1
	move.l	a4,-(a7)
	bsr	pokewd
	move	4(a3),d1
	bsr	pokewd
	move.l	(a7)+,a4
.pgot	addq	#1,d6
	cmp	#7,d6
	bcc	toovarerr
	move.b	d2,(a4)+
	cmp	#',',d0
	bne	.nomore
	bsr	getchar3
	bra	.more
.nomore	cmp	#'}',d0
	bne	syntaxerr
	;
.done	move.l	thisproc,a2
	lsl	#4,d5
	or	d5,d6
	move.b	d6,4(a2)
	lsr	#4,d6
	beq	.nostrings
	lea	stbuff,a0
	subq	#1,d6
.stloop	;
	;do all the string things
	;
	move	d6,d1
	lsl	#2,d1
	addq	#8,d1
	move	d1,funcst+2
	move.l	funcst,d1
	bsr	pokel
	move	(a0)+,d1
	or	movedna3,d1
	bsr	pokewd
	move	(a0)+,least+2
	move.l	least,d1
	bsr	pokel
	move.l	a0,-(a7)
	move	#lastring,d1
	bsr	tokejsr
	move.l	(a7)+,a0
	dbf	d6,.stloop
	;
.nostrings	bra	getchar3

linkput	move	nomemleft,d1
	bne	.skip
	move.l	pc,-(a7)
	;
	move.l	a0,pc
	move.l	linka4,d1
	bsr	pokel
	move	#clrloc,d1
	bsr	tokejsr2
	;
	move.l	(a7)+,pc
.skip	rts

procfixer	;fix up procs!
	;
	move.l	thisproc,a2
	move.l	14(a2),a0	;pc of proc
	move	6(a2),d1
	beq	.skiplink
	move	d1,linka4+2
	move	8(a2),d1
	bne	.howdy
	;
	;link only
	;
	addq	#6,a0
	move.l	a0,14(a2)
	bra	linkput
	;
.howdy	;link and jsr
	;
	move.l	a0,-(a7)
	bsr	linkput
	move.l	(a7)+,a0
	lea	10(a0),a0
	move.l	thisproc,a2
	bra	.cont
	;
.skiplink	move	8(a2),d1
	bne	.cont
	lea	16(a0),a0
	move.l	a0,14(a2)
	rts
.cont	move	nomemleft,d1
	bne	.contskip
	;
	move.l	pc,-(a7)
	;
	move.l	a0,pc
	move	#$4eb9,d1	;jsr
	bsr	pokewd
	bsr	addoff
	bsr	pokel
	;
	move.l	(a7)+,a0
	move.l	pc,a1
	move.l	a0,-(a1)
	move.l	a0,pc
	;
.contskip	move	8(a2),d4
	bpl	.linky
	move	#newmem,d1
	bsr	tokejsr2
	move.l	thisproc,a2
	move	8(a2),d4
	and	#32767,d4
.linky	beq	.skipstat
	;
	;allocate statics!
	;
	move.b	4(a2),d1
	and	#15,d1
	move	d1,-(a7)
	cmp	#5,d1
	bcs	.npush
	move	#$2f04,d1
	bsr	pokewd
	;
.npush	move.l	locdatast,d3
	bsr	datastart
	move	#localstat,d1
	bsr	tokejsr2
	;
	move	(a7)+,d1
	cmp	#5,d1
	bcs	.skipstat
	move	#$281f,d1
	bsr	pokewd
.skipstat	;
	move	#$4e75,d1
	bra	pokewd

domwait	lea	mwait,a0
	lea	mwaitf,a1
	bra	pokecode

donewtype	;
	cmp	#'.',d0
	bne	syntaxerr
	bsr	makename
	beq	laberr
	lea	alltypes,a2
	bsr	findtype
	bne	.ok1
	cmp.l	#$ff,4(a2)
	bne	typeerr
	bra	.ok2
.ok1	bsr	addhere
.ok2	clr.l	4(a2)
	move.l	a2,thistype
	clr.l	prevtype
	clr	typelen
	clr	linemode
	bsr	reget
	bne	typemode
	rts
	;
typemode	cmp	#$8002,d0
	beq	doend2
	bsr	bakup
	moveq	#0,d6	;not pointer
	cmp	#'*',d0
	bne	.skip
	moveq	#1,d6
	bsr	getchar3
	bra	.skipv
.skip	cmp	#'@',d0
	bne	.skipv
	moveq	#5,d6
	bsr	getchar3
.skipv	move	d6,flagmask
	bsr	makename
	beq	syntaxerr
	move.l	thistype,a2
	addq	#4,a2
	bsr	findvar
	beq	dupofferr	;beq	.skip2
	;
	bsr	addhere
	;
.skip2	move.l	a2,-(a7)
	cmp	#'.',d0
	beq	.skip3
	cmp	#'$',d0
	bne	.notstring
	move.l	#stringtype,d2
	bsr	getchar3
	bra	.skip4a
.notstring	move.l	prevtype,d2
	beq	notypeerr
	bra	.skip4
.skip3	bsr	makename
	beq	syntaxerr
	lea	alltypes,a2
	bsr	findtype
	beq	.gotit
	btst	#0,flagmask+1
	beq	notypeerr
	;
	;pointer type, gotta do something tricky!
	;
	bsr	addhere
	move	linenumat,8(a2)
	move.l	#$ff,4(a2)	;set to pointer crap
	;	
.gotit	move.l	a2,d2
.skip4	cmp.l	#bytetype,d2
	beq	.byte
.skip4a	addq	#1,typelen
	bclr	#0,typelen+1
.byte	moveq	#0,d3
	move.l	d2,a2
	move.l	a2,prevtype
	move	8(a2),d3
	move.l	(a7)+,a2
	move.l	d2,10(a2)
	moveq	#0,d4
	move	typelen,d4
	move	d4,4(a2)
	btst	#0,flagmask+1
	beq	.skipz
	moveq	#4,d3
.skipz	cmp	#'[',d0
	bne	.skipzz
	;
	;get constant value!
	;
	movem.l	d3/d4/a2,-(a7)
	bsr	evalconst2
	cmp	#']',d0
	bne	syntaxerr
	tst	d6
	bne	fpconerr
	move.l	d3,d1
	movem.l	(a7)+,d3/d4/a2
	bsr	getchar3
	move	d1,8(a2)
	mulu	d1,d3
	or	#2,flagmask
	;
.skipzz	add.l	d3,d4
	cmp.l	#32768,d4
	bcc	toolongerr
	move	flagmask,6(a2)
	move	d4,typelen
	rts

doendif3	move.l	firstif,d0
	beq	noiferr
	move.l	d0,a0
	move	12(a0),d0
	and	#255,d0
	cmp	d0,d1
	bne	badenderr
doendif2	cmp	#1,d1
	bne	.calcbra
	;put in while bra
	move	#$6000,d1
	bsr	pokewd
	move.l	pc,a1
	move.l	4(a0),d1
	sub.l	a1,d1
	bsr	pokewd
	;
.calcbra	move.l	8(a0),a1
	move.l	pc,d1
	sub.l	a1,d1
	addq.l	#2,d1
	;
	cmp.l	#32768,d1
	bcc	bigiferr
	;
	move	nomemleft,d0
	bne	.skip
	move	d1,-2(a1)
.skip	rts

dowend	bsr	bakup
dowend2	moveq	#1,d1
	bra	doendif
mydoendif2	bsr	bakup
mydoendif	moveq	#0,d1
doendif	bsr	doendif3
	bsr	freetheifz
	bra	getchar3

freetheifz	move.l	(a0),firstif
	move.l	a0,a1
	moveq	#14,d0
	move.l	4.w,a6
	jmp	freemem(a6)

doend2	bsr	getchar3
doend	beq	.done
	;
.loop	bsr	.doend3
	bsr	reget
	bne	.loop
	rts
.doend3	cmp	#$8001,d0
	bne	.nottype
	move	linemode,d1
	bne	modeerr
	addq	#1,typelen
	bclr	#0,typelen+1
	move.l	thistype,a0
	move	typelen,8(a0)
	move	#-1,linemode
	bra	getchar3
	;
.nottype	cmp	#$800b,d0
	beq	mydoendif
	;
.notif	cmp	#$800c,d0
	beq	dowend2
	;
.notwhile	cmp	#$8008,d0
	bne	.notstate
.state	;end of statement/function processing!
	;
	bra	endstate
	;
.notstate	cmp	#$8009,d0
	bne	.notfunc
	move	#$7000,d1
	bsr	pokewd
	move.l	thisproc,a0
	cmp.b	#7,5(a0)
	bne	.state
	move	putstlen,d1
	bsr	pokewd
	bra	.state
.notfunc	;
	cmp	#$8000+48,d0
	bne	.notsetint
	;
	move	procmode,d1
	bne	interr3
	;
	tst.b	debugga
	beq	.norerrf1
	;
	moveq	#3,d1
	jsr	maketrap
	;
	move	nomemleft,d1
	bne	.norerrf1
	;
	move.l	intcleanat,a0
	move.l	pc,(a0)
	;
	move	#gouse,d1
	bsr	tokejsr	;for runerrlib stack chex
	;
.norerrf1	move	intstring,d1
	beq	interr
	bpl	.nosp
	;
	move	intlevel,d1
	or	#$7200,d1
	bsr	pokewd	;moveq #level,d1
	move	#oldint,d1
	bsr	tokejsr
	clr	intlevel
	;
.nosp	clr	intstring
	;
	move.l	intfin,d1
	bsr	pokel
	;
	move.l	#$70004e75,d1
	bsr	pokel
	;
	move	nomemleft,d1
	bne	.sintdone
	move.l	intjmpat,a0
	move.l	pc(pc),(a0)
.sintdone	bra	getchar3

.notsetint	cmp	#$800e,d0	;end select?
	beq	doendsel
	cmp	#$8001+tnum,d0
	bne	.notseterr
	jmp	doendseterr
.notseterr	;
	;
	bra	syntaxerr
.done	tst	dirmode
	bne	baddirerr
	move	#endjmp,d1
	bra	tokejsr

dostop	tst	dirmode
	bne	baddirerr
	tst.b	debugga
	beq	badstoperr
	;
	move	#$d501,d1
	bra	tokejsr

docont	jmp	badconterr	;cont not currently supported!

nop	move	#$4e71,d1
	bra	pokewd

freefors	move.l	firstfor,a2
	clr.l	firstfor
	move.l	4.w,a6
.loop	cmp	#0,a2
	beq	.done
	move.l	a2,a1
	move.l	(a1),a2
	moveq	#0,d0
	move.b	16(a1),d0
	jsr	freemem(a6)
	bra	.loop
.done	rts

endstate	;End Statement
	;
	;first, fill in any FUNCTION RETURN type shit.....
	;
	move	procmode,d1
	beq	badpenderr
	;
	move	nomemleft,d1
	bne	.ship
	move.l	firstpend,a2
.loop0	cmp	#0,a2
	beq	.ship
	move.l	4(a2),a0
	move.l	pc,(a0)
	move.l	(a2),a2
	bra	.loop0
	;
.ship	tst.b	debugga
	beq.s	.ship2
	;
	moveq	#5,d1
	jsr	maketrap
	;
.ship2	move.l	firstlocal,a2
	bsr	calcstatic2
	move.l	thisproc,a0
	move	d4,8(a0)
	move.l	d3,locdatast
	move.l	memlib,a1
	tst	12(a1)
	bpl	.nolskip
	bset	#7,8(a0)
	move	#freelast,d1
	bsr	tokejsr2
	bra	.lskip2
	;
.nolskip	move	memlibstat,12(a1)
.lskip2	;
	move.l	thisproc,a0
	move.l	14(a0),-(a7)
	move	locvaroff,6(a0)
	bclr	#1,7(a0)
	bclr	#0,7(a0)
	cmp.b	#7,5(a0)
	bne	.penis
	move	getstlen,d1
	bsr	pokewd
.penis	tst	6(a0)
	beq	.nolink
	move	#64635,d1
	bsr	uselib
	move	unlinka4,d1
	bsr	pokewd
.nolink	;
	;fix the stacked string lengths!
	;
	move.l	thisproc,a0
	moveq	#0,d1
	move.b	4(a0),d1
	lsr	#4,d1
	beq	.nofix
	cmp	#1,d1
	bne	.not1
	move	fix1,d1
	bsr	pokewd
	bra	.nofix
.not1	lsl	#2,d1
	move	d1,-(a7)
	move	d1,moverts+2
	move.l	moverts,d1
	bsr	pokel
	move	(a7)+,d1
	cmp	#8,d1
	bhi	.fix
	and	#7,d1
	lsl	#8,d1
	lsl	#1,d1
	or	fixq,d1
	bsr	pokewd
	bra	.nofix
	;
.fix	move	d1,fixstack+2
	move.l	fixstack,d1
	bsr	pokel
	;
.nofix	bsr	normret
	;
	;put in the setup stuff here!
	;
	bsr	procfixer
	;
	move.l	(a7)+,a0
	move	nomemleft,d1
	bne	.skipjp
	move.l	pc,-(a0)
.skipjp	;
	clr	procmode
	clr.l	thisproc
	clr	procnum
	bsr	droplocals
	bsr	freepends
	bra	getchar3

droplocals	moveq	#12,d0
	moveq	#1,d1
	move.l	4.w,a6
	jsr	doallocmem
	move.l	d0,a0
	move.l	alllocals,(a0)
	move.l	a0,alllocals
	;
	move.l	firstlocal,d0
	clr.l	firstlocal
	move.l	d0,4(a0)
	move.l	firstglob,d1
	clr.l	firstglob
	move.l	d1,8(a0)
	;
	tst.b	debugga
	beq.s	.skip
	tst	nomemleft
	bne.s	.skip
	;
	move.l	proclocals(pc),a0
	move.l	d0,(a0)+
	move.l	d1,(a0)
	;
.skip	rts

donext	;
	tst	dirmode
	bne	baddirerr
	move.l	firstfor,d1
	beq	noforerr
	bsr	reget
	beq	.unknown
	;
	;here, we've got 'Next Var[,Var...]'
	;
.nextnext	bsr	getvname
	move.l	firstfor(pc),a2
	moveq	#0,d1
	move.b	16(a2),d1
	sub	#18,d1
	cmp	d1,d2
	bne	noforerr
	lea	namebuff(pc),a0
	lea	17(a2),a1
	subq	#1,d2
.chkname	cmp.b	(a0)+,(a1)+
	bne	noforerr
	dbf	d2,.chkname
	bsr	.unknown2
	bsr	reget
	beq	.byebye
	cmp	#',',d0
	bne	syntaxerr
	bsr	getchar3
	bra	.nextnext
.byebye	rts
	;
.unknown	move.l	d1,a2
.unknown2	jsr	popnext	;error checking for next.
	move	12(a2),d0
	;
	lea	nextb,a0
	lea	nextbf,a1
	cmp	#1,d0
	beq	.donext
	lea	nextw,a0
	lea	nextwf,a1
	cmp	#2,d0
	beq	.donext
	lea	nextl,a0
	lea	nextlf,a1
	cmp	#5,d0
	bne	.donext
	move	#getffpbase,d1
	bsr	tokejsr
	lea	nextf,a0
	lea	nextff,a1
.donext	bsr	pokecode
	move.l	thebra(pc),d1
	bsr	pokel
	;
	move.l	firstfor,a2
	move.l	(a2),firstfor
	;
	;pass2, o.k. to put in my BRA's!
	;
	move.l	8(a2),a0
	move.l	pc,a1
	move.l	a1,d1
	sub.l	a0,d1	;d1=positive bra
	addq.l	#2,d1
	cmp.l	#32768,d1
	bcc	bigforerr
	tst	nomemleft
	bne	.nopoke1
	move	d1,-2(a0)
.nopoke1	move.l	a1,d1
	sub.l	4(a2),d1
	subq.l	#6,d1
	cmp.l	#32768,d1
	bcc	bigforerr
	tst	nomemleft
	bne	.skip
	neg	d1
	move	d1,-2(a1)
	;
.skip	jsr	popnext3	;fix stack
	;
	move.l	4.w,a6
	move.l	a2,a1
	moveq	#0,d0
	move.b	16(a1),d0
	jsr	freemem(a6)
	;
	bra	reget

forset	move	#'fO',-(a7)

thebra	bra	thebra

forlineat	dc	0
fortemp	dc	0

dofor	;
	;For var = START To FINISH [Step INCREMENT]
	;
	tst	dirmode
	bne	baddirerr
	move	linenumat,forlineat
	;
	;new stuff!
	;
	move.l	a5,letstart
	bsr	getvname
	move	d2,fortemp
	;
	bsr	findfor
	beq	fornexterr
	lea	firstfor,a2
	bsr	addhere2
	move.l	a2,-(a7)
	;
	tst.b	debugga
	beq.s	.noerr
	;
	jsr	chkstak
	move.l	forset,d1
	bsr	pokel
.noerr	move	fortemp(pc),d2
	bsr	dolet2
	cmp	#$8018,d0
	bne	syntaxerr
	move	commode,d1
	bne	syntaxerr
	cmp.b	#6,d2
	bcc	badforerr	
	btst	#15,d2
	bne	.skip
	move	leaamp,d1
	bsr	pokewda5s
	move	d3,d1
	bsr	pokewd
.skip	move	pushindex,d1
	bsr	pokewd	;index lea on stack
	and	#255,d2
	move.l	(a7),a1
	move	d2,12(a1)
	;
	move	d2,-(a7)
	bsr	eval	;get fin
	move	(a7),d2
	;
	move	pushd0l,d1
	cmp	#3,d2
	bcc	.skipl
	move	pushd0wd,d1
.skipl	move	d1,-(a7)
	bsr	pokewd	;push fin on stack
	cmp	#$8019,d0
	bne	.defstep
	;
	bsr	eval	;get step
	bra	.pushstep
	;
.defstep	cmp	#4,d2
	bcc	.qup
	move	#$7001,d1
	bsr	pokewd
	bra	.pushstep
.qup	bne	.notq
	move	#$7001,d1
	bsr	pokewd
	move	swapd0,d1
	bsr	pokewd
	bra	.pushstep
.notq	move	#$203c,d1
	bsr	pokewd
	move.l	#$80000041,d1	;ffp '1'
	bsr	pokel
.pushstep	move	(a7)+,d1
	bsr	pokewd		;push step on stack
	; 
	move	(a7)+,d2
	move.l	(a7),a1
	move.l	pc,4(a1)
	lea	forcompb,a0
	lea	forcompbf,a1
	cmp	#1,d2
	beq	.docomp
	lea	forcompw,a0
	lea	forcompwf,a1
	cmp	#2,d2
	beq	.docomp
	lea	forcompl,a0
	lea	forcomplf,a1
	cmp	#5,d2
	bne	.docomp
	lea	forcompf,a0
	lea	forcompff,a1
	bsr	pokecode
	move	#getffpbase,d1
	bsr	tokejsr
	lea	forcompf2,a0
	lea	forcompf2f,a1
.docomp	bsr	pokecode
	move.l	thebgt(pc),d1
	bsr	pokel
	move.l	(a7)+,a1
	move.l	pc,8(a1)
	bra	reget

thebgt	bgt	thebgt

dolet	move.l	a5,letstart
	bsr	getvname
dolet2	;
	bsr	pushstart
	move	#1,regat	;don't disturb this reg!
	bsr	fetchvar	;var in a3, type in a2
	bsr	calcvar	;get offset stuff
	clr	regat	;don't disturb this reg
	bsr	pushdo
	clr	commode
	clr	pcodd
	;
	cmp	#'=',d0
	beq	.nextcom
	;
	;move char to start of var name!
	;
	move.l	letstart,a5
	subq	#1,a5
	;
.nextcom	cmp.b	#7,d2
	bne	.notstring
	;
	;string get!
	;
	movem	d2-d3,-(a7)
	move.l	lastoffset,-(a7)
	move	varmode,-(a7)
	jsr	setsvars	;!@!
	moveq	#7,d2
	bsr	eval
	move	(a7)+,varmode
	move.l	(a7)+,lastoffset
	move	moved0a3,d1
	bsr	pokewd
	move	commode,d1
	beq	.stconti
	lea	pulla2st,a0
	lea	pulla2stf,a1
	bsr	pokecode
	bra	.stconti2
.stconti	bsr	pushput
.stconti2	movem	(a7)+,d2-d3
	btst	#15,d2
	bne	.already
	move	d3,leaa5d3a2+2
	move.l	leaa5d3a2,d1
	bsr	pokela5s
.already	move	#65135,d1
	bsr	uselib
	move	#lastring,d1
	move	varmode,d2
	bne	.local
	addq	#1,d1	;use global allocmem
.local	bsr	tokejsr
	cmp	#',',d0
	bne	.done
	move	addq4a2,d1
	bsr	pokewd
	bra	.nextstr
	;
.notstring	btst	#14,d2	;pointer, ignore!
	bne	.skip
	tst.b	d2
	beq	noleterr	;tried to assign a struct - later!
	bra	.skip2
.skip	move.b	#3,d2
.skip2	;
	;let's get what is to be assigned.....
	;
	movem	d2-d3,-(a7)
	move	varmode,-(a7)
	and	#$ff,d2
	move.l	lastoffset,-(a7)
	bsr	eval
	move.l	(a7)+,lastoffset
	move	commode,d1
	bne	.conti
	bsr	pushput
	;
.conti	move	(a7)+,varmode
	movem	(a7)+,d2-d3
	;
	move	#$2b40,d1
	move	varmode,d4
	beq	.skipl
	bclr	#9,d1
.skipl	btst	#15,d2
	beq	.code
	;
	move	commode,d1
	beq	.skipc1
	move	pulla2,d1
	bsr	pokewd
	;
.skipc1	move	#$2480,d1	;move.l d0,(a2)
	;
	cmp	#',',d0
	bne	.code
	;
	move	#$24c0,d1	;move.l d0,(a2)+
	bsr	.code
	;
.nextstr	move.l	lastoffset,d0
	beq	nocomerr
	move	#-1,commode	
	clr	varcodelen
	move	pusha2,d1
	bsr	pokewd
	move.l	lastoffset,a0
	move.l	(a0),d0
	beq	comerr	;comma past end of struct
	move.l	d0,a0
	move.l	a0,lastoffset
	btst	#1,7(a0)
	bne	nocomerr	;can't use comma on multiple entries
	move.l	10(a0),a1
	move.l	4(a1),d2
	btst	#0,7(a0)
	bne	.nextpnt	;pointer
	cmp.l	#256,d2
	bcc	nocomerr	;or on structs
	bra	.docom 
.nextpnt	cmp.l	#256,d2
	bcs	.nextpnt2
	moveq	#0,d2
.nextpnt2	bset	#14,d2
.docom	bset	#15,d2
	bra	.nextcom
	;
.code	cmp.b	#1,d2
	beq	.byte
	bsr	alignletpc
	cmp.b	#3,d2
	bcc	.do
	or	#$1000,d1
	bra	.do
.byte	addq	#1,pcodd
	eor	#$3000,d1
.do	bsr	pokewd	;bsr
	btst	#7,d1
	bne.s	.done
	move	d3,d1
	bra	pokewd
.done	rts

;	btst	#7,d1
;	bne.s	.cheese
;	move	d3,d1
;	bra	pokewd
;	;
;.cheese	btst	#13,d1
;	bne.s	.done
;	btst	#6,d1
;	beq.s	.done
;	move	#$524a,d1
;	bra	pokewd
;	;
;.done	rts

alignletpc	move	d1,-(a7)
	move	pcodd(pc),d1
	lsr	#1,d1
	bcc.s	.done
	clr	pcodd
	move	add1a2,d1
	bsr	pokewd
.done	move	(a7)+,d1
	rts

add1a2	addq	#1,a2
pcodd	dc	0	;add 1 to this for bytes
listadd	dc	0	;set to 8 if it's a list
listsize	dc	0

dodim	;dim an array
	;
	addq	#1,regat	;get things into d1
	;
	move	#65434,d1
	bsr	uselib	;arrays lib!
	;
dodim2	clr	listadd
	cmp	#$8000+tnum,d0
	bne	.notlist
	move	#8,listadd	;it's a list
	move	#65530,d1
	bsr	uselib	;use memlib
	bsr	getchar3
.notlist	clr	nonew
	bsr	getvname
	btst	#1,flagmask+1
	beq	syntaxerr
	bsr	fetchvar
	move	added,d1
	bne	.added
	;
	;Here, an Array is being Re-Dimmed
	;
	move	8(a3),temp1
	move	procmode,d2
	bne	.reloc
	;
	move	varoff,-(a7)
	move	4(a3),varoff
	addq	#4,varoff
	bsr	dimwit
	move	(a7)+,varoff
	bra	.next
	;
.reloc	move	locvaroff,-(a7)
	move	4(a3),locvaroff
	subq	#4,locvaroff
	bsr	dimwit
	move	(a7)+,locvaroff
	bra	.next
	;	
.added	;here, we are doing a brand new dim!
	;
	move	#-1,temp1	;no care on # dims
	move	listadd(pc),d1
	beq	.isok
	move	#$4000,temp1	;yes, we do care - must be 1
			;coz it's a list
	bset	#0,6(a3)	;set to list type of array
.isok	bsr	dimwit
.next	bsr	getchar3
	cmp	#',',d0
	bne	.done
	bsr	getchar3
	bra	dodim2
.done	rts

dimwit	move	#-1,nonew
	move	beginarr,d1
	bsr	pokewd
	moveq	#0,d1
	bsr	pokewd	
	moveq	#4,d1
	btst	#0,flagmask+1
	bne	.pointer
	move	8(a2),d1
.pointer	add	listadd(pc),d1	;size of one element.
	move	d1,listsize
	bsr	pokewd
	clr	temp2	;# dim's got
	move.l	a3,-(a7)
.loop	addq	#1,temp2
	moveq	#3,d2	;get word
	bsr	eval
	;
	tst.b	debugga
	beq	.norerr0
	move	#arrchk,d1
	bsr	tokejsr
.norerr0	move	#arrmult,d1
	bsr	tokejsr
	;
	move	procmode,d2
	beq	.global
	subq	#4,locvaroff
	move	locvaroff,putarr+2
	bra	.doit
.global	move	varoff,putarr+2
	addq	#4,varoff
.doit	;
	move.l	putarr,d1
	bsr	pokela5d
	cmp	#',',d0
	beq	.loop
	cmp	#')',d0
	bne	syntaxerr
	;
	move.l	(a7)+,a3
	move	temp1,d1
	bmi	.nocare
	;
	;is it a list?
	;
	btst	#14,d1
	beq	.notl
	cmp	#1,temp2
	bne	redimerr
	bra	.nocare
	;
.notl	cmp	temp2,d1
	bne	redimerr
	lea	varoff,a0
	move	procmode,d1
	beq	.gskip
	lea	locvaroff,a0
.gskip	move	extraword,(a0)
	bra	.care
.nocare	move	temp2,8(a3)	;set # dim's
.care	lea	doarr,a0
	move	4(a3),2(a0)
	move	putarr+2,6(a0)
	move.l	(a0)+,d1
	bsr	pokel
	move.l	(a0),d1
	bsr	pokel
	move	#newarr,d1
	move	procmode,d2
	beq	.isg
	addq	#1,d1
.isg	move	listadd(pc),d2
	beq	.isrg
	move	d1,-(a7)
	move	setles(pc),d1
	bsr	pokewd	;move #x,d4
	move	listsize(pc),d1
	bsr	pokewd
	move	(a7)+,d1
	addq	#3,d1	;for list Tokejsr
.isrg	bra	tokejsr

setles	move	#0,d4

;-----------data-----------------------;

mydata

vbr	dc.l	0

numclibs	equ	3
	
cfetchmode	dc	0	;1=fetching a constant
			;intercept uselib!

constlibs	dc	64935,64735,64835
	
	;below is a PC for the constant evaluation routine
	;
constpcat	dc.l	0
constlibat	dc.l	0
constmaxpc	dc.l	1024
	;
stackfuck	dc.l	0
lastrescon	dc.l	firstlabel
lastresmac	dc.l	firstmacro
lastrestype	dc.l	firsttype
rescnt	dc	0	;# resident
reschg	dc	0	;flag for if res's have changed
resat	dc.l	resbuff
linedone	dc	0
dirpcat	dc.l	0
diropt	dc	0
dira4	dc.l	0
dira5	dc.l	0
dira6	dc.l	0
dirstack	dc.l	0
comdata	dc.l	0

	;routines for type conversion

convtable	dc.l	0,bytetoword,bytetolong,bytetoquick,bytetofloat,bytetolong,noconerr
	dc.l	wordtobyte,0,wordtolong,wordtoquick,wordtofloat,wordtolong,noconerr
	dc.l	longtobyte,longtoword,0,longtoquick,longtofloat,0,noconerr
	dc.l	quicktobyte,quicktoword,quicktolong,0,quicktofloat,quicktolong,noconerr
	dc.l	floattobyte,floattoword,floattolong,floattoquick,0,floattolong,noconerr
	dc.l	longtobyte,longtoword,0,longtoquick,longtofloat,0,noconerr
	dc.l	noconerr,noconerr,stringtolong,noconerr,noconerr,stringtolong,0

	;dc	operator ascii
	;dc.l	..b,.w,.l,.q,.f,.s,.a

operators	dc	'+'
	dc.l	doplusb,doplusw,doplusl,doplusl
	dc.l	doplusf,0,addstrings
	dc	3000
	;
	dc	'-'
	dc.l	dominusb,dominusw,dominusl,dominusl
	dc.l	dominusf,0,0
	dc	3000
	;
	dc	'*'
	dc.l	dotimesb,dotimesw,dotimesl,dotimesq
	dc.l	dotimesf,0,0
	dc	4000
	;
	dc	'/'
	dc.l	dodivb,dodivw,dodivl,dodivq
	dc.l	dodivf,0,0
	dc	4000
	;
	dc	'&'	;AND
	dc.l	doandb,doandw,doandl,doandl
	dc.l	0,0,0
	dc	5000
	;
	dc	'|'	;OR
	dc.l	doorb,doorw,doorl,doorl
	dc.l	0,0,0
	dc	5000
	;
	dc	(opand-opabcd)/$1c+$8000+fnum	;AND
	dc.l	doandb,doandw,doandl,doandl
	dc.l	0,0,0
	dc	1000
	;
	dc	(opor-opabcd)/$1c+$8000+fnum	;OR
	dc.l	doorb,doorw,doorl,doorl
	dc.l	0,0,0
	dc	1000
	;
	dc	(opeor-opabcd)/$1c+$8000+fnum	;OR
	dc.l	doeorb,doeorw,doeorl,doeorl
	dc.l	0,0,0
	dc	1000
	;
	dc	(oplsl-opabcd)/$1c+$8000+fnum	;LSL
	dc.l	dolslb,dolslw,dolsll,dolsll
	dc.l	0,0,0
	dc	6000
	;
	dc	(opasl-opabcd)/$1c+$8000+fnum	;ASL
	dc.l	dolslb,dolslw,dolsll,dolsll
	dc.l	0,0,0
	dc	6000
	;
	dc	(oplsr-opabcd)/$1c+$8000+fnum	;LSR
	dc.l	dolsrb,dolsrw,dolsrl,dolsrl
	dc.l	0,0,0
	dc	6000
	;
	dc	(opasr-opabcd)/$1c+$8000+fnum	;ASR
	dc.l	doasrb,doasrw,doasrl,doasrl
	dc.l	0,0,0
	dc	6000
	;
	dc	$8006+tnum			;Mod
	dc.l	domodb,domodw,domodl,domodq
	dc.l	domodf,0,0
	dc	5000
	;
	dc	"^"
	dc.l	dopow,dopow,dopow,dopow
	dc.l	dopow,0,0
	dc	7000
	;
opeq	dc	'='
	dc.l	doeqb,doeqw,doeql,doeql
	dc.l	doeqf,doeql,doeqs
	dc	2000
	;
opne	dc	'<>'
	dc.l	doneb,donew,donel,donel
	dc.l	donef,donel,dones
	dc	2000
	;
oplt	dc	'<'
	dc.l	doltb,doltw,doltl,doltl
	dc.l	doltf,doltl,dolts
	dc	2000
	;
ople	dc	'<='
	dc.l	doleb,dolew,dolel,dolel
	dc.l	dolef,dolel,doles
	dc	2000
	;
opgt	dc	'>'
	dc.l	dogtb,dogtw,dogtl,dogtl
	dc.l	dogtf,dogtl,dogts
	dc	2000
	;
opge	dc	'>='
	dc.l	dogeb,dogew,dogel,dogel
	dc.l	dogef,dogel,doges
	dc	2000
	;
	dc	$8000+26+tnum
	dc.l	bittst,bittst,bittst,bittst
	dc.l	0,0,0
	dc	8000
	;
	dc	$8000+27+tnum
	dc.l	bitset,bitset,bitset,bitset
	dc.l	0,0,0
	dc	8000
	;
	dc	$8000+28+tnum
	dc.l	bitclr,bitclr,bitclr,bitclr
	dc.l	0,0,0
	dc	8000
	;
	dc	$8000+29+tnum
	dc.l	bitchg,bitchg,bitchg,bitchg
	dc.l	0,0,0
	dc	8000
	;
	dc	0

modetable	dc.l	typemode

alltypes	dc.l	bytetype

bytetype	dc.l	wordtype,1
	dc	1
	dc.b	13,'b',0,0
wordtype	dc.l	longtype,2
	dc	2
	dc.b	13,'w',0,0
longtype	dc.l	quicktype,3
	dc	4
	dc.b	13,'l',0,0
quicktype	dc.l	floattype,4
	dc	4
	dc.b	13,'q',0,0
floattype	dc.l	addresstype,5
	dc	4
	dc.b	13,'f',0,0
addresstype	dc.l	stringtype,6
	dc	4
	dc.b	13,'a',0,0
firsttype	;
stringtype	dc.l	0,7
	dc	4
	dc.b	13,'s',0,0

dummytype	dc.l	0,0
	dc	0
	dc.b	1,0,0,0

incdir	dcb.b	96,0
	even

dirmode	dc	0	;direct mode flag
int	dc.l	0	;intuition!
maxat	dc	0	;max at
maxsat	dc.l	0	;data1 info pos
nummaxs	dc	0	;number of maximums
			;in libs
maxsused	dc	0	;maximums used in prog
	;
	;below are defaults to be saved with source
	;
dark	dc	0	;dark compile?
qlab	dc	0	;quick lab allocate
defaulttype	dc.l	quicktype
	;
	;end of defaults
	;

anyerrs	dc	-1	;Any Errors in compile ?
makeexec	dc	0	;make an executable file!
noinits	dc.l	0	;flag for if we have any init routines!
			;6.l=no!
letstart	dc.l	0
nomemleft	dc	0
lastbiglab	ds.b	128
	;
locdatast	dc.l	0
firstpend	dc.l	0
	;
	;one pass compiler stuff!
	;
data2at	dc.l	0
data2	dc.l	0
data1at	dc.l	0
data1	dc.l	0	;pc for initialized data!
pcat	dc.l	0
pc	dc.l	0
libat	dc.l	0
lib	dc.l	0
allat	dc.l	0	;highest allocmemd location for code
	;
dummyasm	dc	0,0,0,0,0
	dc.l	0
	dc	0
	;
	;data for assembler
	;
buff1	dc.l	0	;buffer for text get
buff2	dc.l	0	;ditto for dest
constmode	dc	0	;0 for norm, <>0 for assembler
asmtype	dc	0	;0=contains no prog reference
extraword	dc	0	;the extension word for assembler
extraword2	dc	0	;ditto
asmsize	dc	0
asmbuff	dc.l	0
asmlen	dc	0	;first (src) text len
asmlen2	dc	0	;second (dest)
firstasm	dc.l	0	;linked list of expressions to resolve
			;for one pass assembly.
	;
macnum	dc	0	;
nextinc0	dc.l	0	;address of next 0 in include file
titleat	dc.l	0	;5 longs for compile streaks
titleadd	ds	5	;5 adds for compile streaks
connest	dc	0	;conditional nest level
firstconst	dc.l	0	;first constant (#a)
numarg	dc	0	;number of macro arguements
myoline	dc.l	0	;macro done yet?
myline	dc.l	0	;pointer to some memory to create
			;line in.....
mylinef	dc.l	0
concomstack	ds	32	;32 deep conditional compilation
concomsp	dc.l	concomstack	;stack pointer
oldqflag	dc	0
;datalib	dc.l	0	;pointer to datalib.obj (64535)
lastconloc	dc.l	0
lastconop	dc	0
firstfor	dc.l	0	;first for
pushflag	dc	0
sbgot	dc	0	;flag for string got 2
usertype	dc	0
userp	dc	0
;libspos	dc	0	;pos in libs dir
;numlibs	dc	0	;number of libraries in libslist
libslist	dc.l	0
stackuse	dc	0	;stack used when gathering lib parameters
numreps	dc	0	;number of repeats in a repeatable
			;parameter list.....
locloc	dc.l	0
locchar	dc	0
stbuff	ds.l	8	;six string varoffs
commode	dc	0	;in comma mode...
lastoffset	dc.l	0	;last offset in calcvar!
linenumat	dc	-1	;line being processed
menuret	dc	-1	;menu return code
optresoff	dc	0	;opt reset offset
varcode	ds.b	vcodelen	;code used to generate
			;last var access
varcode2	ds.b	vcodelen	;above for let.....
varcodelen	dc	0	;and length
varcodelen2	dc	0	;
oldvcodelen	dc	0	;old varcodelen
;stringslib1	dc.l	0	;address of stringslib1
procjmppc	dc.l	0	;pc of jmp of proc
memlib	dc.l	0	;address of memory library
memlibstat	dc	0	;status of memory library during
			;procs
tempvmode	dc	0 
tempvmode2	dc	0
varmode	dc	0	;0=a5 is pointer to globals
			;else pointer to locals
thisproc	dc.l	0	;this procedure being 'done'
firstproc	dc.l	0
procmode	dc	0	;1 if statement, 2 if function
			;0 if norm!
comflag	dc	0	;0 if no compile
passstack	dc.l	0
zero	dc.l	0	;ZERO!
numincs	dc	0	;number of included files,
			;0=main RAM code
firstxinc	dc.l	0	;first exclusive include.
firstinc	dc.l	0	;first include
lasta6	dc	-1
quoteflag	dc	0
macrobuff	dc.l	0	;pointer to macro collection buffer
macrobufff	dc.l	0	;end of above
firstmacro	dc.l	0	;linked list of macro's
endop	dc.l	0	;end of program pc - before finishups!
firstlabel	dc.l	0	;label list
lasttoken	dc.l	0
numstatic	dc	0	;number of static structs
staticdata	dc.l	0	;data1 val for statics
firstlib	dc.l	0	first lib struct
sbasegot	dc	0	;string base got? 
litdata1	dc.l	0
	;
	;Optimization stuff
	;
objlen	dc.l	0
numoffs	dc.l	0
firstoff	dc.l	0	;pointer to linked list 
			;of amigados type reloc offsets
flagmask	dc	0	;mask for flag of variable when
			;searching for it!
added	dc	0	;flag for seeing if variable was added!
nonew	dc	0	;1 to inhibit new variable creation
temp1	dc.l	0
temp2	dc.l	0
	cnop	0,4
namebuff	ds.b	128
namebuff2	ds.b	128
	ds.b	8	;for fileinfoblock
optstuff	ds.b	64	;temp opt make buffer

zerotypes	lea	typereqla30,a0
	moveq	#11,d0
.loop0	move.l	a0,a1
	moveq	#26,d1
.loopm1	move.b	#32,(a1)+
	dbf	d1,.loopm1
	lea	typereqla31-typereqla30(a0),a0
	dbf	d0,.loop0
	rts

typeat	dc	0
maxtypes	dc	0

makebody	moveq	#-1,d1	;full bodied
	move	maxtypes,d0
	cmp	#12,d0
	bls	.skip
	;
	moveq	#12,d1
	swap	d1
	divu	d0,d1
.skip	move	d1,typereqvp1+8
	clr	typereqvp1+4
	rts

countlist	clr	typeat
	move.l	a2,a1
	moveq	#0,d0
.loop	cmp	#0,a1
	beq	.done
	addq	#1,d0
	move.l	(a1),a1
	bra	.loop
.done	move	d0,maxtypes
	rts

f1	dc.l	0
f2	dc	0
f3	dc	0
fuckoff	ds.b	8

showlist3	move.l	f1,a2
	move	f2,d2
	move	f3,d3
	bra	showlist2
	;
showlist	move.l	a2,f1
	move	d2,f2
	move	d3,f3
showlist2	;a2=first item, d2=offset for .offset (0 for none)
	;
	;d3=offset for chars
	;
	;typeat=pos, maxtypes=max
	;
	bsr	zerotypes
	move	typeat,d0
	cmp	maxtypes,d0
	bcc	.rdone
	subq	#1,d0
	bmi	.ok
.loop	move.l	(a2),a2
	dbf	d0,.loop
	;
.ok	move	typeat,d0
	lea	typereqla30,a3
	moveq	#11,d1
	;
.loop2	lea	0(a2,d3),a1
	move.l	a3,a4	;start
	lea	27(a4),a5	;end
	;
	tst	d2
	beq	.ok2
	btst	#0,7(a2)
	beq	.ok2
	move.b	#'*',d4
	btst	#2,7(a2)
	beq	.hiy
	move.b	#'@',d4
.hiy	move.b	d4,(a4)+
	;
.ok2	move.b	(a1)+,(a4)+
	bne	.hello
	move.b	#32,-(a4)
	tst	d2
	beq	.next	;no offset
	move.b	#'.',(a4)+
	move.l	10(a2),a1
	lea	11(a1),a1	;type stuff
.ok3	cmp.l	a5,a4	
	bcc	.next
	move.b	(a1)+,(a4)+
	bne	.ok3
	move.b	#32,-(a4)
	btst	#1,7(a2)
	beq	.next
	move.b	#'[',(a4)+
	movem.l	d1-d3,-(a7)
	moveq	#0,d2
	move	8(a2),d2
	lea	fuckoff,a0
	jsr	makelong
	movem.l	(a7)+,d1-d3
	lea	fuckoff,a0
.penis	cmp.l	a5,a4
	bcc	.next
	move.b	(a0)+,(a4)+
	bne	.penis
	move.b	#']',-(a4)
	bra	.next
	;
.hello	cmp.l	a5,a4
	bcs	.ok2
.next	addq	#1,d0
	cmp	maxtypes,d0
	bcc	.rdone
	lea	typereqla31-typereqla30(a3),a3
	move.l	(a2),a2
	dbf	d1,.loop2
.rdone	rts

typeshow	move	typeat,d2
	move	typereqvp1+4,d0
	move	maxtypes,d1
	sub	#11,d1
	bmi	.skip
	mulu	d0,d1
	swap	d1
	move	d1,typeat
.skip	cmp	typeat,d2
	bne	.showem
	rts
.showem	bsr	showlist3
reflist	lea	typereqga5,a0
	moveq	#12,d0
	move.l	comdata,a1
	move.l	28(a1),a1
	jmp	(a1)

allofem	move.l	firsttype,a2
	bsr	countlist
	bsr	makebody
	moveq	#0,d2
	moveq	#11,d3
	bra	showlist

menu6	;
	;Flashy Type Information....
	;
	bsr	allofem
	;
	move.l	comdata,a1
	move.l	(a1),a1
	lea	typereq,a0
	jsr	(a1)
.loop	lea	typereqga2,a0
	lea	typereq,a2
	move.l	comdata,a1
	move.l	68(a1),a1
	jsr	(a1)
	move.l	comdata,a1
	move.l	8(a1),a1
	jsr	(a1)
	cmp	#-1,d7
	bne	.loop
	cmp	#1,d6
	bne	.notvprop
	;
.vloop	move.l	comdata,a0
	move.l	32(a0),a0
	jsr	(a0)
	tst.l	d7
	beq	.vdo
	cmp	#-1,d7
	bne	.vdo
	cmp	#1,d6
	beq	.vdone
.vdo	bsr	typeshow
	bra	.vloop
.vdone	bsr	typeshow
	bra	.loop
	;
.notvprop	;
	cmp	#2,d6
	bne	.notsg
	lea	typereqla21,a1
	tst.b	(a1)
	bne	.some
	bsr	allofem
	bra	.reflist
	;
.some	move.l	#namebuff,a0
	moveq	#-1,d2
.sgl	addq	#1,d2
	move.b	(a1)+,(a0)+
	bne	.sgl
	lea	firsttype,a2
	bsr	findtype
	beq	.all
.beep	move.l	comdata,a0
	move.l	40(a0),a0
	callint	displaybeep
	bra	.loop
.notsg	;
	cmp	#3,d6
	bne	.nottgad
	clr.b	typereqla21
	bsr	allofem
	bra	.reflist
.nottgad	;
	cmp	#4,d6
	beq	.done
	subq	#5,d6
	bmi	.loop
	cmp	#12,d6
	bcc	.loop
	;d6=0 to 7
	add	typeat,d6
	cmp	maxtypes,d6
	bcc	.loop
	;
	;d6 selected
	;
	move	f2,d0
	bne	.intype
	;goto type
	move.l	firsttype,a2
	subq	#1,d6
	bmi	.gotit
.hit	move.l	(a2),a2
	dbf	d6,.hit
.gotit	lea	11(a2),a1
	bsr	typename
	;
.all	move.l	4(a2),a2
	bsr	countlist
	bsr	makebody
	moveq	#-1,d2
	moveq	#15,d3
	bsr	showlist
.reflist	bsr	reflist
	lea	typereqga1,a0
	moveq	#2,d0
	move.l	comdata,a1
	move.l	28(a1),a1
	jsr	(a1)
	bra	.loop
	;
.intype	move.l	f1,a2
	subq	#1,d6
	bmi	.gotit2
.hit2	move.l	(a2),a2
	dbf	d6,.hit2
.gotit2	move.l	10(a2),a2
	cmp.l	#256,4(a2)
	bcs	.beep
	bra	.gotit
	;
	bra	.loop
	;
.done	rts

typename	lea	typereqla21,a0
.loop	move.b	(a1)+,(a0)+
	beq	.done
	cmp.l	#typereqla21+31,a0
	bcs	.loop
.done	rts

	include	typereq

optspnts	;pointers to options involved in source dependant
	;stuff
	;
	dc	1	;one byte stuff...
	;
	dc.l	vers
	dc.l	optreqga9+13
	dc.l	0
	;
	dc	2	;two byte stuff...
	;
jimi0	dc.l	optreqga10+12
	dc.l	optreqga11+12,optreqga12+12
	dc.l	optreqga13+12,optreqga14+12
	dc.l	optreqga15+12,optreqga16+12
	dc.l	optreq2ga1+12,optreq2ga2+12
	dc.l	optreq2ga3+12
	;
	dc.l	optreq2ga4+12,optreq2ga5+12
	dc.l	optreq2ga6+12,optreq2ga7+12
	;
jimi1	dc.l	0
	;
	dc	4	;four byte stuff...
jimi2	;
	;Maximums Int String Gadgets...
	;
	dc.l	optreqla48-8,optreqla49-8
	dc.l	optreqla50-8,optreqla51-8
	dc.l	optreqla52-8,optreqla53-8
	;
jimi3	dc.l	0
	;
	;Resident Buffer...
	;
	dc	68*8
	dc.l	resbuff,0
	;
	;Executable name!
	;
	dc	192*2
	dc.l	xpath,0
	;
	;all done...
	;
	dc	0
	;
optspntsf	;

optssave	ds.b	((jimi1-jimi0)/4*2)+(jimi3-jimi2)+(68*8)+(192*2)+2

allchg	dc	0

vers	dc	0

loadxtra	jsr	freeres2
	;
	lea	optspnts,a2
	moveq	#0,d4
.loop	move	(a2)+,d4
	beq.s	.done
.loop2	move.l	(a2)+,d2
	beq.s	.loop
	move.l	d4,d3
	move.l	d7,d1
	jsr	read(a6)
	tst.l	d0
	bne.s	.loop2
	bra	.done2
	;
.done	tst.b	vers
	bne.s	.notver0
	;
	move	#128,optreq2ga1+12	;auto run on
	move	optreq2ga6+12,optreq2ga2+12	;interupt checking on
	clr	optreq2ga3+12	;assembler checking off
	move	optreq2ga7+12,optreq2ga4+12	;overflow chex
	bra.s	.ver0
	;
.notver0	move.l	d7,d1		;load cli arg!
	move.l	#argreqla8,d2
	move.l	#128,d3
	jsr	read(a6)
	;
.ver0	;here, we load in current max settings. done last coz of
	;unknown number of max's
	;
	move.l	a7,errstack
	move.l	#.done2,errcont
	move	#-1,ezerr
	;
.dloop	move.l	#temp1,d2
	moveq	#4,d3
	move.l	d7,d1
	jsr	read(a6)
	tst.l	d0
	beq.s	.done2
	;
	move	temp1,d1
	;
	jsr	findlibnoerr
	beq.s	.done2
	;beq.s	.dloop
	;
	move.l	18(a1),d0
	move	temp1+2,-4(a1,d0.l)
	bra.s	.dloop
	;
.done2	;
	;load in residents
	;
	lea	resbuff(pc),a0
	moveq	#7,d0
.loop3	clr.l	64(a0)
	lea	68(a0),a0
	dbf	d0,.loop3
	movem.l	d7/a6,-(a7)
	jsr	makeiallox
	jsr	loadres
	movem.l	(a7)+,d7/a6
	rts

savextra	move.b	#1,vers		;.xtra version number...
	;
	lea	optspnts,a2
	moveq	#0,d4
.loop	move	(a2)+,d4
	beq.s	.done
.loop2	move.l	(a2)+,d2
	beq.s	.loop
	move.l	d4,d3
	move.l	d7,d1
	jsr	write(a6)
	bra.s	.loop2
	;
.done	;write out cli arguement...
	;
	move.l	d7,d1
	move.l	#argreqla8,d2
	move.l	#128,d3
	jsr	write(a6)
	;
	;OK, now to write out max's
	;
	;lib#.w,
	;max.w.
	lea	firstlib,a2
.loop3	move.l	(a2),d0
	beq	.done2
	move.l	d0,a2
	move.l	18(a2),d4
	tst	-2(a2,d4.l)
	beq	.loop3
	lea	4(a2),a0
	move.l	a0,d2
	moveq	#2,d3
	move.l	d7,d1
	jsr	write(a6)
	lea	-4(a2,d4.l),a0
	move.l	a0,d2
	moveq	#2,d3
	move.l	d7,d1
	jsr	write(a6)
	bra	.loop3
.done2	rts

menu4	;options requester
	;
	lea	optssave,a0
	lea	optspnts,a1
.loop	move	(a1)+,d0	;length of data move
	beq.s	.done
	subq	#1,d0
.loop2	move.l	(a1)+,d1
	beq.s	.loop
	move.l	d1,a2
	move	d0,d1
.loop3	move.b	(a2)+,(a0)+
	dbf	d1,.loop3
	bra	.loop2
.done	;
	;MAKE INT GADS!
	lea	jimi2,a1
.loop4	move.l	(a1)+,d2
	beq.s	.done2
	move.l	d2,a0
	move.l	(a0),d2
	addq	#8,a0
	jsr	makelong
	bra.s	.loop4
	;
.done2	;
	;
menu4c	clr	reschg	;resident change
	clr	allchg	;alloc change
	clr	maxat
	bsr	makemax
	bsr	makeres
	;
	move.l	comdata,a1
	move.l	(a1),a1
	lea	optreq,a0
	jsr	(a1)	;openreq
	;
.loop	move.l	comdata,a0
	move.l	8(a0),a0
	jsr	(a0)	;getinput
.igot	cmp	#-1,d7
	bne	.loop
	cmp	#1,d6
	bcs	.notall
	cmp	#6,d6
	bhi	.notall
	move	d6,allchg
	bra	.loop
.notall	;
	cmp	#21,d6
	bne	.notup
	subq	#1,maxat
.newmax	bsr	makemax
	move.l	comdata,a5
	move.l	28(a5),a5
	lea	optreqga7,a0
	moveq	#2,d0
	jsr	(a5)
	lea	optreqga21,a0
	moveq	#2,d0
	jsr	(a5)
	lea	optreqga25,a0
	moveq	#2,d0
	jsr	(a5)
	bra	.loop
.notup	cmp	#22,d6
	bne	.notdown
	addq	#1,maxat
	bra	.newmax
.notdown	cmp	#7,d6
	bne	.notmax1
	move	maxat,d5
	lea	optreqla54-6,a3
.ugw	move.l	comdata,a0
	move.l	8(a0),a0
	jsr	(a0)	;getinput (ungadget etc)
	move.l	firstlib(pc),a2
.ugwl	cmp	#0,a2
	beq	.igot
	move.l	a2,a1
	add.l	18(a1),a1
	tst	-2(a1)
	beq	.ugwl2
	subq	#1,d5
	bmi	.ugw2
.ugwl2	move.l	(a2),a2
	bra	.ugwl
	;
.ugw2	move	(a3),-4(a1)
	bra	.igot
	;
.notmax1	cmp	#8,d6
	bne	.notmax2
	move	maxat,d5
	addq	#1,d5
	lea	optreqla55-6,a3
	bra	.ugw
	;
.notmax2	cmp	#10,d6
	bne	.notrerr
	btst	#7,optreqga10+13
	beq	.loop
	;
	jsr	runerropts
	bra	.loop
	;
.notrerr	
	cmp	#23,d6
	bne	.notrup
	sub.l	#68,resat
.newres	bsr	newres
	bra	.loop
.notrup	cmp	#24,d6
	bne	.notrdown
	add.l	#68,resat
	bra	.newres
	;	
.notrdown	cmp	#27,d6
	bne	.notme
.chg	;move.l	comdata,a0	;*** res ***
	;move.l	8(a0),a0
	;jsr	(a0)	;getinput
	move	#-1,reschg
	bsr	newres
	bra	.loop
	;
.notme	cmp	#28,d6
	beq	.chg
	;
	cmp	#17,d6
	bcs	.loop
	cmp	#20,d6
	bhi	.loop
	beq	menu4canc
	;
optsdone	move	d6,-(a7)
	move	allchg,d0
	beq	.skip
	jsr	makeiallox
.skip	;
	move	reschg,d0
	beq	.zdone
	jsr	loadres
	;
.zdone	move	(a7)+,d6
	cmp	#18,d6
	beq	.menu0
	cmp	#19,d6
	beq	.menu1
.done	rts
.menu0	jmp	menu0
.menu1	jmp	menu1
	;
	;cancel
	;
menu4canc	lea	optssave,a0
	lea	optspnts,a1
.loop	move	(a1)+,d0
	beq.s	.done
	subq	#1,d0
.loop2	move.l	(a1)+,d1
	beq.s	.loop
	move.l	d1,a2
	move	d0,d1
.loop3	move.b	(a0)+,(a2)+
	dbf	d1,.loop3
	bra.s	.loop2
.done	;
	rts
	
newres	bsr	makeres
	move.l	comdata,a5
	move.l	28(a5),a5
	lea	optreqga23,a0
	moveq	#2,d0
	jsr	(a5)
	lea	optreqga27,a0
	moveq	#2,d0
	jmp	(a5)

makeres	;
	;convert resident list to string gads
	;
	;resat=top gad.
	;
	clr	optreqsgz+8
	clr	optreqsgz+12
	clr	optreqsgy+8
	clr	optreqsgy+12
	;
	and	#$ffff-$100,optreqga23+12
	and	#$ffff-$100,optreqga24+12
	;
	move.l	resat,a0
	move.l	a0,optreqsgz
	cmp.l	#resbuff,a0
	bne	.upok
	or	#$100,optreqga23+12
.upok	lea	68(a0),a0
	move.l	a0,optreqsgy
	cmp.l	#resbuff+(7*68),a0
	bne	.downok
	or	#$100,optreqga24+12
.downok	rts

makemax	;put from maxat into gadgets.....
	;
	lea	optreqla54,a0
	lea	optreqla55,a1
	moveq	#11,d0
	moveq	#32,d1
.cloop	move.b	d1,(a0)+
	move.b	d1,(a1)+
	dbf	d0,.cloop
	lea	optreqla108,a0
	lea	optreqla109,a1
	moveq	#13,d0
.cloop2	move.b	d1,(a0)+
	move.b	d1,(a1)+
	dbf	d0,.cloop2
	;
	or	#$100,optreqga7+12
	or	#$100,optreqga25+12
	and	#$ffff-$100,optreqga21+12	;up!
	and	#$ffff-$100,optreqga22+12	;down!
	move	maxat,d1
	bne	.upok
	or	#$100,optreqga21+12	;no up arrow
.upok	cmp	nummaxs,d1
	bcs	.doit
	;
.nsec	or	#$100,optreqga8+12
	or	#$100,optreqga26+12
.ndown	or	#$100,optreqga22+12	;no down
	;
	rts
.doit	and	#$ffff-$100,optreqga7+12
	and	#$ffff-$100,optreqga25+12
	lea	optreqla108,a1
	lea	optreqla54,a0
	bsr	maxit
	move	maxat,d1
	addq	#1,d1
	cmp	nummaxs,d1
	beq	.nsec
	and	#$ffff-$100,optreqga8+12
	and	#$ffff-$100,optreqga26+12
	lea	optreqla109,a1
	lea	optreqla55,a0
	bsr	maxit
	move	maxat,d1
	addq	#2,d1
	cmp	nummaxs,d1
	bcc	.ndown
	rts

maxit	move.l	firstlib,a2
.loop	move.l	18(a2),d0
	tst	-2(a2,d0.l)
	beq	.next
	subq	#1,d1
	bpl	.next
	;
	move.l	-26(a2,d0.l),a3	;token offset
	add.l	a2,a3
.ttl	move.b	(a3)+,(a1)+
	bne	.ttl
	move.b	#'s',-(a1)
	;
	moveq	#0,d2
	move	-4(a2,d0.l),d2
	jmp	makelong
	;
.next	move.l	(a2),a2
	bra	.loop

	include	options.src

	include	calcreq

calclibat	dc.l	0

menu7	;
	;calculator
	;
	move.l	libat,calclibat
	move.l	a7,errstack
	move.l	#.calcerr,errcont
	;
	clr.b	calcreqla15
	move.l	comdata,a1
	move.l	(a1),a1
	lea	calcreq,a0
	jsr	(a1)
	;
.loopq	lea	calcreqga2,a0
	moveq	#3,d0
	lea	calcreq,a2
	move.l	comdata,a1
	move.l	28(a1),a1
	jsr	(a1)
	;
.loop	;
	lea	calcreqga1,a0
	lea	calcreq,a2
	move.l	comdata,a1
	move.l	68(a1),a1
	jsr	(a1)
	tst.l	d0
	beq	.loop
	;
	move.l	comdata,a1
	move.l	8(a1),a1
	jsr	(a1)
	cmp	#-1,d7
	bne	.loop
	cmp	#1,d6
	bne	.notex
	;
	;calculate the expression
	;
	lea	calcreqla15,a0
	move.l	comdata,a1
	move.l	56(a1),a1
	jsr	(a1)	;tokenise line.....
	;
	jsr	setcvars
	jsr	setsvars
	;
	clr	connest	;no idea...
	;
	lea	calcreqla15,a5
	bsr	evalconst2	;evaluate constant
	;
	lea	calcreqla15,a0
	tst.l	d3
	bpl	.ispos
	move.b	#'-',(a0)+
	neg.l	d3
.ispos	;
	cmp	#128,calcreqga2+12
	beq	.dec
	moveq	#0,d1
	cmp	#128,calcreqga3+12
	bne	.hex
	;
	;bin Print
	moveq	#31,d0
	move.b	#'%',(a0)+
.bloop	lsl.l	#1,d3
	bcc	.bzero
	move.b	#49,(a0)+
	moveq	#-1,d1
	bra	.bnext
.bzero	tst	d1
	beq	.bnext
	move.b	#48,(a0)+
.bnext	dbf	d0,.bloop
.bdone	tst	d1
	bne	.pc1
	move.b	#48,(a0)+
.pc1	clr.b	(a0)
	bra	.pc
	;
.hex	;
	moveq	#7,d0
	move.b	#'$',(a0)+
.hloop	move.l	d3,d2
	swap	d2
	lsr	#8,d2
	lsr	#4,d2
	add	#48,d2
	cmp	#58,d2
	bcs	.hok
	addq	#7,d2
.hok	cmp	#48,d2
	beq	.hzero
	move.b	d2,(a0)+
	moveq	#-1,d1
	bra	.hnext
.hzero	tst	d1
	beq	.hnext
	move.b	d2,(a0)+
.hnext	lsl.l	#4,d3
	dbf	d0,.hloop
	bra	.bdone
	;
.dec	move.l	d3,d2
	jsr	makelong	;to long...
	;
.pc	clr	calcreqsg1+8
	clr	calcreqsg1+12
	;
	move.l	comdata,a1
	move.l	28(a1),a1
	lea	calcreqga1,a0
	lea	calcreq,a2
	moveq	#1,d0
	jsr	(a1)
	;
	bra	.loop
	;
.notex	cmp	#5,d6
	bcc	.notbase
	;
	;new number base selected
	;
	subq	#2,d6
	mulu	#calcreqga3-calcreqga2,d6
	move	d6,-(a7)
	lea	calcreqga2,a0
	clr	12(a0,d6)
	;
	lea	calcreqga2,a0
	moveq	#2,d0
	;
.loopz	cmp	#128,12(a0)
	beq	.thisone
	lea	calcreqga3-calcreqga2(a0),a0
	addq	#1,d0
	cmp	#5,d0
	bcs	.loopz
	bra	.loopz2
.thisone	;
	clr	12(a0)
.loopz2	move	(a7)+,d6
	lea	calcreqga2,a0
	move	#128,12(a0,d6)
	;
	bra	.loopq
	
.notbase	bne	.loop
	rts

.calcerr	move.l	calclibat,libat
	clr.b	calcreqla15
	bra	.pc

argreq	dc.l	0
	dc.w	52,42,408,56,0,0
	dc.l	argreqga1,argreqbo1,argreqin1
	dc.w	0
	dc.b	0,0
	dc.l	0
	ds.b	32
	dc.l	0,0
	ds.b	36

argreqbo1	dc.w	0,0
	dc.b	2,1,1,3
	dc.l	argreqla1,argreqla2
argreqla1	dc.w	399,20,8,20,8,31
argreqla2	dc.w	0,0
	dc.b	1,2,1,3
	dc.l	argreqla3,argreqbo2
argreqla3	dc.w	399,21,399,31,9,31
argreqbo2	dc.w	0,0
	dc.b	1,2,1,3
	dc.l	argreqla4,argreqla5
argreqla4	dc.w	407,0,0,0,0,55
argreqla5	dc.w	0,0
	dc.b	2,1,1,3
	dc.l	argreqla6,0
argreqla6	dc.w	407,1,407,55,1,55
argreqbo3	dc.w	0,0
	dc.b	1,2,1,3
	dc.l	argreqla9,argreqla10
argreqla9	dc.w	39,0,0,0,0,11
argreqla10	dc.w	0,0
	dc.b	2,1,1,3
	dc.l	argreqla11,0
argreqla11	dc.w	39,1,39,11,1,11
argreqbo4	dc.w	0,0
	dc.b	1,2,1,3
	dc.l	argreqla13,argreqla14
argreqla13	dc.w	71,0,0,0,0,11
argreqla14	dc.w	0,0
	dc.b	2,1,1,3
	dc.l	argreqla15,0
argreqla15	dc.w	71,1,71,11,1,11

argreqin1	dc.b	1,0,1,0
	dc.w	12,6
	dc.l	0
	dc.l	argreqla7,0
argreqla7	dc.b	'CLI Arguement:',0
	even
argreqin2	dc.b	1,0,1,0
	dc.w	4,2
	dc.l	0
	dc.l	argreqla12,0
argreqla12	dc.b	' OK ',0
	even
argreqin3	dc.b	1,0,1,0
	dc.w	4,2
	dc.l	0
	dc.l	argreqla16,0
argreqla16	dc.b	' CANCEL ',0
	even

argreqga1	dc.l	argreqga2	;string gadget
	dc.w	12,22,384,8,0,5,4
	dc.l	0,0,0,0,argreqsg1
	dc.w	1
	dc.l	0
argreqsg1	dc.l	argreqla8,undobuffer
	dc.w	0,128,0
	dc.w	0,0,0,0,0,0,0
	dc.l	0,0
argreqla8	dcb.b	128,0
	even
argreqga2	dc.l	argreqga3	;OK!
	dc.w	8,40,40,12,0,5,1
	dc.l	argreqbo3,0,argreqin2,0,0
	dc.w	2
	dc.l	0
argreqga3	dc.l	0	:CANCEL!
	dc.w	328,40,72,12,0,5,1
	dc.l	argreqbo4,0,argreqin3,0,0
	dc.w	3
	dc.l	0

menu9	;CLI ARGUEMENT
	;
	lea	namebuff(pc),a0
	lea	argreqla8(pc),a1
	moveq	#128/4-1,d0
.loop0	move.l	(a1)+,(a0)+
	dbf	d0,.loop0
	;
	move.l	comdata,a1
	move.l	(a1),a1
	lea	argreq,a0
	jsr	(a1)
	;
	lea	argreqga1,a0
	lea	argreq,a2
	move.l	comdata,a1
	move.l	68(a1),a1
	jsr	(a1)
	;
.loop	move.l	comdata,a1
	move.l	8(a1),a1
	jsr	(a1)
	cmp	#-1,d7
	bne	.loop
	cmp	#1,d6
	beq	.ok
	cmp	#2,d6
	beq	.ok
	cmp	#3,d6
	bne	.loop
	;cancel
	lea	namebuff(pc),a0
	lea	argreqla8(pc),a1
	moveq	#128/4-1,d0
.loop2	move.l	(a0)+,(a1)+
	dbf	d0,.loop2
.ok	rts

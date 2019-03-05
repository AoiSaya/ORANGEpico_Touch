100 '----------------------------
110 ' Drawing sample program
120 ' Copyright (c)2019 AoiSaya
130 '----------------------------
200 dim col(8)
210 '--- parameters -------------
220 kn=4 : gain!=0.1 : dump=0
230 ga=0 : c=7 : sz=0
240 CMD_GETX=&h90 : CMD_GETY=&hD0
250 '----------------------------
260 RESTART@
270 cls
280 gosub MENU@
400 '--- drawing ---
410 uart 1,2,115200
420 gosub INIT_PORT@
430 CHANGE@
440 line 8,0,8,239,&h0000 : line 8,c*16,8,c*16+13,&hFFFF
450 line 8,(sz+9)*16,8,(sz+9)*16+13,&hFFFF
460 LOOP@
470 gosub GET_DATA@,CMD_GETY
480 y=pop()
490 gosub GET_DATA@,CMD_GETX
500 x=pop()
510 if dump then locate 28,0 : print format$("%5d,%5d",x,y);
520 if x>4000 then ga=0 : k=0 : goto LOOP@
530 k=k+1 : if k<kn goto LOOP@
540 '--- draw start
550 if k=kn then xs!=x : ys!=y
560 xd!=x-xs! : yd!=y-ys!
570 xs!=xs!+xd!*gain! : ys!=ys!+yd!*gain!
580 yb=ya : x=xs!*0.091-40 : ya=257-ys!*0.0667
590 if x>9+sz or ya<0 or ya>239 goto SKIP@
600 if ga=1 or x<0 goto LOOP@
610 if ya<16	goto RESTART@
620 if ya<16*9	then c=ya/16	: goto CHANGE@
630 if ya>=16*9 then sz=ya/16-9 : goto CHANGE@
640 goto LOOP@
650 SKIP@
660 gb=ga : ga=1 : xb = xa : xa=x
670 if gb=0 goto LOOP@
680 gosub PROT@,xa,ya,xb,yb,sz,col(c)
690 goto LOOP@
700 '---
710 INIT_PORT@
720 T_IRQ=1 : T_DO=2 : T_DIN=3 : T_CS=4 : T_CLK=100
730 ioctrl T_IRQ,2 : ioctrl T_DO,2 : ioctrl T_DIN,0 : ioctrl T_CS,0 : ioctrl T_CLK,0
740 out T_CLK,0 : out T_DIN,0 : out T_CS,1
750 return
800 '---
810 GET_DATA@
820 cmd=pop() : dat=0
830 out T_CLK,0
840 out T_CS,0
850 for i=7 to 0 step -1
860   out T_DIN,(cmd>>i)&1
870   out T_CLK,1 : out T_CLK,0
880 next
890 out T_DIN,0
900 out T_CLK,1 : out T_CLK,0
910 for i=1 to 12
920   dat=dat*2+in(T_DO)
930   out T_CLK,1 : out T_CLK,0
940 next
950 out T_CS,1
960 return dat
1000 '---
1010 MENU@
1020 gprint 0,0,"\x81\xA6",&hFFFF
1030 gprint 0,7,"\x81\xA6",&hFFFF
1040 for i=1 to 8
1050   col(i)=(i&2)*31*1024+(i&4)*63*8+(i&1)*31
1060   gprint 0,i*16+j,  "\x81\xA1",col(i)
1070   gprint 0,i*16+j+7,"\x81\xA1",col(i)
1080 next
1090 for i=0 to 5
1100   y = 16*(i+9)
1110   gprint 0,y,	"\x81\xA1",&h8410
1120   gprint 0,y+7,"\x81\xA1",&h8410
1130   gosub PROT@,3,y+7,3,y+7,i,&hFFFF
1140 next
1150 return
1200 '---
1210 PROT@
1220 pc=pop() : ps=pop() : py2=pop() : px2=pop() : py1=pop() : px1=pop()
1230 if ps=0 then line px1,py1,px2,py2,pc : return
1240 circle px1,py1,ps,pc
1250 ps=ps-1
1260 for i=-ps to ps
1270   line px1+i,py1-ps,px1+i,py1+ps,pc
1280 next
1290 return
